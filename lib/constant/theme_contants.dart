import 'package:flutter/material.dart';

class ThemeConstant {
  // === 2026 locked design tokens (mockups in /snapdrop_mockups) ===
  static const Color base = Color(0xFF142C1D); // base background
  static const Color glowCore = Color(0xFF2C9967); // glow core
  static const Color teal = Color(0xFF207D72); // teal
  static const Color surface = Color(0xFF1E2A23); // dialogs/sheets/cards
  static const Color ink = Color(0xFFFFFFFF); // primary text
  static const Color muted = Color(0xFF9BA39E); // labels/secondary
  static const Color accentGreen = Color(0xFF3BA873); // links/dots
  static const Color softGreen = Color(0xFF8FD9B0); // icons
  static const Color buttonInk = Color(0xFF0E1A12); // dark ink on white pills
  static const Color toastSurface = Color(0xFF222E27); // on-brand toast

  // Titles: ~800 weight, -0.015em tracking, white. (Inter tops at Bold —
  // w800 renders as Bold.) Left- or center-aligned per screen.
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32.0,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.48,
    color: ink,
  );
  static const TextStyle subtitleMuted = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    color: muted,
  );

  //App Primary Colors
  static const Color primaryAppColor = Color(0xff206946);
  //static const Color primaryAppColor = Color(0xFF005540);
  static const Color primaryAppColorGradient2 = Color(0xff071414);
  static const Color primaryAppColorGradient3 = Color(0xff040807);

  // White color constant for consistency
  static const Color whiteColor = Colors.white;

  // Green accent color constant
  static const Color greenAccentColor = Color(0xff39C679);

  static const Color primaryThemeColor = Color(0xff14291E);

  // Text styles
  static const TextStyle largeTextSize = TextStyle(
    fontSize: 42.0, // Use double precision for better rendering
    color: whiteColor,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
  );

  static const TextStyle mediumTextSizeDark = TextStyle(
    fontSize: 28.0, // Use double precision for better rendering
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
  );

  static const TextStyle smallTextSizeGrey = TextStyle(
    fontSize: 16.0, // Use double precision for better rendering
    color: Colors.black87,
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

  static const BoxDecoration appBackgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        ThemeConstant.primaryAppColor,
        ThemeConstant.primaryAppColorGradient2,
        ThemeConstant.primaryAppColorGradient3
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  // Helper methods for light and dark variations
  static TextStyle get smallTextSizeLight =>
      smallTextSize.copyWith(color: whiteColor);
  static TextStyle get smallTextSizeDark =>
      smallTextSize.copyWith(color: Colors.black);
  static TextStyle get smallTextSizeDarkFontWidth =>
      smallTextSizeFontWidth.copyWith(color: Colors.black);
  static TextStyle get smallTextSizeWhiteFontWidth =>
      smallTextSizeFontWidth.copyWith(color: Colors.white);
  static TextStyle get mediumTextSizeWhiteFontWidth =>
      mediumTextSizeDark.copyWith(color: Colors.white);
}
