import 'package:flutter/material.dart';

class AppTheme {
  static const Color neumorphicBaseDark = Color(0xFF1A1A1A);
  static const Color neumorphicBaseLight = Color(0xFFF0F0F0);

  static const Color navyBlue = Color(0xFF0A192F);
  static const Color brightOrange = Color(0xFFFF8C00);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: neumorphicBaseDark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.cyanAccent,
        surface: neumorphicBaseDark,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: neumorphicBaseDark,
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: neumorphicBaseLight,
      colorScheme: const ColorScheme.light(
        primary: brightOrange,
        secondary: navyBlue,
        surface: neumorphicBaseLight,
        onSurface: navyBlue,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: navyBlue),
        titleTextStyle: TextStyle(
          color: navyBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: neumorphicBaseLight,
        selectedItemColor: brightOrange,
        unselectedItemColor: Colors.black26,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
