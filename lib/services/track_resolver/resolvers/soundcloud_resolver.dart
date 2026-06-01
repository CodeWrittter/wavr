import 'package:dio/dio.dart';
import '../../../core/utils/fuzzy_matcher.dart';
import '../../../data/models/track.dart';
import '../../playlist_decoder/models/decoded_track.dart';
import 'youtube_resolver.dart' show ResolverResult;
import '../../../core/constants/app_credentials.dart';
import '../../../core/constants/app_constants.dart';

class SoundCloudResolver {
  final Dio _dio;


  static const _clientId = AppCredentials.soundCloudClientId;
  static const _base      = AppConstants.soundcloudApiBase;
  static const _minScore  = 0.55;

  SoundCloudResolver({Dio? dio}) : _dio = dio ?? Dio();

  Future<ResolverResult?> resolve(DecodedTrack track) async {
    try {
      final query = '${track.artist} ${track.title}';
      final res   = await _dio.get(
        '$_base/search/tracks',
        queryParameters: {
          'q':         query,
          'client_id': _clientId,
          'limit':     10,
        },
      );

      final items = res.data['collection'] as List? ?? [];
      if (items.isEmpty) return null;

      double bestScore = 0;
      Map<String, dynamic>? bestItem;

      for (final item in items) {
        final t = item as Map<String, dynamic>;
        final score = FuzzyMatcher.score(
          targetTitle:        track.title,
          targetArtist:       track.artist,
          targetDurationMs:   track.durationMs,
          candidateTitle:     t['title'] as String? ?? '',
          candidateArtist:    (t['user'] as Map?)?['username'] as String? ?? '',
          candidateDurationMs: t['duration'] as int?,
        );
        if (score > bestScore) {
          bestScore = score;
          bestItem  = t;
        }
      }

      if (bestScore < _minScore || bestItem == null) return null;

      // resolve stream URL
      final streamUrl = await _resolveStream(bestItem['id'].toString());
      if (streamUrl == null) return null;

      return ResolverResult(
        streamUrl:    streamUrl,
        score:        bestScore,
        resolvedFrom: TrackSource.soundcloud,
        resolvedTitle:  bestItem['title'] as String?,
        resolvedArtist: (bestItem['user'] as Map?)?['username'] as String?,
        resolvedDurationMs: bestItem['duration'] as int?,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> _resolveStream(String trackId) async {
    try {
      final res = await _dio.get(
        '$_base/tracks/$trackId/streams',
        queryParameters: {'client_id': _clientId},
      );
      // prefer progressive MP3 stream
      return res.data['http_mp3_128_url'] as String? ??
             res.data['preview_mp3_128_url'] as String?;
    } catch (_) {
      return null;
    }
  }
}
