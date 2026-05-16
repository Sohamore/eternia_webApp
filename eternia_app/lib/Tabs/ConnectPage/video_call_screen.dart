import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class VideoCallScreen extends StatefulWidget {
  final String counselorName;
  final String avatarUrl;
  const VideoCallScreen({super.key, required this.counselorName, required this.avatarUrl});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool isMuted = false;
  bool isCameraOff = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final bool isDark = provider.isDark;

    final Color primary = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF53B29A);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // MAIN VIDEO (Background)
          Opacity(
            opacity: isCameraOff ? 0.3 : 1.0,
            child: Image.network(
              widget.avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
            ),
          ),

          // BLUR OVERLAY
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: isCameraOff ? 10 : 2, sigmaY: isCameraOff ? 10 : 2),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),

          // TOP HEADER
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFF70737C), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.counselorName, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: primary, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text("08:42", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // SELF VIEW
          Positioned(
            top: 120,
            right: 20,
            child: Container(
              height: 160,
              width: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24, width: 2),
                boxShadow: [BoxShadow(color: const Color(0xFF70737C), blurRadius: 20)],
                image: const DecorationImage(
                  image: NetworkImage("https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&q=80"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // BOTTOM CONTROLS
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 50, top: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControl(isMuted ? Icons.mic_off : Icons.mic, "Mute", isMuted, () => setState(() => isMuted = !isMuted)),
                  _buildControl(isCameraOff ? Icons.videocam_off : Icons.videocam, "Video", isCameraOff, () => setState(() => isCameraOff = !isCameraOff)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 70, width: 70,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)],
                      ),
                      child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                    ),
                  ),
                  _buildControl(Icons.flip_camera_ios, "Flip", false, () {}),
                  _buildControl(Icons.more_horiz, "More", false, () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControl(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 52, width: 52,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white12,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isActive ? Colors.black : Colors.white, size: 22),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}
