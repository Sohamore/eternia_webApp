// ==========================================================
// ABOUT ETERNIA SCREEN - THERAPY CONTEXT
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDark;

    final Color primaryColor = isDark ? const Color(0xFF67F5D4) : const Color(0xFF335848);
    final Color bg = isDark ? const Color(0xFF071011) : const Color(0xFFF9F8F4);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1B2722);
    final Color innerCardColor = isDark ? const Color(0xFF141D1F) : Colors.white;
    final Color borderColor = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE7E2D8);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // LOGO
              Container(
                height: 100, width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primaryColor.withOpacity(0.2), primaryColor.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
                ),
                child: Icon(Icons.spa, color: primaryColor, size: 50),
              ),
              const SizedBox(height: 24),
              Text("Eternia", style: GoogleFonts.playfairDisplay(color: textColor, fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Version 2.4.0 • Build 88", style: GoogleFonts.poppins(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 11, letterSpacing: 1)),
              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "A sanctuary for emotional healing, guided therapy, and genuine peer connection.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 14, height: 1.6, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 40),

              // INFO CARDS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildInfoCard("Our Clinical Mission", "To break down barriers to mental health by providing an accessible, stigma-free digital space for everyone.", Icons.favorite_border, innerCardColor, borderColor, primaryColor, textColor, isDark),
                    const SizedBox(height: 16),
                    _buildInfoCard("HIPAA Compliance", "All sessions, journal entries, and chat logs are end-to-end encrypted following strict medical privacy guidelines.", Icons.verified_user_outlined, innerCardColor, borderColor, primaryColor, textColor, isDark),
                    const SizedBox(height: 16),
                    _buildInfoCard("The Care Team", "Eternia is maintained by a coalition of licensed therapists, compassionate engineers, and designers.", Icons.groups_outlined, innerCardColor, borderColor, primaryColor, textColor, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Terms of Service", style: GoogleFonts.poppins(color: primaryColor, fontSize: 11, decoration: TextDecoration.underline)),
                  const SizedBox(width: 16),
                  Text("Privacy Policy", style: GoogleFonts.poppins(color: primaryColor, fontSize: 11, decoration: TextDecoration.underline)),
                ],
              ),
              const SizedBox(height: 24),
              Text("Made with 💚 for your mind", style: GoogleFonts.poppins(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 10)),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String body, IconData icon, Color cardColor, Color borderColor, Color primaryColor, Color textColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 20),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.poppins(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(body, style: GoogleFonts.poppins(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }
}
