import 'package:freezed_annotation/freezed_annotation.dart';
import 'track.dart';

part 'album.freezed.dart';
part 'album.g.dart';

@freezed
abstract class Album with _$Album {
  const factory Album({
    // ── Identity ──────────────────────────────────
    required String id,
    required String title,
    required String artist,

    // ── Metadata ──────────────────────────────────
    String?       artworkUrl,
    String?       artworkLocalPath,
    int?          year,
    String?       genre,
    int?          totalTracks,
    required      TrackSource source,
    String?       sourceAlbumId,

    // ── Tracks ────────────────────────────────────
    @Default([]) List<String> trackIds,

    // ── Download state ────────────────────────────
    @Default(false) bool isFullyDownloaded,
    int?  downloadedTracks,

    // ── Timestamps ────────────────────────────────
    required DateTime createdAt,
    DateTime?         lastPlayedAt,

    // ── Flags ─────────────────────────────────────
    @Default(false) bool isFavorite,
  }) = _Album;

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
}
