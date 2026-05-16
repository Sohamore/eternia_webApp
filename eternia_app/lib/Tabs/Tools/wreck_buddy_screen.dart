// ==========================================================
// WRECK BUDDY - PREMIUM SOUL BUDDY
// UPDATED DARK/LIGHT THEME VERSION
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:eternia_ef/providers/theme_provider.dart';

class WreckBuddyScreen extends StatefulWidget {
  const WreckBuddyScreen({super.key});

  @override
  State<WreckBuddyScreen> createState() => _WreckBuddyScreenState();
}

class _WreckBuddyScreenState extends State<WreckBuddyScreen> {
  double _scale = 1.0;

  void _punch() {
    setState(() {
      _scale = 0.9;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _scale = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final isDark = themeProvider.isDark;

    // =========================================================
    // THEME COLORS
    // =========================================================

    final Color bgColor = isDark
        ? const Color(0xFF071011)
        : const Color(0xFFF6F3ED);

    final Color primaryGreen = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF53B29A);

    final Color textDark = isDark ? Colors.white : const Color(0xFF1B2722);

    final Color textLight = isDark ? Colors.white70 : const Color(0xFF70737C);

    final Color cardBg = isDark
        ? const Color(0xFF0E1718)
        : Colors.white.withOpacity(0.92);

    final Color borderColor = isDark
        ? const Color(0xFF1A2B2B)
        : const Color(0xFFE7E2D8);

    return Scaffold(
      backgroundColor: bgColor,

      body: SafeArea(
        child: Column(
          children: [
            // ===================================================
            // TOP BAR
            // ===================================================
            _buildTopBar(context, textDark, cardBg, borderColor),

            const Spacer(),

            // ===================================================
            // BUDDY
            // ===================================================
            _buildBuddy(_scale, primaryGreen),

            const SizedBox(height: 40),

            // ===================================================
            // TITLE
            // ===================================================
            Text(
              "Release Stress\nNaturally",

              textAlign: TextAlign.center,

              style: GoogleFonts.playfairDisplay(
                color: textDark,

                fontSize: 34,

                fontWeight: FontWeight.bold,

                height: 1.2,
              ),
            ),

            const SizedBox(height: 16),

            // ===================================================
            // SUBTITLE
            // ===================================================
            Text(
              "Tap to release your stress.\nYour buddy can take it.",

              textAlign: TextAlign.center,

              style: GoogleFonts.poppins(
                color: textLight,

                fontSize: 14,

                height: 1.6,
              ),
            ),

            const Spacer(),

            // ===================================================
            // BUTTON
            // ===================================================
            _buildActionButton(primaryGreen),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // TOP BAR
  // =========================================================

  Widget _buildTopBar(
    BuildContext context,
    Color textDark,
    Color cardBg,
    Color borderColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),

      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // BACK BUTTON
          GestureDetector(
            onTap: () => Navigator.pop(context),

            child: Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: cardBg,

                shape: BoxShape.circle,

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),

                    blurRadius: 10,
                  ),
                ],
              ),

              child: Icon(Icons.arrow_back, color: textDark, size: 22),
            ),
          ),
          const SizedBox(width: 24),
          // TITLE
          Text(
            "Singing Bowl",

            style: GoogleFonts.playfairDisplay(
              color: textDark,

              fontSize: 24,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BUDDY
  // =========================================================

  Widget _buildBuddy(double scale, Color primaryGreen) {
    return GestureDetector(
      onTap: _punch,

      child: AnimatedScale(
        scale: scale,

        duration: const Duration(milliseconds: 100),

        child: SizedBox(
          height: 340,

          child: Stack(
            alignment: Alignment.center,

            children: [
              // GLOW
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),

                width: scale == 0.9 ? 270 : 240,

                height: scale == 0.9 ? 270 : 240,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: primaryGreen.withOpacity(0.10),

                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.25),

                      blurRadius: 90,

                      spreadRadius: 6,
                    ),
                  ],
                ),
              ),

              // IMAGE
              Image.asset(
                "assets/images/wreck_buddy.png",

                height: 300,

                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BUTTON
  // =========================================================

  Widget _buildActionButton(Color primaryGreen) {
    return GestureDetector(
      onTap: _punch,

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),

        height: 62,

        decoration: BoxDecoration(
          color: primaryGreen,

          borderRadius: BorderRadius.circular(32),

          boxShadow: [
            BoxShadow(
              color: primaryGreen.withOpacity(0.35),

              blurRadius: 24,

              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.touch_app_rounded, color: Colors.white, size: 22),

            const SizedBox(width: 12),

            Text(
              "TAP TO RELEASE",

              style: GoogleFonts.poppins(
                color: Colors.white,

                fontSize: 13,

                fontWeight: FontWeight.bold,

                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
