import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

/// Shown inside the artwork canvas when video mode is toggled.
/// Tapping shows a "coming soon" snackbar.
class VideoOverlay extends StatelessWidget {
  const VideoOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showComingSoon(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha:  0.82),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.theme.withValues(alpha:  0.12),
                  border: Border.all(
                    color: AppColors.theme,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.theme,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Click to play the video full screen',
                style: TextStyle(
                  fontFamily: AppFonts.outfit,
                  fontSize: 13,
                  color: Colors.white.withValues(alpha:  0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.theme,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Video playback coming in a future update',
              style: TextStyle(
                fontFamily: AppFonts.outfit,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: Colors.white.withValues(alpha:  0.1),
          ),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
