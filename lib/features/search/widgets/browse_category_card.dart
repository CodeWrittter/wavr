import 'package:flutter/material.dart';
import '../../../core/theme/app_fonts.dart';

class BrowseCategoryCard extends StatelessWidget {
  final String       label;
  final String       emoji;
  final Color        color1;
  final Color        color2;
  final VoidCallback onTap;

  const BrowseCategoryCard({
    super.key,
    required this.label,
    required this.emoji,
    required this.color1,
    required this.color2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end:   Alignment.topRight,
            colors: [color1, color2],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // emoji — top right, rotated, oversized
            Positioned(
              top:   -8,
              right: -8,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 52),
              ),
            ),
            // label — bottom left
            Positioned(
              bottom: 16,
              left:   16,
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily : AppFonts.outfit,
                  fontSize:   15,
                  fontWeight: FontWeight.w800,
                  color:      Colors.white,
                  shadows: [
                    Shadow(
                      color:  Colors.black45,
                      offset: Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
