import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // ── Toggle off background ──────────────────────────────────────────────────
  static const toggleOff    = Color(0xFF2A2A3A);

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color theme = Color(0xFF30FF4F); // Neon yellow
  static const Color theme2 = Color(0xFFE8FF5A); // Soft green
  static const Color theme3 = Color(0xFF4CAF50); // Material green

  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF080810);
  static const Color surface = Color(0xFF161624);
  static const Color surfaceAlt = Color(0xFF0F0F1A);
  static const Color surfaceDeep = Color(0xFF0A0A12); // Accent dark
  static const Color surfaceElevated = Color(0xFF1E1E2E);

  // ── Deep backgrounds (player artwork gradients) ────────────────────────────
  static const deepNavy = Color(0xFF0D0D2E); // deep navy
  static const deepViolet = Color(0xFF1A0D3D); // deep violet
  static const deepOcean = Color(0xFF0D2040); // deep ocean
  static const deepPurple = Color(0xFF2A0D40); // deep purple
  static const nearBlackBlue = Color(0xFF0A0A18); // near black blue
  static const nearBlackViolet = Color(0xFF0D0820); // near black violet

  // ── Mini player artwork gradient ───────────────────────────────────────────
  static const midnightBlue     = Color(0xFF1A1A3E); // midnight blue
  static const deepTealBlue     = Color(0xFF1A3E6E); // deep teal blue

  // ── Glow / ambient colors ──────────────────────────────────────────────────
  static const glowViolet   = Color(0xFF3D1A6E); // lyrics bg top glow
  // static const glowNavy     = Color(0xFF1A0D3D); // lyrics bg bottom glow
  static const glowIndigo   = Color(0xFF5A5AFF); // artwork canvas glow

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary  = Color(0xFFEEEEFC);
  static const textSub      = Color(0xFF9494B8);
  static const textMuted    = Color(0xFF4A4A6A);

  // ── Borders ────────────────────────────────────────────────────────────────
  static const border       = Color(0x12FFFFFF); // 7% white
  static const border2      = Color(0x1FFFFFFF); // 12% white

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF5AE85A);
  static const Color info = Color(0xFF5AA0FF);
  static const Color warning = Color(0xFFFFA05A);
  static const Color error = Color(0xFFFF5A5A);

  // ── Source colors ──────────────────────────────────────────────────────────
  static const spotify      = Color(0xFF1DB954);
  static const appleMusic   = Color(0xFFFC3C44);
  static const deezer       = Color(0xFFA15AFF);
  static const youtube      = Color(0xFFFF0000);
  static const soundcloud   = Color(0xFFFF5500);

  // ── Source brand backgrounds (icon containers) ─────────────────────────────
  static const srcSpotifyBg    = Color(0xFF0D2B0D); // dark green
  static const srcAppleBg      = Color(0xFF2E0D0D); // dark red       (also YT Music)
  static const srcDeezerBg     = Color(0xFF1A0D2E); // dark indigo    (also Audius)
  static const srcSoundcloudBg = Color(0xFF2E1A0D); // dark amber     (also Manual)
  static const srcJamendoBg    = Color(0xFF0D2E1A); // dark emerald
  static const srcWavrBg       = Color(0xFF1E1E0D); // dark olive (also Accent row)
  static const srcLocalBg      = Color(0xFF0D1A2E); // dark steel blue
  static const srcThemeBg      = Color(0xFF2E0D2E); // dark magenta   (Theme row)

  // ── Source brand foregrounds ───────────────────────────────────────────────
  static const srcPurpleFg     = Color(0xFFA05AFF); // Audio Quality, Privacy icon
  static const srcTealFg       = Color(0xFF5AE8FF); // Equalizer icon
  static const srcPinkFg       = Color(0xFFFF5AA0); // Theme icon

  // ── Browse category gradients ──────────────────────────────────────────────
  // Afrobeats
  static const catAfroFrom     = Color(0xFF1A3A1A);
  static const catAfroTo       = Color(0xFF2D6B2D);
  // Hip-Hop
  static const catHipHopFrom   = Color(0xFF1A1A3A);
  static const catHipHopTo     = Color(0xFF3A2D6B);
  // R&B
  static const catRnbFrom      = Color(0xFF3A1A1A);
  static const catRnbTo        = Color(0xFF7A2020);
  // Pop
  static const catPopFrom      = Color(0xFF2A1A3A);
  static const catPopTo        = Color(0xFF6B2D8E);
  // Chill
  static const catChillFrom    = Color(0xFF1A2A3A);
  static const catChillTo      = Color(0xFF1A4A6B);
  // Trending
  static const catTrendingFrom = Color(0xFF3A2A1A);
  static const catTrendingTo   = Color(0xFF8B4A1A);

}
