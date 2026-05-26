import 'package:eternia_ef/Screens/onboarding_screen.dart/VerifyCampusScreen.dart';
import 'package:eternia_ef/widgets/glass_button.dart';
import 'package:eternia_ef/Screens/onboarding_screen.dart/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class GuidanceScreen extends StatefulWidget {
  const GuidanceScreen({super.key});

  @override
  State<GuidanceScreen> createState() => _GuidanceScreenState();
}

class _GuidanceScreenState extends State<GuidanceScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<ThemeProvider>(context);
    final isDark = provider.isDark;

    final Color primary = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF53B29A);
    final Color bg = isDark ? const Color(0xFF031313) : const Color(0xFFF6F3ED);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1B2722);
    final Color textSecondary = isDark
        ? Colors.white54
        : const Color(0xFF70737C);
    final Color orbGlow = isDark
        ? const Color(0xFF7BE7D4)
        : const Color(0xFF53B29A);
    final Color ringColor = isDark ? Colors.teal : const Color(0xFF53B29A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SizedBox(
          height: size.height,
          child: Column(
            children: [
              // =============================================
              // TOP BAR
              // =============================================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Eternia",

                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,

                        color: isDark
                            ? const Color(0xFF67F5D4)
                            : const Color(0xFF53B29A),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VerifyCampusScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Skip",
                        style: GoogleFonts.poppins(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =============================================
              // MAIN VISUAL — RADIAL ORB SYSTEM
              // =============================================
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // DEEP BACKGROUND
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 1.2,
                          colors: isDark
                              ? [
                                  const Color(0xFF123A38),
                                  const Color(0xFF031313),
                                ]
                              : [primary.withValues(alpha: 0.06), bg],
                        ),
                      ),
                    ),

                    // OUTER RING
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ringColor.withValues(
                            alpha: isDark ? 0.12 : 0.1,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ringColor.withValues(
                            alpha: isDark ? 0.14 : 0.12,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      width: 162,
                      height: 162,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ringColor.withValues(
                            alpha: isDark ? 0.18 : 0.15,
                          ),
                        ),
                      ),
                    ),

                    // CENTER GLOW ORB
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF90FFE8),
                                  const Color(0xFF57B8A8),
                                ]
                              : [
                                  const Color(0xFF7DCDB8),
                                  const Color(0xFF53B29A),
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: orbGlow.withValues(
                              alpha: isDark ? 0.5 : 0.3,
                            ),
                            blurRadius: 60,
                            spreadRadius: 14,
                          ),
                        ],
                      ),
                    ),

                    // SMALL ORBS
                    Positioned(
                      bottom: 140,
                      left: 90,
                      child: _smallOrb(26, isDark),
                    ),
                    Positioned(
                      bottom: 110,
                      right: 105,
                      child: _smallOrb(18, isDark),
                    ),
                    Positioned(top: 80, left: 65, child: _smallOrb(10, isDark)),

                    // CORNER BUTTONS
                    Positioned(
                      top: 18,
                      right: 18,
                      child: _circleButton(
                        Icons.settings_outlined,
                        isDark,
                        primary,
                      ),
                    ),
                    Positioned(
                      bottom: 18,
                      left: 18,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ),
                          );
                        },
                        child: _circleButton(
                          Icons.person_outline_rounded,
                          isDark,
                          primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =============================================
              // BOTTOM CONTENT
              // =============================================
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
                child: Column(
                  children: [
                    // TITLE
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Expert\n",
                            style: GoogleFonts.poppins(
                              fontSize: 40,
                              fontWeight: FontWeight.w500,
                              color: textPrimary,
                              height: 1.1,
                            ),
                          ),
                          TextSpan(
                            text: "Guidance",
                            style: GoogleFonts.poppins(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: primary,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      "Connect with verified professionals\n& trained peers.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        height: 1.7,
                        color: textSecondary,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // CONTINUE BUTTON
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VerifyCampusScreen(),
                          ),
                        );
                      },
                      child: const GlassButton(text: "Continue"),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallOrb(double size, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isDark
              ? [const Color(0xFFB7FFF1), const Color(0xFF5FCDB8)]
              : [const Color(0xFF7DCDB8), const Color(0xFF53B29A)],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, bool isDark, Color primary) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primary.withValues(alpha: 0.25)),
        color: isDark
            ? Colors.black.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.6),
      ),
      child: Icon(icon, size: 18, color: primary),
    );
  }
}
