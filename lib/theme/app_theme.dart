import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightBackground = Color(0xFFF2F2F7); // Only for home screen
  static const Color lightScreenBackground = Colors.white; // For other screens

  // Updated to dark grey colors instead of navy/blue
  static const Color darkBackground = Color(0xFF1E1E1E);       // Dark grey background
  static const Color darkCardColor = Color(0xFF2A2A2A);        // Slightly lighter card color
  static const Color darkHoverColor = Color(0xFF3A3A3A);       // Hover state color

  static const Color cardColor = Colors.white;
  static const Color redAccent = Color(0xFFEF4444); // red-500

  // Helper method to create TextStyle with variable fonts
  static TextStyle _textStyle({
    required String fontFamily,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
  }) {
    // Convert FontWeight to numeric value for variable fonts
    double weightValue;
    switch (fontWeight) {
      case FontWeight.w100:
        weightValue = 100;
        break;
      case FontWeight.w200:
        weightValue = 200;
        break;
      case FontWeight.w300:
        weightValue = 300;
        break;
      case FontWeight.w400:
        weightValue = 400;
        break;
      case FontWeight.w500:
        weightValue = 500;
        break;
      case FontWeight.w600:
        weightValue = 600;
        break;
      case FontWeight.w700:
        weightValue = 700;
        break;
      case FontWeight.w800:
        weightValue = 800;
        break;
      case FontWeight.w900:
        weightValue = 900;
        break;
      default:
        weightValue = 400;
    }

    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontVariations: [
        FontVariation('wght', weightValue),
      ],
      color: color,
      height: height,
    );
  }

  // Specific font style getters
  static TextStyle dmSerifDisplay({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
  }) {
    return _textStyle(
      fontFamily: 'DMSerifDisplay', // Make sure this font is defined in pubspec.yaml
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle inter({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
  }) {
    return _textStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle cardo({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
  }) {
    return _textStyle(
      fontFamily: 'Cardo', // Make sure this font is defined in pubspec.yaml
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightScreenBackground,
    cardColor: cardColor,
    textTheme: TextTheme(
      displayLarge: _textStyle(
        fontFamily: 'DMSerifDisplay',
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      headlineMedium: _textStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      bodyLarge: _textStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      bodyMedium: _textStyle(
        fontFamily: 'Cardo',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Colors.black,
        height: 1.6,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      titleTextStyle: _textStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: redAccent,
      unselectedItemColor: Colors.grey[400],
      type: BottomNavigationBarType.fixed,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkCardColor,
    textTheme: TextTheme(
      displayLarge: _textStyle(
        fontFamily: 'DMSerifDisplay',
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      headlineMedium: _textStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: _textStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      bodyMedium: _textStyle(
        fontFamily: 'Cardo',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        height: 1.6,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: _textStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkBackground,
      selectedItemColor: redAccent,
      unselectedItemColor: Colors.grey[400],
      type: BottomNavigationBarType.fixed,
    ),
  );
}