import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/playlist.dart';
import '../../../data/models/track.dart';
import '../../../data/repositories/library_repository.dart';
import '../../../services/download/download_queue.dart';
import '../../../services/download/download_service.dart';
import '../../../services/playlist_decoder/models/decoded_track.dart';
import '../../../services/playlist_decoder/playlist_decoder_service.dart';
import '../../../services/track_resolver/track_resolver_service.dart';
import '../../library/providers/library_provider.dart';

// ── Import status ──────────────────────────────────────────────────────────

enum ImportStep { idle, decoding, resolving, queuing, done, error }

class ImportState {
  final ImportStep step;
  final int        total;
  final int        done;
  final String?    errorMessage;
  final String?    playlistId;   // ID of the saved playlist on success

  const ImportState({
    this.step         = ImportStep.idle,
    this.total        = 0,
    this.done         = 0,
    this.errorMessage,
    this.playlistId,
  });

  ImportState copyWith({
    ImportStep? step,
    int?        total,
    int?        done,
    String?     errorMessage,
    String?     playlistId,
  }) =>
      ImportState(
        step:         step         ?? this.step,
        total:        total        ?? this.total,
        done:         done         ?? this.done,
        errorMessage: errorMessage ?? this.errorMessage,
        playlistId:   playlistId   ?? this.playlistId,
      );

  double get progress => total == 0 ? 0 : done / total;
}

// ── Services ───────────────────────────────────────────────────────────────

final playlistDecoderServiceProvider = Provider<PlaylistDecoderService>(
  (_) => PlaylistDecoderService(),
);

final trackResolverServiceProvider = Provider<TrackResolverService>((ref) {
  final db = ref.read(appDatabaseProvider);
  return TrackResolverService(db: db);
});

final downloadQueueProvider = Provider<DownloadQueue>((ref) {
  final db = ref.read(appDatabaseProvider);
  return DownloadQueue(db: db);
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  final db    = ref.read(appDatabaseProvider);
  final queue = ref.read(downloadQueueProvider);
  return DownloadService(db: db, queue: queue);
});

// ── Import notifier ────────────────────────────────────────────────────────

class ImportNotifier extends Notifier<ImportState> {
  final _uuid = const Uuid();

  @override
  ImportState build() => const ImportState();

  Future<void> importFromUrl(String url) async {
    state = const ImportState(step: ImportStep.decoding);

    try {
      // 1 — decode playlist metadata
      final decoder = ref.read(playlistDecoderServiceProvider);
      final decoded = await decoder.decode(url);

      if (decoded.isEmpty) {
        state = state.copyWith(
          step: ImportStep.error,
          errorMessage: 'No tracks found at this URL.',
        );
        return;
      }

      await _resolveAndSave(decoded, sourceUrl: url);
    } catch (e) {
      state = state.copyWith(
        step: ImportStep.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> importFromManualList(List<DecodedTrack> tracks) async {
    if (tracks.isEmpty) return;
    state = ImportState(step: ImportStep.resolving, total: tracks.length);
    await _resolveAndSave(tracks);
  }

  Future<void> _resolveAndSave(
    List<DecodedTrack> decoded, {
    String? sourceUrl,
  }) async {
    state = state.copyWith(
      step:  ImportStep.resolving,
      total: decoded.length,
      done:  0,
    );

    // 2 — resolve each track
    final resolver = ref.read(trackResolverServiceProvider);
    final resolved = await resolver.resolveAll(
      decoded,
      onProgress: (done, total) {
        state = state.copyWith(done: done, total: total);
      },
    );

    state = state.copyWith(step: ImportStep.queuing);

    // 3 — save playlist to DB
    final repo = ref.read(libraryRepositoryProvider);
    final playlistId = _uuid.v4();
    final playlist = Playlist(
      id:        playlistId,
      name:      _inferName(decoded, sourceUrl),
      type:      sourceUrl != null ? PlaylistType.imported : PlaylistType.manual,
      source:    decoded.first.source,
      sourceUrl: sourceUrl,
      trackIds:  resolved.map((r) => r.trackId).toList(),
      totalTracks: decoded.length,
      downloadedTracks: 0,
      createdAt: DateTime.now(),
    );

    await repo.savePlaylist(playlist);
    await repo.setPlaylistTracks(
      playlistId,
      resolved.map((r) => r.trackId).toList(),
    );

    // 4 — queue all downloads
    final downloader = ref.read(downloadServiceProvider);
    await downloader.downloadPlaylist(resolved);

    state = state.copyWith(
      step:       ImportStep.done,
      playlistId: playlistId,
    );

    // invalidate library so it refreshes
    ref.invalidate(allPlaylistsProvider);
    ref.invalidate(allTracksProvider);
  }

  void reset() => state = const ImportState();

  String _inferName(List<DecodedTrack> tracks, String? sourceUrl) {
    if (sourceUrl != null) {
      if (sourceUrl.contains('spotify'))    return 'Spotify Playlist';
      if (sourceUrl.contains('deezer'))     return 'Deezer Playlist';
      if (sourceUrl.contains('apple'))      return 'Apple Music Playlist';
      if (sourceUrl.contains('youtube'))    return 'YouTube Playlist';
      if (sourceUrl.contains('soundcloud')) return 'SoundCloud Playlist';
      if (sourceUrl.contains('audius'))     return 'Audius Playlist';
      if (sourceUrl.contains('jamendo'))    return 'Jamendo Playlist';
      if (sourceUrl.contains('wavr'))       return 'Shared Playlist';
    }
    return 'Manual Playlist';
  }
}

final importProvider = NotifierProvider<ImportNotifier, ImportState>(
  ImportNotifier.new,
);
