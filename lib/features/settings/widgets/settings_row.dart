import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

class SettingsRow extends StatelessWidget {
  final Widget       icon;
  final String       label;
  final String       subtitle;
  final Widget?      trailing;
  final VoidCallback? onTap;
  final bool         isLast;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: AppFonts.outfit,
                      fontSize:   14,
                      fontWeight: FontWeight.w600,
                      color:      Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppFonts.jetbrainsMono,
                      fontSize:   11,
                      color: Colors.white.withOpacity(0.4),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 10),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Row icon helper ────────────────────────────────────────────────────────

class RowIcon extends StatelessWidget {
  final IconData icon;
  final Color    bg;
  final Color    fg;

  const RowIcon({
    super.key,
    required this.icon,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  36,
      height: 36,
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: fg, size: 18),
    );
  }
}

// ── Toggle widget ──────────────────────────────────────────────────────────

class SettingsToggle extends StatelessWidget {
  final bool             value;
  final ValueChanged<bool> onChanged;

  const SettingsToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width:  44,
        height: 26,
        decoration: BoxDecoration(
          color: value
              ? AppColors.theme
              : AppColors.toggleOff,
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve:    Curves.easeOut,
          alignment: value
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width:  20,
            height: 20,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.surfaceDeep
                  : Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────

class SettingsSectionLabel extends StatelessWidget {
  final String text;
  const SettingsSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 0, 10),
      child: Text(
        text,
        style: TextStyle(
          fontFamily:    AppFonts.outfit,
          fontSize:      11,
          fontWeight:    FontWeight.w700,
          letterSpacing: 0.12,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}

// ── Settings group container ───────────────────────────────────────────────

class SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const SettingsGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}
