import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (_) => SettingsRepository(),
);

// ── Audio quality ──────────────────────────────────────────────────────────

class AudioQualityNotifier extends AsyncNotifier<AudioQuality> {
  @override
  Future<AudioQuality> build() =>
      ref.read(settingsRepositoryProvider).getAudioQuality();

  Future<void> set(AudioQuality q) async {
    await ref.read(settingsRepositoryProvider).setAudioQuality(q);
    state = AsyncData(q);
  }
}

final audioQualityProvider =
    AsyncNotifierProvider<AudioQualityNotifier, AudioQuality>(
  AudioQualityNotifier.new,
);

// ── Crossfade ──────────────────────────────────────────────────────────────

class CrossfadeNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() =>
      ref.read(settingsRepositoryProvider).getCrossfadeSeconds();

  Future<void> set(int seconds) async {
    await ref.read(settingsRepositoryProvider).setCrossfadeSeconds(seconds);
    state = AsyncData(seconds);
  }
}

final crossfadeProvider = AsyncNotifierProvider<CrossfadeNotifier, int>(
  CrossfadeNotifier.new,
);

// ── Normalize volume ───────────────────────────────────────────────────────

class NormalizeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.read(settingsRepositoryProvider).getNormalizeVolume();

  Future<void> toggle() async {
    final current = state.value ?? true;
    await ref
        .read(settingsRepositoryProvider)
        .setNormalizeVolume(!current);
    state = AsyncData(!current);
  }
}

final normalizeProvider = AsyncNotifierProvider<NormalizeNotifier, bool>(
  NormalizeNotifier.new,
);

// ── Equalizer ──────────────────────────────────────────────────────────────

class EqualizerNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.read(settingsRepositoryProvider).getEqualizerEnabled();

  Future<void> toggle() async {
    final current = state.value ?? false;
    await ref
        .read(settingsRepositoryProvider)
        .setEqualizerEnabled(!current);
    state = AsyncData(!current);
  }
}

final equalizerProvider = AsyncNotifierProvider<EqualizerNotifier, bool>(
  EqualizerNotifier.new,
);

// ── Animated artwork ───────────────────────────────────────────────────────

class AnimatedArtworkNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.read(settingsRepositoryProvider).getAnimatedArtwork();

  Future<void> toggle() async {
    final current = state.value ?? true;
    await ref
        .read(settingsRepositoryProvider)
        .setAnimatedArtwork(!current);
    state = AsyncData(!current);
  }
}

final animatedArtworkProvider =
    AsyncNotifierProvider<AnimatedArtworkNotifier, bool>(
  AnimatedArtworkNotifier.new,
);

// ── Accent color ───────────────────────────────────────────────────────────

class AccentColorNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() =>
      ref.read(settingsRepositoryProvider).getAccentColor();

  Future<void> set(int color) async {
    await ref.read(settingsRepositoryProvider).setAccentColor(color);
    state = AsyncData(color);
  }
}

final accentColorProvider = AsyncNotifierProvider<AccentColorNotifier, int>(
  AccentColorNotifier.new,
);
