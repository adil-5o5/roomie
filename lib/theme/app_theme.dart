import 'package:flutter/material.dart';

class AppTheme {
  // Reddit-like Color Palette
  static const Color primaryOrange = Color(
    0xFFFF4500,
  ); // Reddit's signature orange
  static const Color secondaryOrange = Color(0xFFFF8C00);
  static const Color darkGrey = Color(0xFF1A1A1B); // Dark background
  static const Color mediumGrey = Color(0xFF272729); // Card background
  static const Color lightGrey = Color(0xFF343536); // Lighter elements
  static const Color textPrimary = Color(0xFFD7DADC); // Primary text
  static const Color textSecondary = Color(0xFF818384); // Secondary text
  static const Color accentBlue = Color(0xFF0079D3); // Accent color
  static const Color successGreen = Color(0xFF46D160);
  static const Color errorRed = Color(0xFFFF4444);
  static const Color warningYellow = Color(0xFFFFD700);

  // Glassmorphic effects
  static const double glassOpacity = 0.1;
  static const double glassBlur = 20.0;
  static const double glassBorderRadius = 16.0;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryOrange,
        secondary: secondaryOrange,
        surface: mediumGrey,
        background: darkGrey,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        error: errorRed,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: darkGrey,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: mediumGrey.withOpacity(0.8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(glassBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGrey.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(glassBorderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(glassBorderRadius),
          borderSide: BorderSide(color: lightGrey.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(glassBorderRadius),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(glassBorderRadius),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 16),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 16),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(glassBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: lightGrey.withOpacity(0.5), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(glassBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryOrange,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: textSecondary, size: 24),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: lightGrey,
        thickness: 0.5,
        space: 1,
      ),
    );
  }

  // Glassmorphic container decoration
  static BoxDecoration get glassmorphicDecoration {
    return BoxDecoration(
      color: mediumGrey.withOpacity(glassOpacity),
      borderRadius: BorderRadius.circular(glassBorderRadius),
      border: Border.all(color: lightGrey.withOpacity(0.2), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: glassBlur,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Glassmorphic card decoration
  static BoxDecoration get glassmorphicCardDecoration {
    return BoxDecoration(
      color: mediumGrey.withOpacity(0.15),
      borderRadius: BorderRadius.circular(glassBorderRadius),
      border: Border.all(color: lightGrey.withOpacity(0.3), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 25,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Gradient backgrounds
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A1B), Color(0xFF272729), Color(0xFF343536)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4500), Color(0xFFFF8C00)],
  );
}
