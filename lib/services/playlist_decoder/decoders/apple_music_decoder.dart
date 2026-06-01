import 'package:dio/dio.dart';
import '../models/decoded_track.dart';
import '../../../data/models/track.dart';
import '../../../core/constants/app_constants.dart';

/// Uses the iTunes Search API — completely free, no auth.
/// Apple Music share links contain a playlist/album ID
/// that maps directly to the iTunes catalog.
class AppleMusicDecoder {
  final Dio _dio;
  AppleMusicDecoder({Dio? dio}) : _dio = dio ?? Dio();

  static const _base = AppConstants.itunesApiBase;

  Future<List<DecodedTrack>> decode(String url) async {
    // Apple Music URL format:
    // https://music.apple.com/us/album/album-name/123456789
    // https://music.apple.com/us/playlist/name/pl.abc123
    final type = _urlType(url);
    final id   = _extractId(url);

    if (type == 'album')    return _fetchAlbum(id);
    if (type == 'playlist') return _fetchPlaylist(id, url);

    throw Exception('Unsupported Apple Music URL: $url');
  }

  Future<List<DecodedTrack>> _fetchAlbum(String id) async {
    final res = await _dio.get(
      '$_base/lookup',
      queryParameters: {
        'id': id,
        'entity': 'song',
        'limit': 200,
      },
    );
    final results = res.data['results'] as List;
    // first result is the collection itself, skip it
    return results
        .skip(1)
        .where((r) => r['wrapperType'] == 'track')
        .map((r) => _mapTrack(r))
        .toList();
  }

  /// Apple Music playlists are not fully accessible via
  /// iTunes API without auth — we do a best-effort lookup.
  Future<List<DecodedTrack>> _fetchPlaylist(String id, String url) async {
    // Attempt iTunes lookup by playlist id
    try {
      final res = await _dio.get(
        '$_base/lookup',
        queryParameters: {'id': id, 'entity': 'song'},
      );
      final results = res.data['results'] as List;
      if (results.length > 1) {
        return results
            .skip(1)
            .where((r) => r['wrapperType'] == 'track')
            .map((r) => _mapTrack(r))
            .toList();
      }
    } catch (_) {}
    // fallback — return empty, let UI inform user
    return [];
  }

  DecodedTrack _mapTrack(Map<String, dynamic> t) {
    final artworkUrl = (t['artworkUrl100'] as String?)
        ?.replaceAll('100x100', '600x600');

    return DecodedTrack(
      title:      t['trackName'] as String? ?? 'Unknown',
      artist:     t['artistName'] as String? ?? 'Unknown',
      album:      t['collectionName'] as String?,
      year:       _parseYear(t['releaseDate'] as String?),
      durationMs: t['trackTimeMillis'] as int?,
      trackNumber: t['trackNumber'] as int?,
      artworkUrl: artworkUrl,
      source:     TrackSource.appleMusic,
      sourceId:   t['trackId']?.toString(),
    );
  }

  int? _parseYear(String? date) {
    if (date == null) return null;
    return int.tryParse(date.split('-').first);
  }

  String _urlType(String url) {
    if (url.contains('/playlist/')) return 'playlist';
    if (url.contains('/album/'))    return 'album';
    return 'unknown';
  }

  String _extractId(String url) {
    final uri = Uri.parse(url);
    // last path segment is always the numeric ID
    return uri.pathSegments.last.split('?').first;
  }
}
