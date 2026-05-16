// ==========================================================
// PRIVACY & SAFETY SCREEN - SPLIT CARDS
// ==========================================================

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:eternia_ef/Tabs/ProfilePage/emergency_support_screen.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class PrivacySafetyScreen extends StatefulWidget {
  const PrivacySafetyScreen({super.key});

  @override
  State<PrivacySafetyScreen> createState() => _PrivacySafetyScreenState();
}

class _PrivacySafetyScreenState extends State<PrivacySafetyScreen> {
  bool _anonymousEncryption = true;
  bool _stealthMode = false;
  String? _recoveryPhrase;

  void _generateRecoveryPhrase() {
    const words = [
      "calm", "river", "anchor", "forest", "lantern", "breathe",
      "meadow", "stone", "harbor", "gentle", "signal", "haven",
      "mirror", "north", "circle", "quiet",
    ];
    final random = Random();
    _recoveryPhrase = List.generate(12, (_) => words[random.nextInt(words.length)]).join(" ");
    Clipboard.setData(ClipboardData(text: _recoveryPhrase!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Recovery phrase generated and copied.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDark;

    final Color primaryColor = isDark ? const Color(0xFF67F5D4) : const Color(0xFF335848);
    final Color iconAccent = const Color(0xFF53B29A);
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _buildHeader(textColor, primaryColor),
              ),
              const SizedBox(height: 16),
              
              // HIPAA / Privacy Info Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield, color: primaryColor, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Your data is zero-knowledge encrypted. We cannot read your journal entries or session notes.",
                          style: GoogleFonts.poppins(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // SPLIT CARD 1: ENCRYPTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildSectionTitle("DATA & ENCRYPTION", primaryColor),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: innerCardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _buildToggleItem("End-to-End Encryption", "Force strict E2EE on all chats.", Icons.lock_outline, _anonymousEncryption, isDark, iconAccent, (v) => setState(() => _anonymousEncryption = v)),
                      Divider(height: 1, color: borderColor, indent: 64),
                      _buildToggleItem("Stealth Mode", "Hide online status from peers.", Icons.visibility_off_outlined, _stealthMode, isDark, iconAccent, (v) => setState(() => _stealthMode = v)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // SPLIT CARD 2: RECOVERY & ACCESS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildSectionTitle("RECOVERY & ACCESS", primaryColor),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: innerCardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _buildActionTile(Icons.vpn_key_outlined, "Recovery Phrase", "Generate 12-word seed", isDark, iconAccent, _generateRecoveryPhrase),
                      Divider(height: 1, color: borderColor, indent: 64),
                      _buildActionTile(Icons.fingerprint, "Biometric Lock", "Require FaceID to open", isDark, iconAccent, () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Biometrics enabled.")));
                      }),
                      Divider(height: 1, color: borderColor, indent: 64),
                      _buildActionTile(Icons.emergency_outlined, "Emergency SOS", "Manage crisis contacts", isDark, const Color(0xFFE53935), () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencySupportScreen()));
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color primaryColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
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
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Privacy &\nSafety", style: GoogleFonts.playfairDisplay(color: textColor, fontSize: 38, height: 1.1, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Your sanctuary, your rules.", style: GoogleFonts.poppins(color: primaryColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(title, style: GoogleFonts.poppins(color: color.withOpacity(0.6), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold));
  }

  Widget _buildToggleItem(String title, String sub, IconData icon, bool val, bool isDark, Color iconColor, ValueChanged<bool> onChanged) {
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1B2722);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: titleColor)),
                const SizedBox(height: 2),
                Text(sub, style: GoogleFonts.poppins(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11)),
              ],
            ),
          ),
          Switch.adaptive(
            value: val,
            activeColor: Colors.white,
            activeTrackColor: iconColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String sub, bool isDark, Color iconColor, VoidCallback onTap) {
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1B2722);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: titleColor)),
                  const SizedBox(height: 2),
                  Text(sub, style: GoogleFonts.poppins(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
