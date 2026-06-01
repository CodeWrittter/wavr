extension StringExtensions on String {

  /// Capitalizes only the first letter.
  /// 'hello world' → 'Hello world'
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Title-cases every word.
  /// 'blinding lights' → 'Blinding Lights'
  String get titleCased => split(' ')
      .map((w) => w.isEmpty ? w : w.capitalized)
      .join(' ');

  /// Removes featuring credits, remix tags, official tags.
  /// 'Blinding Lights (feat. Someone) [Official Video]'
  /// → 'Blinding Lights'
  String get cleanedTitle => replaceAll(RegExp(r'\(.*?\)'), '')
      .replaceAll(RegExp(r'\[.*?\]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Normalizes for fuzzy matching.
  /// Lowercases, strips punctuation, collapses whitespace.
  String get normalized => toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Truncates with ellipsis if longer than [maxLength].
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 1)}…';
  }

  /// True if the string looks like a URL.
  bool get isUrl =>
      startsWith('http://') ||
      startsWith('https://') ||
      startsWith('wavr://');

  /// True if the string is a Wavr share link.
  bool get isWavrShareLink =>
      contains('wavr.app/share') || startsWith('wavr://share');

  /// Extracts a platform name from a URL for display.
  /// 'https://open.spotify.com/...' → 'Spotify'
  String get platformName {
    if (contains('spotify'))    return 'Spotify';
    if (contains('apple'))      return 'Apple Music';
    if (contains('deezer'))     return 'Deezer';
    if (contains('youtube') ||
        contains('youtu.be'))   { return 'YouTube Music'; }
    if (contains('soundcloud')) return 'SoundCloud';
    if (contains('audius'))     return 'Audius';
    if (contains('jamendo'))    return 'Jamendo';
    if (contains('wavr'))       return 'Wavr Share';
    return 'Unknown';
  }

  /// Parses 'Artist — Title' or 'Title — Artist' into a map.
  /// Returns null if no separator is found.
  Map<String, String>? parseTrackLine() {
    final sep = contains(' — ')
        ? ' — '
        : contains(' - ')
            ? ' - '
            : null;
    if (sep == null) return null;
    final parts = split(sep);
    return {
      'first': parts.first.trim(),
      'second': parts.sublist(1).join(sep).trim(),
    };
  }
}

extension NullableStringExtensions on String? {
  /// Returns the string or a fallback if null/empty.
  String orDefault(String fallback) {
    if (this == null || this!.isEmpty) return fallback;
    return this!;
  }
}
