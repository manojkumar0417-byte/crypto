import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF090C15);
  static const Color surface = Color(0xFF131824);
  static const Color surfaceElevated = Color(0xFF1C2233);
  static const Color border = Color(0xFF263043);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Crypto Financial Palette
  static const Color green = Color(0xFF00D092);
  static const Color greenLight = Color(0x2200D092);
  static const Color red = Color(0xFFFF4D4D);
  static const Color redLight = Color(0x22FF4D4D);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color starGold = Color(0xFFFBBF24);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: green,
      cardColor: surface,
      dividerColor: border,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: green,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      colorScheme: const ColorScheme.dark(
        primary: green,
        secondary: cyan,
        surface: surface,
        error: red,
      ),
    );
  }
}
