sealed class Failure {
  final String message;
  const Failure(this.message);
}

/// Failures are the UI-facing equivalent of exceptions.
/// Services throw exceptions; repositories/providers catch them
/// and return Failure objects that the UI can render meaningfully.

// ── Network ───────────────────────────────────────────────────────────────────

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class NoInternetFailure extends Failure {
  const NoInternetFailure()
      : super('No internet connection. '
            'Only downloaded tracks are available.');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure()
      : super('Request timed out. Please try again.');
}

// ── Import ────────────────────────────────────────────────────────────────────

class UnsupportedPlatformFailure extends Failure {
  const UnsupportedPlatformFailure(String url)
      : super('This platform is not supported yet: $url');
}

class EmptyPlaylistFailure extends Failure {
  const EmptyPlaylistFailure()
      : super('No tracks were found at this URL.');
}

class InvalidUrlFailure extends Failure {
  const InvalidUrlFailure()
      : super('This URL does not appear to be a valid playlist or album.');
}

// ── Resolver ──────────────────────────────────────────────────────────────────

class TrackNotFoundFailure extends Failure {
  const TrackNotFoundFailure(String title, String artist)
      : super('Could not find "$title" by $artist on any source.');
}

// ── Download ──────────────────────────────────────────────────────────────────

class DownloadFailure extends Failure {
  const DownloadFailure(String message) : super(message);
}

class StoragePermissionFailure extends Failure {
  const StoragePermissionFailure()
      : super('Storage permission is required to download music.');
}

class InsufficientStorageFailure extends Failure {
  const InsufficientStorageFailure()
      : super('Not enough storage space to download this track.');
}

// ── Database ──────────────────────────────────────────────────────────────────

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

// ── Credentials ───────────────────────────────────────────────────────────────

class MissingCredentialFailure extends Failure {
  const MissingCredentialFailure(String credential)
      : super('API credential "$credential" is not configured. '
            'Open lib/core/constants/app_credentials.dart to fill it in.');
}

// ── Unknown ───────────────────────────────────────────────────────────────────

class UnknownFailure extends Failure {
  const UnknownFailure() : super('An unexpected error occurred.');
}
