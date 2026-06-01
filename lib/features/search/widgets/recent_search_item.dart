import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

class RecentSearchItem extends StatelessWidget {
  final String       query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const RecentSearchItem({
    super.key,
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            // search icon box
            Container(
              width:  38,
              height: 38,
              decoration: BoxDecoration(
                color:         AppColors.surface,
                borderRadius:  BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.search_rounded,
                color: Colors.white.withValues(alpha:  0.3),
                size:  18,
              ),
            ),
            const SizedBox(width: 14),
            // query text
            Expanded(
              child: Text(
                query,
                style: const TextStyle(
                  fontFamily : AppFonts.outfit,
                  fontSize:   14,
                  fontWeight: FontWeight.w600,
                  color:      Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // remove button
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withValues(alpha:  0.3),
                  size:  16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
