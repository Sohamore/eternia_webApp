// ==========================================================
// TOOLS HUB SCREEN - PREMIUM ADAPTIVE
// tools_screen.dart
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:eternia_ef/Tabs/Tools/sound_therapy_screen.dart';
import 'package:eternia_ef/Tabs/Tools/quest_cards_screen.dart';
import 'package:eternia_ef/Tabs/Tools/wreck_buddy_screen.dart';
import 'package:eternia_ef/Tabs/Tools/tibetan_bowl_screen.dart';
import 'package:eternia_ef/Tabs/Tools/breathing_exercise_screen.dart';
import 'package:eternia_ef/Tabs/Tools/daily_checkin_screen.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDark;

    // Use exact colors from the image
    final Color bgColor = const Color(0xFFF6F4F0);
    final Color primaryGreen = const Color(0xFF59A28A);
    final Color textDark = const Color(0xFF1B2722);
    final Color textLight = const Color(0xFF6E7873);
    final Color cardBg = Colors.white;

    final actualBg = isDark ? const Color(0xFF121212) : bgColor;
    final actualCardBg = isDark ? const Color(0xFF1E1E1E) : cardBg;
    final actualTextDark = isDark ? Colors.white : textDark;

    return Scaffold(
      backgroundColor: actualBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ===================================================
              // FEATURED — SOUND THERAPY CARD
              // ===================================================
              GestureDetector(
                onTap: () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => const SoundTherapyScreen()),
                ),
                child: Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/sound_therapy.png'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withOpacity(0.85),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.7],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "FEATURED",
                              style: GoogleFonts.poppins(
                                color: primaryGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Sound Therapy",
                              style: GoogleFonts.playfairDisplay(
                                color: textDark,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: 160,
                              child: Text(
                                "Immersive spatial audio for deep focus and relaxation.",
                                style: GoogleFonts.poppins(
                                  color: textDark.withOpacity(0.8),
                                  fontSize: 12,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryGreen.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ===================================================
              // DAILY CHECK-IN
              // ===================================================
              GestureDetector(
                onTap: () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => const DailyCheckinScreen()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: actualCardBg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: primaryGreen,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Daily Check-in",
                              style: GoogleFonts.poppins(
                                color: actualTextDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Log your feelings & track mood",
                              style: GoogleFonts.poppins(
                                color: textLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: textLight.withOpacity(0.5),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ===================================================
              // EXPLORE TOOLS TITLE
              // ===================================================
              Row(
                children: [
                  Text(
                    "EXPLORE TOOLS",
                    style: GoogleFonts.poppins(
                      color: textDark,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ===================================================
              // GRID
              // ===================================================
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildGridCard(
                    "Wreck Buddy",
                    "Release stress\nthrough tapping",
                    'assets/images/wreck_buddy.png',
                    const WreckBuddyScreen(),
                    actualCardBg,
                    actualTextDark,
                    textLight,
                    true,
                  ),
                  _buildGridCard(
                    "Tibetan Bowl",
                    "Healing sound\nvibrations",
                    'assets/images/singing_bowl.png',
                    const TibetanBowlScreen(),
                    actualCardBg,
                    actualTextDark,
                    textLight,
                    true,
                  ),
                  _buildGridCard(
                    "Quest Cards",
                    "Mindful prompts\nfor reflection",
                    'assets/images/quest_card.png',
                    const QuestCardsScreen(),
                    actualCardBg,
                    actualTextDark,
                    textLight,
                    true,
                  ),
                  _buildGridCard(
                    "Breath Guide",
                    "Guided breathing\nexercises",
                    'assets/images/breath_guide.png',
                    const BreathingExerciseScreen(),
                    actualCardBg,
                    actualTextDark,
                    textLight,
                    true,
                    // icon: Icons.air_rounded,
                    // primaryColor: primaryGreen,
                  ),
                ],
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(
    String title,
    String sub,
    String? imagePath,
    Widget screen,
    Color cardBg,
    Color textDark,
    Color textLight,
    bool isImage, {
    IconData? icon,
    Color? primaryColor,
  }) {
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: isImage && imagePath != null
                  ? Image.asset(imagePath, height: 80, fit: BoxFit.contain)
                  : Container(
                      height: 70,
                      width: 70,
                      // decoration: BoxDecoration(
                      //   //color: primaryColor!.withOpacity(0.15),
                      //   //shape: BoxShape.circle,
                      // ),
                      child: Icon(icon, color: primaryColor, size: 36),
                    ),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sub,
              style: GoogleFonts.poppins(
                color: textLight,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
