// config/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // 10-30-60 Color Rule Implementation
  // 60% - Neutral/Background colors (FFF9F4)
  static const Color neutralColor = Color(0xFFFFF9F4); // Main background
  static const Color backgroundColor = Color(0xFFFFF9F4);
  static const Color cardColor = Colors.white;

  // 30% - Secondary colors (CCA291)
  static const Color primaryColor = Color(0xFFCCA291); // Brown/tan color
  static const Color secondaryColor = Color(0xFFCCA291);

  // 10% - Accent colors (F4C2C2)
  static const Color accentColor = Color(0xFFF4C2C2); // Pink accent
  static const Color highlightColor = Color(0xFFF4C2C2);

  // Supporting colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color errorColor = Color(0xFFE17055);
  static const Color successColor = Color(0xFF00B894);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color backgroundSecondary = Color(0xFFF1F2F6);

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Additional spacing constants
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusExtraLarge = 24.0;

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  // App Theme
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.brown,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: neutralColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}