import 'package:flutter/material.dart';

/// Sawrni / صورني fixed mobile brand system.
/// Slogan: استوديو كامل بجيبك
class SawrniBrand {
  static const String appNameAr = 'صورني';
  static const String appNameEn = 'Sawrni';
  static const String sloganAr = 'استوديو كامل بجيبك';
  static const String sloganEn = 'A full studio in your pocket';

  static const Color midnight = Color(0xFF061225);
  static const Color ink = Color(0xFF0B1328);
  static const Color purple = Color(0xFF5B2DA4);
  static const Color purpleDark = Color(0xFF3B1B74);
  static const Color gold = Color(0xFFE3B341);
  static const Color cream = Color(0xFFFFF8E8);
  static const Color snow = Color(0xFFF7F8FB);
  static const Color line = Color(0xFFE2E7F0);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFE11D48);
  static const Color muted = Color(0xFF64748B);

  static ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: snow,
      fontFamily: null,
      colorScheme: ColorScheme.fromSeed(
        seedColor: purple,
        primary: purple,
        secondary: gold,
        surface: Colors.white,
        background: snow,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: ink,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: purple, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: purple,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: line),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
