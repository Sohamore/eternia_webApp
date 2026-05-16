// ==========================================================
// ETERNIA APP BAR - Reusable premium app bar
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eternia_ef/utils/eternia_theme.dart';

class EterniaAppBar extends StatelessWidget {
  final String? title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showBack;

  const EterniaAppBar({
    super.key,
    this.title,
    this.onBack,
    this.trailing,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = EterniaTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            GestureDetector(
              onTap: onBack ?? () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconSecondary, size: 20),
            )
          else
            const SizedBox(width: 20),
          if (title != null)
            Text(
              title!,
              style: GoogleFonts.cormorantGaramond(
                color: theme.primary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (trailing != null) trailing! else const SizedBox(width: 20),
        ],
      ),
    );
  }
}
