import 'package:eternia_ef/Screens/onboarding_screen.dart/guidance_screen.dart';
import 'package:eternia_ef/Tabs/ProfilePage/privacy_safety_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/app_color.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/glass_button.dart';

import '../../../utils/theme_config.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final isDark = provider.isDark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ...SanctuaryTheme.buildBackgroundGlow(isDark),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 18,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TOP BAR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       Text(
                          "Eternia",

                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,

                            color: isDark ?  const Color(0xFF67F5D4)
        : const Color(0xFF53B29A),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // SHIELD IMAGE
                    Container(
                      height: 280,
                      width: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  (isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE7E2D8)),
                                  Colors.white.withOpacity(0.02),
                                ]
                              : [
                                  const Color(0xFF547850).withOpacity(0.08),
                                  const Color(0xFF547850).withOpacity(0.02),
                                ],
                        ),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? AppColors.mint.withOpacity(0.15)
                                : const Color(0xFF547850).withOpacity(0.1),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Image.asset(
                          'assets/figma/shield.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // HEADING
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Built with\n",
                            style: GoogleFonts.poppins(
                              fontSize: 42,
                              height: 1.1,
                              color: isDark ? Colors.white : AppColors.black,
                            ),
                          ),
                          TextSpan(
                            text: "privacy-first\n",
                            style: GoogleFonts.poppins(
                              fontSize: 42,
                              height: 1.1,
                              color: isDark
                                  ? AppColors.mint
                                  : const Color(0xFF4F8C78),
                            ),
                          ),
                          TextSpan(
                            text: "architecture.",
                            style: GoogleFonts.poppins(
                              fontSize: 42,
                              height: 1.1,
                              color: isDark ? Colors.white : AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      "Your data is decentralized and\nencrypted at the source.\nIn Eternia, you own your\nidentity—always.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.8,
                        fontSize: 15,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // BUTTON
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GuidanceScreen(),
                          ),
                        );
                      },
                      child: const GlassButton(text: "Get Started"),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_done_outlined,
                          color: isDark
                              ? AppColors.mint
                              : const Color(0xFF4F8C78),
                          size: 18,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "SECURE CLOUD SYNC ENABLED",
                          style: TextStyle(
                            letterSpacing: 2,
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // INDICATORS
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     dot(false),

                    //     const SizedBox(width: 10),

                    //     dot(false),

                    //     const SizedBox(width: 10),

                    //     dot(true),
                    //   ],
                    // ),
                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySafetyScreen()));
                          },
                          child: Text(
                            "Privacy Policy",
                            style: TextStyle(
                              color: isDark ? Colors.white54 : const Color(0xFF70737C),
                            ),
                          ),
                        ),

                        const SizedBox(width: 18),

                        Container(
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white38 : const Color(0xFF9DA3A8),
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 18),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySafetyScreen()));
                          },
                          child: Text(
                            "Terms of Service",
                            style: TextStyle(
                              color: isDark ? Colors.white54 : const Color(0xFF70737C),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dot(bool active) {
    return Container(
      height: 8,
      width: active ? 28 : 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: active ? AppColors.mint : Colors.grey,
      ),
    );
  }
}
