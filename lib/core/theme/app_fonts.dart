import 'package:flutter/material.dart';

/// Centralized text styles for the whole app.
/// Use these instead of writing inline TextStyle everywhere.
class AppFonts {
  AppFonts._();

  static const String outfit = 'Outfit'; // Primary UI font, used for most text elements
  static const String jetbrainsMono = 'JetBrains Mono'; // Mono font for metadata, timestamps, and code-like elements

  // ── Colors used in text styles ───────────────────────────────────────────────
  static const Color textPrimary  = Color(0xFFEEEEFC);
  static const Color textSub      = Color(0xFF9494B8);
  static const Color textMuted    = Color(0xFF4A4A6A);

  // ── Display ────────────────────────────────────────────────────────────────
  static const screenTitle = TextStyle(
    fontFamily:    'Outfit',
    fontSize:      26,
    fontWeight:    FontWeight.w900,
    letterSpacing: -0.3,
    color:         Color(0xFFEEEEFC),
  );

  static const modalTitle = TextStyle(
    fontFamily: 'Outfit',
    fontSize:   18,
    fontWeight: FontWeight.w800,
    color:      Color(0xFFEEEEFC),
  );

  // ── Body ───────────────────────────────────────────────────────────────────
  static const bodyLarge = TextStyle(
    fontFamily: 'Outfit',
    fontSize:   16,
    fontWeight: FontWeight.w700,
    color:      Color(0xFFEEEEFC),
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'Outfit',
    fontSize:   14,
    fontWeight: FontWeight.w600,
    color:      Color(0xFFEEEEFC),
  );

  static const bodySmall = TextStyle(
    fontFamily: 'Outfit',
    fontSize:   13,
    fontWeight: FontWeight.w500,
    color:      Color(0xFFEEEEFC),
  );

  // ── Mono (metadata, timestamps, code-like) ─────────────────────────────────
  static const monoMedium = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize:   12,
    fontWeight: FontWeight.w400,
    color:      Color(0xFF9494B8),
  );

  static const monoSmall = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize:   11,
    fontWeight: FontWeight.w400,
    color:      Color(0xFF9494B8),
  );

  static const monoTiny = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize:   10,
    fontWeight: FontWeight.w400,
    color:      Color(0xFF4A4A6A),
  );

  // ── Labels ─────────────────────────────────────────────────────────────────
  static const sectionLabel = TextStyle(
    fontFamily:    'Outfit',
    fontSize:      11,
    fontWeight:    FontWeight.w700,
    letterSpacing: 0.12,
    color:         Color(0xFF4A4A6A),
  );

  static const chipLabel = TextStyle(
    fontFamily: 'Outfit',
    fontSize:   12,
    fontWeight: FontWeight.w600,
  );

  static const navLabel = TextStyle(
    fontFamily: 'Outfit',
    fontSize:   10,
    fontWeight: FontWeight.w500,
  );

  // ── Buttons ────────────────────────────────────────────────────────────────
  static const btnPrimary = TextStyle(
    fontFamily: 'Outfit',
    fontSize:   14,
    fontWeight: FontWeight.w800,
    color:      Color(0xFF0A0A12),
  );

  static const btnSecondary = TextStyle(
    fontFamily: 'Outfit',
    fontSize:   13,
    fontWeight: FontWeight.w700,
    color:      Color(0xFFEEEEFC),
  );

  // ── Player ─────────────────────────────────────────────────────────────────
  static const trackTitle = TextStyle(
    fontFamily:    'Outfit',
    fontSize:      22,
    fontWeight:    FontWeight.w800,
    letterSpacing: -0.3,
    color:         Color(0xFFEEEEFC),
  );

  static const trackArtist = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize:   14,
    fontWeight: FontWeight.w400,
    color:      Color(0xFF9494B8),
  );

  static const miniTrackTitle = TextStyle(
    fontFamily: 'Outfit',
    fontSize:   13,
    fontWeight: FontWeight.w700,
    color:      Color(0xFFEEEEFC),
  );

  static const miniTrackArtist = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize:   11,
    color:      Color(0xFF9494B8),
  );

  // ── Lyrics ─────────────────────────────────────────────────────────────────
  static const lyricActive = TextStyle(
    fontFamily:    'Outfit',
    fontSize:      26,
    fontWeight:    FontWeight.w800,
    letterSpacing: -0.3,
    color:         Color(0xFFEEEEFC),
    height:        1.4,
  );

  static const lyricInactive = TextStyle(
    fontFamily: 'Outfit',
    fontSize:   18,
    fontWeight: FontWeight.w500,
    color:      Color(0x3FEEEEFC),
    height:     1.4,
  );
}
