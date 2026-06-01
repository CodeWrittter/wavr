import 'package:freezed_annotation/freezed_annotation.dart';
import 'track.dart';

part 'playlist.freezed.dart';
part 'playlist.g.dart';

enum PlaylistType {
  imported,   // came from Spotify, Deezer, etc.
  manual,     // user typed songs manually
  txtFile,    // loaded from a .txt file
  wavrShare,  // received via Wavr Share link
  smart,      // auto-generated (e.g. "Recently played")
}

@freezed
abstract class Playlist with _$Playlist {
  const factory Playlist({
    // ── Identity ──────────────────────────────────
    required String id,
    required String name,

    // ── Metadata ──────────────────────────────────
    String?       description,
    String?       artworkUrl,
    String?       artworkLocalPath,
    required      PlaylistType type,
    required      TrackSource  source,      // where it was imported from
    String?       sourceUrl,                // original link pasted by user
    String?       sourcePlaylistId,         // ID on the original platform

    // ── Tracks ────────────────────────────────────
    @Default([]) List<String> trackIds,     // ordered list of Track UUIDs
    // note: full Track objects are fetched via TrackDao, not embedded here

    // ── Download state ────────────────────────────
    @Default(false) bool isFullyDownloaded,
    int?  totalTracks,
    int?  downloadedTracks,

    // ── Timestamps ────────────────────────────────
    required DateTime createdAt,
    DateTime?         lastSyncedAt,         // last time metadata was refreshed
    DateTime?         lastPlayedAt,

    // ── Flags ─────────────────────────────────────
    @Default(false) bool isPinned,
    @Default(false) bool isArchived,
  }) = _Playlist;

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);
}
