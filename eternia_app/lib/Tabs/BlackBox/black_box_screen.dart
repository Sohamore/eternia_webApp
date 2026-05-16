// ==========================================================
// BLACKBOX SCREEN - FINAL PREMIUM VERSION
// black_box_screen.dart
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:eternia_ef/Tabs/BlackBox/create_entry_screen.dart';
import 'package:eternia_ef/Tabs/BlackBox/voice_recording_screen.dart';
import 'package:eternia_ef/Tabs/BlackBox/journal_writing_screen.dart';
import 'package:eternia_ef/Tabs/BlackBox/memory_archive_screen.dart';
import 'package:eternia_ef/Tabs/BlackBox/memory_history_screen.dart';

class BlackBoxScreen extends StatefulWidget {
  const BlackBoxScreen({super.key});

  @override
  State<BlackBoxScreen> createState() => _BlackBoxScreenState();
}

class _BlackBoxScreenState extends State<BlackBoxScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);

    bool isDark = provider.isDark;
    final Color primaryColor = isDark
        ? const Color(0xFF7CF5D7)
        : const Color(0xFF5EAE9A);

    final Color bgColor = isDark
        ? const Color(0xFF040707)
        : const Color(0xFFF7F4EC);

    final Color cardColor = isDark
        ? const Color(0xFF0A1111)
        : Colors.white.withOpacity(0.82);

    final Color textColor = isDark ? Colors.white : const Color(0xFF28312D);

    final Color subText = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,

      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

              children: [
                // =====================================================
                // APPBAR
                // =====================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu, color: primaryColor, size: 30),

                        const SizedBox(width: 14),

                        Text(
                          "Eternia",
                          style: GoogleFonts.cormorantGaramond(
                            color: primaryColor,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) => const MemoryHistoryScreen(),
                                ),
                              ),
                          child: Container(
                            height: 54,
                            width: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? Colors.white12 : Colors.black12,
                              ),
                            ),
                            child: Icon(
                              Icons.history_rounded,
                              color: primaryColor,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Divider(color: isDark ? Colors.white10 : Colors.black12),

                const SizedBox(height: 26),

                // =====================================================
                // HERO SECTION
                // =====================================================
                SizedBox(
                  height: 420,

                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(34),
                          child: Image.asset(
                            isDark
                                ? "assets/figma/Blackbox_background_black.png"
                                : "assets/figma/Blackbox_background_white.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(34),

                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(isDark ? 0.30 : 0.08),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                          left: 22,
                          top: 28,
                          bottom: 34,
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Spacer(),

                            Text(
                              "Express\nFreely",
                              style: GoogleFonts.playfairDisplay(
                                color: const Color.fromARGB(255, 158, 202, 190),
                                fontSize: 60,
                                height: 1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 18),

                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 22),

                            SizedBox(
                              width: 220,

                              child: Text(
                                "A sacred space for your unspoken thoughts.\nYour emotions, encrypted in light and silence.",

                                style: GoogleFonts.poppins(
                                  color: const Color.fromARGB(179, 0, 0, 0),
                                  fontSize: 13,
                                  height: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // =====================================================
                // VOICE ENTRY
                // =====================================================
                _premiumCard(
                  isDark,
                  cardColor,

                  child: SizedBox(
                    height: 188,

                    child: Row(
                      children: [
                        Expanded(
                          flex: 56,

                          child: Padding(
                            padding: const EdgeInsets.all(6),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Container(
                                  height: 48,
                                  width: 48,

                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.14),

                                    borderRadius: BorderRadius.circular(10),
                                  ),

                                  child: Icon(
                                    Icons.mic,
                                    color: primaryColor,
                                    size: 34,
                                  ),
                                ),

                                const SizedBox(height: 0),

                                Text(
                                  "Voice Entry",

                                  style: GoogleFonts.playfairDisplay(
                                    color: textColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 1),

                                Text(
                                  "Capture the texture of your feelings through spoken word.",

                                  style: GoogleFonts.poppins(
                                    color: subText,
                                    fontSize: 12,
                                    height: 1.9,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                GestureDetector(
                                  onTap: () =>
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const VoiceRecordingScreen(),
                                        ),
                                      ),
                                  child: Text(
                                    "Start Recording →",
                                    style: GoogleFonts.poppins(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 55,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 0, top: 10),
                              child: Transform.scale(
                                scale: 1.2,
                                child: Image.asset(
                                  "assets/figma/voice.png",
                                  height: 500,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =====================================================
                // JOURNAL CARD
                // =====================================================
                Container(
                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF120F18)
                        : const Color(0xFFF9F1FC),

                    borderRadius: BorderRadius.circular(32),

                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),

                  child: SizedBox(
                    height: 188,

                    child: Row(
                      children: [
                        Expanded(
                          flex: 56,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Container(
                                height: 48,
                                width: 48,

                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFB47CFF,
                                  ).withOpacity(0.15),

                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: const Icon(
                                  Icons.edit_note,
                                  color: Color(0xFFB47CFF),
                                  size: 34,
                                ),
                              ),

                              const SizedBox(height: 1),

                              Text(
                                "Journal Entry",

                                style: GoogleFonts.playfairDisplay(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Transcribe your inner dialogue into a private digital sanctuary.",

                                style: GoogleFonts.poppins(
                                  color: subText,
                                  fontSize: 12,
                                  height: 1.9,
                                ),
                              ),

                              const SizedBox(height: 1),

                              GestureDetector(
                                onTap: () =>
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const JournalWritingScreen(),
                                      ),
                                    ),
                                child: const Text(
                                  "Begin Writing →",
                                  style: TextStyle(
                                    color: Color(0xFFB47CFF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          flex: 55,

                          child: Align(
                            alignment: Alignment.bottomRight,

                            child: Image.asset(
                              isDark
                                  ? "assets/figma/book_black.png"
                                  : "assets/figma/Book_white.png",

                              height: 250,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 34),

                // =====================================================
                // MEMORY HEADER
                // =====================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      "Memory Archive",

                      style: GoogleFonts.playfairDisplay(
                        color: textColor,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => const MemoryArchiveScreen(),
                            ),
                          ),
                      child: Text(
                        "View All ⊙",
                        style: GoogleFonts.poppins(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // =====================================================
                // MEMORY CARD 1
                // =====================================================
                _memoryCard(
                  isDark,
                  cardColor,
                  textColor,
                  primaryColor,
                  "assets/figma/Forest.png",
                  "CALM • 2h ago",
                  "The weight of the morning fog...",
                  "Spoken entry regarding the peaceful silence that heals.",
                  true,
                ),

                const SizedBox(height: 16),

                // =====================================================
                // MEMORY CARD 2
                // =====================================================
                _memoryCard(
                  isDark,
                  cardColor,
                  textColor,
                  const Color(0xFFB47CFF),
                  "assets/figma/wave.png",
                  "CONTEMPLATIVE • Yesterday",
                  "Navigating the digital ocean",
                  "Written journal entry about the speed of thoughts.",
                  false,
                ),

                const SizedBox(height: 150),
              ],
            ),

            // FLOATING ADD BUTTON - positioned at bottom right
            Positioned(
              bottom: 100,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => const CreateEntryScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 68,
                  width: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.82)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.35),
                        blurRadius: 25,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    size: 36,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // PREMIUM CARD
  // =========================================================

  Widget _premiumCard(bool isDark, Color cardColor, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(32),

        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),

        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
        ],
      ),

      child: child,
    );
  }

  // =========================================================
  // MEMORY CARD
  // =========================================================

  Widget _memoryCard(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color accentColor,
    String image,
    String tag,
    String title,
    String subtitle,
    bool voice,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(30),

        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),

      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),

            child: Image.asset(
              image,
              width: 150,
              height: 210,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: SizedBox(
              height: 210,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text(
                    tag,

                    style: GoogleFonts.poppins(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    title,

                    style: GoogleFonts.playfairDisplay(
                      color: textColor,
                      fontSize: 15,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    subtitle,

                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white60 : Colors.black54,

                      fontSize: 11,
                      height: 1.9,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Icon(
                    voice
                        ? Icons.play_circle_outline
                        : Icons.menu_book_outlined,

                    color: accentColor,
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
