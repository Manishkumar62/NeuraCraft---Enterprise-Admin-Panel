import 'package:flutter/material.dart';

class AppTheme {
  static const Color _scaffoldColor = Color(0xFF0F1115);
  static const Color _surfaceColor = Color(0xFF161B22);
  static const Color _cardColor = Color(0xFF1C2128);
  static const Color _primaryColor = Color(0xFF7C3AED); // Deep Violet

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _scaffoldColor,
    colorScheme: const ColorScheme.dark(
      primary: _primaryColor,
      surface: _surfaceColor,
      secondary: _primaryColor,
    ),
    cardColor: _cardColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: _surfaceColor,
      elevation: 0,
      centerTitle: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),
  );
}