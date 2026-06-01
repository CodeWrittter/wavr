import 'package:freezed_annotation/freezed_annotation.dart';

part 'track.freezed.dart';
part 'track.g.dart';

enum TrackSource {
  spotify,
  appleMusic,
  deezer,
  ytMusic,
  soundcloud,
  audius,
  jamendo,
  local,
  wavrShare,
  manual,
}

enum DownloadStatus {
  none,       // never touched
  pending,    // queued
  resolving,  // TrackResolverService is working
  downloading,// DownloadService is pulling the file
  done,       // file exists locally
  failed,     // something went wrong
}

@freezed
abstract class Track with _$Track {
  const factory Track({
    // ── Identity ──────────────────────────────────
    required String id,           // UUID generated locally
    required String title,
    required String artist,

    // ── Optional metadata ─────────────────────────
    String? album,
    String? genre,
    int?    year,
    int?    durationMs,           // milliseconds
    int?    trackNumber,

    // ── Artwork ───────────────────────────────────
    String? artworkUrl,           // remote URL (used before download)
    String? artworkLocalPath,     // local path after download

    // ── Source ────────────────────────────────────
    required TrackSource source,
    String? sourceId,             // original ID on the source platform
    String? resolvedUrl,          // best URL found by TrackResolverService

    // ── Local file ────────────────────────────────
    String? localFilePath,        // absolute path once downloaded

    // ── Status ────────────────────────────────────
    @Default(DownloadStatus.none) DownloadStatus downloadStatus,
    int?    downloadProgress,     // 0–100

    // ── Timestamps ────────────────────────────────
    required DateTime addedAt,
    DateTime? downloadedAt,
    DateTime? lastPlayedAt,

    // ── Playback ──────────────────────────────────
    @Default(0) int playCount,
    @Default(false) bool isFavorite,
  }) = _Track;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);
}
