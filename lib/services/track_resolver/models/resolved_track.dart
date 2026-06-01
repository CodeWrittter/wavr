import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/track.dart';

part 'resolved_track.freezed.dart';
part 'resolved_track.g.dart';

/// Result returned by TrackResolverService.
/// Contains the best matched stream URL + confidence score.
@freezed
abstract class ResolvedTrack with _$ResolvedTrack {
  const factory ResolvedTrack({
    required String      trackId,       // local DB UUID
    required String      resolvedUrl,   // best audio stream URL
    required TrackSource resolvedFrom,  // which platform provided the URL
    required double      score,         // 0.0 – 1.0 fuzzy match confidence
    String?              resolvedTitle, // title as found on the source
    String?              resolvedArtist,
    int?                 resolvedDurationMs,
  }) = _ResolvedTrack;

  factory ResolvedTrack.fromJson(Map<String, dynamic> json) =>
      _$ResolvedTrackFromJson(json);
}
