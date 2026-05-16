// ==========================================================
// SANCTUARY THEME CONFIGURATION - VIBRANT MODE
// theme_config.dart
// ==========================================================

import 'package:flutter/material.dart';

class SanctuaryTheme {
  // LIGHT THEME COLORS
  static const Color lightBg = Color(0xFFF6F3ED);
  static const Color lightPrimary = Color(0xFF53B29A);
  static const Color lightAccent = Color(0xFF4A7D73);
  static const Color lightCard = Colors.white;
  static const Color lightBorder = Color(0x0F000000);

  // DARK THEME COLORS
  static const Color darkBg = Color(0xFF0A1214);
  static const Color darkPrimary = Color(0xFF67F5D4);
  static const Color darkCard = Color(0xFF141D1F);
  static const Color darkBorder = Color(0x1AFFFFFF);

  // VIBRANT GRADIENT GETTER
  static List<Widget> buildBackgroundGlow(bool isDark) {
    if (isDark) {
      return [
        // Dark solid background
        Positioned.fill(
          child: Container(color: const Color(0xFF040B0D)),
        ),
        _glow(Alignment.topRight, darkPrimary.withOpacity(0.12), 350),
        _glow(Alignment.bottomLeft, darkPrimary.withOpacity(0.08), 400),
      ];
    } else {
      // Light mode — solid warm light background matching home screen
      return [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8F5EF),
                  Color(0xFFF6F3ED),
                  Color(0xFFF3EFE7),
                ],
              ),
            ),
          ),
        ),
        _glow(Alignment.topRight, lightPrimary.withOpacity(0.05), 350),
        _glow(Alignment.bottomLeft, const Color(0xFF9BC283).withOpacity(0.04), 400),
      ];
    }
  }

  static Widget _glow(Alignment alignment, Color color, double size) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}
