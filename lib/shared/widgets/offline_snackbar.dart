import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/connectivity_provider.dart';
import '../../shared/providers/offline_mode_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';

class OfflineSnackbar extends ConsumerStatefulWidget {
  const OfflineSnackbar({super.key});

  @override
  ConsumerState<OfflineSnackbar> createState() =>
      _OfflineSnackbarState();
}

class _OfflineSnackbarState extends ConsumerState<OfflineSnackbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset>   _slide;
  late final Animation<double>   _fade;

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _show() {
    if (_visible) return;
    setState(() => _visible = true);
    _ctrl.forward();
    // auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), _hide);
  }

  void _hide() {
    if (!_visible) return;
    _ctrl.reverse().then((_) {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline     = ref.watch(isOnlineProvider);
    final offlineMode  = ref.watch(offlineModeProvider);
    final shouldShow   = !isOnline || offlineMode;

    // react to state changes
    ref.listen(isOnlineProvider, (prev, next) {
      if (!next) _show();
    });
    ref.listen(offlineModeProvider, (prev, next) {
      if (next) _show();
      else      _hide();
    });

    if (!_visible && !shouldShow) return const SizedBox.shrink();

    final message = offlineMode
        ? 'Offline mode activated'
        : 'No network available';

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withOpacity(0.4),
                  blurRadius: 16,
                  offset:     const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width:  8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.theme,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  message,
                  style: const TextStyle(
                    fontFamily: AppFonts.outfit,
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                    color:      Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
