import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens and dark/light `ThemeData` for Jamal's Addiction.
class AppTheme {
  const AppTheme._();

  static const Color obsidianDark = Color(0xFF040508);
  static const Color surfaceDark = Color(0xFF0C0F17);
  static const Color surfaceLight = Color(0xFFF5F7FB);

  static ThemeData get darkTheme {
    final TextTheme baseText = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: obsidianDark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFF40009),
        secondary: Color(0xFF38BDF8),
        tertiary: Color(0xFFB8FF01),
        surface: surfaceDark,
      ),
      textTheme: baseText,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xE610141F),
      ),
    );
  }

  static ThemeData get lightTheme {
    final TextTheme baseText = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.light().textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: surfaceLight,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFDC0012),
        secondary: Color(0xFF005CB4),
        tertiary: Color(0xFF1F9D3D),
        surface: Colors.white,
      ),
      textTheme: baseText,
    );
  }

  /// Display font used for big numbers, brand titles, and Soda Wrapped slides.
  static TextStyle syneStyle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w800,
    Color color = Colors.white,
    double letterSpacing = -0.5,
    double height = 1.05,
  }) {
    return GoogleFonts.syne(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Monospace font used for volume counters, timestamps, and badges.
  static TextStyle monoStyle({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w700,
    Color color = Colors.white,
    double letterSpacing = 0.4,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
