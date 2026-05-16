// ==========================================================
// CREATE ENTRY SCREEN - PREMIUM ADAPTIVE
// create_entry_screen.dart
// ==========================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:eternia_ef/utils/theme_config.dart';
import 'package:eternia_ef/Tabs/BlackBox/voice_recording_screen.dart';

class CreateEntryScreen extends StatefulWidget {
  const CreateEntryScreen({super.key});

  @override
  State<CreateEntryScreen> createState() => _CreateEntryScreenState();
}

class _CreateEntryScreenState extends State<CreateEntryScreen> {
  String selectedMood = "Neutral";

  final List<Map<String, dynamic>> moods = [
    {"icon": Icons.sentiment_very_satisfied, "label": "Joyful"},
    {"icon": Icons.sentiment_satisfied, "label": "Calm"},
    {"icon": Icons.sentiment_neutral, "label": "Neutral"},
    {"icon": Icons.sentiment_dissatisfied, "label": "Anxious"},
    {"icon": Icons.sentiment_very_dissatisfied, "label": "Overwhelm"},
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDark;
    final primaryColor = isDark
        ? SanctuaryTheme.darkPrimary
        : SanctuaryTheme.lightPrimary;
    final textColor = isDark ? Colors.white : SanctuaryTheme.lightPrimary;
    final cardColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.7);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.5);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF120F18) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: textColor.withOpacity(0.4)),
                  ),
                  Text(
                    "New Reflection",
                    style: GoogleFonts.cormorantGaramond(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Save",
                      style: GoogleFonts.poppins(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      "HOW ARE YOU FEELING?",
                      style: GoogleFonts.poppins(
                        color: primaryColor.withOpacity(0.6),
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildMoodSelector(
                      primaryColor,
                      isDark,
                      cardColor,
                      borderColor,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "YOUR THOUGHTS",
                      style: GoogleFonts.poppins(
                        color: primaryColor.withOpacity(0.6),
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(isDark, cardColor, borderColor),
                    const SizedBox(height: 40),
                    _buildRecordToggle(
                      primaryColor,
                      isDark,
                      cardColor,
                      borderColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector(
    Color primaryColor,
    bool isDark,
    Color cardColor,
    Color borderColor,
  ) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: moods.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedMood == moods[index]['label'];
          return GestureDetector(
            onTap: () => setState(() => selectedMood = moods[index]['label']),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? primaryColor : borderColor,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    moods[index]['icon'],
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.white)
                        : primaryColor,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    moods[index]['label'],
                    style: GoogleFonts.poppins(
                      color: isSelected
                          ? (isDark ? Colors.black : Colors.white)
                          : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(bool isDark, Color cardColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.greenAccent),
      ),
      child: TextField(
        maxLines: 8,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: "Begin expressing yourself...",
          hintStyle: GoogleFonts.poppins(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRecordToggle(
    Color primaryColor,
    bool isDark,
    Color cardColor,
    Color borderColor,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VoiceRecordingScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.greenAccent),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mic, color: primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Voice Note",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Express through sound",
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_outline, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
