import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wavr.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createTracksTable);
    await db.execute(_createPlaylistsTable);
    await db.execute(_createPlaylistTracksTable);
    await db.execute(_createAlbumsTable);
    await db.execute(_createAlbumTracksTable);
    await db.execute(_createDownloadQueueTable);

    // indices for common queries
    await db.execute(
      'CREATE INDEX idx_tracks_download_status ON tracks(download_status)',
    );
    await db.execute(
      'CREATE INDEX idx_tracks_source ON tracks(source)',
    );
    await db.execute(
      'CREATE INDEX idx_playlist_tracks_playlist ON playlist_tracks(playlist_id)',
    );
    await db.execute(
      'CREATE INDEX idx_album_tracks_album ON album_tracks(album_id)',
    );
  }

  // called when version bumps — safe migrations go here
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // ── Table definitions ──────────────────────────────────────────────────────

  static const _createTracksTable = '''
    CREATE TABLE tracks (
      id                  TEXT PRIMARY KEY,
      title               TEXT NOT NULL,
      artist              TEXT NOT NULL,
      album               TEXT,
      genre               TEXT,
      year                INTEGER,
      duration_ms         INTEGER,
      track_number        INTEGER,
      artwork_url         TEXT,
      artwork_local_path  TEXT,
      source              TEXT NOT NULL,
      source_id           TEXT,
      resolved_url        TEXT,
      local_file_path     TEXT,
      download_status     TEXT NOT NULL DEFAULT 'none',
      download_progress   INTEGER DEFAULT 0,
      added_at            TEXT NOT NULL,
      downloaded_at       TEXT,
      last_played_at      TEXT,
      play_count          INTEGER NOT NULL DEFAULT 0,
      is_favorite         INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const _createPlaylistsTable = '''
    CREATE TABLE playlists (
      id                    TEXT PRIMARY KEY,
      name                  TEXT NOT NULL,
      description           TEXT,
      artwork_url           TEXT,
      artwork_local_path    TEXT,
      type                  TEXT NOT NULL,
      source                TEXT NOT NULL,
      source_url            TEXT,
      source_playlist_id    TEXT,
      is_fully_downloaded   INTEGER NOT NULL DEFAULT 0,
      total_tracks          INTEGER,
      downloaded_tracks     INTEGER DEFAULT 0,
      created_at            TEXT NOT NULL,
      last_synced_at        TEXT,
      last_played_at        TEXT,
      is_pinned             INTEGER NOT NULL DEFAULT 0,
      is_archived           INTEGER NOT NULL DEFAULT 0
    )
  ''';

  // junction table — keeps track order inside a playlist
  static const _createPlaylistTracksTable = '''
    CREATE TABLE playlist_tracks (
      playlist_id   TEXT NOT NULL,
      track_id      TEXT NOT NULL,
      position      INTEGER NOT NULL,
      PRIMARY KEY (playlist_id, track_id),
      FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
      FOREIGN KEY (track_id)    REFERENCES tracks(id)    ON DELETE CASCADE
    )
  ''';

  static const _createAlbumsTable = '''
    CREATE TABLE albums (
      id                  TEXT PRIMARY KEY,
      title               TEXT NOT NULL,
      artist              TEXT NOT NULL,
      artwork_url         TEXT,
      artwork_local_path  TEXT,
      year                INTEGER,
      genre               TEXT,
      total_tracks        INTEGER,
      source              TEXT NOT NULL,
      source_album_id     TEXT,
      is_fully_downloaded INTEGER NOT NULL DEFAULT 0,
      downloaded_tracks   INTEGER DEFAULT 0,
      created_at          TEXT NOT NULL,
      last_played_at      TEXT,
      is_favorite         INTEGER NOT NULL DEFAULT 0
    )
  ''';

  // junction table — keeps track order inside an album
  static const _createAlbumTracksTable = '''
    CREATE TABLE album_tracks (
      album_id    TEXT NOT NULL,
      track_id    TEXT NOT NULL,
      position    INTEGER NOT NULL,
      PRIMARY KEY (album_id, track_id),
      FOREIGN KEY (album_id)  REFERENCES albums(id) ON DELETE CASCADE,
      FOREIGN KEY (track_id)  REFERENCES tracks(id) ON DELETE CASCADE
    )
  ''';

  // persistent download queue — survives app kills
  static const _createDownloadQueueTable = '''
    CREATE TABLE download_queue (
      id            TEXT PRIMARY KEY,
      track_id      TEXT NOT NULL,
      resolved_url  TEXT NOT NULL,
      priority      INTEGER NOT NULL DEFAULT 0,
      retries       INTEGER NOT NULL DEFAULT 0,
      status        TEXT NOT NULL DEFAULT 'pending',
      created_at    TEXT NOT NULL,
      FOREIGN KEY (track_id) REFERENCES tracks(id) ON DELETE CASCADE
    )
  ''';

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }

  /// Wipe everything — used in "Clear cache" settings action
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wavr.db');
    await databaseFactory.deleteDatabase(path);
    _db = null;
  }
}
