class DurationUtils {
  DurationUtils._();

  /// 3:22 format — used in player seek bar time labels.
  static String format(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// 1h 24m format — used in playlist/album total duration.
  static String formatLong(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  /// Converts milliseconds to a Duration.
  static Duration fromMs(int? ms) =>
      Duration(milliseconds: ms ?? 0);

  /// Sums a list of track durations given in milliseconds.
  static Duration totalFromMs(List<int?> msList) {
    final total = msList.fold<int>(
      0, (sum, ms) => sum + (ms ?? 0));
    return Duration(milliseconds: total);
  }

  /// Returns a human-readable relative time string.
  /// DateTime.now() - 2 hours → '2h ago'
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60)  return 'just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24)  return '${diff.inHours}h ago';
    if (diff.inDays    < 7)   return '${diff.inDays}d ago';
    if (diff.inDays    < 30)  return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays    < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }
}
