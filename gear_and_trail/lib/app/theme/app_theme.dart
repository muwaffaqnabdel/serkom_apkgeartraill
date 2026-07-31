import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    // AppBar Styling (Sharp, Bold, Athletic Orbitron Header)
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryForest,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: primaryForest),
      titleTextStyle: GoogleFonts.orbitron(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
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
        textStyle: GoogleFonts.orbitron(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
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

    // Bold Athletic Orbitron Text Theme for Extreme Sports Titles
    textTheme: TextTheme(
      displayLarge: GoogleFonts.orbitron(fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.5),
      displayMedium: GoogleFonts.orbitron(fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.5),
      displaySmall: GoogleFonts.orbitron(fontWeight: FontWeight.w800, color: textDark),
      headlineLarge: GoogleFonts.orbitron(fontWeight: FontWeight.w900, color: textDark, letterSpacing: 0.2),
      headlineMedium: GoogleFonts.orbitron(fontWeight: FontWeight.w800, color: textDark),
      headlineSmall: GoogleFonts.orbitron(fontWeight: FontWeight.w800, color: textDark),
      titleLarge: GoogleFonts.orbitron(fontWeight: FontWeight.w800, color: textDark, letterSpacing: 0.2),
      titleMedium: GoogleFonts.orbitron(fontWeight: FontWeight.w700, color: textDark),
      titleSmall: GoogleFonts.orbitron(fontWeight: FontWeight.w700, color: textDark),
      bodyLarge: const TextStyle(fontWeight: FontWeight.w500, color: textDark),
      bodyMedium: const TextStyle(fontWeight: FontWeight.normal, color: textMuted),
    ),
  );
}
