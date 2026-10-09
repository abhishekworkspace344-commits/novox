import 'package:flutter/material.dart';

class AppColors {
  // Primary Blues
  static const Color primary = Color(0xFF1E40AF); // Deep Royal Blue
  static const Color primaryDark = Color(0xFF1E3A8A); // Midnight Navy
  static const Color primaryLight = Color(0xFF3B82F6); // Electric Blue
  static const Color primarySoft = Color(0xFFEFF6FF); // Ice Blue Tint
  static const Color accent = Color(0xFF0284C7); // Vivid Ocean Blue
  static const Color accentLight = Color(0xFFE0F2FE); // Soft Sky Tint

  // Backgrounds & Surfaces (White & Cool Slate)
  static const Color background = Color(0xFFF8FAFC); // Clean Slate White
  static const Color surface = Colors.white; // Crisp White
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Light Gray Surface
  static const Color cardBorder = Color(0xFFE2E8F0); // Subtle Border
  static const Color cardBorderHighlight = Color(0xFFBFDBFE); // Soft Blue Border

  // Typography
  static const Color textPrimary = Color(0xFF0F172A); // Midnight Charcoal
  static const Color textSecondary = Color(0xFF475569); // Slate Gray
  static const Color textMuted = Color(0xFF94A3B8); // Light Slate
  static const Color textOnPrimary = Colors.white;

  // Status Colors (Premium pastels + deep accents)
  static const Color success = Color(0xFF059669); // Emerald
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFD97706); // Amber
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFDC2626); // Crimson
  static const Color dangerBg = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF2563EB); // Royal Blue
  static const Color infoBg = Color(0xFFEFF6FF);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E3A8A),
      Color(0xFF2563EB),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white,
      Color(0xFFF8FAFC),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB),
      Color(0xFF38BDF8),
    ],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primarySoft,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.primaryLight,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.accentLight,
        onSecondaryContainer: AppColors.primaryDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
        onError: Colors.white,
        outline: AppColors.cardBorder,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(
          color: AppColors.primary,
          size: 22,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.cardBorder,
            width: 1,
          ),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.cardBorder,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.danger,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.danger,
            width: 1.8,
          ),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
