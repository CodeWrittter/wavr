import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';

enum AudioQuality { low, medium, high }

class SettingsRepository {
  static const _keyQuality    = 'audio_quality';
  static const _keyCrossfade  = 'crossfade_seconds';
  static const _keyNormalize  = 'normalize_volume';
  static const _keyEq         = 'equalizer_enabled';
  static const _keyAnimArt    = 'animated_artwork';
  static const _keyTheme      = 'theme';
  static const _keyAccent     = 'accent_color';
  static const _keyResolverOrder = 'resolver_order';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ── Audio ─────────────────────────────────────────────────────────────────

  Future<AudioQuality> getAudioQuality() async {
    final p = await _prefs;
    final v = p.getString(_keyQuality) ?? AudioQuality.high.name;
    return AudioQuality.values.byName(v);
  }

  Future<void> setAudioQuality(AudioQuality q) async {
    final p = await _prefs;
    await p.setString(_keyQuality, q.name);
  }

  Future<int> getCrossfadeSeconds() async {
    final p = await _prefs;
    return p.getInt(_keyCrossfade) ?? 3;
  }

  Future<void> setCrossfadeSeconds(int s) async {
    final p = await _prefs;
    await p.setInt(_keyCrossfade, s);
  }

  Future<bool> getNormalizeVolume() async {
    final p = await _prefs;
    return p.getBool(_keyNormalize) ?? true;
  }

  Future<void> setNormalizeVolume(bool v) async {
    final p = await _prefs;
    await p.setBool(_keyNormalize, v);
  }

  Future<bool> getEqualizerEnabled() async {
    final p = await _prefs;
    return p.getBool(_keyEq) ?? false;
  }

  Future<void> setEqualizerEnabled(bool v) async {
    final p = await _prefs;
    await p.setBool(_keyEq, v);
  }

  // ── Appearance ────────────────────────────────────────────────────────────

  Future<bool> getAnimatedArtwork() async {
    final p = await _prefs;
    return p.getBool(_keyAnimArt) ?? true;
  }

  Future<void> setAnimatedArtwork(bool v) async {
    final p = await _prefs;
    await p.setBool(_keyAnimArt, v);
  }

  Future<String> getTheme() async {
    final p = await _prefs;
    return p.getString(_keyTheme) ?? 'dark';
  }

  Future<void> setTheme(String theme) async {
    final p = await _prefs;
    await p.setString(_keyTheme, theme);
  }

  Future<int> getAccentColor() async {
    final p = await _prefs;
    // default: #65ff5a
    return p.getInt(_keyAccent) ?? 0xFFE8FF5A;
  }

  Future<void> setAccentColor(int color) async {
    final p = await _prefs;
    await p.setInt(_keyAccent, color);
  }

  // ── Resolver order ────────────────────────────────────────────────────────

  Future<List<String>> getResolverOrder() async {
    final p = await _prefs;
    return p.getStringList(_keyResolverOrder) ??
        ['youtube', 'soundcloud', 'audius', 'jamendo'];
  }

  Future<void> setResolverOrder(List<String> order) async {
    final p = await _prefs;
    await p.setStringList(_keyResolverOrder, order);
  }
}
