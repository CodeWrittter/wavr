import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../data/models/track.dart';
import '../../../data/repositories/library_repository.dart';
import '../../library/providers/library_provider.dart';

// ── Player state ───────────────────────────────────────────────────────────

class PlayerState {
  final Track?         currentTrack;
  final List<Track>    queue;
  final int            queueIndex;
  final bool           isPlaying;
  final bool           isBuffering;
  final Duration       position;
  final Duration       duration;
  final bool           shuffleEnabled;
  final LoopMode       loopMode;
  final bool           lyricsOpen;
  final bool           videoMode;

  const PlayerState({
    this.currentTrack,
    this.queue          = const [],
    this.queueIndex     = 0,
    this.isPlaying      = false,
    this.isBuffering    = false,
    this.position       = Duration.zero,
    this.duration       = Duration.zero,
    this.shuffleEnabled = false,
    this.loopMode       = LoopMode.off,
    this.lyricsOpen     = false,
    this.videoMode      = false,
  });

  bool get hasTrack     => currentTrack != null;
  bool get hasPrevious  => queueIndex > 0;
  bool get hasNext      => queueIndex < queue.length - 1;

  double get progressFraction =>
      duration.inMilliseconds == 0
          ? 0
          : position.inMilliseconds / duration.inMilliseconds;

  PlayerState copyWith({
    Track?        currentTrack,
    List<Track>?  queue,
    int?          queueIndex,
    bool?         isPlaying,
    bool?         isBuffering,
    Duration?     position,
    Duration?     duration,
    bool?         shuffleEnabled,
    LoopMode?     loopMode,
    bool?         lyricsOpen,
    bool?         videoMode,
  }) =>
      PlayerState(
        currentTrack:   currentTrack   ?? this.currentTrack,
        queue:          queue          ?? this.queue,
        queueIndex:     queueIndex     ?? this.queueIndex,
        isPlaying:      isPlaying      ?? this.isPlaying,
        isBuffering:    isBuffering    ?? this.isBuffering,
        position:       position       ?? this.position,
        duration:       duration       ?? this.duration,
        shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
        loopMode:       loopMode       ?? this.loopMode,
        lyricsOpen:     lyricsOpen     ?? this.lyricsOpen,
        videoMode:      videoMode      ?? this.videoMode,
      );
}

// ── Player notifier ────────────────────────────────────────────────────────

class PlayerNotifier extends Notifier<PlayerState> {
  late final AudioPlayer _player;
  late final Ref _ref;

  @override
  PlayerState build() {
    _ref = ref;
    _player = AudioPlayer();
    _bindStreams();
    ref.onDispose(_player.dispose);
    return const PlayerState();
  }

  void _bindStreams() {
    // position
    _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    // duration
    _player.durationStream.listen((dur) {
      if (dur != null) state = state.copyWith(duration: dur);
    });

    // playing state
    _player.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    // buffering
    _player.processingStateStream.listen((ps) {
      state = state.copyWith(
        isBuffering: ps == ProcessingState.buffering ||
            ps == ProcessingState.loading,
      );
      // auto-advance when track completes
      if (ps == ProcessingState.completed) _onTrackComplete();
    });
  }

  // ── Playback ──────────────────────────────────────────────────────────────

  /// Main entry — called when user taps a track row.
  Future<void> play(Track track, {List<Track>? queue}) async {
    final q     = queue ?? [track];
    final index = q.indexWhere((t) => t.id == track.id);

    state = state.copyWith(
      currentTrack: track,
      queue:        q,
      queueIndex:   index < 0 ? 0 : index,
    );

    final source = _buildAudioSource(track);
    await _player.setAudioSource(source);
    await _player.play();

    // increment play count in DB
    ref.read(libraryRepositoryProvider).incrementPlayCount(track.id);
  }

  Future<void> resume()   => _player.play();
  Future<void> pause()    => _player.pause();

  Future<void> togglePlayPause() async {
    state.isPlaying ? await pause() : await resume();
  }

  Future<void> seekTo(Duration position) => _player.seek(position);

  Future<void> seekToFraction(double fraction) {
    final ms = (state.duration.inMilliseconds * fraction).toInt();
    return seekTo(Duration(milliseconds: ms));
  }

  Future<void> skipNext() async {
    if (!state.hasNext) return;
    final nextIndex = state.queueIndex + 1;
    await play(state.queue[nextIndex], queue: state.queue);
  }

  Future<void> skipPrevious() async {
    // if past 3 seconds, restart current track
    if (state.position.inSeconds > 3) {
      await seekTo(Duration.zero);
      return;
    }
    if (!state.hasPrevious) return;
    final prevIndex = state.queueIndex - 1;
    await play(state.queue[prevIndex], queue: state.queue);
  }

  Future<void> toggleShuffle() async {
    final newVal = !state.shuffleEnabled;
    await _player.setShuffleModeEnabled(newVal);
    state = state.copyWith(shuffleEnabled: newVal);
  }

  Future<void> cycleLoopMode() async {
    final next = switch (state.loopMode) {
      LoopMode.off  => LoopMode.all,
      LoopMode.all  => LoopMode.one,
      LoopMode.one  => LoopMode.off,
    };
    await _player.setLoopMode(next);
    state = state.copyWith(loopMode: next);
  }

  void toggleLyrics() =>
      state = state.copyWith(lyricsOpen: !state.lyricsOpen);

  void toggleVideoMode() =>
      state = state.copyWith(videoMode: !state.videoMode);

  // ── Queue ─────────────────────────────────────────────────────────────────

  void addToQueue(Track track) {
    final updated = [...state.queue, track];
    state = state.copyWith(queue: updated);
  }

  void removeFromQueue(int index) {
    final updated = [...state.queue]..removeAt(index);
    state = state.copyWith(
      queue:      updated,
      queueIndex: state.queueIndex > index
          ? state.queueIndex - 1
          : state.queueIndex,
    );
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  AudioSource _buildAudioSource(Track track) {
    if (track.localFilePath != null) {
      return AudioSource.file(track.localFilePath!);
    }
    // check offline mode
    final offline = _ref.read(offlineModeProvider);
    if (offline) {
      throw Exception('Offline mode — track not downloaded');
    }
    if (track.resolvedUrl != null) {
      return AudioSource.uri(Uri.parse(track.resolvedUrl!));
    }
    throw Exception('No audio source for track: ${track.id}');
  }

  void _onTrackComplete() {
    switch (state.loopMode) {
      case LoopMode.one:
        _player.seek(Duration.zero);
        _player.play();
      case LoopMode.all:
        skipNext();
        if (!state.hasNext) {
          play(state.queue.first, queue: state.queue);
        }
      case LoopMode.off:
        if (state.hasNext) skipNext();
    }
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(
  PlayerNotifier.new,
);

// ── Convenience providers ──────────────────────────────────────────────────

final currentTrackProvider = Provider<Track?>(
  (ref) => ref.watch(playerProvider).currentTrack,
);

final isPlayingProvider = Provider<bool>(
  (ref) => ref.watch(playerProvider).isPlaying,
);

final playerProgressProvider = Provider<double>(
  (ref) => ref.watch(playerProvider).progressFraction,
);
