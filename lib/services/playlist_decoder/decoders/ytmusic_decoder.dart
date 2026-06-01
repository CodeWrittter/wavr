import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/decoded_track.dart';
import '../../../data/models/track.dart';

/// Handles YouTube and YouTube Music links.
/// Uses youtube_explode_dart — no API key needed.
class YtMusicDecoder {
  final YoutubeExplode _yt;
  YtMusicDecoder({YoutubeExplode? yt}) : _yt = yt ?? YoutubeExplode();

  Future<List<DecodedTrack>> decode(String url) async {
    if (_isPlaylist(url)) return _fetchPlaylist(url);
    return [await _fetchSingle(url)];
  }

  Future<List<DecodedTrack>> _fetchPlaylist(String url) async {
    final playlist = await _yt.playlists.get(url);
    final tracks   = <DecodedTrack>[];

    await for (final video in _yt.playlists.getVideos(playlist.id)) {
      tracks.add(_mapVideo(video));
    }
    return tracks;
  }

  Future<DecodedTrack> _fetchSingle(String url) async {
    final video = await _yt.videos.get(url);
    return _mapVideo(video);
  }

  DecodedTrack _mapVideo(Video v) {
    // YT Music titles are often "Artist - Title"
    // we attempt to split them
    final parts   = v.title.split(' - ');
    final title   = parts.length >= 2 ? parts.sublist(1).join(' - ') : v.title;
    final artist  = parts.length >= 2 ? parts.first : v.author;

    return DecodedTrack(
      title:      title.trim(),
      artist:     artist.trim(),
      durationMs: v.duration?.inMilliseconds,
      artworkUrl: v.thumbnails.highResUrl,
      source:     TrackSource.ytMusic,
      sourceId:   v.id.value,
    );
  }

  bool _isPlaylist(String url) =>
      url.contains('list=') || url.contains('/playlist');

  void dispose() => _yt.close();
}
