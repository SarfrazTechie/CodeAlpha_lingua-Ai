import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primary.withOpacity(0.15),
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: isDark ? const Color(0xFF122E27) : const Color(0xFFE1F5EE),
      onSecondaryContainer: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      tertiary: AppColors.primary,
      onTertiary: Colors.white,
      tertiaryContainer: isDark ? const Color(0xFF122E27) : const Color(0xFFE1F5EE),
      onTertiaryContainer: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.error.withOpacity(0.12),
      onErrorContainer: AppColors.error,
      surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      onSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      surfaceContainerHighest: isDark ? const Color(0xFF122E27) : const Color(0xFFF0FBF9),
      onSurfaceVariant: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      outline: isDark ? AppColors.borderDark : AppColors.borderLight,
      outlineVariant: isDark ? const Color(0xFF1D6B5A) : const Color(0xFF9FE1CB),
      scrim: Colors.black,
      inverseSurface: isDark ? AppColors.surfaceLight : AppColors.surfaceDark,
      onInverseSurface: isDark ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
      inversePrimary: AppColors.primary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.dmSans(fontSize: 48, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        titleLarge: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        titleMedium: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        titleSmall: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        bodyLarge: GoogleFonts.dmSans(fontSize: 15, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        bodyMedium: GoogleFonts.dmSans(fontSize: 13, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        bodySmall: GoogleFonts.dmSans(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        labelLarge: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        labelMedium: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        labelSmall: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
        indicatorColor: Colors.transparent,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const IconThemeData(color: AppColors.primary);
          return IconThemeData(color: isDark ? const Color(0xFF3A7A68) : const Color(0xFF9FE1CB));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary);
          return GoogleFonts.dmSans(fontSize: 11, color: isDark ? const Color(0xFF3A7A68) : const Color(0xFF9FE1CB));
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        hintStyle: GoogleFonts.dmSans(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      dividerTheme: DividerThemeData(color: isDark ? AppColors.borderDark : AppColors.borderLight, thickness: 0.5),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: isDark ? const Color(0xFF1A3D35) : const Color(0xFF085041),
        contentTextStyle: GoogleFonts.dmSans(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
