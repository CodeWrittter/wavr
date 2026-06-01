import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/track.dart';
import '../../../data/models/playlist.dart';
import '../../../data/repositories/library_repository.dart';
import '../../../data/repositories/playlist_repository.dart';

// ── Database singleton ─────────────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((_) => AppDatabase());

// ── Repositories ─────────────────────────────────────────────────────────────

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return LibraryRepository(db: db);
});

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return PlaylistRepository(db: db);
});

// ── All tracks ─────────────────────────────────────────────────────────────

final allTracksProvider = FutureProvider<List<Track>>((ref) {
  return ref.read(libraryRepositoryProvider).getAllTracks();
});

// ── Downloaded tracks only ─────────────────────────────────────────────────

final downloadedTracksProvider = FutureProvider<List<Track>>((ref) {
  return ref.read(libraryRepositoryProvider).getDownloaded();
});

// ── Favorites ──────────────────────────────────────────────────────────────

final favoritesProvider = FutureProvider<List<Track>>((ref) {
  return ref.read(libraryRepositoryProvider).getFavorites();
});

// ── All playlists ──────────────────────────────────────────────────────────

final allPlaylistsProvider = FutureProvider<List<Playlist>>((ref) {
  return ref.read(libraryRepositoryProvider).getAllPlaylists();
});

// ── Tracks for a specific playlist ────────────────────────────────────────

final playlistTracksProvider =
    FutureProvider.family<List<Track>, String>((ref, playlistId) {
  return ref.read(libraryRepositoryProvider).getTracksForPlaylist(playlistId);
});

// ── Active filter chip ─────────────────────────────────────────────────────

enum LibraryFilter { all, playlists, albums, artists, local }

class LibraryFilterNotifier extends Notifier<LibraryFilter> {
  @override
  LibraryFilter build() => LibraryFilter.all;
  void set(LibraryFilter f) => state = f;
}

final libraryFilterProvider =
    NotifierProvider<LibraryFilterNotifier, LibraryFilter>(
  LibraryFilterNotifier.new,
);
