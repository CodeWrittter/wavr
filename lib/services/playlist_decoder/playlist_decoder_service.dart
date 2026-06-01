import '../../data/models/track.dart';
import 'decoders/spotify_decoder.dart';
import 'decoders/apple_music_decoder.dart';
import 'decoders/deezer_decoder.dart';
import 'decoders/ytmusic_decoder.dart';
import 'decoders/soundcloud_decoder.dart';
import 'decoders/audius_decoder.dart';
import 'decoders/jamendo_decoder.dart';
import 'decoders/wavr_share_decoder.dart';
import 'models/decoded_track.dart';

/// Detects the platform from a raw URL and delegates
/// to the correct decoder. Returns a normalized list
/// of [DecodedTrack] — metadata only, no audio URLs.
class PlaylistDecoderService {
  final SpotifyDecoder     _spotify;
  final AppleMusicDecoder  _apple;
  final DeezerDecoder      _deezer;
  final YtMusicDecoder     _ytMusic;
  final SoundCloudDecoder  _soundcloud;
  final AudiusDecoder      _audius;
  final JamendoDecoder     _jamendo;
  final WavrShareDecoder   _wavrShare;

  PlaylistDecoderService({
    SpotifyDecoder?    spotify,
    AppleMusicDecoder? apple,
    DeezerDecoder?     deezer,
    YtMusicDecoder?    ytMusic,
    SoundCloudDecoder? soundcloud,
    AudiusDecoder?     audius,
    JamendoDecoder?    jamendo,
    WavrShareDecoder?  wavrShare,
  })  : _spotify    = spotify    ?? SpotifyDecoder(),
        _apple      = apple      ?? AppleMusicDecoder(),
        _deezer     = deezer     ?? DeezerDecoder(),
        _ytMusic    = ytMusic    ?? YtMusicDecoder(),
        _soundcloud = soundcloud ?? SoundCloudDecoder(),
        _audius     = audius     ?? AudiusDecoder(),
        _jamendo    = jamendo    ?? JamendoDecoder(),
        _wavrShare  = wavrShare  ?? WavrShareDecoder();

  /// Entry point — pass any supported URL.
  Future<List<DecodedTrack>> decode(String rawUrl) async {
    final url = rawUrl.trim();
    final platform = _detect(url);

    switch (platform) {
      case TrackSource.spotify:
        return _spotify.decode(url);
      case TrackSource.appleMusic:
        return _apple.decode(url);
      case TrackSource.deezer:
        return _deezer.decode(url);
      case TrackSource.ytMusic:
        return _ytMusic.decode(url);
      case TrackSource.soundcloud:
        return _soundcloud.decode(url);
      case TrackSource.audius:
        return _audius.decode(url);
      case TrackSource.jamendo:
        return _jamendo.decode(url);
      case TrackSource.wavrShare:
        return _wavrShare.decode(url);
      default:
        throw UnsupportedPlatformException(url);
    }
  }

  TrackSource _detect(String url) {
    if (url.contains('open.spotify.com'))           return TrackSource.spotify;
    if (url.contains('music.apple.com'))            return TrackSource.appleMusic;
    if (url.contains('deezer.com'))                 return TrackSource.deezer;
    if (url.contains('music.youtube.com'))          return TrackSource.ytMusic;
    if (url.contains('youtube.com') ||
        url.contains('youtu.be'))                   return TrackSource.ytMusic;
    if (url.contains('soundcloud.com'))             return TrackSource.soundcloud;
    if (url.contains('audius.co'))                  return TrackSource.audius;
    if (url.contains('jamendo.com'))                return TrackSource.jamendo;
    if (url.contains('wavr.app') ||
        url.startsWith('wavr://'))                  return TrackSource.wavrShare;
    return TrackSource.local;
  }
}

class UnsupportedPlatformException implements Exception {
  final String url;
  UnsupportedPlatformException(this.url);

  @override
  String toString() => 'UnsupportedPlatformException: no decoder found for $url';
}
