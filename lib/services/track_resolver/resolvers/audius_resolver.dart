import 'package:dio/dio.dart';
import '../../../core/utils/fuzzy_matcher.dart';
import '../../../data/models/track.dart';
import '../../playlist_decoder/models/decoded_track.dart';
import 'youtube_resolver.dart' show ResolverResult;
import '../../../core/constants/app_constants.dart';

class AudiusResolver {
  final Dio _dio;

  static const _base     = AppConstants.audiusApiBase;
  static const _minScore = 0.55;

  AudiusResolver({Dio? dio}) : _dio = dio ?? Dio();

  Future<ResolverResult?> resolve(DecodedTrack track) async {
    try {
      final res = await _dio.get(
        '$_base/tracks/search',
        queryParameters: {
          'query': '${track.artist} ${track.title}',
          'limit': 10,
        },
      );

      final items = res.data['data'] as List? ?? [];
      if (items.isEmpty) return null;

      double bestScore = 0;
      Map<String, dynamic>? bestItem;

      for (final item in items) {
        final t = item as Map<String, dynamic>;
        final score = FuzzyMatcher.score(
          targetTitle:         track.title,
          targetArtist:        track.artist,
          targetDurationMs:    track.durationMs,
          candidateTitle:      t['title'] as String? ?? '',
          candidateArtist:
              (t['user'] as Map?)?['name'] as String? ?? '',
          candidateDurationMs:
              ((t['duration'] as num?)?.toInt() ?? 0) * 1000,
        );
        if (score > bestScore) {
          bestScore = score;
          bestItem  = t;
        }
      }

      if (bestScore < _minScore || bestItem == null) return null;

      final trackId  = bestItem['id'] as String;
      final streamUrl =
          '$_base/tracks/$trackId/stream';

      return ResolverResult(
        streamUrl:    streamUrl,
        score:        bestScore,
        resolvedFrom: TrackSource.audius,
        resolvedTitle:  bestItem['title'] as String?,
        resolvedArtist:
            (bestItem['user'] as Map?)?['name'] as String?,
        resolvedDurationMs:
            ((bestItem['duration'] as num?)?.toInt() ?? 0) * 1000,
      );
    } catch (_) {
      return null;
    }
  }
}
