import 'package:sqflite/sqflite.dart';
import '../../models/playlist.dart';
import '../../models/track.dart';
import '../app_database.dart';

class PlaylistDao {
  final AppDatabase _db;
  PlaylistDao(this._db);

  // ── Mappers ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _toMap(Playlist p) => {
        'id': p.id,
        'name': p.name,
        'description': p.description,
        'artwork_url': p.artworkUrl,
        'artwork_local_path': p.artworkLocalPath,
        'type': p.type.name,
        'source': p.source.name,
        'source_url': p.sourceUrl,
        'source_playlist_id': p.sourcePlaylistId,
        'is_fully_downloaded': p.isFullyDownloaded ? 1 : 0,
        'total_tracks': p.totalTracks,
        'downloaded_tracks': p.downloadedTracks,
        'created_at': p.createdAt.toIso8601String(),
        'last_synced_at': p.lastSyncedAt?.toIso8601String(),
        'last_played_at': p.lastPlayedAt?.toIso8601String(),
        'is_pinned': p.isPinned ? 1 : 0,
        'is_archived': p.isArchived ? 1 : 0,
      };

  Playlist _fromMap(Map<String, dynamic> m) => Playlist(
        id: m['id'] as String,
        name: m['name'] as String,
        description: m['description'] as String?,
        artworkUrl: m['artwork_url'] as String?,
        artworkLocalPath: m['artwork_local_path'] as String?,
        type: PlaylistType.values.byName(m['type'] as String),
        source: TrackSource.values.byName(m['source'] as String),
        sourceUrl: m['source_url'] as String?,
        sourcePlaylistId: m['source_playlist_id'] as String?,
        isFullyDownloaded: (m['is_fully_downloaded'] as int? ?? 0) == 1,
        totalTracks: m['total_tracks'] as int?,
        downloadedTracks: m['downloaded_tracks'] as int?,
        createdAt: DateTime.parse(m['created_at'] as String),
        lastSyncedAt: m['last_synced_at'] != null
            ? DateTime.parse(m['last_synced_at'] as String)
            : null,
        lastPlayedAt: m['last_played_at'] != null
            ? DateTime.parse(m['last_played_at'] as String)
            : null,
        isPinned: (m['is_pinned'] as int? ?? 0) == 1,
        isArchived: (m['is_archived'] as int? ?? 0) == 1,
      );

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> insert(Playlist playlist) async {
    final db = await _db.database;
    await db.insert(
      'playlists',
      _toMap(playlist),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Playlist playlist) async {
    final db = await _db.database;
    await db.update(
      'playlists',
      _toMap(playlist),
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
  }

  Future<void> patch(String id, Map<String, dynamic> fields) async {
    final db = await _db.database;
    await db.update('playlists', fields, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    // junction rows are cleaned up by CASCADE
    await db.delete('playlists', where: 'id = ?', whereArgs: [id]);
  }

  /// Replace all tracks in the playlist (full re-sync)
  Future<void> setTracks(String playlistId, List<String> trackIds) async {
    final db = await _db.database;
    final batch = db.batch();
    batch.delete(
      'playlist_tracks',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );
    for (var i = 0; i < trackIds.length; i++) {
      batch.insert('playlist_tracks', {
        'playlist_id': playlistId,
        'track_id': trackIds[i],
        'position': i,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> addTrack(String playlistId, String trackId) async {
    final db = await _db.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM playlist_tracks WHERE playlist_id = ?',
      [playlistId],
    ))!;
    await db.insert('playlist_tracks', {
      'playlist_id': playlistId,
      'track_id': trackId,
      'position': count,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeTrack(String playlistId, String trackId) async {
    final db = await _db.database;
    await db.delete(
      'playlist_tracks',
      where: 'playlist_id = ? AND track_id = ?',
      whereArgs: [playlistId, trackId],
    );
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<Playlist?> findById(String id) async {
    final db = await _db.database;
    final rows =
        await db.query('playlists', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<List<Playlist>> findAll() async {
    final db = await _db.database;
    final rows = await db.query(
      'playlists',
      where: 'is_archived = 0',
      orderBy: 'is_pinned DESC, created_at DESC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<List<String>> getTrackIds(String playlistId) async {
    final db = await _db.database;
    final rows = await db.query(
      'playlist_tracks',
      columns: ['track_id'],
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
      orderBy: 'position ASC',
    );
    return rows.map((r) => r['track_id'] as String).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> incrementDownloadedCount(String id) async {
    final db = await _db.database;
    await db.rawUpdate('''
      UPDATE playlists
      SET downloaded_tracks = downloaded_tracks + 1,
          is_fully_downloaded = CASE
            WHEN downloaded_tracks + 1 >= total_tracks THEN 1
            ELSE 0
          END
      WHERE id = ?
    ''', [id]);
  }
}
