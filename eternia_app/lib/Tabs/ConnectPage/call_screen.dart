// ==========================================================
// CALL SCREEN - PREMIUM ADAPTIVE
// call_screen.dart
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final bool isDark = provider.isDark;

    final Color primary = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF53B29A);
    final Color bg = isDark ? const Color(0xFF040B0D) : const Color(0xFFF6F3ED);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1B2722);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                _buildCallIdentity(textPrimary, primary, isDark),
                const Spacer(),
                _buildCallStatus(textPrimary, primary, isDark),
                const SizedBox(height: 60),
                _buildControls(isDark, primary),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallIdentity(Color textPrimary, Color primary, bool isDark) {
    return Column(
      children: [
        Container(
          height: 120, width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primary.withOpacity(0.2), width: 2),
          ),
          child: Center(child: Icon(Icons.person, size: 60, color: isDark ? Colors.grey : Colors.black38)),
        ),
        const SizedBox(height: 24),
        Text(
          "Anonymous Node",
          style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
        ),
        Text(
          "SECURED CONNECTION",
          style: GoogleFonts.poppins(color: primary, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCallStatus(Color textPrimary, Color primary, bool isDark) {
    return Column(
      children: [
        Text("04:22", style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w200, color: textPrimary)),
        const SizedBox(height: 8),
        Text("Spatial Audio Active", style: GoogleFonts.poppins(color: primary.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildControls(bool isDark, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleBtn(Icons.mic_off_outlined, isDark ? Colors.grey : const Color(0xFF70737C), isDark: isDark),
          _buildCircleBtn(Icons.call_end, Colors.red, isEnd: true, isDark: isDark),
          _buildCircleBtn(Icons.volume_up_outlined, isDark ? Colors.grey : const Color(0xFF70737C), isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, Color color, {bool isEnd = false, required bool isDark}) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 70, width: 70,
        decoration: BoxDecoration(
          color: isEnd ? color : color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isEnd ? Colors.white : color, size: 28),
      ),
    );
  }
}

