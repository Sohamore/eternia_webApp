// ==========================================================
// CONNECT HOME SCREEN — PREMIUM DARK/LIGHT SANCTUARY
// connect_home_screen.dart
// ==========================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class ConnectHomeScreen extends StatefulWidget {
  final VoidCallback onExpertConnect;
  final VoidCallback onPeerConnect;
  final VoidCallback onJoinSession;

  const ConnectHomeScreen({
    super.key,
    required this.onExpertConnect,
    required this.onPeerConnect,
    required this.onJoinSession,
  });

  @override
  State<ConnectHomeScreen> createState() => _ConnectHomeScreenState();
}

class _ConnectHomeScreenState extends State<ConnectHomeScreen> {
  int _moodIndex = -1;

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Anxious', 'emoji': '😰'},
    {'label': 'Sad', 'emoji': '😔'},
    {'label': 'Confused', 'emoji': '😕'},
    {'label': 'Okay', 'emoji': '🙂'},
    {'label': 'Good', 'emoji': '😊'},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final bool isDark = provider.isDark;

    final Color primary = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF53B29A);
    final Color bg = isDark ? const Color(0xFF040B0D) : const Color(0xFFF6F3ED);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1B2722);
    final Color textSecondary = isDark
        ? Colors.white38
        : const Color(0xFF70737C);
    final Color cardColor = isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.white.withOpacity(0.7);
    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.07)
        : const Color(0xFFE7E2D8);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // BACKGROUND TOP GLOW
          Positioned(
            top: -100,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [primary.withOpacity(0.07), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [primary.withOpacity(0.08), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Connect",

                              style: GoogleFonts.playfairDisplay(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,

                                color: isDark
                                    ? const Color(0xFF67F5D4)
                                    : const Color(0xFF53B29A),
                              ),
                            ),
                            Text(
                              "Your sanctuary, your support.",
                              style: GoogleFonts.poppins(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: primary.withOpacity(0.08),
                            border: Border.all(color: primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "42 Online",
                                style: GoogleFonts.poppins(
                                  color: primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // MOOD CHECK-IN CARD
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: cardColor,
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.favorite_border_rounded,
                                    color: primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "How are you feeling today?",
                                    style: GoogleFonts.poppins(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: List.generate(_moods.length, (i) {
                                  final isSelected = _moodIndex == i;
                                  return GestureDetector(
                                    onTap: () => setState(() => _moodIndex = i),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: isSelected
                                            ? primary.withOpacity(0.15)
                                            : Colors.transparent,
                                        border: isSelected
                                            ? Border.all(
                                                color: primary.withOpacity(0.4),
                                              )
                                            : Border.all(
                                                color: Colors.transparent,
                                              ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            _moods[i]['emoji'],
                                            style: const TextStyle(
                                              fontSize: 22,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _moods[i]['label'],
                                            style: GoogleFonts.poppins(
                                              color: isSelected
                                                  ? primary
                                                  : textSecondary,
                                              fontSize: 9,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // SECTION LABEL
                    Text(
                      "CHOOSE YOUR PATH",
                      style: GoogleFonts.poppins(
                        color: primary.withOpacity(0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // EXPERT GUIDANCE — HERO CARD
                    _buildHeroCard(
                      title: "Expert\nGuidance",
                      subtitle: "Connect with verified counselors",
                      tag: "PROFESSIONAL",
                      tagIcon: Icons.verified_outlined,
                      bottomLabel: "320+ Sessions •4.9★",
                      onTap: widget.onExpertConnect,

                      gradient: isDark
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0F3A35), Color(0xFF071A18)],
                            )
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF183D37),
                                Color.fromARGB(255, 103, 196, 180),
                              ],
                            ),
                      glowColor: primary,
                      icon: Icons.psychology_outlined,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 14),

                    // PEER + GROUP — ROW CARDS
                    Row(
                      children: [
                        Expanded(
                          child: _buildSmallCard(
                            title: "Peer\nConnect",
                            subtitle: "Anonymous & Safe",
                            icon: Icons.people_outline_rounded,
                            glowColor: isDark
                                ? const Color(0xFF6B9FFF)
                                : const Color(0xFF4A7DAA),
                            gradient: isDark
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF0F1A3A),
                                      Color(0xFF070D1A),
                                    ],
                                  )
                                : const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF13283F),
                                      Color.fromARGB(255, 93, 123, 158),
                                    ],
                                  ),
                            onTap: widget.onPeerConnect,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildSmallCard(
                            title: "Group\nSession",
                            subtitle: "Live & Guided",
                            icon: Icons.videocam_outlined,
                            glowColor: isDark
                                ? const Color(0xFFFF9B6B)
                                : const Color(0xFFCC7A4A),
                            gradient: isDark
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF3A1F0F),
                                      Color(0xFF1A0E07),
                                    ],
                                  )
                                : const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.fromARGB(255, 128, 48, 2),
                                      Color.fromARGB(255, 227, 177, 141),
                                    ],
                                  ),
                            onTap: widget.onJoinSession,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // COMMUNITY STATS
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: cardColor,
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStat(
                                "8.4k",
                                "Community\nMembers",
                                Icons.group_outlined,
                                primary,
                                textPrimary,
                                textSecondary,
                              ),
                              _buildStatDivider(borderColor),
                              _buildStat(
                                "96%",
                                "Anonymous\nSessions",
                                Icons.shield_outlined,
                                primary,
                                textPrimary,
                                textSecondary,
                              ),
                              _buildStatDivider(borderColor),
                              _buildStat(
                                "4.9★",
                                "Average\nRating",
                                Icons.star_border_rounded,
                                primary,
                                textPrimary,
                                textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // QUICK CONNECT BANNER
                    GestureDetector(
                      onTap: widget.onPeerConnect,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,

                                colors: [
                                  isDark
                                      ? const Color(0xFF102924)
                                      : const Color.fromARGB(255, 71, 152, 139),

                                  isDark
                                      ? const Color(0xFF071614)
                                      : const Color.fromARGB(
                                          255,
                                          131,
                                          194,
                                          184,
                                        ),
                                ],
                              ),
                              border: Border.all(
                                color: primary.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 52,
                                  width: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.15),
                                    border: Border.all(
                                      color: primary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.bolt_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Quick Anonymous Connect",
                                        style: GoogleFonts.playfairDisplay(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        "Tap to match with a peer instantly",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HERO CARD
  Widget _buildHeroCard({
    required String title,
    required String subtitle,
    required String tag,
    required IconData tagIcon,
    required String bottomLabel,
    required VoidCallback onTap,
    required LinearGradient gradient,
    required Color glowColor,
    required IconData icon,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: gradient,
              border: Border.all(color: glowColor.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.08),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    icon,
                    size: 160,
                    color: glowColor.withOpacity(0.05),
                  ),
                ),
                Positioned(
                  top: -30,
                  right: 40,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          glowColor.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: glowColor.withOpacity(0.12),
                              border: Border.all(
                                color: glowColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(tagIcon, color: glowColor, size: 12),
                                const SizedBox(width: 6),
                                Text(
                                  tag,
                                  style: GoogleFonts.poppins(
                                    color: glowColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: glowColor.withOpacity(0.5),
                            size: 14,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  subtitle,
                                  style: GoogleFonts.poppins(
                                    color: isDark
                                        ? const Color.fromARGB(
                                            137,
                                            255,
                                            255,
                                            255,
                                          )
                                        : const Color(0xFF0D2B26), // Darker green for light mode visibility
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                height: 1,
                                width: 12,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                bottomLabel,
                                style: GoogleFonts.poppins(
                                  color: isDark 
                                      ? glowColor.withOpacity(0.7)
                                      : const Color(0xFF0D2B26), // Darker green for light mode visibility
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SMALL CARD
  Widget _buildSmallCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color glowColor,
    required LinearGradient gradient,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 150,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: gradient,
              border: Border.all(color: glowColor.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(color: glowColor.withOpacity(0.06), blurRadius: 20),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -14,
                  bottom: -14,
                  child: Icon(
                    icon,
                    size: 90,
                    color: glowColor.withOpacity(0.06),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: glowColor.withOpacity(0.12),
                        border: Border.all(color: glowColor.withOpacity(0.25)),
                      ),
                      child: Icon(icon, color: glowColor, size: 20),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.playfairDisplay(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? Colors.white38
                                : Colors.black.withOpacity(0.6), // Darker text for visibility in light mode
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // STAT ITEM
  Widget _buildStat(
    String value,
    String label,
    IconData icon,
    Color primary,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      children: [
        Icon(icon, color: primary.withOpacity(0.5), size: 18),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: textSecondary,
            fontSize: 9,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(Color borderColor) {
    return Container(height: 40, width: 1, color: borderColor);
  }
}
