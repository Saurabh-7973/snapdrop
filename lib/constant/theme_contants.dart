import 'package:flutter/material.dart';

class ThemeConstant {
  //App Primary Colors
  static const Color primaryAppColor = Color(0xff206946);
  static const Color primaryAppColorGradient2 = Color(0xff071414);
  static const Color primaryAppColorGradient3 = Color(0xff040807);

  // White color constant for consistency
  static const Color whiteColor = Colors.white;

  // Green accent color constant
  static const Color greenAccentColor = Color(0xff39C679);

  static const Color primaryThemeColor = Color(0xff14291E);

  // Text styles
  static const TextStyle largeTextSize = TextStyle(
    fontSize: 40.0, // Use double precision for better rendering
    color: whiteColor,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
  );

  static const TextStyle smallTextSize = TextStyle(
    fontSize: 16.0, // Double precision for consistency
    fontFamily: 'Inter',
  );

  static const TextStyle smallTextSizeFontWidth = TextStyle(
      fontSize: 18.0, // Double precision for consistency
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600);

  // Helper methods for light and dark variations
  static TextStyle get smallTextSizeLight =>
      smallTextSize.copyWith(color: whiteColor);
  static TextStyle get smallTextSizeDark =>
      smallTextSize.copyWith(color: Colors.black);
  static TextStyle get smallTextSizeDarkFontWidth =>
      smallTextSizeFontWidth.copyWith(color: Colors.black);
  static TextStyle get smallTextSizeWhiteFontWidth =>
      smallTextSizeFontWidth.copyWith(color: Colors.white);
}
