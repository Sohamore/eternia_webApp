import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class VoiceRecordingScreen extends StatefulWidget {
  const VoiceRecordingScreen({super.key});

  @override
  State<VoiceRecordingScreen> createState() => _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends State<VoiceRecordingScreen> {
  bool isRecording = true;
  bool isPaused = false;
  int seconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isPaused) {
        setState(() => seconds++);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String _formatTime(int s) {
    int min = s ~/ 60;
    int sec = s % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  void _showSuccessPopup() {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0A1111) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF7CF5D7),
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              "Voice Entry Sent",
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Your unspoken thoughts are now safe.",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to BlackBox
              },
              child: Text(
                "Return to Sanctuary",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF7CF5D7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final bool isDark = provider.isDark;
    final Color primary = isDark
        ? const Color(0xFF7CF5D7)
        : const Color(0xFF53B29A);
    final Color bg = isDark ? const Color(0xFF040707) : const Color(0xFFF6F3ED);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              "Recording Voice Entry",
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white60 : const Color(0xFF70737C),
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 80),

            // WAVEFORM MOCK
            Center(
              child: Container(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    20,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 4,
                      height: isPaused ? 10 : (20 + (index % 5) * 15.0),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
            Text(
              _formatTime(seconds),
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : const Color(0xFF1B2722),
                fontSize: 48,
                fontWeight: FontWeight.w300,
              ),
            ),
            const Spacer(),

            // CONTROLS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFE7E2D8).withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _circleBtn(
                        Icons.delete_outline,
                        Colors.redAccent.withOpacity(0.2),
                        Colors.redAccent,
                        () => Navigator.pop(context),
                      ),
                      _circleBtn(
                        isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        primary.withOpacity(0.2),
                        primary,
                        () => setState(() => isPaused = !isPaused),
                      ),
                      _circleBtn(
                        Icons.send_rounded,
                        primary,
                        Colors.black,
                        _showSuccessPopup,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Tap to pause or send when finished",
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white38 : const Color(0xFF70737C),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(
    IconData icon,
    Color bg,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }
}
