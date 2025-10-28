import 'package:flutter/material.dart';

class DreamSleepTheme {
  static ThemeData get dark {
    const background = Color(0xFF0D0B1A);
    const surface = Color(0xFF141226);
    const accent = Color(0xFF7B5CD6);

    final base = ThemeData.dark();

    return base.copyWith(
      primaryColor: accent,
      scaffoldBackgroundColor: background,
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        secondary: const Color(0xFFEDCBB1),
        surface: surface,
        background: background,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: const Color(0xFFE6E0FF),
        displayColor: const Color(0xFFE6E0FF),
        fontFamily: 'Roboto',
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Color(0xFFE6E0FF),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFEDCBB1),
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      ),
    );
  }
}
