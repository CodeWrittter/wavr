class AppCredentials {
    /// ─────────────────────────────────────────────────────────────────────────
    /// WAVR — API CREDENTIALS & CONFIGURATION
    /// ─────────────────────────────────────────────────────────────────────────
    ///
    /// This is the ONLY file where API keys and credentials live.
    /// Never hardcode credentials anywhere else in the codebase.
    ///
    /// HOW TO FILL THIS FILE:
    ///
    /// Spotify:
    ///   → https://developer.spotify.com/dashboard
    ///   → Create app → get Client ID + Client Secret
    ///   → Free tier, read-only public data is enough
    ///
    /// Jamendo:
    ///   → https://developer.jamendo.com/v3.0
    ///   → Register → get Client ID (called "client_id" in their docs)
    ///
    /// Last.fm:
    ///   → https://www.last.fm/api/account/create
    ///   → Free account → get API Key
    ///
    /// SoundCloud:
    ///   → The client_id below is a public one extracted from their web app.
    ///   → It rotates occasionally. If you get 401 errors, fetch any
    ///     SoundCloud page, open DevTools → Network → filter by "client_id"
    ///     in any request URL, copy the new value here.
    ///
    /// MusicBrainz / Cover Art Archive:
    ///   → No key needed. Just set your app name + contact below
    ///     so MusicBrainz can identify your requests (their policy).
    ///
    /// ─────────────────────────────────────────────────────────────────────────

  AppCredentials._(); // prevent instantiation

  // ── Spotify ───────────────────────────────────────────────────────────────
  static const spotifyClientId     = '8c679cc2798f4d59b333644122f5e681';
  static const spotifyClientSecret = '5c31c1f1234b404ebd175bc96a8e871a';

  // ── Jamendo ───────────────────────────────────────────────────────────────
  static const jamendoClientId     = 'YOUR_JAMENDO_CLIENT_ID';
  static const jamendoBase = 'https://api.jamendo.com/v3.0';

  // ── Last.fm ───────────────────────────────────────────────────────────────
  static const lastFmApiKey        = 'YOUR_LASTFM_API_KEY';

  // ── SoundCloud ────────────────────────────────────────────────────────────
  // Public client_id — update if requests return 401
  static const soundCloudClientId  = 'iZIs9mchVcX5lhVRyQGGAYlNPVldzAoX';

  // ── MusicBrainz ───────────────────────────────────────────────────────────
  // No key needed — just identify your app (their policy requires a User-Agent)
  static const musicBrainzAppName    = 'Wavr';
  static const musicBrainzAppVersion = '1.0.0';
  static const musicBrainzContact    = 'jerry.sonhana@gmail.com';
  static String get musicBrainzUserAgent =>
      '$musicBrainzAppName/$musicBrainzAppVersion ($musicBrainzContact)';

  // ── Update check ───────────────────────────────────────────────────────────
  static const updateCheckUrl     = 'YOUR_UPDATE_CHECK_URL';
  // e.g. 'https://api.github.com/repos/yourname/wavr/releases/latest'
  // or a simple JSON endpoint: { "version": "1.0.1", "download_url": "..." }
  static const currentVersion     = '1.0.0';

  // ── Donation ───────────────────────────────────────────────────────────────
  static const donationWebsiteUrl = 'YOUR_DONATION_WEBSITE_URL';
  // e.g. 'https://buymeacoffee.com/yourname'

  // ── Developer info ─────────────────────────────────────────────────────────
  static const developerName      = 'Code Writter';
  static const developerAddress   = 'Yaoundé, Cameroon';
  static const developerMessage   =
      'Wavr is built with love as a free, ad-free tool '
      'for music lovers. Every contribution keeps it alive.';
}
