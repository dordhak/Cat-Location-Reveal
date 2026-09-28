import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand colors. Marmalade is the action color, jade (a cat-eye green) is the
/// supporting color, and ink is a deep aubergine used instead of pure black.
class AppColors {
  AppColors._();

  static const marmalade = Color(0xFFEE8A1F);
  static const jade = Color(0xFF3F7D6B);
  static const ink = Color(0xFF2E2230);
  static const milk = Color(0xFFFAF7F4);
  static const gold = Color(0xFFF2B705);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.marmalade,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.marmalade,
      // Dark text on marmalade has far better contrast than white text.
      onPrimary: AppColors.ink,
      primaryContainer: const Color(0xFFFFE3C2),
      onPrimaryContainer: const Color(0xFF4A2A00),
      secondary: AppColors.jade,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFD4EBE3),
      onSecondaryContainer: const Color(0xFF0F3A2E),
      surface: AppColors.milk,
      onSurface: AppColors.ink,
      onSurfaceVariant: const Color(0xFF6E6273),
      outline: const Color(0xFF9C90A0),
      outlineVariant: const Color(0xFFE9E2E6),
    );

    final base = GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    // Fredoka (rounded, toy-like) for titles; DM Sans for everything else.
    final textTheme = base.copyWith(
      headlineSmall: GoogleFonts.fredoka(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.15,
        color: scheme.onSurface,
      ),
      titleLarge: GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: GoogleFonts.fredoka(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: scheme.onSurface,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.outline),
        helperStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        border: _inputBorder(scheme.outlineVariant),
        enabledBorder: _inputBorder(scheme.outlineVariant),
        focusedBorder: _inputBorder(scheme.primary, width: 2),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 2),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        highlightElevation: 4,
        extendedTextStyle: textTheme.labelLarge,
        shape: const StadiumBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
        showCheckmark: false,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.onSurface,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}