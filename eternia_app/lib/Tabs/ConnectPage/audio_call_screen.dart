import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class AudioCallScreen extends StatefulWidget {
  final String counselorName;
  final String avatarUrl;
  const AudioCallScreen({
    super.key,
    required this.counselorName,
    required this.avatarUrl,
  });

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  bool isMuted = false;
  bool isSpeakerOn = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final bool isDark = provider.isDark;

    final Color primary = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF53B29A);
    final Color bg = isDark ? const Color(0xFF040B0D) : const Color(0xFFF6F3ED);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // WAVE DESIGN (Background)
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [primary.withOpacity(0.15), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: isDark ? Colors.white70 : Colors.black54,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.security, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "SECURE CALL",
                        style: GoogleFonts.poppins(
                          color: Colors.green,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),

                const Spacer(),

                // AVATAR
                Container(
                  height: 180,
                  width: 180,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(90),
                    child: Image.network(widget.avatarUrl, fit: BoxFit.cover),
                  ),
                ),

                const SizedBox(height: 32),

                // NAME & TIMER
                Text(
                  widget.counselorName,
                  style: GoogleFonts.playfairDisplay(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "04:20",
                  style: GoogleFonts.poppins(
                    color: primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),

                const Spacer(),

                // CONTROLS
                Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControl(
                        isMuted ? Icons.mic_off : Icons.mic,
                        "Mute",
                        isMuted,
                        () => setState(() => isMuted = !isMuted),
                        isDark,
                        primary,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 72,
                          width: 72,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      _buildControl(
                        isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                        "Speaker",
                        isSpeakerOn,
                        () => setState(() => isSpeakerOn = !isSpeakerOn),
                        isDark,
                        primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControl(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
    bool isDark,
    Color primary,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: isActive
                  ? primary
                  : (isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05)),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.1),
              ),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? Colors.white70 : Colors.black54),
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
