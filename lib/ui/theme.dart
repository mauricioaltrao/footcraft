import 'package:flutter/material.dart';

/// Cores inspiradas na FCB1010: corpo escuro, LEDs vermelhos e visor.
abstract final class FcbColors {
  static const led = Color(0xFFFF3B30);
  static const ledOff = Color(0xFF4A1512);
  static const display = Color(0xFFFF453A);
  static const displayBg = Color(0xFF1A0505);
  static const pedal = Color(0xFF2B2E33);
  static const pedalTop = Color(0xFF3A3E45);
  static const body = Color(0xFF16181B);
  static const accent = Color(0xFFFFB020);
  static const program = Color(0xFF64B5F6);
  static const control = Color(0xFFFFB020);
  static const expression = Color(0xFF81C784);
  static const note = Color(0xFFBA68C8);
  static const relay = Color(0xFFFF8A65);
}

ThemeData buildTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: FcbColors.led,
        brightness: Brightness.dark,
        surface: const Color(0xFF111316),
      ).copyWith(
        primary: FcbColors.accent,
        onPrimary: Colors.black,
        secondary: FcbColors.led,
      );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF0D0F11),
    cardTheme: const CardThemeData(
      color: Color(0xFF1A1D21),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      isDense: true,
      border: OutlineInputBorder(),
    ),
  );
}
