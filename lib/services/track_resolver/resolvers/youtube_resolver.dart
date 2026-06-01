import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../../core/utils/fuzzy_matcher.dart';
import '../../../data/models/track.dart';
import '../../playlist_decoder/models/decoded_track.dart';
import '../../../core/constants/app_constants.dart';

class _Candidate {
  final String url;
  final double score;
  final String title;
  final String artist;
  final int?   durationMs;
  const _Candidate({
    required this.url,
    required this.score,
    required this.title,
    required this.artist,
    this.durationMs,
  });
}

/// Searches YouTube for the best matching audio stream URL.
/// Prefers audio-only streams (WebM/Opus or M4A) for smaller
/// file sizes and faster downloads.
class YoutubeResolver {
  final YoutubeExplode _yt;
  YoutubeResolver({YoutubeExplode? yt}) : _yt = yt ?? YoutubeExplode();

  /// Minimum score to accept a result — below this we skip YouTube
  /// and let the next resolver try.
  static const _minScore = 0.55;

  Future<ResolverResult?> resolve(DecodedTrack track) async {
    try {
      final queries = _buildQueries(track);
      final candidates = <_Candidate>[];

      for (final query in queries) {
        final results = await _yt.search.search(query);
        for (final video in results.take(5)) {
          final score = FuzzyMatcher.score(
            targetTitle:        track.title,
            targetArtist:       track.artist,
            targetDurationMs:   track.durationMs,
            candidateTitle:     video.title,
            candidateArtist:    video.author,
            candidateDurationMs: video.duration?.inMilliseconds,
          );
          if (score >= _minScore) {
            candidates.add(_Candidate(
              url:        AppConstants.youtubeBase + '/watch?v=${video.id.value}',
              score:      score,
              title:      video.title,
              artist:     video.author,
              durationMs: video.duration?.inMilliseconds,
            ));
          }
        }
        // stop searching if we already have a high-confidence result
        if (candidates.any((c) => c.score >= 0.88)) break;
      }

      if (candidates.isEmpty) return null;
      candidates.sort((a, b) => b.score.compareTo(a.score));
      final best = candidates.first;

      // resolve actual audio stream URL
      final manifest = await _yt.videos.streamsClient
          .getManifest(best.url);

      // prefer audio-only streams
      final audioStreams = manifest.audioOnly.sortByBitrate();
      if (audioStreams.isEmpty) return null;

      // pick highest quality audio-only stream
      final stream = audioStreams.last;

      return ResolverResult(
        streamUrl:    stream.url.toString(),
        score:        best.score,
        resolvedFrom: TrackSource.ytMusic,
        resolvedTitle:  best.title,
        resolvedArtist: best.artist,
        resolvedDurationMs: best.durationMs,
      );
    } catch (_) {
      return null;
    }
  }

  List<String> _buildQueries(DecodedTrack track) => [
        '${track.artist} ${track.title} official audio',
        '${track.artist} ${track.title} lyrics',
        '${track.artist} ${track.title}',
      ];

  void dispose() => _yt.close();
}

class ResolverResult {
  final String      streamUrl;
  final double      score;
  final TrackSource resolvedFrom;
  final String?     resolvedTitle;
  final String?     resolvedArtist;
  final int?        resolvedDurationMs;

  const ResolverResult({
    required this.streamUrl,
    required this.score,
    required this.resolvedFrom,
    this.resolvedTitle,
    this.resolvedArtist,
    this.resolvedDurationMs,
  });
}
