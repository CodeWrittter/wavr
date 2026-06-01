import 'package:sqflite/sqflite.dart';
import '../../models/track.dart';
import '../app_database.dart';

class TrackDao {
  final AppDatabase _db;
  TrackDao(this._db);

  // ── Mappers ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _toMap(Track t) => {
        'id': t.id,
        'title': t.title,
        'artist': t.artist,
        'album': t.album,
        'genre': t.genre,
        'year': t.year,
        'duration_ms': t.durationMs,
        'track_number': t.trackNumber,
        'artwork_url': t.artworkUrl,
        'artwork_local_path': t.artworkLocalPath,
        'source': t.source.name,
        'source_id': t.sourceId,
        'resolved_url': t.resolvedUrl,
        'local_file_path': t.localFilePath,
        'download_status': t.downloadStatus.name,
        'download_progress': t.downloadProgress,
        'added_at': t.addedAt.toIso8601String(),
        'downloaded_at': t.downloadedAt?.toIso8601String(),
        'last_played_at': t.lastPlayedAt?.toIso8601String(),
        'play_count': t.playCount,
        'is_favorite': t.isFavorite ? 1 : 0,
      };

  Track _fromMap(Map<String, dynamic> m) => Track(
        id: m['id'] as String,
        title: m['title'] as String,
        artist: m['artist'] as String,
        album: m['album'] as String?,
        genre: m['genre'] as String?,
        year: m['year'] as int?,
        durationMs: m['duration_ms'] as int?,
        trackNumber: m['track_number'] as int?,
        artworkUrl: m['artwork_url'] as String?,
        artworkLocalPath: m['artwork_local_path'] as String?,
        source: TrackSource.values.byName(m['source'] as String),
        sourceId: m['source_id'] as String?,
        resolvedUrl: m['resolved_url'] as String?,
        localFilePath: m['local_file_path'] as String?,
        downloadStatus: DownloadStatus.values
            .byName(m['download_status'] as String? ?? 'none'),
        downloadProgress: m['download_progress'] as int?,
        addedAt: DateTime.parse(m['added_at'] as String),
        downloadedAt: m['downloaded_at'] != null
            ? DateTime.parse(m['downloaded_at'] as String)
            : null,
        lastPlayedAt: m['last_played_at'] != null
            ? DateTime.parse(m['last_played_at'] as String)
            : null,
        playCount: m['play_count'] as int? ?? 0,
        isFavorite: (m['is_favorite'] as int? ?? 0) == 1,
      );

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> insert(Track track) async {
    final db = await _db.database;
    await db.insert(
      'tracks',
      _toMap(track),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAll(List<Track> tracks) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final t in tracks) {
      batch.insert('tracks', _toMap(t),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> update(Track track) async {
    final db = await _db.database;
    await db.update(
      'tracks',
      _toMap(track),
      where: 'id = ?',
      whereArgs: [track.id],
    );
  }

  /// Partial update — only touches the fields you care about
  Future<void> patch(String id, Map<String, dynamic> fields) async {
    final db = await _db.database;
    await db.update('tracks', fields, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('tracks', where: 'id = ?', whereArgs: [id]);
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<Track?> findById(String id) async {
    final db = await _db.database;
    final rows = await db.query('tracks', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<List<Track>> findAll() async {
    final db = await _db.database;
    final rows = await db.query('tracks', orderBy: 'added_at DESC');
    return rows.map(_fromMap).toList();
  }

  Future<List<Track>> findDownloaded() async {
    final db = await _db.database;
    final rows = await db.query(
      'tracks',
      where: 'download_status = ?',
      whereArgs: ['done'],
      orderBy: 'downloaded_at DESC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<List<Track>> findByPlaylist(String playlistId) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT t.* FROM tracks t
      INNER JOIN playlist_tracks pt ON pt.track_id = t.id
      WHERE pt.playlist_id = ?
      ORDER BY pt.position ASC
    ''', [playlistId]);
    return rows.map(_fromMap).toList();
  }

  Future<List<Track>> findByAlbum(String albumId) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT t.* FROM tracks t
      INNER JOIN album_tracks at ON at.track_id = t.id
      WHERE at.album_id = ?
      ORDER BY at.position ASC
    ''', [albumId]);
    return rows.map(_fromMap).toList();
  }

  Future<List<Track>> search(String query) async {
    final db = await _db.database;
    final q = '%$query%';
    final rows = await db.query(
      'tracks',
      where: 'title LIKE ? OR artist LIKE ? OR album LIKE ?',
      whereArgs: [q, q, q],
      orderBy: 'play_count DESC',
      limit: 50,
    );
    return rows.map(_fromMap).toList();
  }

  Future<List<Track>> findFavorites() async {
    final db = await _db.database;
    final rows = await db.query(
      'tracks',
      where: 'is_favorite = 1',
      orderBy: 'added_at DESC',
    );
    return rows.map(_fromMap).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> markDownloaded(
    String id, {
    required String localFilePath,
    String? artworkLocalPath,
  }) async {
    await patch(id, {
      'download_status': DownloadStatus.done.name,
      'download_progress': 100,
      'local_file_path': localFilePath,
      'artwork_local_path': artworkLocalPath,
      'downloaded_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateProgress(String id, int progress) async {
    await patch(id, {
      'download_status': DownloadStatus.downloading.name,
      'download_progress': progress,
    });
  }

  Future<void> markFailed(String id) async {
    await patch(id, {'download_status': DownloadStatus.failed.name});
  }

  Future<void> incrementPlayCount(String id) async {
    final db = await _db.database;
    await db.rawUpdate('''
      UPDATE tracks SET play_count = play_count + 1,
      last_played_at = ? WHERE id = ?
    ''', [DateTime.now().toIso8601String(), id]);
  }
}
