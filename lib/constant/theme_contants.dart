import 'package:flutter/material.dart';

class ThemeConstant {
  // White color constant for consistency
  static const Color whiteColor = Colors.white;

  // Green accent color constant
  static const Color greenAccentColor = Color(0xff39C679);

  // Text styles
  static const TextStyle largeTextSize = TextStyle(
    fontSize: 32.0, // Use double precision for better rendering
    color: whiteColor,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
  );

  static const TextStyle smallTextSize = TextStyle(
    fontSize: 16.0, // Double precision for consistency
    fontFamily: 'Inter',
  );

  // Helper methods for light and dark variations
  static TextStyle get smallTextSizeLight =>
      smallTextSize.copyWith(color: whiteColor);
  static TextStyle get smallTextSizeDark =>
      smallTextSize.copyWith(color: Colors.black);
}
