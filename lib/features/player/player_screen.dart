import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/player_provider.dart';
import 'widgets/full_player.dart';
import '../../core/theme/app_fonts.dart';

/// Pushed as a full-screen route when the mini player is tapped.
/// Acts as a thin shell — all state and UI live in [FullPlayerSheet].
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(currentTrackProvider);

    // nothing playing — shouldn't normally be reachable
    if (track == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF080810),
        body: Center(
          child: Text(
            'Nothing playing',
            style: TextStyle(
              fontFamily: AppFonts.outfit,
              color:      Colors.white38,
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      backgroundColor: Color(0xFF080810),
      body: FullPlayerSheet(),
    );
  }
}
