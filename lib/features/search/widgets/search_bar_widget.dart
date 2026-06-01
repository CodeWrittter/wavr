import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback?        onSubmit;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.onSubmit,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha:  0.07)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha:  0.3),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller:  _ctrl,
              focusNode:   _focus,
              style: const TextStyle(
                fontFamily: AppFonts.outfit,
                fontSize:   14,
                color:      Colors.white,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Artists, songs, playlists...',
                hintStyle: TextStyle(
                  fontFamily: AppFonts.outfit,
                  fontSize:   14,
                  color:      Colors.white.withValues(alpha:  0.3),
                  fontWeight: FontWeight.w400,
                ),
                border:         InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              textInputAction: TextInputAction.search,
              onChanged:   widget.onChanged,
              onSubmitted: (_) => widget.onSubmit?.call(),
            ),
          ),
          // mic icon — not functional yet, shows "coming soon" tooltip
          GestureDetector(
            onTap: () => _showComingSoon(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(
                Icons.mic_rounded,
                color: Colors.white.withValues(alpha:  0.3),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                color: AppColors.theme,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Voice search coming in a future update',
              style: TextStyle(
                fontFamily: AppFonts.outfit,
                fontSize:   13,
                fontWeight: FontWeight.w600,
                color:      Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.white.withValues(alpha:  0.1)),
        ),
        margin:   const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
