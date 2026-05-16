// ==========================================================
// ETERNIA THEME HELPER
// Centralized theme colors — matches Home Screen exactly
// ==========================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class EterniaTheme {
  final bool isDark;

  EterniaTheme._(this.isDark);

  factory EterniaTheme.of(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    return EterniaTheme._(provider.isDark);
  }

  // PRIMARY — exact Home Screen colors
  Color get primary => isDark
      ? const Color(0xFF67F5D4)
      : const Color(0xFF53B29A);

  // BACKGROUNDS — exact Home Screen colors
  Color get bg => isDark
      ? const Color(0xFF071011)
      : const Color(0xFFF6F3ED);

  // CARDS — exact Home Screen colors
  Color get card => isDark
      ? const Color(0xFF0E1718)
      : Colors.white.withOpacity(0.92);

  Color get cardSolid => isDark
      ? const Color(0xFF0E1718)
      : Colors.white;

  // BORDERS — exact Home Screen colors
  Color get border => isDark
      ? const Color(0xFF1A2B2B)
      : const Color(0xFFE7E2D8);

  // TEXT — exact Home Screen colors
  Color get textPrimary => isDark
      ? Colors.white
      : const Color(0xFF1B2722);

  Color get textSecondary => isDark
      ? Colors.white70
      : const Color(0xFF70737C);

  Color get textTertiary => isDark
      ? Colors.white38
      : const Color(0xFF9DA3A8);

  // ICONS
  Color get iconPrimary => primary;
  Color get iconSecondary => isDark ? Colors.white54 : const Color(0xFF70737C);

  // BUTTON
  Color get buttonBg => primary;
  Color get buttonText => isDark ? Colors.black : Colors.white;

  // SHADOWS — exact Home Screen style
  List<BoxShadow> get cardShadow => isDark
      ? [BoxShadow(color: primary.withOpacity(0.06), blurRadius: 28)]
      : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 10))];

  // GRADIENTS
  LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, primary.withOpacity(0.85)],
  );

  // GLASSMORPHISM
  Color get glassColor => isDark
      ? Colors.white.withOpacity(0.04)
      : Colors.white.withOpacity(0.92);

  Color get glassBorder => isDark
      ? const Color(0xFF1A2B2B)
      : const Color(0xFFE7E2D8);
}
