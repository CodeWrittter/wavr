import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3:       true,
        brightness:         Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary:   AppColors.theme,
          secondary: AppColors.theme,
          surface:   AppColors.surface,
          error:     AppColors.error,
        ),
        fontFamily: AppFonts.outfit,

        // app bar
        appBarTheme: const AppBarTheme(
          backgroundColor:    AppColors.background,
          elevation:          0,
          centerTitle:        true,
          foregroundColor:    AppColors.textPrimary,
          titleTextStyle: TextStyle(
            fontFamily: AppFonts.outfit,
            fontSize:   17,
            fontWeight: FontWeight.w700,
            color:      AppColors.textPrimary,
          ),
        ),

        // bottom nav (we use custom, but this covers system defaults)
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor:    AppColors.surface,
          selectedItemColor:  AppColors.theme,
          unselectedItemColor: AppColors.textMuted,
          elevation: 0,
        ),

        // text
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: AppFonts.outfit,
            fontSize:   32,
            fontWeight: FontWeight.w900,
            color:      AppColors.textPrimary,
          ),
          titleLarge: TextStyle(
            fontFamily: AppFonts.outfit,
            fontSize:   20,
            fontWeight: FontWeight.w800,
            color:      AppColors.textPrimary,
          ),
          titleMedium: TextStyle(
            fontFamily: AppFonts.outfit,
            fontSize:   16,
            fontWeight: FontWeight.w700,
            color:      AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontFamily: AppFonts.outfit,
            fontSize:   14,
            fontWeight: FontWeight.w500,
            color:      AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontFamily: AppFonts.jetbrainsMono,
            fontSize:   12,
            fontWeight: FontWeight.w400,
            color:      AppColors.textSub,
          ),
          bodySmall: TextStyle(
            fontFamily: AppFonts.jetbrainsMono,
            fontSize:   11,
            fontWeight: FontWeight.w400,
            color:      AppColors.textMuted,
          ),
        ),

        // input fields
        inputDecorationTheme: InputDecorationTheme(
          filled:      true,
          fillColor:   AppColors.surfaceAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:   BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.theme,
              width: 1.5,
            ),
          ),
          hintStyle: const TextStyle(
            fontFamily: AppFonts.outfit,
            color:      AppColors.textMuted,
          ),
        ),

        // snackbar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceAlt,
          contentTextStyle: const TextStyle(
            fontFamily: AppFonts.outfit,
            fontSize:   13,
            fontWeight: FontWeight.w600,
            color:      AppColors.textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // dialogs
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: const TextStyle(
            fontFamily: AppFonts.outfit,
            fontSize:   17,
            fontWeight: FontWeight.w800,
            color:      AppColors.textPrimary,
          ),
          contentTextStyle: TextStyle(
            fontFamily: AppFonts.jetbrainsMono,
            fontSize:   12,
            color:      AppColors.textSub,
            height:     1.6,
          ),
        ),

        // bottom sheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor:    Colors.transparent,
          modalBackgroundColor: Colors.transparent,
          elevation:          0,
        ),

        // divider
        dividerTheme: const DividerThemeData(
          color:     AppColors.border,
          thickness: 1,
          space:     1,
        ),

        // circular progress
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.theme,
        ),
      );
}
