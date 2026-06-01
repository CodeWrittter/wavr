import 'package:dio/dio.dart';
import '../models/decoded_track.dart';
import '../../../data/models/track.dart';
import '../../../core/constants/app_credentials.dart';

/// Jamendo public API — free, CC-licensed music.
/// Free API key available at developer.jamendo.com
class JamendoDecoder {
  final Dio _dio;


  static const _clientId = AppCredentials.jamendoClientId;
  static const _base = AppCredentials.jamendoBase;

  JamendoDecoder({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<DecodedTrack>> decode(String url) async {
    final type = _urlType(url);
    final id   = _extractId(url);

    if (type == 'album')    return _fetchAlbum(id);
    if (type == 'playlist') return _fetchPlaylist(id);
    if (type == 'track')    return [await _fetchTrack(id)];

    throw Exception('Unsupported Jamendo URL: $url');
  }

  Future<List<DecodedTrack>> _fetchAlbum(String id) async {
    final res = await _dio.get('$_base/albums/tracks', queryParameters: {
      'client_id': _clientId,
      'id': id,
      'format': 'json',
      'limit': 200,
    });
    final albums = res.data['results'] as List;
    if (albums.isEmpty) return [];
    final tracks = albums.first['tracks'] as List;
    return tracks.map((t) => _mapTrack(t as Map<String, dynamic>,
        albumName: albums.first['name'] as String?,
        artworkUrl: albums.first['image'] as String?)).toList();
  }

  Future<List<DecodedTrack>> _fetchPlaylist(String id) async {
    final res = await _dio.get('$_base/playlists/tracks', queryParameters: {
      'client_id': _clientId,
      'id': id,
      'format': 'json',
      'limit': 200,
    });
    final playlists = res.data['results'] as List;
    if (playlists.isEmpty) return [];
    final tracks = playlists.first['tracks'] as List;
    return tracks.map((t) => _mapTrack(t as Map<String, dynamic>)).toList();
  }

  Future<DecodedTrack> _fetchTrack(String id) async {
    final res = await _dio.get('$_base/tracks', queryParameters: {
      'client_id': _clientId,
      'id': id,
      'format': 'json',
    });
    final results = res.data['results'] as List;
    return _mapTrack(results.first as Map<String, dynamic>);
  }

  DecodedTrack _mapTrack(
    Map<String, dynamic> t, {
    String? albumName,
    String? artworkUrl,
  }) =>
      DecodedTrack(
        title:      t['name'] as String? ?? 'Unknown',
        artist:     t['artist_name'] as String? ?? 'Unknown',
        album:      albumName ?? t['album_name'] as String?,
        durationMs: ((t['duration'] as num?)?.toInt() ?? 0) * 1000,
        artworkUrl: artworkUrl ?? t['album_image'] as String?,
        source:     TrackSource.jamendo,
        sourceId:   t['id'] as String?,
      );

  String _urlType(String url) {
    if (url.contains('/album/'))    return 'album';
    if (url.contains('/playlist/')) return 'playlist';
    return 'track';
  }

  String _extractId(String url) {
    final uri = Uri.parse(url);
    return uri.pathSegments.last.split('?').first;
  }
}
