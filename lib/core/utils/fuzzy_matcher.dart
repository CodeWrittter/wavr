import 'package:string_similarity/string_similarity.dart';

/// Scores how well a candidate (title + artist from a search result)
/// matches the target (what we're looking for).
/// Returns a value between 0.0 and 1.0.
class FuzzyMatcher {
  /// Main entry point.
  /// Weights: title 50%, artist 35%, duration 15%
  static double score({
    required String targetTitle,
    required String targetArtist,
    int?            targetDurationMs,
    required String candidateTitle,
    required String candidateArtist,
    int?            candidateDurationMs,
  }) {
    final titleScore  = _strScore(targetTitle,  candidateTitle);
    final artistScore = _strScore(targetArtist, candidateArtist);
    final durScore    = _durationScore(targetDurationMs, candidateDurationMs);

    return (titleScore  * 0.50) +
           (artistScore * 0.35) +
           (durScore    * 0.15);
  }

  static double _strScore(String a, String b) =>
      StringSimilarity.compareTwoStrings(
        _normalize(a),
        _normalize(b),
      );

  /// Tolerates up to 3 seconds of drift — common with
  /// different versions, intros, outros.
  static double _durationScore(int? target, int? candidate) {
    if (target == null || candidate == null) return 0.5; // neutral
    final diffMs  = (target - candidate).abs();
    if (diffMs <= 3000)  return 1.0;
    if (diffMs <= 8000)  return 0.7;
    if (diffMs <= 15000) return 0.4;
    return 0.0;
  }

  static String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'\(.*?\)'), '')   // remove (feat. ...), (remix), etc.
      .replaceAll(RegExp(r'\[.*?\]'), '')   // remove [Official Video], etc.
      .replaceAll(RegExp(r'[^\w\s]'), ' ') // strip punctuation
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
