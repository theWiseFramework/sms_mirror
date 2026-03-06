import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color orange = Color(0xFFE67E22);
  static const Color darkOrange = Color(0xFFC35409);
  static const Color brown = Color(0xFF2C1B17);
  static const Color gold = Color(0xFFF39C12);
  static const Color offWhite = Color(0xFFFAF9F6);

  static const String fontGeistFamily = 'Geist';
  static const String fontGeistMonoFamily = 'GeistMono';

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: fontGeistFamily,
    platform: TargetPlatform.android,
    brightness: Brightness.light,
    primaryColor: orange,
    colorScheme: ColorScheme.fromSeed(
      seedColor: orange,
      secondary: brown,
      primary: orange,
      tertiary: gold,
      surface: offWhite,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: Color(0xFF1C1B1F),
      brightness: Brightness.light,
      outline: Color(0xFF79747E),
    ),
    appBarTheme: const AppBarTheme(
      scrolledUnderElevation: 1,
      centerTitle: false,
      shadowColor: Colors.black26,
      surfaceTintColor: Colors.transparent,
      backgroundColor: offWhite,
      foregroundColor: Colors.black,
      titleTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: offWhite,
      isDense: true,
      errorMaxLines: 3,
      border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: darkOrange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: offWhite,
      elevation: 8,
      shadowColor: Color(0xFF1C1B1F),
      // selectedItemColor: darkOrange,
      // unselectedItemColor: Colors.grey,
    ),
  );
}
