import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:eternia_ef/providers/theme_provider.dart';

class EmergencySupportScreen extends StatefulWidget {
  const EmergencySupportScreen({super.key});

  @override
  State<EmergencySupportScreen> createState() => _EmergencySupportScreenState();
}

class _EmergencySupportScreenState extends State<EmergencySupportScreen> {
  // =========================================================
  // CALL FUNCTION
  // =========================================================

  Future<void> _callNumber(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final bool isDark = themeProvider.isDark;

    final Color primaryColor = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF53B29A);

    final Color dangerColor = const Color(0xFFE53935);

    final Color bg = isDark ? const Color(0xFF071011) : const Color(0xFFF6F3ED);

    final Color textColor = isDark ? Colors.white : const Color(0xFF1B2722);

    final Color cardColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.white.withOpacity(0.92);

    final Color borderColor = isDark
        ? const Color(0xFF1A2B2B)
        : const Color(0xFFE7E2D8);

    return Scaffold(
      backgroundColor: bg,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ===================================================
              // HEADER
              // ===================================================
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),

                    child: Container(
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        border: Border.all(color: borderColor),
                      ),

                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: textColor,
                        size: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "Emergency Support",

                          style: GoogleFonts.playfairDisplay(
                            color: dangerColor,

                            fontSize: 34,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "If you're in crisis, help is available now.",

                          style: GoogleFonts.poppins(
                            color: textColor.withOpacity(0.6),

                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ===================================================
              // CRISIS CARD
              // ===================================================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(28),

                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C0A0A)
                      : const Color(0xFFFFF0F0),

                  borderRadius: BorderRadius.circular(32),

                  border: Border.all(color: dangerColor.withOpacity(0.3)),
                ),

                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: dangerColor.withOpacity(0.15),

                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        Icons.phone_in_talk,
                        color: dangerColor,
                        size: 42,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      "Crisis Helpline",

                      style: GoogleFonts.playfairDisplay(
                        color: dangerColor,

                        fontSize: 30,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Available 24/7. Completely confidential.",

                      textAlign: TextAlign.center,

                      style: GoogleFonts.poppins(
                        color: textColor.withOpacity(0.6),

                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 28),

                    GestureDetector(
                      onTap: () => _callNumber("8010594617"),

                      child: Container(
                        width: double.infinity,

                        height: 58,

                        decoration: BoxDecoration(
                          color: dangerColor,

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            const Icon(Icons.phone, color: Colors.white),

                            const SizedBox(width: 12),

                            Text(
                              "Call 8010594617",

                              style: GoogleFonts.poppins(
                                color: Colors.white,

                                fontWeight: FontWeight.bold,

                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ===================================================
              // OTHER RESOURCES
              // ===================================================
              Text(
                "OTHER RESOURCES",

                style: GoogleFonts.poppins(
                  color: primaryColor,

                  fontSize: 12,

                  letterSpacing: 2,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _resourceTile(
                "Crisis Text Line",
                "Text HOME to 741741",
                Icons.chat_outlined,
                primaryColor,
                textColor,
                borderColor,
                () => _callNumber("9156046848"),
              ),

              const SizedBox(height: 14),

              _resourceTile(
                "Emergency Services",
                "Immediate emergency support",
                Icons.local_hospital_outlined,
                primaryColor,
                textColor,
                borderColor,
                () => _callNumber("112"),
              ),

              const SizedBox(height: 14),

              _resourceTile(
                "Eternia Counselor",
                "Connect with a professional",
                Icons.psychology_outlined,
                primaryColor,
                textColor,
                borderColor,
                () => _callNumber("108"),
              ),

              const SizedBox(height: 34),

              // ===================================================
              // SAFETY PLAN
              // ===================================================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: cardColor,

                  borderRadius: BorderRadius.circular(24),

                  border: Border.all(color: borderColor),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  // children: [
                  //   Row(
                  //     children: [
                  //       Icon(Icons.shield_outlined, color: primaryColor),

                  //       const SizedBox(width: 12),

                  //       Text(
                  //         "Safety Plan",

                  //         style: GoogleFonts.poppins(
                  //           color: textColor,

                  //           fontSize: 16,

                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ],
                  //   ),

                  //   const SizedBox(height: 16),

                  //   Text(
                  //     "Create a personalized safety plan with coping strategies, trusted contacts, and professional resources.",

                  //     style: GoogleFonts.poppins(
                  //       color: textColor.withOpacity(0.6),

                  //       fontSize: 12,

                  //       height: 1.6,
                  //     ),
                  //   ),

                  //   const SizedBox(height: 24),

                  //   Container(
                  //     width: double.infinity,

                  //     padding: const EdgeInsets.symmetric(vertical: 16),

                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(16),

                  //       border: Border.all(
                  //         color: primaryColor.withOpacity(0.5),
                  //       ),

                  //       color: primaryColor.withOpacity(0.05),
                  //     ),

                  //     alignment: Alignment.center,

                  //     child: Text(
                  //       "Create Plan",

                  //       style: GoogleFonts.poppins(
                  //         color: primaryColor,

                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  // ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // RESOURCE TILE
  // =========================================================

  Widget _resourceTile(
    String title,
    String subtitle,
    IconData icon,
    Color primaryColor,
    Color textColor,
    Color borderColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(20),

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: borderColor),
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.12),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(icon, color: primaryColor, size: 22),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: GoogleFonts.poppins(
                      color: textColor,

                      fontSize: 14,

                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,

                    style: GoogleFonts.poppins(
                      color: textColor.withOpacity(0.6),

                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: textColor.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}
