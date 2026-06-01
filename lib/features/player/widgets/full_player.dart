import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/player_provider.dart';
import 'waveform_seekbar.dart';
import 'video_overlay.dart';
import 'lyrics_overlay.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import 'package:just_audio/just_audio.dart';

class FullPlayerSheet extends ConsumerStatefulWidget {
  const FullPlayerSheet({super.key});

  @override
  ConsumerState<FullPlayerSheet> createState() => _FullPlayerSheetState();
}

class _FullPlayerSheetState extends ConsumerState<FullPlayerSheet>
    with TickerProviderStateMixin {
  // pulse animation for play button
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulse1;
  late final Animation<double>   _pulse2;

  // slide-down to dismiss
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulse1 = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(
        parent: _pulseCtrl,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
    _pulse2 = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _pulseCtrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _dismiss() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final notifier    = ref.read(playerProvider.notifier);
    final track       = playerState.currentTrack;

    if (track == null) return const SizedBox.shrink();

    return GestureDetector(
      onVerticalDragUpdate: (d) {
        setState(() => _dragOffset = d.primaryDelta! > 0
            ? _dragOffset + d.primaryDelta!
            : 0);
      },
      onVerticalDragEnd: (d) {
        if (_dragOffset > 120 ||
            (d.primaryVelocity != null && d.primaryVelocity! > 600)) {
          _dismiss();
        } else {
          setState(() => _dragOffset = 0);
        }
      },
      child: Transform.translate(
        offset: Offset(0, _dragOffset * 0.4),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // drag handle
                Center(
                  child: GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(top: 14, bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    children: [
                      _IconBtn(
                        icon: Icons.keyboard_arrow_down_rounded,
                        onTap: _dismiss,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'PLAYING FROM',
                              style: TextStyle(
                                fontFamily: AppFonts.outfit,
                                fontSize: 10,
                                letterSpacing: 0.12,
                                color: Colors.white.withOpacity(0.35),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'AfroBeats 2025',
                              style: TextStyle(
                                fontFamily: AppFonts.jetbrainsMono,
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _IconBtn(
                        icon: Icons.more_vert_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                // artwork / video / lyrics panel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        // artwork or waveform viz
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: _ArtworkCanvas(track: track),
                        ),

                        // video FAB + lyrics FAB
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Column(
                            children: [
                              _FabBtn(
                                icon: Icons.play_circle_outline_rounded,
                                active: playerState.videoMode,
                                onTap: () => notifier.toggleVideoMode(),
                              ),
                              const SizedBox(height: 8),
                              _FabBtn(
                                icon: Icons.format_align_left_rounded,
                                active: playerState.lyricsOpen,
                                onTap: () => notifier.toggleLyrics(),
                              ),
                            ],
                          ),
                        ),

                        // video overlay
                        if (playerState.videoMode)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: const VideoOverlay(),
                            ),
                          ),

                        // source tag
                        Positioned(
                          bottom: 14,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.spotify,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'via Spotify',
                                  style: TextStyle(
                                    fontFamily: AppFonts.jetbrainsMono,
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // lyrics compact panel — shown when lyricsOpen
                if (playerState.lyricsOpen && !playerState.videoMode)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: LyricsPanelWidget(
                      lines: _demoLines,
                      onExpand: () => _openFullLyrics(context, track.title,
                          track.artist),
                    ),
                  )
                else ...[
                  // song info + favorite
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                style: const TextStyle(
                                  fontFamily: AppFonts.outfit,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                track.artist,
                                style: TextStyle(
                                  fontFamily: AppFonts.jetbrainsMono,
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            track.isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: AppColors.theme,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // waveform seekbar
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 4),
                  child: const WaveformSeekbar(),
                ),

                // time labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(ref.watch(playerProvider).position),
                        style: TextStyle(
                          fontFamily: AppFonts.jetbrainsMono,
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      Text(
                        _formatDuration(ref.watch(playerProvider).duration),
                        style: TextStyle(
                          fontFamily: AppFonts.jetbrainsMono,
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // controls row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // shuffle
                      _CtrlBtn(
                        icon: Icons.shuffle_rounded,
                        active: playerState.shuffleEnabled,
                        onTap: notifier.toggleShuffle,
                      ),
                      // previous
                      _CtrlBtn(
                        icon: Icons.skip_previous_rounded,
                        onTap: notifier.skipPrevious,
                      ),
                      // play / pause with pulse
                      _PulsePlayBtn(
                        isPlaying: playerState.isPlaying,
                        pulse1:    _pulse1,
                        pulse2:    _pulse2,
                        onTap:     notifier.togglePlayPause,
                      ),
                      // next
                      _CtrlBtn(
                        icon: Icons.skip_next_rounded,
                        onTap: notifier.skipNext,
                      ),
                      // loop
                      _CtrlBtn(
                        icon: _loopIcon(playerState.loopMode),
                        active: playerState.loopMode != LoopMode.off,
                        onTap: notifier.cycleLoopMode,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // extra actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ExtraBtn(icon: Icons.queue_music_rounded,  label: 'Queue'),
                      _ExtraBtn(icon: Icons.share_rounded,         label: 'Share'),
                      _ExtraBtn(icon: Icons.add_rounded,           label: 'Add to'),
                      _ExtraBtn(icon: Icons.music_note_rounded,    label: 'Similar'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openFullLyrics(BuildContext ctx, String title, String artist) {
    Navigator.of(ctx).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => LyricsFullScreen(
          lines:       _demoLines,
          trackTitle:  title,
          artistName:  artist,
        ),
      ),
    );
  }

  IconData _loopIcon(LoopMode mode) => switch (mode) {
        LoopMode.off => Icons.repeat_rounded,
        LoopMode.all => Icons.repeat_rounded,
        LoopMode.one => Icons.repeat_one_rounded,
      };

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // demo lyrics — replaced by real LRC data in production
  static final _demoLines = [
    LyricLine(timestamp: Duration.zero,          text: "I've been alone all night"),
    LyricLine(timestamp: const Duration(seconds: 3),  text: "thinkin' 'bout where I went wrong"),
    LyricLine(timestamp: const Duration(seconds: 7),  text: "I said, ooh, I'm blinded by the lights"),
    LyricLine(timestamp: const Duration(seconds: 13), text: "No, I can't sleep until I feel your touch"),
    LyricLine(timestamp: const Duration(seconds: 17), text: "I said, ooh, I'm drowning in the night"),
    LyricLine(timestamp: const Duration(seconds: 21), text: "Oh, when I'm like this, you're the one I trust"),
  ];
}

// ── Artwork canvas ─────────────────────────────────────────────────────────

class _ArtworkCanvas extends StatefulWidget {
  final dynamic track;
  const _ArtworkCanvas({required this.track});

  @override
  State<_ArtworkCanvas> createState() => _ArtworkCanvasState();
}

class _ArtworkCanvasState extends State<_ArtworkCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _vizCtrl;

  @override
  void initState() {
    super.initState();
    _vizCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _vizCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.deepNavy,
            AppColors.deepViolet,
            AppColors.deepOcean,
            AppColors.deepPurple,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // radial glows
          Positioned.fill(
            child: CustomPaint(painter: _ArtGlowPainter()),
          ),
          // animated waveform bars
          AnimatedBuilder(
            animation: _vizCtrl,
            builder: (_, __) => _WaveformViz(progress: _vizCtrl.value),
          ),
        ],
      ),
    );
  }
}

class _ArtGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..color = AppColors.theme.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(
        Offset(size.width * 0.35, size.height * 0.35), 80, p1);

    final p2 = Paint()
      ..color = AppColors.glowIndigo.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(
        Offset(size.width * 0.65, size.height * 0.65), 100, p2);
  }

  @override
  bool shouldRepaint(_ArtGlowPainter old) => false;
}

class _WaveformViz extends StatelessWidget {
  final double progress;
  const _WaveformViz({required this.progress});

  static const _barCount  = 9;
  static const _baseHeights = [24.0, 60.0, 100.0, 140.0, 160.0,
                                140.0, 100.0, 60.0, 24.0];
  static const _delays = [0.0, 0.1, 0.2, 0.12, 0.06, 0.18, 0.08, 0.22, 0.14];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_barCount, (i) {
        final phase = (progress + _delays[i]) % 1.0;
        final scale = 1.0 + (math.sin(phase * math.pi) * 0.3);
        final opacity = 0.25 + (math.sin(phase * math.pi) * 0.45);
        return Container(
          width: 5,
          height: _baseHeights[i] * scale,
          margin: i < _barCount - 1
              ? const EdgeInsets.only(right: 5)
              : null,
          decoration: BoxDecoration(
            color: AppColors.theme.withOpacity(opacity),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ── Pulse play button ──────────────────────────────────────────────────────

class _PulsePlayBtn extends StatelessWidget {
  final bool                 isPlaying;
  final Animation<double>    pulse1;
  final Animation<double>    pulse2;
  final VoidCallback         onTap;

  const _PulsePlayBtn({
    required this.isPlaying,
    required this.pulse1,
    required this.pulse2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // outer pulse ring
          AnimatedBuilder(
            animation: pulse1,
            builder: (_, __) => Transform.scale(
              scale: pulse1.value,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.theme.withOpacity(
                      (1 - (pulse1.value - 1) / 0.6).clamp(0.0, 0.3),
                    ),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          // inner pulse ring
          AnimatedBuilder(
            animation: pulse2,
            builder: (_, __) => Transform.scale(
              scale: pulse2.value,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.theme.withOpacity(
                      (1 - (pulse2.value - 1) / 0.4).clamp(0.0, 0.15),
                    ),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          // button
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.theme,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.theme.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: AppColors.surfaceDeep,
                size: 34,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small reusable widgets ─────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.55), size: 20),
        ),
      );
}

class _FabBtn extends StatelessWidget {
  final IconData     icon;
  final bool         active;
  final VoidCallback onTap;
  const _FabBtn(
      {required this.icon, this.active = false, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active
                ? AppColors.theme.withOpacity(0.15)
                : Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: active
                  ? AppColors.theme.withOpacity(0.45)
                  : Colors.white.withOpacity(0.15),
            ),
          ),
          child: Icon(
            icon,
            color: active
                ? AppColors.theme
                : Colors.white,
            size: 18,
          ),
        ),
      );
}

class _CtrlBtn extends StatelessWidget {
  final IconData     icon;
  final bool         active;
  final VoidCallback onTap;
  const _CtrlBtn(
      {required this.icon, this.active = false, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: active
                ? AppColors.theme
                : Colors.white.withOpacity(0.55),
            size: 26,
          ),
        ),
      );
}

class _ExtraBtn extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _ExtraBtn({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {},
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.35), size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.jetbrainsMono,
                fontSize: 10,
                color: Colors.white.withOpacity(0.35),
              ),
            ),
          ],
        ),
      );
}
