import 'package:flutter/material.dart';

ThemeData buildThemeData() {
  final base = ThemeData.light();

  const primaryColor = Color(0xFFFF4F81);
  const secondaryColor = Color(0xFF9B51E0);

  return base.copyWith(
    primaryColor: primaryColor,

    colorScheme: base.colorScheme.copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      error: const Color(0xFFFF5252),
      surface: Colors.white,
    ),

    scaffoldBackgroundColor: const Color(0xFFFFF8FA),

    textTheme: buildTextTheme(base.textTheme),
    scrollbarTheme: const ScrollbarThemeData(),
    splashFactory: NoSplash.splashFactory,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF222222),
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        minimumSize: const Size(double.infinity, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(
          color: primaryColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),

    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      indicatorColor: primaryColor.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

TextTheme buildTextTheme(TextTheme base) {
  return base
      .copyWith(
        displayLarge: base.displayLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        displayMedium: base.displayMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        headlineLarge: base.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: base.titleMedium?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: base.bodyLarge?.copyWith(
          fontSize: 16,
        ),
        bodyMedium: base.bodyMedium?.copyWith(
          fontSize: 14,
        ),
      )
      .apply(
        fontFamily: 'Roboto',
      );
}