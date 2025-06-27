import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors
  static const Color lightPrimary = Color(0xFF078A24);
  static const Color lightAccent = Color(0xFF028688);
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightCard = Colors.white;
  static const Color lightText = Color(0xFF212121);
  static const Color lightHint = Color(0xFF9E9E9E);

  // Dark theme colors
  static const Color darkPrimary = Color(0xFF03C0C2);
  static const Color darkAccent = Color(0xFF15D3D6);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkText = Colors.white;
  static const Color darkHint = Color(0xFFBDBDBD);

  // Common colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    //useMaterial3: true,
    primaryColor: lightPrimary,
    colorScheme: ColorScheme.light(
      primary: lightPrimary,
      secondary: lightAccent,
      background: lightBackground,
      surface: lightCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: lightText,
      onSurface: lightText,
      error: error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: lightBackground,

    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: lightText),
      titleTextStyle: TextStyle(
        color: lightText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: IconThemeData(color: lightPrimary),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: lightText),
      headlineMedium: TextStyle(color: lightText),
      headlineSmall: TextStyle(color: lightText),
      bodyLarge: TextStyle(color: lightText),
      bodyMedium: TextStyle(color: lightText),
      bodySmall: TextStyle(color: lightHint),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightPrimary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightPrimary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightHint.withOpacity(0.2)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightPrimary,
        side: const BorderSide(color: lightPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: lightPrimary,
      unselectedItemColor: lightHint,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: darkPrimary,
    colorScheme: ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkAccent,
      background: darkBackground,
      surface: darkCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: darkText,
      onSurface: darkText,
      error: error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackground,
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: darkText),
      titleTextStyle: TextStyle(
        color: darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: IconThemeData(color: darkPrimary),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: darkText),
      headlineMedium: TextStyle(color: darkText),
      headlineSmall: TextStyle(color: darkText),
      bodyLarge: TextStyle(color: darkText),
      bodyMedium: TextStyle(color: darkText),
      bodySmall: TextStyle(color: darkHint),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkPrimary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkPrimary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkPrimary,
        side: const BorderSide(color: darkPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkCard,
      selectedItemColor: darkPrimary,
      unselectedItemColor: darkHint,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
