/// Platform-specific constants used across the app.
/// API base URLs, limits, timeouts — nothing secret goes here,
/// that belongs in app_credentials.dart.

class AppConstants {
  AppConstants._();

  // ── Network timeouts ───────────────────────────────────────────────────────
  static const connectTimeoutMs  = 10000; // 10s
  static const receiveTimeoutMs  = 30000; // 30s
  static const downloadTimeoutMs = 300000; // 5min

  // ── Retry policy ───────────────────────────────────────────────────────────
  static const maxDownloadRetries = 3;
  static const maxResolveRetries  = 2;

  // ── Resolver ───────────────────────────────────────────────────────────────
  static const minResolveScore    = 0.55; // minimum fuzzy score to accept
  static const highResolveScore   = 0.90; // stop trying other resolvers
  static const maxSearchResults   = 10;   // per resolver search query
  static const maxSearchQueries   = 3;    // queries tried per track

  // ── Download queue ─────────────────────────────────────────────────────────
  static const maxConcurrentDownloads = 2;
  static const maxQueueRetries        = 3;

  // ── Cache ──────────────────────────────────────────────────────────────────
  static const maxCachedArtworks     = 500;
  static const maxRecentSearches     = 10;
  static const maxRecentImports      = 20;

  // ── Playlist limits ────────────────────────────────────────────────────────
  static const maxTracksPerFetch     = 200; // single API call limit
  static const spotifyPageSize       = 100; // USED
  static const deezerPageSize        = 100;
  static const appleMusicPageSize    = 200;

  // ── Lyrics ─────────────────────────────────────────────────────────────────
  static const lrclibBaseUrl     = 'https://lrclib.net/api'; // NOT USED

  // ── Audio ──────────────────────────────────────────────────────────────────
  static const defaultCrossfadeMs    = 3000;
  static const maxCrossfadeMs        = 8000;
  static const audioBufferSizeMs     = 5000;

  // ── Platforms base URLs ────────────────────────────────────────────────────
  static const youtubeBase       = 'https://www.youtube.com';
  static const spotifyApiBase    = 'https://api.spotify.com/v1';
  static const spotifyAuthUrl    = 'https://accounts.spotify.com/api/token';
  static const deezerApiBase     = 'https://api.deezer.com';
  static const itunesApiBase     = 'https://itunes.apple.com';
  static const soundcloudApiBase = 'https://api-v2.soundcloud.com';
  static const audiusApiBase     = 'https://discoveryprovider.audius.co/v1';
  static const jamendoApiBase    = 'https://api.jamendo.com/v3.0'; // ALREADY IN CREDENTIALS
  static const musicBrainzBase   = 'https://musicbrainz.org/ws/2';
  static const coverArtBase      = 'https://coverartarchive.org/release';
  static const lastFmBase        = 'https://ws.audioscrobbler.com/2.0';
}
