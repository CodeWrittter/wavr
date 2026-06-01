import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

// ── Lyrics line model ──────────────────────────────────────────────────────

class LyricLine {
  final Duration timestamp;
  final String   text;
  const LyricLine({required this.timestamp, required this.text});
}

// ── Compact lyrics panel (inside player screen) ────────────────────────────

class LyricsPanelWidget extends ConsumerWidget {
  final List<LyricLine> lines;
  final VoidCallback    onExpand;

  const LyricsPanelWidget({
    super.key,
    required this.lines,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position    = ref.watch(playerProvider).position;
    final activeIndex = _activeIndex(position);

    return GestureDetector(
      onTap: onExpand,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Row(
              children: [
                Text(
                  'Lyrics · Tap to expand',
                  style: TextStyle(
                    fontFamily: AppFonts.outfit,
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withOpacity(0.4),
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // show 5 lines centered around active
            ..._visibleLines(activeIndex).map((entry) {
              final isActive = entry.key == activeIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  entry.value.text,
                  style: TextStyle(
                    fontFamily: AppFonts.outfit,
                    fontSize: isActive ? 16 : 14,
                    fontWeight: isActive
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.35),
                    height: 1.4,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  int _activeIndex(Duration position) {
    if (lines.isEmpty) return 0;
    int active = 0;
    for (var i = 0; i < lines.length; i++) {
      if (position >= lines[i].timestamp) active = i;
    }
    return active;
  }

  List<MapEntry<int, LyricLine>> _visibleLines(int active) {
    final start = (active - 1).clamp(0, lines.length - 1);
    final end   = (active + 4).clamp(0, lines.length);
    return lines
        .asMap()
        .entries
        .toList()
        .sublist(start, end);
  }
}

// ── Full screen lyrics overlay ─────────────────────────────────────────────

class LyricsFullScreen extends ConsumerStatefulWidget {
  final List<LyricLine> lines;
  final String          trackTitle;
  final String          artistName;

  const LyricsFullScreen({
    super.key,
    required this.lines,
    required this.trackTitle,
    required this.artistName,
  });

  @override
  ConsumerState<LyricsFullScreen> createState() => _LyricsFullScreenState();
}

class _LyricsFullScreenState extends ConsumerState<LyricsFullScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset>   _slideAnim;
  final ScrollController         _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final position    = ref.watch(playerProvider).position;
    final activeIndex = _activeIndex(position);

    // auto-scroll to active line
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll(activeIndex);
    });

    return GestureDetector(
      onTap: _dismiss,
      onVerticalDragEnd: (d) {
        if (d.primaryVelocity != null && d.primaryVelocity! > 300) {
          _dismiss();
        }
      },
      child: SlideTransition(
        position: _slideAnim,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.nearBlackBlue,
                  AppColors.nearBlackViolet,
                  AppColors.background,
                ],
              ),
            ),
            child: Stack(
              children: [
                // blurred background glow
                Positioned.fill(
                  child: CustomPaint(painter: _GlowPainter()),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      // header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Row(
                          children: [
                            const Spacer(),
                            Column(
                              children: [
                                Text(
                                  widget.trackTitle,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.outfit,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.artistName,
                                  style: TextStyle(
                                    fontFamily: AppFonts.jetbrainsMono,
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.45),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: _dismiss,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // lyrics list
                      Expanded(
                        child: ListView.builder(
                          controller:  _scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(28, 40, 28, 80),
                          itemCount: widget.lines.length,
                          itemBuilder: (_, i) {
                            final isPast   = i < activeIndex;
                            final isActive = i == activeIndex;
                            final isFuture = i > activeIndex;

                            return AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              style: TextStyle(
                                fontFamily: AppFonts.outfit,
                                fontSize: isActive ? 26 : 18,
                                fontWeight: isActive
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isActive
                                    ? Colors.white
                                    : isFuture
                                        ? Colors.white.withOpacity(0.25)
                                        : Colors.white.withOpacity(0.35),
                                height: 1.4,
                                letterSpacing: isActive ? -0.3 : 0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: Text(widget.lines[i].text),
                              ),
                            );
                          },
                        ),
                      ),

                      // footer hint
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          'Tap anywhere to minimize · Cached for offline ✓',
                          style: TextStyle(
                            fontFamily: AppFonts.jetbrainsMono,
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                      ),
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

  int _activeIndex(Duration position) {
    if (widget.lines.isEmpty) return 0;
    int active = 0;
    for (var i = 0; i < widget.lines.length; i++) {
      if (position >= widget.lines[i].timestamp) active = i;
    }
    return active;
  }

  void _autoScroll(int activeIndex) {
    if (!_scrollCtrl.hasClients) return;
    const itemHeight = 60.0;
    final offset = (activeIndex * itemHeight) -
        (_scrollCtrl.position.viewportDimension / 2) +
        itemHeight;
    _scrollCtrl.animateTo(
      offset.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }
}

// ── Background glow painter ────────────────────────────────────────────────

class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    // top-left purple glow
    paint.color = AppColors.glowViolet.withOpacity(0.4);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.25),
      120,
      paint,
    );

    // bottom-right subtle glow
    paint.color = AppColors.deepViolet.withOpacity(0.3);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.6),
      100,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => false;
}
