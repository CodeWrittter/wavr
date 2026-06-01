import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../player/widgets/mini_player.dart';
import '../player/providers/player_provider.dart';
import 'providers/search_provider.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/recent_search_item.dart';
import 'widgets/browse_category_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query         = ref.watch(searchQueryProvider);
    final results       = ref.watch(searchResultsProvider);
    final recentSearches = ref.watch(recentSearchesProvider);

    return Column(
      children: [
        // header + search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Search',
                style: TextStyle(
                  fontFamily: AppFonts.outfit,
                  fontSize:   26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color:      Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              SearchBarWidget(
                onChanged: (q) {
                  ref.read(searchQueryProvider.notifier).set(q);
                },
                onSubmit: () {
                  final q = ref.read(searchQueryProvider);
                  if (q.trim().isNotEmpty) {
                    ref.read(recentSearchesProvider.notifier).add(q);
                  }
                },
              ),
            ],
          ),
        ),

        // body
        Expanded(
          child: query.trim().isEmpty
              ? _IdleBody(recentSearches: recentSearches)
              : _ResultsBody(results: results),
        ),

        // mini player — visible on search
        const MiniPlayer(),
      ],
    );
  }
}

// ── Idle body (no query typed yet) ────────────────────────────────────────

class _IdleBody extends ConsumerWidget {
  final AsyncValue<List<String>> recentSearches;
  const _IdleBody({required this.recentSearches});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [

        // ── Recent searches ──────────────────────────────────────────────
        recentSearches.when(
          data: (searches) {
            if (searches.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 4, 24, 12),
                  child: Text(
                    'Recent searches',
                    style: TextStyle(
                      fontFamily: AppFonts.outfit,
                      fontSize:   16,
                      fontWeight: FontWeight.w800,
                      color:      Colors.white,
                    ),
                  ),
                ),
                ...searches.map(
                  (q) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 2),
                    child: RecentSearchItem(
                      query:    q,
                      onTap: () {
                        ref
                            .read(searchQueryProvider.notifier)
                            .set(q);
                        ref
                            .read(recentSearchesProvider.notifier)
                            .add(q);
                      },
                      onRemove: () => ref
                          .read(recentSearchesProvider.notifier)
                          .remove(q),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error:   (_, __) => const SizedBox.shrink(),
        ),

        // ── Browse categories ─────────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 14),
          child: Text(
            'Browse categories',
            style: TextStyle(
              fontFamily: AppFonts.outfit,
              fontSize:   16,
              fontWeight: FontWeight.w800,
              color:      Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.count(
            crossAxisCount:    2,
            crossAxisSpacing:  10,
            mainAxisSpacing:   10,
            childAspectRatio:  1.6,
            shrinkWrap:        true,
            physics: const NeverScrollableScrollPhysics(),
            children: _categories.map((c) => BrowseCategoryCard(
              label:  c.label,
              emoji:  c.emoji,
              color1: c.color1,
              color2: c.color2,
              onTap:  () => _onCategoryTap(context, ref, c.label),
            )).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _onCategoryTap(
      BuildContext context, WidgetRef ref, String category) {
        ref.read(searchQueryProvider.notifier).set(category);
        // ref.read(searchQueryProvider.notifier).state = category;
  }
}

// ── Results body (query active) ────────────────────────────────────────────

class _ResultsBody extends ConsumerWidget {
  final AsyncValue results;
  const _ResultsBody({required this.results});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return results.when(
      data: (tracks) {
        if (tracks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  color: Colors.white.withValues(alpha:  0.15),
                  size: 52,
                ),
                const SizedBox(height: 14),
                Text(
                  'No results found',
                  style: TextStyle(
                    fontFamily: AppFonts.outfit,
                    fontSize:   15,
                    color: Colors.white.withValues(alpha:  0.3),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tracks.length,
          itemBuilder: (_, i) {
            final track = tracks[i];
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: Stack(
                children: [
                  Container(
                    width:  46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: track.artworkLocalPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              track.artworkLocalPath,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.music_note_rounded,
                            color: Colors.white.withValues(alpha:  0.3),
                            size: 20,
                          ),
                  ),
                  // green badge if downloaded
                  if (track.downloadStatus.name == 'done')
                    Positioned(
                      bottom: 0,
                      right:  0,
                      child: Container(
                        width:  14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.theme3,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size:  9,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                track.title,
                style: const TextStyle(
                  fontFamily: AppFonts.outfit,
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color:      Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                track.artist,
                style: TextStyle(
                  fontFamily: AppFonts.jetbrainsMono,
                  fontSize:   11,
                  color: Colors.white.withValues(alpha:  0.4),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Icon(
                Icons.more_vert_rounded,
                color: Colors.white.withValues(alpha:  0.3),
                size: 18,
              ),
              onTap: () => ref
                  .read(playerProvider.notifier)
                  .play(track),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.theme,
          strokeWidth: 2,
        ),
      ),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

// ── Category data ──────────────────────────────────────────────────────────

class _Category {
  final String label;
  final String emoji;
  final Color  color1;
  final Color  color2;
  const _Category({
    required this.label,
    required this.emoji,
    required this.color1,
    required this.color2,
  });
}

const _categories = [
  _Category(
    label:  'Afrobeats',
    emoji:  '🌍',
    color1: AppColors.catAfroFrom,
    color2: AppColors.catAfroTo,
  ),
  _Category(
    label:  'Hip-Hop',
    emoji:  '🎸',
    color1: AppColors.catHipHopFrom,
    color2: AppColors.catHipHopTo,
  ),
  _Category(
    label:  'R&B',
    emoji:  '❤️',
    color1: AppColors.catRnbFrom,
    color2: AppColors.catRnbTo,
  ),
  _Category(
    label:  'Pop',
    emoji:  '🎉',
    color1: AppColors.catPopFrom,
    color2: AppColors.catPopTo,
  ),
  _Category(
    label:  'Chill',
    emoji:  '🌊',
    color1: AppColors.catChillFrom,
    color2: AppColors.catChillTo,
  ),
  _Category(
    label:  'Trending',
    emoji:  '🔥',
    color1: AppColors.catTrendingFrom,
    color2: AppColors.catTrendingTo,
  ),
];
