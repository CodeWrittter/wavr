import 'package:dio/dio.dart';
import '../../../core/utils/fuzzy_matcher.dart';
import '../../../data/models/track.dart';
import '../../playlist_decoder/models/decoded_track.dart';
import 'youtube_resolver.dart' show ResolverResult;
import '../../../core/constants/app_credentials.dart';

class JamendoResolver {
  final Dio _dio;

  static const _clientId = AppCredentials.jamendoClientId;
  static const _base = AppCredentials.jamendoBase;
  static const _minScore = 0.55;

  JamendoResolver({Dio? dio}) : _dio = dio ?? Dio();

  Future<ResolverResult?> resolve(DecodedTrack track) async {
    try {
      final res = await _dio.get(
        '$_base/tracks',
        queryParameters: {
          'client_id':  _clientId,
          'search':     '${track.artist} ${track.title}',
          'limit':      10,
          'format':     'json',
          'audioformat': 'mp32',  // direct MP3 stream URL
        },
      );

      final items = res.data['results'] as List? ?? [];
      if (items.isEmpty) return null;

      double bestScore = 0;
      Map<String, dynamic>? bestItem;

      for (final item in items) {
        final t = item as Map<String, dynamic>;
        final score = FuzzyMatcher.score(
          targetTitle:         track.title,
          targetArtist:        track.artist,
          targetDurationMs:    track.durationMs,
          candidateTitle:      t['name'] as String? ?? '',
          candidateArtist:     t['artist_name'] as String? ?? '',
          candidateDurationMs:
              ((t['duration'] as num?)?.toInt() ?? 0) * 1000,
        );
        if (score > bestScore) {
          bestScore = score;
          bestItem  = t;
        }
      }

      if (bestScore < _minScore || bestItem == null) return null;

      // Jamendo returns audiodownload — a direct MP3 link
      final streamUrl = bestItem['audiodownload'] as String? ??
                        bestItem['audio'] as String?;
      if (streamUrl == null) return null;

      return ResolverResult(
        streamUrl:    streamUrl,
        score:        bestScore,
        resolvedFrom: TrackSource.jamendo,
        resolvedTitle:  bestItem['name'] as String?,
        resolvedArtist: bestItem['artist_name'] as String?,
        resolvedDurationMs:
            ((bestItem['duration'] as num?)?.toInt() ?? 0) * 1000,
      );
    } catch (_) {
      return null;
    }
  }
}
