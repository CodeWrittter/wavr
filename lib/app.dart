import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'shared/widgets/app_bottom_nav.dart';
import 'shared/widgets/offline_snackbar.dart';
import 'features/library/library_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_screen.dart';

class WavrApp extends StatelessWidget {
  const WavrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:        'Wavr',
      debugShowCheckedModeBanner: false,
      theme:        AppTheme.dark,
      home:         const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);

    // lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // transparent status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:           Colors.transparent,
        statusBarIconBrightness:  Brightness.light,
        systemNavigationBarColor: AppColors.surfaceAlt,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── Main content ───────────────────────────────────────────
            Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: activeTab.index,
                    children: const [
                      LibraryScreen(),
                      SearchScreen(),
                      SettingsScreen(),
                    ],
                  ),
                ),
                const AppBottomNav(),
              ],
            ),

            // ── Offline snackbar overlay ───────────────────────────────
            const Positioned(
              bottom: 80, // sits just above the nav bar
              left:   0,
              right:  0,
              child:  OfflineSnackbar(),
            ),
          ],
        ),
      ),
    );
  }
}
