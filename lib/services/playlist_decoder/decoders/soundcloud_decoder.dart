import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import '../models/decoded_track.dart';
import '../../../data/models/track.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/constants/app_constants.dart';

/// SoundCloud public resolve API.
/// Uses the public client_id extracted from the web app.
/// Note: this client_id rotates occasionally and may need
/// to be refreshed by fetching any SC page and extracting
/// the JS bundle that contains `client_id=`.
class SoundCloudDecoder {
  final Dio _dio;

  static const _clientId = AppCredentials.soundCloudClientId;

  SoundCloudDecoder({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<DecodedTrack>> decode(String url) async {
    final resolved = await _resolve(url);
    final kind = resolved['kind'] as String?;

    if (kind == 'playlist') return _mapPlaylist(resolved);
    if (kind == 'track')    return [_mapTrack(resolved)];

    throw Exception('Unsupported SoundCloud resource: $kind');
  }

  Future<Map<String, dynamic>> _resolve(String url) async {
    final res = await _dio.get(
      AppConstants.soundcloudApiBase + '/resolve',
      queryParameters: {'url': url, 'client_id': _clientId},
    );
    return res.data as Map<String, dynamic>;
  }

  List<DecodedTrack> _mapPlaylist(Map<String, dynamic> data) {
    final tracks = data['tracks'] as List? ?? [];
    return tracks.map((t) => _mapTrack(t as Map<String, dynamic>)).toList();
  }

  DecodedTrack _mapTrack(Map<String, dynamic> t) {
    final user = t['user'] as Map<String, dynamic>?;
    return DecodedTrack(
      title:      t['title'] as String? ?? 'Unknown',
      artist:     user?['username'] as String? ?? 'Unknown',
      durationMs: t['duration'] as int?,
      artworkUrl: (t['artwork_url'] as String?)
          ?.replaceAll('large', 't500x500'),
      source:   TrackSource.soundcloud,
      sourceId: t['id']?.toString(),
    );
  }
}
