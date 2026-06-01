import 'package:dio/dio.dart';
import '../models/decoded_track.dart';
import '../../../data/models/track.dart';
import '../../../core/constants/app_constants.dart';

/// Deezer public API — no auth required.
class DeezerDecoder {
  final Dio _dio;
  DeezerDecoder({Dio? dio}) : _dio = dio ?? Dio();

  static const _base = AppConstants.deezerApiBase;

  Future<List<DecodedTrack>> decode(String url) async {
    final type = _urlType(url);
    final id   = _extractId(url);

    if (type == 'playlist') return _fetchPlaylist(id);
    if (type == 'album')    return _fetchAlbum(id);
    if (type == 'track')    return [await _fetchTrack(id)];

    throw Exception('Unsupported Deezer URL: $url');
  }

  Future<List<DecodedTrack>> _fetchPlaylist(String id) async {
    final tracks = <DecodedTrack>[];
    String? nextUrl = '$_base/playlist/$id/tracks?limit=100';

    while (nextUrl != null) {
      final res = await _dio.get(nextUrl);
      final items = res.data['data'] as List;
      for (final t in items) { tracks.add(_mapTrack(t)); }
      nextUrl = res.data['next'] as String?;
    }
    return tracks;
  }

  Future<List<DecodedTrack>> _fetchAlbum(String id) async {
    final tracks = <DecodedTrack>[];

    final albumRes = await _dio.get('$_base/album/$id');
    final albumData = albumRes.data;
    final artworkUrl = albumData['cover_xl'] as String? ??
        albumData['cover_big'] as String?;
    final albumName  = albumData['title'] as String?;
    final year       = albumData['release_date'] != null
        ? int.tryParse(
            (albumData['release_date'] as String).split('-').first)
        : null;

    final tracksRes = await _dio.get('$_base/album/$id/tracks?limit=100');
    for (final t in tracksRes.data['data'] as List) {
      tracks.add(_mapTrack(t,
          albumOverride: albumName,
          artworkOverride: artworkUrl,
          yearOverride: year));
    }
    return tracks;
  }

  Future<DecodedTrack> _fetchTrack(String id) async {
    final res = await _dio.get('$_base/track/$id');
    return _mapTrack(res.data);
  }

  DecodedTrack _mapTrack(
    Map<String, dynamic> t, {
    String? albumOverride,
    String? artworkOverride,
    int?    yearOverride,
  }) {
    final albumData = t['album'] as Map<String, dynamic>?;
    return DecodedTrack(
      title:      t['title'] as String? ?? 'Unknown',
      artist:     (t['artist'] as Map?)?['name'] as String? ?? 'Unknown',
      album:      albumOverride ?? albumData?['title'] as String?,
      year:       yearOverride,
      durationMs: ((t['duration'] as int?) ?? 0) * 1000,
      artworkUrl: artworkOverride ??
          albumData?['cover_xl'] as String? ??
          albumData?['cover_big'] as String?,
      source:   TrackSource.deezer,
      sourceId: t['id']?.toString(),
    );
  }

  String _urlType(String url) {
    if (url.contains('/playlist/')) return 'playlist';
    if (url.contains('/album/'))    return 'album';
    if (url.contains('/track/'))    return 'track';
    return 'unknown';
  }

  String _extractId(String url) {
    final uri = Uri.parse(url);
    return uri.pathSegments.last.split('?').first;
  }
}
