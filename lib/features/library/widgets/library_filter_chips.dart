import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/library_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

class LibraryFilterChips extends ConsumerWidget {
  const LibraryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(libraryFilterProvider);

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: LibraryFilter.values.map((f) {
          final isActive = f == active;
          return GestureDetector(
            onTap: () =>
                ref.read(libraryFilterProvider.notifier).set(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.theme
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: isActive
                    ? null
                    : Border.all(
                        color: Colors.white.withValues(alpha:  0.07)),
              ),
              child: Text(
                _label(f),
                style: TextStyle(
                  fontFamily: AppFonts.outfit,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppColors.surfaceDeep
                      : Colors.white.withValues(alpha:  0.55),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(LibraryFilter f) => switch (f) {
        LibraryFilter.all       => 'All',
        LibraryFilter.playlists => 'Playlists',
        LibraryFilter.albums    => 'Albums',
        LibraryFilter.artists   => 'Artists',
        LibraryFilter.local     => 'Local',
      };
}
