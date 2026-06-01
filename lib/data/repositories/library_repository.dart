import '../database/app_database.dart';
import '../database/daos/track_dao.dart';
import '../database/daos/playlist_dao.dart';
import '../models/track.dart';
import '../models/playlist.dart';

class LibraryRepository {
  final TrackDao    _trackDao;
  final PlaylistDao _playlistDao;

  LibraryRepository({required AppDatabase db})
      : _trackDao    = TrackDao(db),
        _playlistDao = PlaylistDao(db);

  // ── Tracks ────────────────────────────────────────────────────────────────

  Future<List<Track>> getAllTracks()       => _trackDao.findAll();
  Future<List<Track>> getDownloaded()     => _trackDao.findDownloaded();
  Future<List<Track>> getFavorites()      => _trackDao.findFavorites();
  Future<List<Track>> searchTracks(String q) => _trackDao.search(q);

  Future<List<Track>> getTracksForPlaylist(String playlistId) =>
      _trackDao.findByPlaylist(playlistId);

  Future<List<Track>> getTracksForAlbum(String albumId) =>
      _trackDao.findByAlbum(albumId);

  Future<void> toggleFavorite(Track track) async {
    await _trackDao.patch(track.id, {
      'is_favorite': track.isFavorite ? 0 : 1,
    });
  }

  Future<void> incrementPlayCount(String trackId) =>
      _trackDao.incrementPlayCount(trackId);

  Future<void> deleteTrack(String trackId) =>
      _trackDao.delete(trackId);

  // ── Playlists ─────────────────────────────────────────────────────────────

  Future<List<Playlist>> getAllPlaylists() => _playlistDao.findAll();

  Future<Playlist?> getPlaylist(String id) => _playlistDao.findById(id);

  Future<void> savePlaylist(Playlist playlist) =>
      _playlistDao.insert(playlist);

  Future<void> updatePlaylist(Playlist playlist) =>
      _playlistDao.update(playlist);

  Future<void> deletePlaylist(String id) => _playlistDao.delete(id);

  Future<void> setPlaylistTracks(String playlistId, List<String> ids) =>
      _playlistDao.setTracks(playlistId, ids);

  Future<void> addTrackToPlaylist(String playlistId, String trackId) =>
      _playlistDao.addTrack(playlistId, trackId);

  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) =>
      _playlistDao.removeTrack(playlistId, trackId);
}
