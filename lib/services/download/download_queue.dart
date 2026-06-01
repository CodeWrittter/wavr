import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/download_dao.dart';
import '../../data/database/daos/track_dao.dart';
import '../../data/models/track.dart';
import '../track_resolver/models/resolved_track.dart';
import 'models/download_task.dart';

/// Manages the persistent download queue.
/// Survives app kills — state is stored in SQLite.
/// Processes at most [maxConcurrent] downloads at a time.
class DownloadQueue {
  final DownloadDao _downloadDao;
  final TrackDao    _trackDao;
  final _uuid = const Uuid();

  /// How many downloads run in parallel
  static const maxConcurrent = 2;

  /// Stream that emits the current queue state
  /// so the UI can react in real time
  final _controller = StreamController<List<DownloadTask>>.broadcast();
  Stream<List<DownloadTask>> get stream => _controller.stream;

  DownloadQueue({required AppDatabase db})
      : _downloadDao = DownloadDao(db),
        _trackDao    = TrackDao(db);

  /// Add a single resolved track to the queue.
  Future<DownloadTask> enqueue(ResolvedTrack resolved) async {
    // mark track as pending in tracks table
    await _trackDao.patch(resolved.trackId, {
      'download_status': DownloadStatus.pending.name,
      'resolved_url':    resolved.resolvedUrl,
    });

    final task = DownloadTask(
      id:          _uuid.v4(),
      trackId:     resolved.trackId,
      resolvedUrl: resolved.resolvedUrl,
      priority:    0,
      createdAt:   DateTime.now(),
    );

    await _downloadDao.enqueue(task);
    await _notify();
    return task;
  }

  /// Add an entire playlist at once — higher priority
  /// tasks (lower index in list) go first.
  Future<void> enqueueAll(List<ResolvedTrack> resolved) async {
    final tasks = <DownloadTask>[];

    for (var i = 0; i < resolved.length; i++) {
      final r = resolved[i];

      await _trackDao.patch(r.trackId, {
        'download_status': DownloadStatus.pending.name,
        'resolved_url':    r.resolvedUrl,
      });

      tasks.add(DownloadTask(
        id:          _uuid.v4(),
        trackId:     r.trackId,
        resolvedUrl: r.resolvedUrl,
        // earlier tracks in the playlist get higher priority
        priority:    resolved.length - i,
        createdAt:   DateTime.now(),
      ));
    }

    await _downloadDao.enqueueAll(tasks);
    await _notify();
  }

  /// Returns next [maxConcurrent] pending tasks.
  Future<List<DownloadTask>> nextBatch() async {
    final all = await _downloadDao.allPending();
    return all.take(maxConcurrent).toList();
  }

  Future<void> markDownloading(String taskId) async {
    await _downloadDao.markDownloading(taskId);
    await _notify();
  }

  Future<void> markDone(String taskId) async {
    await _downloadDao.markDone(taskId);
    await _notify();
  }

  Future<void> markFailed(String taskId) async {
    await _downloadDao.markFailed(taskId);
    await _notify();
  }

  Future<void> incrementRetries(String taskId) async {
    await _downloadDao.incrementRetries(taskId);
  }

  Future<void> requeueFailed() async {
    await _downloadDao.requeueFailed();
    await _notify();
  }

  Future<int> pendingCount() => _downloadDao.pendingCount();

  Future<void> _notify() async {
    final pending = await _downloadDao.allPending();
    if (!_controller.isClosed) _controller.add(pending);
  }

  void dispose() => _controller.close();
}
