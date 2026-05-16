// ==========================================================
// PREMIUM SUBSCRIPTION SCREEN - PREMIUM ADAPTIVE
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _trialStarted = false;

  void _startTrial() {
    final alreadyStarted = _trialStarted;
    setState(() => _trialStarted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(alreadyStarted ? "Free trial is active." : "Free trial started.")),
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
    final Color innerCardColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final Color borderColor = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE7E2D8);

    final features = [
      {"icon": Icons.all_inclusive, "title": "Unlimited Sessions", "desc": "Connect with counselors anytime"},
      {"icon": Icons.shield_outlined, "title": "Priority Matching", "desc": "Get matched with peers faster"},
      {"icon": Icons.auto_awesome, "title": "AI Insights", "desc": "Personalized wellness recommendations"},
      {"icon": Icons.headphones_outlined, "title": "Premium Sounds", "desc": "Exclusive meditation library"},
      {"icon": Icons.analytics_outlined, "title": "Advanced Analytics", "desc": "Deep mood and progress tracking"},
    ];

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
                      child: Icon(Icons.close, color: textColor, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B1412) : const Color(0xFFF5F3EC),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: primaryColor.withOpacity(0.05), blurRadius: 20, spreadRadius: 5)
                  ],
                  gradient: isDark ? null : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF5F3EC), Color(0xFFEFECE2)],
                  ),
                ),
                child: Column(
                  children: [
                    // CROWN ICON
                    Container(
                      height: 80, width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.6)]),
                        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 30)],
                      ),
                      child: const Icon(Icons.workspace_premium, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 24),
                    Text("Eternia Premium", style: GoogleFonts.playfairDisplay(color: textColor, fontSize: 36, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Unlock the full sanctuary experience.", style: GoogleFonts.poppins(color: primaryColor.withOpacity(0.7), fontSize: 12)),
                    const SizedBox(height: 36),

                    // FEATURES
                    Container(
                      decoration: BoxDecoration(
                        color: innerCardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: List.generate(features.length, (index) {
                          final f = features[index];
                          return Column(
                            children: [
                              _buildFeatureItem(f, isDark, primaryColor, iconAccent, textColor),
                              if (index < features.length - 1)
                                Divider(height: 1, color: borderColor, indent: 64),
                            ],
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // PRICING
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor.withOpacity(0.12), primaryColor.withOpacity(0.04)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Text("\$9.99", style: GoogleFonts.playfairDisplay(color: primaryColor, fontSize: 42, fontWeight: FontWeight.bold)),
                          Text("per month", style: GoogleFonts.poppins(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: _startTrial,
                            child: Container(
                              width: double.infinity,
                              height: 54,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              alignment: Alignment.center,
                              child: Text("Start Free Trial", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text("7-day free trial • Cancel anytime", style: GoogleFonts.poppins(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(Map<String, dynamic> f, bool isDark, Color primaryColor, Color iconAccent, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(f["icon"] as IconData, color: iconAccent, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f["title"] as String, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1B2722))),
                const SizedBox(height: 2),
                Text(f["desc"] as String, style: GoogleFonts.poppins(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: primaryColor, size: 20),
        ],
      ),
    );
  }
}
