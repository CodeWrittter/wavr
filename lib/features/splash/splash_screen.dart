import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../data/database/app_database.dart';
import '../../core/utils/seed_data.dart';
import '../../data/database/daos/track_dao.dart';
import '../../data/models/track.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class SplashScreen extends StatefulWidget {
  final Widget      child;
  final AppDatabase db;
  const SplashScreen({super.key, required this.child, required this.db});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _waveCtrl;
  late final Animation<double>   _fade;
  late final Animation<double>   _slideUp;

  bool _showSplash      = false;
  bool _ready           = false;
  bool   _scanning      = false;
  String _scanStatus    = '';
  // int    _scannedCount  = 0;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    );
    _waveCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _fade = CurvedAnimation(
      parent: _fadeCtrl,
      curve:  Curves.easeOut,
    );
    _slideUp = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic),
    );

    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs      = await SharedPreferences.getInstance();
    final splashSeen = prefs.getBool('splash_seen') ?? false;

    if (!splashSeen) {
      setState(() => _showSplash = true);
      await _fadeCtrl.forward();
    } else {
      // not first launch — check if scan was done
      final scanDone = prefs.getBool('scan_done') ?? false;
      if (!scanDone) {
        await _runScan();
      }
      setState(() => _ready = true);
    }
  }

 Future<void> _onGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('splash_seen', true);

    // request permission then scan
    await _runScan();

    await _fadeCtrl.reverse();
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _runScan() async {
    setState(() {
      _scanning     = true;
      _scanStatus   = 'Requesting permission…';
      // _scannedCount = 0;
    });

    await SeedData.requestStoragePermission();

    setState(() => _scanStatus = 'Scanning device for music…');

    await SeedData.seedTestTrack(widget.db);

    final files = await SeedData.scanWholeStorage(
      onProgress: (count, current) {
        if (mounted) { setState(() {
          // _scannedCount = count;
          _scanStatus   = 'Found $count tracks…';
        }); }
      },
    );

    if (files.isNotEmpty) {
      setState(() => _scanStatus = 'Saving ${files.length} tracks…');
      final dao = TrackDao(widget.db);
      for (final path in files) {
        final name = p.basenameWithoutExtension(path);
        await dao.insert(Track(
          id:             const Uuid().v4(),
          title:          name,
          artist:         'Unknown',
          source:         TrackSource.local,
          localFilePath:  path,
          downloadStatus: DownloadStatus.done,
          addedAt:        DateTime.now(),
        ));
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('scan_done', true);

    setState(() {
      _scanning   = false;
      _scanStatus = '';
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.child;
    if (!_showSplash) {
      return const Scaffold(backgroundColor: AppColors.background);
    }
    return _buildSplash(context);
  }

  Widget _buildSplash(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:          Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fade,
        child: AnimatedBuilder(
          animation: _slideUp,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, _slideUp.value),
            child:  child,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Top section: logo ──────────────────────────────────
                const Spacer(flex: 2),
                _buildLogo(),
                const SizedBox(height: 8),
                const Text(
                  'WAVR',
                  style: TextStyle(
                    fontFamily:    AppFonts.outfit,
                    fontSize:      42,
                    fontWeight:    FontWeight.w900,
                    letterSpacing: 8,
                    color:         Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'YOUR MUSIC. YOUR WAY.',
                  style: TextStyle(
                    fontFamily:    AppFonts.jetbrainsMono,
                    fontSize:      11,
                    letterSpacing: 3,
                    color:         Colors.white.withValues(alpha: 0.45),
                  ),
                ),
                const Spacer(flex: 2),

                // ── Wave animation ─────────────────────────────────────
                SizedBox(
                  height: 120,
                  child: AnimatedBuilder(
                    animation: _waveCtrl,
                    builder:  (_, _) => CustomPaint(
                      painter: _WavePainter(progress: _waveCtrl.value),
                      size:    const Size(double.infinity, 120),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // ── Headline ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: AppFonts.outfit,
                        fontSize:   28,
                        fontWeight: FontWeight.w800,
                        height:     1.3,
                        color:      Colors.white,
                      ),
                      children: [
                        const TextSpan(text: 'All your music,\n'),
                        TextSpan(
                          text:  'offline ',
                          style: TextStyle(color: AppColors.theme),
                        ),
                        const TextSpan(text: 'and in '),
                        TextSpan(
                          text:  'sync.',
                          style: TextStyle(color: AppColors.theme),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'Import, resolve, download and play your\n'
                    'favorite tracks. Anytime, anywhere.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.outfit,
                      fontSize:   14,
                      height:     1.6,
                      color:      Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // ── Feature icons ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _FeatureItem(
                        icon:  Icons.download_rounded,
                        label: 'Download\nfor offline',
                      ),
                      _FeatureItem(
                        icon:  Icons.music_note_rounded,
                        label: 'High Quality\naudio',
                      ),
                      _FeatureItem(
                        icon:  Icons.cloud_off_rounded,
                        label: 'Offline First\nexperience',
                      ),
                      _FeatureItem(
                        icon:  Icons.verified_user_outlined,
                        label: 'Private &\nSecure',
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                if (_scanning) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        const SizedBox(
                          width:  24,
                          height: 24,
                          child:  CircularProgressIndicator(
                            color:       AppColors.theme,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _scanStatus,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppFonts.jetbrainsMono,
                            fontSize:   11,
                            color:      Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── CTA button ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: _scanning ? null : _onGetStarted,
                    child: Container(
                      width:  double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.theme,
                            AppColors.theme.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:      AppColors.theme.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset:     const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Let's get started",
                            style: TextStyle(
                              fontFamily: AppFonts.outfit,
                              fontSize:   16,
                              fontWeight: FontWeight.w800,
                              color:      AppColors.surfaceDeep,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.surfaceDeep,
                            size:  20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Terms ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: AppFonts.jetbrainsMono,
                        fontSize:   11,
                        color:      Colors.white.withValues(alpha: 0.3),
                      ),
                      children: [
                        const TextSpan(
                            text: 'By continuing, you agree to our\n'),
                        TextSpan(
                          text:  'Terms of Service',
                          style: TextStyle(
                            color:      AppColors.theme,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text:  'Privacy Policy',
                          style: TextStyle(
                            color:      AppColors.theme,
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width:  100,
      height: 80,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

// ── W logo painter ─────────────────────────────────────────────────────────

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeJoin  = StrokeJoin.round
      ..strokeCap   = StrokeCap.round
      ..shader = LinearGradient(
        begin:  Alignment.topLeft,
        end:    Alignment.bottomRight,
        colors: [
          AppColors.theme,
          AppColors.theme.withValues(alpha: 0.6),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final w = size.width;
    final h = size.height;

    // W shape made of two V shapes
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.2, h)
      ..lineTo(w * 0.4, h * 0.35)
      ..lineTo(w * 0.5, h * 0.6)
      ..lineTo(w * 0.6, h * 0.35)
      ..lineTo(w * 0.8, h)
      ..lineTo(w, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LogoPainter old) => false;
}

// ── Wave painter ───────────────────────────────────────────────────────────

class _WavePainter extends CustomPainter {
  final double progress;
  _WavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // draw 3 wave layers with different opacities and offsets
    _drawWave(canvas, size,
      amplitude:  22,
      frequency:  1.5,
      phase:      progress * 2 * math.pi,
      opacity:    0.9,
      yOffset:    h * 0.5,
    );
    _drawWave(canvas, size,
      amplitude:  14,
      frequency:  2.2,
      phase:      progress * 2 * math.pi + 1.2,
      opacity:    0.5,
      yOffset:    h * 0.45,
    );
    _drawWave(canvas, size,
      amplitude:  8,
      frequency:  3.0,
      phase:      progress * 2 * math.pi + 2.4,
      opacity:    0.25,
      yOffset:    h * 0.55,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size   size, {
    required double amplitude,
    required double frequency,
    required double phase,
    required double opacity,
    required double yOffset,
  }) {
    final paint = Paint()
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = LinearGradient(
        colors: [
          AppColors.theme.withValues(alpha: 0),
          AppColors.theme.withValues(alpha: opacity),
          AppColors.theme.withValues(alpha: opacity * 0.7),
          AppColors.theme.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final path = Path();
    final steps = size.width.toInt() + 1;

    for (var i = 0; i <= steps; i++) {
      final x = i.toDouble();
      final y = yOffset +
          amplitude *
              math.sin(
                (x / size.width) * frequency * 2 * math.pi + phase,
              );
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}

// ── Feature item ───────────────────────────────────────────────────────────

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String   label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width:  56,
          height: 56,
          decoration: BoxDecoration(
            color:        Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.7),
            size:  24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.outfit,
            fontSize:   11,
            height:     1.4,
            color:      Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
