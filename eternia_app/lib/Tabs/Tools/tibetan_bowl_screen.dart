// ==========================================================
// TIBETAN BOWL - LUXURY SOUND THERAPY
// UPDATED DARK/LIGHT THEME VERSION
// ==========================================================

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:eternia_ef/providers/theme_provider.dart';

class TibetanBowlScreen extends StatefulWidget {
  const TibetanBowlScreen({super.key});

  @override
  State<TibetanBowlScreen> createState() => _TibetanBowlScreenState();
}

class _TibetanBowlScreenState extends State<TibetanBowlScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _vibrationController;
  bool _isPlaying = false;
  double _volume = 0.8;
  int _timerMinutes = 0; // 0, 5, 10, 15

  @override
  void initState() {
    super.initState();

    _vibrationController = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _vibrationController.dispose();

    super.dispose();
  }

  void _toggleBowl() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _cycleVolume() {
    setState(() {
      if (_volume >= 1.0) {
        _volume = 0.0;
      } else {
        _volume += 0.5;
      }
    });
    String msg = _volume == 0.0 ? "Muted" : "Volume: ${(_volume * 100).toInt()}%";
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF53B29A),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        width: 150,
      ),
    );
  }

  void _cycleTimer() {
    setState(() {
      _timerMinutes = (_timerMinutes + 5) % 20;
    });
    String msg = _timerMinutes == 0 ? "Timer Off" : "Timer: $_timerMinutes min";
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF53B29A),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        width: 150,
      ),
    );
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
            _buildTopBar(context, textDark, cardBg),

            const Spacer(),

            // ===================================================
            // BOWL
            // ===================================================
            _buildBowl(primaryGreen),

            const Spacer(),

            // ===================================================
            // STATUS
            // ===================================================
            _buildSoundStatus(primaryGreen, textDark, textLight),

            const SizedBox(height: 40),

            // ===================================================
            // CONTROLS
            // ===================================================
            _buildBowlControls(primaryGreen, textDark, cardBg, borderColor),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // TOP BAR
  // =========================================================

  Widget _buildTopBar(BuildContext context, Color textDark, Color cardBg) {
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
  // BOWL
  // =========================================================

  Widget _buildBowl(Color primaryGreen) {
    return GestureDetector(
      onTap: _toggleBowl,

      child: AnimatedBuilder(
        animation: _vibrationController,

        builder: (context, child) {
          double shake = _isPlaying
              ? sin(_vibrationController.value * 2 * pi) * 2
              : 0;

          return Transform.translate(
            offset: Offset(shake, 0),

            child: Stack(
              alignment: Alignment.center,

              children: [
                // AMBIENT GLOW
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),

                  width: _isPlaying ? 320 : 260,

                  height: _isPlaying ? 320 : 260,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: primaryGreen.withOpacity(_isPlaying ? 0.10 : 0.04),

                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(_isPlaying ? 0.30 : 0),

                        blurRadius: 100,

                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),

                // IMAGE
                Image.asset(
                  "assets/images/singing_bowl.png",

                  height: 300,

                  fit: BoxFit.contain,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // STATUS
  // =========================================================

  Widget _buildSoundStatus(
    Color primaryGreen,
    Color textDark,
    Color textLight,
  ) {
    return Column(
      children: [
        Text(
          _isPlaying ? "RESONATING..." : "STILLNESS",

          style: GoogleFonts.poppins(
            color: primaryGreen,

            fontSize: 11,

            fontWeight: FontWeight.bold,

            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          _isPlaying
              ? "Feel the healing vibrations."
              : "Tap the bowl to begin the resonance.",

          style: GoogleFonts.poppins(color: textLight, fontSize: 14),
        ),
      ],
    );
  }

  // =========================================================
  // CONTROLS
  // =========================================================

  Widget _buildBowlControls(
    Color primaryGreen,
    Color textDark,
    Color cardBg,
    Color borderColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        // VOLUME
        _buildMiniBtn(
          _volume == 0.0 ? Icons.volume_off_outlined : Icons.volume_up_outlined,
          textDark,
          cardBg,
          borderColor,
          _cycleVolume,
        ),

        const SizedBox(width: 32),

        // PLAY BUTTON
        GestureDetector(
          onTap: _toggleBowl,

          child: Container(
            height: 90,
            width: 90,

            decoration: BoxDecoration(
              color: primaryGreen,

              shape: BoxShape.circle,

              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withOpacity(0.35),

                  blurRadius: 28,

                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,

              color: Colors.white,

              size: 42,
            ),
          ),
        ),

        const SizedBox(width: 32),

        // TIMER
        _buildMiniBtn(
          _timerMinutes == 0 ? Icons.timer_outlined : Icons.timer_rounded,
          textDark,
          cardBg,
          borderColor,
          _cycleTimer,
        ),
      ],
    );
  }

  // =========================================================
  // MINI BUTTON
  // =========================================================

  Widget _buildMiniBtn(
    IconData icon,
    Color textDark,
    Color cardBg,
    Color borderColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12),
          ],
        ),
        child: Icon(icon, color: textDark, size: 24),
      ),
    );
  }
}
