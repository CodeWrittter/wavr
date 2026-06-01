/// DownloadTask lives here.
/// download_dao.dart imports from this file.
/// This avoids the circular dependency that would arise
/// if both files defined the same class.

enum QueueStatus { pending, downloading, done, failed }

class DownloadTask {
  final String      id;
  final String      trackId;
  final String      resolvedUrl;
  final int         priority;
  final int         retries;
  final QueueStatus status;
  final DateTime    createdAt;

  const DownloadTask({
    required this.id,
    required this.trackId,
    required this.resolvedUrl,
    this.priority  = 0,
    this.retries   = 0,
    this.status    = QueueStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id':           id,
        'track_id':     trackId,
        'resolved_url': resolvedUrl,
        'priority':     priority,
        'retries':      retries,
        'status':       status.name,
        'created_at':   createdAt.toIso8601String(),
      };

  factory DownloadTask.fromMap(Map<String, dynamic> m) => DownloadTask(
        id:          m['id'] as String,
        trackId:     m['track_id'] as String,
        resolvedUrl: m['resolved_url'] as String,
        priority:    m['priority'] as int? ?? 0,
        retries:     m['retries'] as int? ?? 0,
        status:      QueueStatus.values
            .byName(m['status'] as String? ?? 'pending'),
        createdAt:   DateTime.parse(m['created_at'] as String),
      );

  DownloadTask copyWith({QueueStatus? status, int? retries}) =>
      DownloadTask(
        id:          id,
        trackId:     trackId,
        resolvedUrl: resolvedUrl,
        priority:    priority,
        retries:     retries ?? this.retries,
        status:      status  ?? this.status,
        createdAt:   createdAt,
      );
}
