import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class LiveSessionScreen extends StatefulWidget {
  const LiveSessionScreen({super.key});

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  bool isMuted = false;
  bool isVideoOff = false;

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
        fit: StackFit.expand,
        children: [
          // EXPERT VIDEO (Mock)
          Image.network(
            "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&q=80",
            fit: BoxFit.cover,
          ),
          
          // BLUR OVERLAY FOR UI READABILITY
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // TOP CONTROLS
          Positioned(
            top: 50, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
                      const SizedBox(width: 6),
                      Text("LIVE", style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // MAIN UI
          Positioned(
            bottom: 40, left: 20, right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mindful Breathing",
                  style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Dr. Aria Vance is leading the session",
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // PARTICIPANTS BUBBLES
                Row(
                  children: [
                    _buildParticipantAvatar("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&q=80"),
                    _buildParticipantAvatar("https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&q=80"),
                    _buildParticipantAvatar("https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=100&q=80"),
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                      child: Text("+39 More", style: GoogleFonts.poppins(color: Colors.white, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // BOTTOM CONTROLS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlBtn(isMuted ? Icons.mic_off_rounded : Icons.mic_rounded, isMuted, () => setState(() => isMuted = !isMuted)),
                    const SizedBox(width: 20),
                    _buildControlBtn(Icons.front_hand_rounded, false, () {}),
                    const SizedBox(width: 20),
                    _buildControlBtn(isVideoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded, isVideoOff, () => setState(() => isVideoOff = !isVideoOff)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantAvatar(String url) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      height: 32, width: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildControlBtn(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isActive ? Colors.redAccent.withOpacity(0.9) : Colors.white10,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
