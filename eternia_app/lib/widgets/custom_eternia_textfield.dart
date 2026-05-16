// ==========================================================
// widgets/custom_eternia_textfield.dart
// ==========================================================

import 'package:flutter/material.dart';

class CustomEterniaTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isDark;

  const CustomEterniaTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,

      style: TextStyle(
        color:
            isDark
                ? Colors.white
                : Colors.black87,
      ),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(
          color:
              isDark
                  ? Colors.white38
                  : Colors.black38,
        ),

        prefixIcon: Icon(
          icon,

          color:
              isDark
                  ? const Color(0xFF71E6D4)
                  : const Color(0xFF7BA268),
        ),

        filled: true,

        fillColor:
            isDark
                ? Colors.white.withOpacity(.04)
                : Colors.white,

        contentPadding:
            const EdgeInsets.symmetric(
          vertical: 18,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(20),

          borderSide: BorderSide(
            color:
                isDark
                    ? Colors.white10
                    : Colors.black12,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(20),

          borderSide: BorderSide(
            color:
                isDark
                    ? Colors.white10
                    : Colors.black12,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(20),

          borderSide: BorderSide(
            width: 1.3,

            color:
                isDark
                    ? const Color(0xFF71E6D4)
                    : const Color(0xFF7BA268),
          ),
        ),
      ),
    );
  }
}