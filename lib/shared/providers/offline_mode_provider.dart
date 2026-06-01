import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-toggled offline mode — stored in SharedPreferences
/// so it survives app restarts.
class OfflineModeNotifier extends Notifier<bool> {
  static const _key = 'offline_mode';

  @override
  bool build() {
    // read synchronously — prefs loaded at app start
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    state = !state;
    await prefs.setBool(_key, state);
  }

  Future<void> set(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    state = value;
    await prefs.setBool(_key, value);
  }
}

final offlineModeProvider = NotifierProvider<OfflineModeNotifier, bool>(
  OfflineModeNotifier.new,
);
