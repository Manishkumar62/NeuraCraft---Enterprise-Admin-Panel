import 'package:flutter/material.dart';

class AppTheme {
  static const Color _scaffoldColor = Color(0xFF0F1115);
  static const Color _surfaceColor = Color(0xFF161B22);
  static const Color _cardColor = Color(0xFF1C2128);
  static const Color _primaryColor = Color(0xFF7C3AED);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: _scaffoldColor,

    colorScheme: const ColorScheme.dark(
      primary: _primaryColor,
      secondary: _primaryColor,
      surface: _surfaceColor,
    ),

    /// 🧊 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    /// 🪟 Cards (Glass Layer)
    cardTheme: CardThemeData(
      color: _cardColor.withOpacity(0.6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
    ),

    /// 🧊 Elevated Buttons (Soft Glow)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    /// ✏ Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: _primaryColor,
          width: 1.2,
        ),
      ),
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(0.7),
      ),
    ),

    /// 🧩 Floating Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
    ),

    /// 📦 Divider
    dividerColor: Colors.white.withOpacity(0.05),

    /// ✨ Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(_primaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),

    /// 🔘 Navigation Bar
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: _surfaceColor,
      indicatorColor: _primaryColor,
      labelTextStyle: MaterialStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
  );
}