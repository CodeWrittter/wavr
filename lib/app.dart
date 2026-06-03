import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'shared/widgets/app_bottom_nav.dart';
import 'shared/widgets/offline_snackbar.dart';
import 'features/library/library_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';

class WavrApp extends StatelessWidget {
  final AppDatabase db;
  const WavrApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                      'Wavr',
      debugShowCheckedModeBanner: false,
      theme:                      AppTheme.dark,
      home: SplashScreen(
        db:    db,
        child: const _AppShell(),
      ),
    );
  }
}

class _AppShell extends ConsumerWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:           Colors.transparent,
        statusBarIconBrightness:  Brightness.light,
        systemNavigationBarColor: Color(0xFF0F0F1A),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
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
            const Positioned(
              bottom: 80,
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
