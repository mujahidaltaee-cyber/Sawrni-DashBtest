import 'package:flutter/material.dart';

class SawrniBrand {
  static const String appNameAr = 'صورني';
  static const String appNameEn = 'Sawrni';
  static const String sloganAr = 'استوديو كامل بجيبك';

  static const Color navy = Color(0xFF071426);
  static const Color purple = Color(0xFF5B2EAE);
  static const Color deepPurple = Color(0xFF35156E);
  static const Color gold = Color(0xFFE9B44C);
  static const Color surface = Color(0xFFF6F7FB);
  static const Color card = Colors.white;
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color muted = Color(0xFF64748B);

  static ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: purple,
        primary: purple,
        secondary: gold,
        surface: surface,
        error: danger,
      ),
      fontFamily: null,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: purple, width: 1.4),
        ),
      ),
    );
  }
}
