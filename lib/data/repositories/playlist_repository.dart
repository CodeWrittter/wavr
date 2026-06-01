import '../database/app_database.dart';
import '../database/daos/playlist_dao.dart';
import '../database/daos/track_dao.dart';
import '../models/playlist.dart';
import '../models/track.dart';

/// Dedicated playlist repository — handles all playlist
/// operations including track ordering and sync state.
class PlaylistRepository {
  final PlaylistDao _playlistDao;
  final TrackDao    _trackDao;

  PlaylistRepository({required AppDatabase db})
      : _playlistDao = PlaylistDao(db),
        _trackDao    = TrackDao(db);

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<List<Playlist>> getAll() => _playlistDao.findAll();

  Future<Playlist?> getById(String id) =>
      _playlistDao.findById(id);

  Future<List<Track>> getTracks(String playlistId) =>
      _trackDao.findByPlaylist(playlistId);

  Future<List<String>> getTrackIds(String playlistId) =>
      _playlistDao.getTrackIds(playlistId);

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> save(Playlist playlist) =>
      _playlistDao.insert(playlist);

  Future<void> update(Playlist playlist) =>
      _playlistDao.update(playlist);

  Future<void> delete(String id) =>
      _playlistDao.delete(id);

  /// Replace all tracks in the playlist — used after a full
  /// re-sync from the source platform.
  Future<void> setTracks(
      String playlistId, List<String> trackIds) =>
      _playlistDao.setTracks(playlistId, trackIds);

  Future<void> addTrack(String playlistId, String trackId) =>
      _playlistDao.addTrack(playlistId, trackId);

  Future<void> removeTrack(String playlistId, String trackId) =>
      _playlistDao.removeTrack(playlistId, trackId);

  // ── Sync ──────────────────────────────────────────────────────────────────

  Future<void> markSynced(String playlistId) =>
      _playlistDao.patch(playlistId, {
        'last_synced_at': DateTime.now().toIso8601String(),
      });

  Future<void> updateDownloadProgress(
      String playlistId, int downloaded) async {
    await _playlistDao.patch(playlistId, {
      'downloaded_tracks':    downloaded,
    });
    await _playlistDao.incrementDownloadedCount(playlistId);
  }

  Future<void> rename(String playlistId, String name) =>
      _playlistDao.patch(playlistId, {'name': name});

  Future<void> togglePin(Playlist playlist) =>
      _playlistDao.patch(playlist.id, {
        'is_pinned': playlist.isPinned ? 0 : 1,
      });

  // ── Stats ─────────────────────────────────────────────────────────────────

  /// Returns how many tracks in the playlist are downloaded.
  Future<int> countDownloaded(String playlistId) async {
    final tracks = await getTracks(playlistId);
    return tracks
        .where((t) => t.downloadStatus == DownloadStatus.done)
        .length;
  }

  /// True if every track in the playlist is downloaded.
  Future<bool> isFullyDownloaded(String playlistId) async {
    final tracks = await getTracks(playlistId);
    if (tracks.isEmpty) return false;
    return tracks.every((t) =>
        t.downloadStatus == DownloadStatus.done);
  }
}
