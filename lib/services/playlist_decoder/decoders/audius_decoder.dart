import 'package:dio/dio.dart';
import '../models/decoded_track.dart';
import '../../../data/models/track.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/constants/app_constants.dart';

/// Audius public API — completely free, no auth.
class AudiusDecoder {
  final Dio _dio;
  AudiusDecoder({Dio? dio}) : _dio = dio ?? Dio();

  // Audius uses a decentralized node network —
  // this is their recommended discovery node
  static const _base = AppConstants.audiusApiBase;

  Future<List<DecodedTrack>> decode(String url) async {
    final type = _urlType(url);
    final slug = _extractSlug(url);

    if (type == 'playlist') return _fetchPlaylist(slug);
    if (type == 'track')    return [await _fetchTrack(slug)];

    throw Exception('Unsupported Audius URL: $url');
  }

  Future<List<DecodedTrack>> _fetchPlaylist(String slug) async {
    final res = await _dio.get('$_base/playlists/$slug/tracks');
    final data = res.data['data'] as List? ?? [];
    return data.map((t) => _mapTrack(t as Map<String, dynamic>)).toList();
  }

  Future<DecodedTrack> _fetchTrack(String slug) async {
    final res = await _dio.get('$_base/tracks/$slug');
    return _mapTrack(res.data['data'] as Map<String, dynamic>);
  }

  DecodedTrack _mapTrack(Map<String, dynamic> t) {
    final artwork = t['artwork'] as Map<String, dynamic>?;
    final user    = t['user'] as Map<String, dynamic>?;
    return DecodedTrack(
      title:      t['title'] as String? ?? 'Unknown',
      artist:     user?['name'] as String? ?? 'Unknown',
      durationMs: ((t['duration'] as num?)?.toInt() ?? 0) * 1000,
      artworkUrl: artwork?['1000x1000'] as String? ??
                  artwork?['480x480'] as String?,
      source:   TrackSource.audius,
      sourceId: t['id'] as String?,
    );
  }

  String _urlType(String url) {
    if (url.contains('/playlist/')) return 'playlist';
    return 'track';
  }

  String _extractSlug(String url) {
    final uri = Uri.parse(url);
    return uri.pathSegments.last;
  }
}
