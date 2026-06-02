import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;
  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<double>   _scale;

  bool _showSplash = false;
  bool _ready      = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs      = await SharedPreferences.getInstance();
    final splashSeen = prefs.getBool('splash_seen') ?? false;

    if (!splashSeen) {
      setState(() => _showSplash = true);
      await _ctrl.forward();
      await Future.delayed(const Duration(milliseconds: 1800));
      await _ctrl.reverse();
      await prefs.setBool('splash_seen', true);
    }

    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return _showSplash ? _buildSplash() : _buildBlank();
    }
    if (_showSplash && _ctrl.isAnimating) return _buildSplash();
    return widget.child;
  }

  Widget _buildBlank() => const Scaffold(
    backgroundColor: AppColors.background,
  );

  Widget _buildSplash() => Scaffold(
    backgroundColor: AppColors.background,
    body: FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // app icon
              Container(
                width:  100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.theme.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppColors.theme.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Text('🎵', style: TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'wavr',
                style: TextStyle(
                  fontFamily:    AppFonts.outfit,
                  fontSize:      36,
                  fontWeight:    FontWeight.w900,
                  letterSpacing: -1,
                  color:         Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'your music, offline.',
                style: TextStyle(
                  fontFamily: AppFonts.jetbrainsMono,
                  fontSize:   13,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
