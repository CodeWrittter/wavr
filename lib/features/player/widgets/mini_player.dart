import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../player_screen.dart';
import '../providers/player_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final notifier    = ref.read(playerProvider.notifier);
    final track       = playerState.currentTrack;

    if (track == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _openFullPlayer(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha:  0.12)),
        ),
        child: Stack(
          children: [
            // subtle left glow
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.theme.withValues(alpha:  0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // artwork
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.midnightBlue,
                          AppColors.glowViolet,
                          AppColors.deepTealBlue,
                        ],
                      ),
                    ),
                    child: track.artworkLocalPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              track.artworkLocalPath!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _MiniArtworkViz(isPlaying: playerState.isPlaying),

                  ),

                  const SizedBox(width: 12),

                  // title + artist
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          track.title,
                          style: const TextStyle(
                            fontFamily: AppFonts.outfit,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track.artist,
                          style: TextStyle(
                            fontFamily: AppFonts.jetbrainsMono,
                            fontSize: 11,
                            color: Colors.white.withValues(alpha:  0.5),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // pause button
                  _MiniCtrlBtn(
                    icon: playerState.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    onTap: notifier.togglePlayPause,
                    highlight: true,
                  ),

                  // next button
                  _MiniCtrlBtn(
                    icon: Icons.skip_next_rounded,
                    onTap: notifier.skipNext,
                  ),
                ],
              ),
            ),

            // progress bar at bottom
            Positioned(
              bottom: 0,
              left: 0,
              child: LayoutBuilder(
                builder: (ctx, _) => Container(
                  width: MediaQuery.of(context).size.width *
                      playerState.progressFraction *
                      0.92, // account for margins
                  height: 2,
                  decoration: const BoxDecoration(
                    color: AppColors.theme,
                    borderRadius: BorderRadius.only(
                      bottomLeft:  Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullPlayer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => const PlayerScreen(),
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end:   Offset.zero,
          ).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Mini animated bars ─────────────────────────────────────────────────────

class _MiniArtworkViz extends StatefulWidget {
  final bool isPlaying;
  const _MiniArtworkViz({required this.isPlaying});

  @override
  State<_MiniArtworkViz> createState() => _MiniArtworkVizState();
}

class _MiniArtworkVizState extends State<_MiniArtworkViz>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    );
    // start only if playing
    if (widget.isPlaying) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_MiniArtworkViz old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isPlaying && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _bar(8,  0.0),
          const SizedBox(width: 2),
          _bar(16, 0.15),
          const SizedBox(width: 2),
          _bar(12, 0.08),
          const SizedBox(width: 2),
          _bar(18, 0.22),
        ],
      ),
    );
  }

  Widget _bar(double base, double delay) {
    final phase = (_ctrl.value + delay) % 1.0;
    final h = base * (1.0 + math.sin(phase * math.pi) * 0.5);
    return Container(
      width: 3,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.theme.withValues(alpha:  0.6),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _MiniCtrlBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  final bool         highlight;

  const _MiniCtrlBtn({
    required this.icon,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          margin: const EdgeInsets.only(left: 6),
          decoration: BoxDecoration(
            color: highlight
                ? Colors.transparent
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: highlight
                ? Colors.white
                : Colors.white.withValues(alpha:  0.5),
            size: 20,
          ),
        ),
      );
}
