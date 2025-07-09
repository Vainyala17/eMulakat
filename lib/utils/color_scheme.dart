import 'package:flutter/material.dart';

class AppColors {
  static const List<Color> availableColors = [
    Color(0xFFEDEEEE),
    Color(0xFF5A8BBA),
    Color(0xFF1E2226),
    Color(0xFF93A6AA),
    Color(0xFF817777),
    Color(0xFF39434D),
    Color(0xFF1F5278),
    Color(0xFFDD4B48),
    Color(0xFF545051),
    Color(0xFF526A5D),
  ];

  static const Color primary = Color(0xFF5A8BBA);
  static const Color secondary = Color(0xFF1F5278);
  static const Color background = Color(0xFFEDEEEE);
  static const Color surface = Color(0xFF93A6AA);
  static const Color error = Color(0xFFDD4B48);

  static const MaterialColor primarySwatch = MaterialColor(
    0xFF5A8BBA,
    <int, Color>{
      50: Color(0xFFE8F0F8),
      100: Color(0xFFC6DAED),
      200: Color(0xFFA0C2E1),
      300: Color(0xFF7AA9D4),
      400: Color(0xFF5E97CB),
      500: Color(0xFF5A8BBA),
      600: Color(0xFF4A7AA8),
      700: Color(0xFF3A6895),
      800: Color(0xFF2B5783),
      900: Color(0xFF1F4670),
    },
  );

  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    secondary: secondary,
    onSecondary: Colors.white,
    error: error,
    onError: Colors.white,
    background: background,
    onBackground: Color(0xFF1E2226),
    surface: surface,
    onSurface: Color(0xFF1E2226),
  );
}