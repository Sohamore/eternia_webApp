import 'dart:async';
import 'dart:ui';
import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


class DailyInsightDetailScreen extends StatelessWidget {
  final String insight;
  const DailyInsightDetailScreen({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final primary = isDark ? const Color(0xFF67F5D4) : const Color(0xFF53B29A);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1B2722);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF071011) : const Color(0xFFF6F3ED),
      body: Stack(
        children: [
          // Background Glows
          if (isDark) ...[
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withOpacity(0.1),
                ),
              ),
            ),
          ],
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios_new, color: textPrimary),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: primary, size: 50),
                        const SizedBox(height: 40),
                        Text(
                          insight,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 60),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: primary.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Mindfulness Tip",
                                style: GoogleFonts.poppins(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Take three deep breaths. Inhale for 4 seconds, hold for 4, and exhale for 8. Feel the tension leave your body.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: textPrimary.withOpacity(0.7),
                                  fontSize: 15,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Center(
                    child: Text(
                      "ETERNIA • DAILY WISDOM",
                      style: GoogleFonts.poppins(
                        color: textPrimary.withOpacity(0.3),
                        fontSize: 12,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}