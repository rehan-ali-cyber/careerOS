import 'package:flutter/material.dart';

class AppTheme {
  static const Color neumorphicBase = Color(0xFF1A1A1A);
  static const Color neumorphicLightShadow = Colors.white;
  static const Color neumorphicDarkShadow = Colors.black;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: neumorphicBase,
      colorScheme: const ColorScheme.dark(
        primary: Colors.cyanAccent,
        surface: neumorphicBase,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
