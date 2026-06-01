import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/track.dart';
import '../../../data/repositories/library_repository.dart';
import '../../library/providers/library_provider.dart';

// ── Search query ───────────────────────────────────────────────────────────

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String q) => state = q;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

// ── Search results (searches local DB) ────────────────────────────────────

final searchResultsProvider = FutureProvider<List<Track>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  final repo = ref.read(libraryRepositoryProvider);
  return repo.searchTracks(query);
});

// ── Recent searches ────────────────────────────────────────────────────────

class RecentSearchesNotifier extends AsyncNotifier<List<String>> {
  static const _key      = 'recent_searches';
  static const _maxItems = 10;

  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> add(String query) async {
    if (query.trim().isEmpty) return;
    final prefs   = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];

    // remove duplicate, push to front
    current.remove(query);
    current.insert(0, query);

    final trimmed = current.take(_maxItems).toList();
    await prefs.setStringList(_key, trimmed);
    state = AsyncData(trimmed);
  }

  Future<void> remove(String query) async {
    final prefs   = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    current.remove(query);
    await prefs.setStringList(_key, current);
    state = AsyncData(current);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = const AsyncData([]);
  }
}

final recentSearchesProvider =
    AsyncNotifierProvider<RecentSearchesNotifier, List<String>>(
  RecentSearchesNotifier.new,
);
