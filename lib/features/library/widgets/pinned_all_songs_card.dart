import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

enum PinnedCardType { allSongs, favorites }

class PinnedCard extends StatelessWidget {
  final PinnedCardType type;
  final int            trackCount;
  final VoidCallback   onTap;

  const PinnedCard({
    super.key,
    required this.type,
    required this.trackCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFav = type == PinnedCardType.favorites;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.surface,
              AppColors.theme.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.theme.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // icon box
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.theme.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isFav
                    ? Icons.favorite_rounded
                    : Icons.music_note_rounded,
                color: AppColors.theme,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            // info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFav ? 'Favorite Songs' : 'All Songs',
                    style: const TextStyle(
                      fontFamily: AppFonts.outfit,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$trackCount tracks'
                    '${isFav ? '' : ' · local + loaded'}',
                    style: TextStyle(
                      fontFamily: AppFonts.jetbrainsMono,
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            // pin icon
            Icon(
              Icons.push_pin_rounded,
              color: AppColors.theme.withOpacity(0.7),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
