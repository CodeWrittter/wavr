/// All exceptions thrown inside Wavr services.
/// Catch these at the provider/repository layer and
/// convert them to [Failure] objects for the UI.

// ── Network ───────────────────────────────────────────────────────────────────

class NetworkException implements Exception {
  final String  message;
  final int?    statusCode;
  const NetworkException(this.message, {this.statusCode});

  @override
  String toString() =>
      'NetworkException: $message'
      '${statusCode != null ? ' (HTTP $statusCode)' : ''}';
}

class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

class NoInternetException implements Exception {
  const NoInternetException();

  @override
  String toString() => 'NoInternetException: no network connection';
}

// ── Decoder ───────────────────────────────────────────────────────────────────

class UnsupportedPlatformException implements Exception {
  final String url;
  const UnsupportedPlatformException(this.url);

  @override
  String toString() =>
      'UnsupportedPlatformException: no decoder found for $url';
}

class EmptyPlaylistException implements Exception {
  final String url;
  const EmptyPlaylistException(this.url);

  @override
  String toString() =>
      'EmptyPlaylistException: no tracks found at $url';
}

class InvalidPlaylistUrlException implements Exception {
  final String url;
  const InvalidPlaylistUrlException(this.url);

  @override
  String toString() =>
      'InvalidPlaylistUrlException: cannot parse $url';
}

// ── Resolver ──────────────────────────────────────────────────────────────────

class TrackNotFoundException implements Exception {
  final String title;
  final String artist;
  const TrackNotFoundException(this.title, this.artist);

  @override
  String toString() =>
      'TrackNotFoundException: could not resolve "$title" by $artist';
}

class ResolveLimitException implements Exception {
  const ResolveLimitException();

  @override
  String toString() =>
      'ResolveLimitException: all resolvers returned no result';
}

// ── Download ──────────────────────────────────────────────────────────────────

class DownloadException implements Exception {
  final String trackId;
  final String message;
  const DownloadException(this.trackId, this.message);

  @override
  String toString() =>
      'DownloadException [$trackId]: $message';
}

class StoragePermissionException implements Exception {
  const StoragePermissionException();

  @override
  String toString() =>
      'StoragePermissionException: storage permission denied';
}

class InsufficientStorageException implements Exception {
  final int requiredBytes;
  const InsufficientStorageException(this.requiredBytes);

  @override
  String toString() =>
      'InsufficientStorageException: need ${requiredBytes}B free';
}

// ── Database ──────────────────────────────────────────────────────────────────

class DatabaseException implements Exception {
  final String operation;
  final String message;
  const DatabaseException(this.operation, this.message);

  @override
  String toString() =>
      'DatabaseException [$operation]: $message';
}

// ── Credentials ───────────────────────────────────────────────────────────────

class MissingCredentialException implements Exception {
  final String credential;
  const MissingCredentialException(this.credential);

  @override
  String toString() =>
      'MissingCredentialException: $credential is not configured '
      'in AppCredentials';
}
