import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../../services/download/models/download_task.dart';

class DownloadDao {
  final AppDatabase _db;
  DownloadDao(this._db);

  Future<void> enqueue(DownloadTask task) async {
    final db = await _db.database;
    await db.insert(
      'download_queue',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> enqueueAll(List<DownloadTask> tasks) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final t in tasks) {
      batch.insert('download_queue', t.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  /// Returns next pending task, highest priority first
  Future<DownloadTask?> nextPending() async {
    final db = await _db.database;
    final rows = await db.query(
      'download_queue',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'priority DESC, created_at ASC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DownloadTask.fromMap(rows.first);
  }

  Future<List<DownloadTask>> allPending() async {
    final db = await _db.database;
    final rows = await db.query(
      'download_queue',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'priority DESC, created_at ASC',
    );
    return rows.map(DownloadTask.fromMap).toList();
  }

  Future<void> markDownloading(String id) async {
    final db = await _db.database;
    await db.update(
      'download_queue',
      {'status': QueueStatus.downloading.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markDone(String id) async {
    final db = await _db.database;
    await db.update(
      'download_queue',
      {'status': QueueStatus.done.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markFailed(String id) async {
    final db = await _db.database;
    await db.update(
      'download_queue',
      {'status': QueueStatus.failed.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementRetries(String id) async {
    final db = await _db.database;
    await db.rawUpdate('''
      UPDATE download_queue SET retries = retries + 1 WHERE id = ?
    ''', [id]);
  }

  /// Reset failed tasks so they can be retried
  Future<void> requeueFailed() async {
    final db = await _db.database;
    await db.update(
      'download_queue',
      {'status': QueueStatus.pending.name},
      where: 'status = ? AND retries < 3',
      whereArgs: ['failed'],
    );
  }

  Future<void> remove(String id) async {
    final db = await _db.database;
    await db.delete('download_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearDone() async {
    final db = await _db.database;
    await db.delete('download_queue',
        where: 'status = ?', whereArgs: ['done']);
  }

  Future<int> pendingCount() async {
    final db = await _db.database;
    return Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM download_queue WHERE status = ?',
          ['pending'],
        )) ??
        0;
  }
}
