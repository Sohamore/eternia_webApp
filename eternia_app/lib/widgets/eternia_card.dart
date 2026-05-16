// ==========================================================
// ETERNIA CARD - Reusable premium card widget
// ==========================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:eternia_ef/utils/eternia_theme.dart';

class EterniaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;

  const EterniaCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 28,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = EterniaTheme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: color ?? theme.card,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor ?? theme.border),
            boxShadow: theme.cardShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
