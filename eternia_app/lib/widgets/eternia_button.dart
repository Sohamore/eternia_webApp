// ==========================================================
// ETERNIA BUTTON - Reusable premium button
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eternia_ef/utils/eternia_theme.dart';

class EterniaButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final bool outlined;
  final double? width;

  const EterniaButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.outlined = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = EterniaTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width ?? double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : theme.buttonBg,
          borderRadius: BorderRadius.circular(16),
          border: outlined ? Border.all(color: theme.primary.withOpacity(0.4)) : null,
          boxShadow: outlined
              ? []
              : [BoxShadow(color: theme.primary.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                color: outlined ? theme.primary : theme.buttonText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, color: outlined ? theme.primary : theme.buttonText, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
