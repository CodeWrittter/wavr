import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/track.dart';

part 'decoded_track.freezed.dart';
part 'decoded_track.g.dart';

/// Raw track metadata extracted from a platform link.
/// No audio URL yet — that comes from TrackResolverService.
@freezed
abstract class DecodedTrack with _$DecodedTrack {
  const factory DecodedTrack({
    required String  title,
    required String  artist,
    String?          album,
    String?          genre,
    int?             year,
    int?             durationMs,
    int?             trackNumber,
    String?          artworkUrl,
    required TrackSource source,
    String?          sourceId,   // ID on the original platform
  }) = _DecodedTrack;

  factory DecodedTrack.fromJson(Map<String, dynamic> json) =>
      _$DecodedTrackFromJson(json);
}
