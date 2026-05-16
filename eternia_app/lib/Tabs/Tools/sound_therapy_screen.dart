// ==========================================================
// SOUND THERAPY SCREEN - CINEMATIC UPGRADE
// sound_therapy_screen.dart
// ==========================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class SoundTherapyScreen extends StatefulWidget {
  const SoundTherapyScreen({super.key});

  @override
  State<SoundTherapyScreen> createState() => _SoundTherapyScreenState();
}

class _SoundTherapyScreenState extends State<SoundTherapyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _pulseAnimation;
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  int currentTrackIndex = 0;

  final Color primaryColor = const Color(0xFF64FFE3);

  final List<Map<String, String>> tracks = [
    {
      "title": "Celestial Echoes",
      "image": "https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?w=800&q=80",
      "desc": "Zen Piano",
      "url": "assets/audio/leberch-meditation-meditation-music-523576.mp3"
    },
    {
      "title": "Whispering Willows",
      "image": "https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?w=800&q=80",
      "desc": "Soft Flute",
      "url": "assets/audio/leberch-meditation-meditation-music-523576.mp3"
    },
    {
      "title": "Etheric Rainfall",
      "image": "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80",
      "desc": "Rain & Chimes",
      "url": "assets/audio/leberch-meditation-meditation-music-523576.mp3"
    },
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _breathingController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut));
    
    _loadTrack(0);
  }

  Future<void> _loadTrack(int index) async {
    try {
      await _audioPlayer.setAsset(tracks[index]['url']!);
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  void _togglePlayback() async {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _audioPlayer.play();
        _breathingController.repeat(reverse: true);
      } else {
        _audioPlayer.pause();
        _breathingController.stop();
      }
    });
  }

  void _changeTrack(int index) async {
    setState(() {
      currentTrackIndex = index;
      isPlaying = false;
      _breathingController.stop();
    });
    await _audioPlayer.stop();
    await _loadTrack(index);
    _togglePlayback();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF040B0D) : const Color(0xFFF6F3ED),
      body: Stack(
        children: [
          // CINEMATIC BACKGROUND IMAGE
          AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: Container(
              key: ValueKey<int>(currentTrackIndex),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(tracks[currentTrackIndex]['image']!),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // HEADER
                _buildHeader(context),

                const Spacer(),

                // BREATHING CIRCLE
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        height: 220,
                        width: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withOpacity(0.05),
                          border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
                          boxShadow: [
                            BoxShadow(color: primaryColor.withOpacity(isPlaying ? 0.2 : 0.05), blurRadius: 100, spreadRadius: 30),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Center(
                        child: Text(
                          isPlaying ? "BREATHE" : "READY?",
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, letterSpacing: 4, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // TRACK INFO
                Text(
                  tracks[currentTrackIndex]['title']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(height: 8),
                Text(
                  tracks[currentTrackIndex]['desc']!.toUpperCase(),
                  style: GoogleFonts.poppins(color: primaryColor.withOpacity(0.8), fontSize: 11, letterSpacing: 4, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 56),

                // PLAYBACK CONTROLS
                _buildPlaybackControls(),

                const Spacer(),

                // TRACK PICKER
                _buildTrackPicker(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          Text("Sound Therapy", style: GoogleFonts.cormorantGaramond(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.surround_sound_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            int nextIndex = (currentTrackIndex - 1) % tracks.length;
            if (nextIndex < 0) nextIndex = tracks.length - 1;
            _changeTrack(nextIndex);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
            child: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(width: 32),
        GestureDetector(
          onTap: _togglePlayback,
          child: Container(
            height: 88,
            width: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle, 
              color: primaryColor,
              boxShadow: [
                BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))
              ],
            ),
            child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: const Color(0xFF040B0D), size: 48),
          ),
        ),
        const SizedBox(width: 32),
        GestureDetector(
          onTap: () {
            _changeTrack((currentTrackIndex + 1) % tracks.length);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
            child: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackPicker() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          bool isSelected = index == currentTrackIndex;
          return GestureDetector(
            onTap: () => _changeTrack(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(tracks[index]['image']!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    isSelected ? Colors.transparent : Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
                border: isSelected ? Border.all(color: primaryColor, width: 2) : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
