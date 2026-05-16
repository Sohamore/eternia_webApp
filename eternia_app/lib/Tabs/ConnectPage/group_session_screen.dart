// ==========================================================
// GROUP SESSION SCREEN
// group_session_screen.dart
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:eternia_ef/Tabs/ConnectPage/live_session_screen.dart';

class GroupSessionScreen extends StatelessWidget {
  const GroupSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final bool isDark = provider.isDark;

    final Color primary = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF53B29A);
    final Color bg = isDark ? const Color(0xFF071011) : const Color(0xFFF6F3ED);
    final Color cardColor = isDark ? const Color(0xFF111C1E) : Colors.white;
    final Color borderColor = isDark ? const Color(0xFF1E3035) : const Color(0xFFE7E2D8);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1B2722);
    final Color textSecondary = isDark ? Colors.white38 : const Color(0xFF70737C);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white54 : const Color(0xFF70737C), size: 20),
              ),
              const SizedBox(height: 20),
              Text(
                "Group\nSessions",
                style: GoogleFonts.cormorantGaramond(
                  color: primary,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Join communal healing spaces led by experts.",
                style: GoogleFonts.poppins(color: textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 32),

              // LIVE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: primary.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.06),
                      blurRadius: 30,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "LIVE NOW",
                          style: GoogleFonts.poppins(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Mindful Breathing",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Live with Dr. Aria",
                      style: GoogleFonts.poppins(color: primary, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "42 Participants",
                      style: GoogleFonts.poppins(color: textSecondary, fontSize: 10),
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveSessionScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          "Join Session",
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                "UPCOMING SESSIONS",
                style: GoogleFonts.poppins(
                  color: primary.withOpacity(0.5),
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSessionItem(context, "Deep Sleep Guide", "Today, 9 PM", isDark: isDark, primary: primary, cardColor: cardColor, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary),
              const SizedBox(height: 12),
              _buildSessionItem(context, "Exam Stress Relief", "Tomorrow, 4 PM", isDark: isDark, primary: primary, cardColor: cardColor, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionItem(
    BuildContext context,
    String title,
    String time, {
    required bool isDark,
    required Color primary,
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.calendar_today_outlined, color: primary, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary)),
                Text(time, style: GoogleFonts.poppins(color: textSecondary, fontSize: 10)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Notification On", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  backgroundColor: primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Icon(Icons.notifications_none_outlined, color: isDark ? Colors.white24 : Colors.black26, size: 20),
          ),
        ],
      ),
    );
  }
}

