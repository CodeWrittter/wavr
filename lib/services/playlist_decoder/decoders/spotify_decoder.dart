import 'package:dio/dio.dart';
import '../models/decoded_track.dart';
import '../../../data/models/track.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/constants/app_constants.dart';

/// Uses the Spotify public metadata API.
/// No auth needed for public playlists/albums —
/// we use the open token endpoint with client credentials
/// embedded (read-only, public data only).
class SpotifyDecoder {
  final Dio _dio;

  static const _clientId     = AppCredentials.spotifyClientId;
  static const _clientSecret = AppCredentials.spotifyClientSecret;

  String? _accessToken;
  DateTime? _tokenExpiry;

  SpotifyDecoder({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<DecodedTrack>> decode(String url) async {
    await _ensureToken();
    final type = _urlType(url);
    final id   = _extractId(url);

    if (type == 'playlist') return _fetchPlaylist(id);
    if (type == 'album')    return _fetchAlbum(id);
    if (type == 'track')    return [await _fetchTrack(id)];

    throw Exception('Unsupported Spotify URL: $url');
  }

  // ── Token ─────────────────────────────────────────────────────────────────

  Future<void> _ensureToken() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) { return; }

    final res = await _dio.post(
      AppConstants.spotifyAuthUrl,
      data: 'grant_type=client_credentials'
          '&client_id=$_clientId'
          '&client_secret=$_clientSecret',
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
      ),
    );

    _accessToken = res.data['access_token'] as String;
    final expiresIn = res.data['expires_in'] as int;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 30));
  }

  Options get _authOptions => Options(headers: {
        'Authorization': 'Bearer $_accessToken',
      });

  // ── Fetchers ──────────────────────────────────────────────────────────────

  Future<List<DecodedTrack>> _fetchPlaylist(String id) async {
    final tracks = <DecodedTrack>[];
    String? nextUrl = AppConstants.spotifyApiBase + '/playlists/$id/tracks?limit=' + AppConstants.spotifyPageSize.toString();

    while (nextUrl != null) {
      final res = await _dio.get(nextUrl, options: _authOptions);
      final items = res.data['items'] as List;

      for (final item in items) {
        final t = item['track'];
        if (t == null || t['id'] == null) continue;
        tracks.add(_mapTrack(t));
      }
      nextUrl = res.data['next'] as String?;
    }
    return tracks;
  }

  Future<List<DecodedTrack>> _fetchAlbum(String id) async {
    final tracks = <DecodedTrack>[];

    // fetch album meta first (for artwork + year)
    final albumRes = await _dio.get(
      AppConstants.spotifyApiBase + '/albums/$id',
      options: _authOptions,
    );
    final albumData = albumRes.data;
    final artworkUrl = (albumData['images'] as List?)?.isNotEmpty == true
        ? albumData['images'][0]['url'] as String?
        : null;
    final year = int.tryParse(
      (albumData['release_date'] as String? ?? '').split('-').first,
    );
    final albumName = albumData['name'] as String?;

    String? nextUrl = AppConstants.spotifyApiBase + '/albums/$id/tracks?limit=50';

    while (nextUrl != null) {
      final res = await _dio.get(nextUrl, options: _authOptions);
      final items = res.data['items'] as List;

      for (final t in items) {
        tracks.add(_mapTrack(t,
            albumOverride: albumName,
            artworkOverride: artworkUrl,
            yearOverride: year));
      }
      nextUrl = res.data['next'] as String?;
    }
    return tracks;
  }

  Future<DecodedTrack> _fetchTrack(String id) async {
    final res = await _dio.get(
      AppConstants.spotifyApiBase + '/tracks/$id',
      options: _authOptions,
    );
    return _mapTrack(res.data);
  }

  // ── Mapper ────────────────────────────────────────────────────────────────

  DecodedTrack _mapTrack(
    Map<String, dynamic> t, {
    String? albumOverride,
    String? artworkOverride,
    int?    yearOverride,
  }) {
    final artists = (t['artists'] as List?)
            ?.map((a) => a['name'] as String)
            .join(', ') ??
        'Unknown Artist';

    final albumData = t['album'] as Map<String, dynamic>?;
    final artworkUrl = artworkOverride ??
      ((albumData?['images'] as List?)?.isNotEmpty == true
        ? albumData!['images'][0]['url'] as String?
        : null);
    final year = yearOverride ??
        int.tryParse(
          (albumData?['release_date'] as String? ?? '').split('-').first,
        );

    return DecodedTrack(
      title:       t['name'] as String? ?? 'Unknown',
      artist:      artists,
      album:       albumOverride ?? albumData?['name'] as String?,
      year:        year,
      durationMs:  t['duration_ms'] as int?,
      trackNumber: t['track_number'] as int?,
      artworkUrl:  artworkUrl,
      source:      TrackSource.spotify,
      sourceId:    t['id'] as String?,
    );
  }

  // ── URL helpers ───────────────────────────────────────────────────────────

  String _urlType(String url) {
    if (url.contains('/playlist/')) return 'playlist';
    if (url.contains('/album/'))    return 'album';
    if (url.contains('/track/'))    return 'track';
    return 'unknown';
  }

  String _extractId(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    // e.g. ['playlist', '37i9dQZF1DXcBWIGoYBM5M']
    return segments.last.split('?').first;
  }
}
