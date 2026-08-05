import 'package:flutter/material.dart';

/// Space Grotesk — sarlavhalar, Inter — matn, IBM Plex Mono — narxlar/raqamlar.
class AppTypography {
  AppTypography._();

  static const String heading = 'SpaceGrotesk';
  static const String body = 'Inter';
  static const String mono = 'IBMPlexMono';

  static TextTheme textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: heading, fontSize: 32, fontWeight: FontWeight.w700, color: primary, height: 1.2),
      displayMedium: TextStyle(fontFamily: heading, fontSize: 26, fontWeight: FontWeight.w700, color: primary, height: 1.2),
      headlineLarge: TextStyle(fontFamily: heading, fontSize: 22, fontWeight: FontWeight.w600, color: primary),
      headlineMedium: TextStyle(fontFamily: heading, fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      titleLarge: TextStyle(fontFamily: body, fontSize: 17, fontWeight: FontWeight.w600, color: primary),
      titleMedium: TextStyle(fontFamily: body, fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontFamily: body, fontSize: 15, fontWeight: FontWeight.w400, color: primary),
      bodyMedium: TextStyle(fontFamily: body, fontSize: 13, fontWeight: FontWeight.w400, color: secondary),
      labelLarge: TextStyle(fontFamily: body, fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      labelMedium: TextStyle(fontFamily: mono, fontSize: 13, fontWeight: FontWeight.w500, color: primary),
      labelSmall: TextStyle(fontFamily: body, fontSize: 11, fontWeight: FontWeight.w500, color: secondary),
    );
  }

  static const TextStyle price = TextStyle(fontFamily: mono, fontSize: 15, fontWeight: FontWeight.w600);
  static const TextStyle priceStrikethrough = TextStyle(
    fontFamily: mono,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.lineThrough,
  );
}
