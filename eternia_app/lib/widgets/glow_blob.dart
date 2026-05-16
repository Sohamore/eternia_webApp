import 'package:flutter/material.dart';

class GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double top;
  final double left;
  final double right;
  final double bottom;

  const GlowBlob({
    super.key,
    required this.color,
    required this.size,
    this.top = 0,
    this.left = 0,
    this.right = 0,
    this.bottom = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left == 0 ? null : left,
      right: right == 0 ? null : right,
      bottom: bottom == 0 ? null : bottom,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.6),
              blurRadius: 120,
              spreadRadius: 40,
            )
          ],
        ),
      ),
    );
  }
}