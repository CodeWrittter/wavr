import 'dart:convert';
import '../models/decoded_track.dart';
import '../../../data/models/track.dart';

/// Handles Wavr internal share links.
/// Format: wavr://share?data=base64(json)
/// or:     https://wavr.app/share?data=base64(json)
///
/// The shared JSON payload contains the full playlist
/// metadata so no network call is needed.
class WavrShareDecoder {
  Future<List<DecodedTrack>> decode(String url) async {
    final uri  = Uri.parse(url);
    final data = uri.queryParameters['data'];

    if (data == null) throw Exception('Missing data param in Wavr share link');

    final json = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(data))),
    ) as Map<String, dynamic>;

    final tracks = json['tracks'] as List;
    return tracks.map((t) => _mapTrack(t as Map<String, dynamic>)).toList();
  }

  DecodedTrack _mapTrack(Map<String, dynamic> t) => DecodedTrack(
        title:      t['title'] as String? ?? 'Unknown',
        artist:     t['artist'] as String? ?? 'Unknown',
        album:      t['album'] as String?,
        year:       t['year'] as int?,
        durationMs: t['duration_ms'] as int?,
        artworkUrl: t['artwork_url'] as String?,
        source:     TrackSource.wavrShare,
        sourceId:   t['source_id'] as String?,
      );
}
