import 'package:uuid/uuid.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/track_dao.dart';
import '../../data/models/track.dart';
import '../playlist_decoder/models/decoded_track.dart';
import 'models/resolved_track.dart';
import 'resolvers/youtube_resolver.dart';
import 'resolvers/soundcloud_resolver.dart';
import 'resolvers/audius_resolver.dart';
import 'resolvers/jamendo_resolver.dart';

/// Orchestrates all resolvers.
/// For each DecodedTrack it:
///   1. Tries resolvers in priority order
///   2. Picks the highest-scoring result above threshold
///   3. Saves the resolved URL into the local DB
///   4. Returns a ResolvedTrack
class TrackResolverService {
  final TrackDao          _trackDao;
  final YoutubeResolver   _youtube;
  final SoundCloudResolver _soundcloud;
  final AudiusResolver    _audius;
  final JamendoResolver   _jamendo;
  final _uuid = const Uuid();

  /// Resolver priority — configurable later via settings
  static const _priority = [
    _Source.youtube,
    _Source.soundcloud,
    _Source.audius,
    _Source.jamendo,
  ];

  TrackResolverService({
    required AppDatabase db,
    YoutubeResolver?    youtube,
    SoundCloudResolver? soundcloud,
    AudiusResolver?     audius,
    JamendoResolver?    jamendo,
  })  : _trackDao   = TrackDao(db),
        _youtube    = youtube    ?? YoutubeResolver(),
        _soundcloud = soundcloud ?? SoundCloudResolver(),
        _audius     = audius     ?? AudiusResolver(),
        _jamendo    = jamendo    ?? JamendoResolver();

  /// Resolve a single track.
  /// Inserts or updates the track in the DB and returns
  /// a [ResolvedTrack] — or null if nothing was found.
  Future<ResolvedTrack?> resolve(
    DecodedTrack decoded, {
    String? existingTrackId,
  }) async {
    // update DB status to resolving
    final trackId = existingTrackId ?? _uuid.v4();
    await _upsertTrack(decoded, trackId, DownloadStatus.resolving);

    ResolverResult? best;

    for (final source in _priority) {
      final result = await _tryResolver(source, decoded);
      if (result == null) continue;

      // if current result is better than previous best, replace
      if (best == null || result.score > best.score) {
        best = result;
      }

      // score high enough — no need to try other resolvers
      if (best.score >= 0.90) break;
    }

    if (best == null) {
      // nothing found — mark as failed
      await _trackDao.markFailed(trackId);
      return null;
    }

    // persist resolved URL
    await _trackDao.patch(trackId, {
      'resolved_url':   best.streamUrl,
      'download_status': DownloadStatus.pending.name,
    });

    return ResolvedTrack(
      trackId:            trackId,
      resolvedUrl:        best.streamUrl,
      resolvedFrom:       best.resolvedFrom,
      score:              best.score,
      resolvedTitle:      best.resolvedTitle,
      resolvedArtist:     best.resolvedArtist,
      resolvedDurationMs: best.resolvedDurationMs,
    );
  }

  /// Resolve a batch — used when user imports a full playlist.
  /// Emits progress via the [onProgress] callback.
  Future<List<ResolvedTrack>> resolveAll(
    List<DecodedTrack> tracks, {
    void Function(int done, int total)? onProgress,
  }) async {
    final results = <ResolvedTrack>[];

    for (var i = 0; i < tracks.length; i++) {
      final resolved = await resolve(tracks[i]);
      if (resolved != null) results.add(resolved);
      onProgress?.call(i + 1, tracks.length);
    }

    return results;
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<ResolverResult?> _tryResolver(
      _Source source, DecodedTrack track) async {
    switch (source) {
      case _Source.youtube:
        return _youtube.resolve(track);
      case _Source.soundcloud:
        return _soundcloud.resolve(track);
      case _Source.audius:
        return _audius.resolve(track);
      case _Source.jamendo:
        return _jamendo.resolve(track);
    }
  }

  Future<void> _upsertTrack(
    DecodedTrack decoded,
    String trackId,
    DownloadStatus status,
  ) async {
    final existing = await _trackDao.findById(trackId);
    if (existing != null) {
      await _trackDao.patch(trackId, {
        'download_status': status.name,
      });
      return;
    }

    await _trackDao.insert(Track(
      id:             trackId,
      title:          decoded.title,
      artist:         decoded.artist,
      album:          decoded.album,
      genre:          decoded.genre,
      year:           decoded.year,
      durationMs:     decoded.durationMs,
      trackNumber:    decoded.trackNumber,
      artworkUrl:     decoded.artworkUrl,
      source:         decoded.source,
      sourceId:       decoded.sourceId,
      downloadStatus: status,
      addedAt:        DateTime.now(),
    ));
  }
}

enum _Source { youtube, soundcloud, audius, jamendo }
