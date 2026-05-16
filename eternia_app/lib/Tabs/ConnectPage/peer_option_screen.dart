// ==========================================================
// PEER OPTION SCREEN
// peer_option_screen.dart
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:eternia_ef/Tabs/ConnectPage/recommend_screen.dart';
import 'package:eternia_ef/Tabs/ConnectPage/institutional_support_screen.dart';

class PeerOptionScreen extends StatelessWidget {
  final Function(String) onPeerSelected;

  const PeerOptionScreen({super.key, required this.onPeerSelected});

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
                "Peer\nConnection",
                style: GoogleFonts.cormorantGaramond(
                  color: primary,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Safe, anonymous, and judgment-free support.",
                style: GoogleFonts.poppins(color: textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 32),
              _buildCard(
                context,
                "Random Node Match",
                "Connect with an anonymous peer instantly",
                Icons.shuffle_rounded,
                () => onPeerSelected("Anonymous Node"),
                isDark: isDark,
                primary: primary,
                cardColor: cardColor,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: 16),
              _buildCard(
                context,
                "See Recommendations",
                "Matches based on your shared interests",
                Icons.auto_awesome_outlined,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecommendScreen())),
                isDark: isDark,
                primary: primary,
                cardColor: cardColor,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: 16),
              _buildCard(
                context,
                "Institutional Support",
                "Connect within your organization",
                Icons.account_balance_outlined,
                () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => InstitutionalSupportScreen()),
                  );
                },
                isDark: isDark,
                primary: primary,
                cardColor: cardColor,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
    VoidCallback onTap, {
    required bool isDark,
    required Color primary,
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor),
          boxShadow: isDark
              ? []
              : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: primary, size: 26),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
                  const SizedBox(height: 3),
                  Text(sub, style: GoogleFonts.poppins(color: textSecondary, fontSize: 10.5)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: primary.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}

