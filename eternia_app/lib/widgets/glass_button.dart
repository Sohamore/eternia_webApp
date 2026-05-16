import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final TextStyle? style;

  const GlassButton({super.key, required this.text, this.onTap, this.style});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final isDark = provider.isDark;

    final Color primaryColor = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF53B29A);
    final Color primaryLight = isDark
        ? const Color(0xFF97FFE7)
        : const Color(0xFF7DCDB8);

    return Container(
      height: 62,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          colors: [primaryColor, primaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.35),
            blurRadius: 40,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: style ?? TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
