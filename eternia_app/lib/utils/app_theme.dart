import 'package:flutter/material.dart';

class AppTheme {

  // =========================================================
  // LIGHT THEME COLORS
  // =========================================================

  static const Color lightBg = Color(0xFFF6F3ED);

  static const Color lightPrimary = Color(0xFF54784F);

  static const Color lightAccent = Color(0xFF4A7D73);

  static const Color lightCard = Colors.white;

  static const Color lightText = Color(0xFF1B2722);

  static const Color lightSubText = Color(0xFF70737C);

  static const Color lightBorder = Color(0xFFE7E2D8);

  // =========================================================
  // DARK THEME COLORS
  // =========================================================

  static const Color darkBg = Color(0xFF071011);

  static const Color darkPrimary = Color(0xFF67F5D4);

  static const Color darkAccent = Color(0xFF53B29A);

  static const Color darkCard = Color(0xFF0E1718);

  static const Color darkText = Colors.white;

  static const Color darkSubText = Colors.white70;

  static const Color darkBorder = Color(0xFF1A2B2B);

  // =========================================================
  // GET COLORS
  // =========================================================

  static Color primary(bool isDark) {
    return isDark ? darkPrimary : lightPrimary;
  }

  static Color accent(bool isDark) {
    return isDark ? darkAccent : lightAccent;
  }

  static Color background(bool isDark) {
    return isDark ? darkBg : lightBg;
  }

  static Color card(bool isDark) {
    return isDark
        ? darkCard
        : Colors.white.withOpacity(0.92);
  }

  static Color text(bool isDark) {
    return isDark ? darkText : lightText;
  }

  static Color subText(bool isDark) {
    return isDark ? darkSubText : lightSubText;
  }

  static Color border(bool isDark) {
    return isDark ? darkBorder : lightBorder;
  }

  // =========================================================
  // BACKGROUND GLOW
  // =========================================================

  static List<Widget> buildBackground(bool isDark) {
    return [

      // MAIN BACKGROUND

      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? RadialGradient(
                    center: const Alignment(-0.9, -1),
                    radius: 1.7,
                    colors: [
                      darkPrimary.withOpacity(0.18),
                      darkBg,
                    ],
                  )
                : const LinearGradient(
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

      // TOP GLOW

      _glow(
        Alignment.topRight,
        isDark
            ? darkPrimary.withOpacity(0.10)
            : lightPrimary.withOpacity(0.05),
        350,
      ),

      // BOTTOM GLOW

      _glow(
        Alignment.bottomLeft,
        isDark
            ? darkPrimary.withOpacity(0.06)
            : lightAccent.withOpacity(0.04),
        400,
      ),
    ];
  }

  // =========================================================
  // GLOW WIDGET
  // =========================================================

  static Widget _glow(
    Alignment alignment,
    Color color,
    double size,
  ) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}