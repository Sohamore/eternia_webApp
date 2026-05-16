// ==========================================================
// widgets/otp_box.dart
// ==========================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const OtpBox({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 74,

      child: TextField(
        controller: controller,

        textAlign: TextAlign.center,

        keyboardType: TextInputType.number,

        inputFormatters: [
          LengthLimitingTextInputFormatter(
            1,
          ),
        ],

        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,

          color:
              isDark
                  ? Colors.white
                  : Colors.black87,
        ),

        decoration: InputDecoration(
          filled: true,

          fillColor:
              isDark
                  ? Colors.white.withOpacity(
                    .03,
                  )
                  : Colors.white,

          contentPadding:
              EdgeInsets.zero,

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(18),

            borderSide: BorderSide(
              color:
                  isDark
                      ? const Color(
                        0xFF71E6D4,
                      )
                      : const Color(
                        0xFF7BA268,
                      ),
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(18),

            borderSide: BorderSide(
              color:
                  isDark
                      ? const Color(
                        0xFF71E6D4,
                      )
                      : const Color(
                        0xFF7BA268,
                      ),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(18),

            borderSide: BorderSide(
              width: 1.4,

              color:
                  isDark
                      ? const Color(
                        0xFF71E6D4,
                      )
                      : const Color(
                        0xFF7BA268,
                      ),
            ),
          ),
        ),

        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(
              context,
            ).nextFocus();
          }
        },
      ),
    );
  }
}