import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';

enum NavTab { library, search, settings }

class NavTabNotifier extends Notifier<NavTab> {
  @override
  NavTab build() => NavTab.library;
  void set(NavTab tab) => state = tab;
}

final activeTabProvider = NotifierProvider<NavTabNotifier, NavTab>(
  NavTabNotifier.new,
);
class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeTabProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha:  0.07)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.folder_outlined,
                iconActive: Icons.folder_rounded,
                label: 'Library',
                tab: NavTab.library,
                active: active,
              ),
              _NavItem(
                icon: Icons.search_rounded,
                iconActive: Icons.search_rounded,
                label: 'Search',
                tab: NavTab.search,
                active: active,
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                iconActive: Icons.settings_rounded,
                label: 'Settings',
                tab: NavTab.settings,
                active: active,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends ConsumerWidget {
  final IconData icon;
  final IconData iconActive;
  final String   label;
  final NavTab   tab;
  final NavTab   active;

  const _NavItem({
    required this.icon,
    required this.iconActive,
    required this.label,
    required this.tab,
    required this.active,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = tab == active;
    const acc = AppColors.theme;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref.read(activeTabProvider.notifier).set(tab),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? iconActive : icon,
              color: isActive ? acc : Colors.white.withValues(alpha:  0.3),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.outfit,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isActive ? acc : Colors.white.withValues(alpha:  0.3),
              ),
            ),
            const SizedBox(height: 4),
            // colored dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width:  isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: const BoxDecoration(
                color: acc,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
