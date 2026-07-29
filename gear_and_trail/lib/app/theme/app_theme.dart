import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - Forest Trail & Amber Outdoor Theme (Dominan Tampilan Login)
  static const Color primaryForest = Color(0xFF1E3A2F);   // Deep Pine Green (Utama Login)
  static const Color accentAmber = Color(0xFFEA580C);     // Trail Amber Orange (Aksen Akses)
  static const Color backgroundSlate = Color(0xFFF8FAFC); // Clean Light Slate (Background Login)
  static const Color cardBorder = Color(0xFFE2E8F0);     // Subtle Slate Border
  static const Color textDark = Color(0xFF0F172A);       // Slate Charcoal Text
  static const Color textMuted = Color(0xFF64748B);      // Slate Muted Gray Text
  static const Color hintGray = Color(0xFF94A3B8);       // Hint Text Gray
  static const Color mintTint = Color(0xFFECFDF5);       // Soft Mint Circle Tint

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryForest,
    scaffoldBackgroundColor: backgroundSlate,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryForest,
      primary: primaryForest,
      secondary: accentAmber,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDark,
    ),

    // AppBar Styling (Sharp, Bold, Athletic Extreme Sports Header)
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryForest,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryForest),
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        color: primaryForest,
      ),
    ),

    // Card Styling
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: cardBorder),
      ),
    ),

    // Button Styling (ElevatedButton Hijau Dominan Login)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryForest,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // Input Field Styling (Form Input Login)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundSlate,
      hintStyle: const TextStyle(color: hintGray),
      prefixIconColor: textMuted,
      suffixIconColor: textMuted,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryForest, width: 1.5),
      ),
    ),

    // Bold Athletic Text Theme for Extreme Sports
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.5),
      displayMedium: TextStyle(fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.5),
      displaySmall: TextStyle(fontWeight: FontWeight.w800, color: textDark),
      headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: textDark, letterSpacing: 0.2),
      headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: textDark),
      headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: textDark),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, color: textDark, letterSpacing: 0.2),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, color: textDark),
      titleSmall: TextStyle(fontWeight: FontWeight.w700, color: textDark),
      bodyLarge: TextStyle(fontWeight: FontWeight.w500, color: textDark),
      bodyMedium: TextStyle(fontWeight: FontWeight.normal, color: textMuted),
    ),
  );
}
