// ==========================================================
// UPDATED PRIVATE PROFILE SCREEN
// private_profile_screen.dart
// ==========================================================

import 'package:eternia_ef/widgets/glass_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eternia_ef/Tabs/home_screen/MainNavigation.dart';

import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_config.dart';

class PrivateProfileScreen extends StatefulWidget {
  const PrivateProfileScreen({super.key});

  @override
  State<PrivateProfileScreen> createState() => _PrivateProfileScreenState();
}

class _PrivateProfileScreenState extends State<PrivateProfileScreen> {
  bool isPhoneChecked = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController apaarController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final isDark = provider.isDark;
    final primaryColor = isDark ? SanctuaryTheme.darkPrimary : SanctuaryTheme.lightPrimary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ...SanctuaryTheme.buildBackgroundGlow(isDark),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // STAGE BAR
                    // ==================================================
                    Row(
                      children: [
                        // STAGE 1
                        Column(
                          children: [
                            Container(
                              width: 30,
                              height: 30,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                              ),

                              child: const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "VERIFICATION",

                              style: GoogleFonts.poppins(
                                fontSize: 8,
                                letterSpacing: 1.2,

                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),

                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            height: 2,
                            color: primaryColor,
                          ),
                        ),

                        // STAGE 2
                        Column(
                          children: [
                            Container(
                              width: 30,
                              height: 30,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                              ),

                              child: const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "PROFILE",

                              style: GoogleFonts.poppins(
                                fontSize: 8,
                                letterSpacing: 1.2,

                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 34),

                    // ==================================================
                    // TITLE SECTION
                    // ==================================================
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                "Private Profile",

                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w600,

                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF2D2D2D),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "Encrypted and only accessed during emergencies.",

                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.7,

                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 110,
                              width: 110,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                border: Border.all(
                                  color: primaryColor.withOpacity(0.25),
                                ),
                              ),
                            ),

                            Icon(
                              Icons.shield_outlined,
                              size: 60,
                              color: primaryColor,
                            ),

                            Positioned(
                              right: 18,
                              bottom: 20,
                              child: Icon(
                                Icons.lock,
                                size: 18,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    buildLabel("LEGAL NAME", isDark: isDark),
                    const SizedBox(height: 10),
                    buildField(
                      icon: Icons.person_outline,
                      hint: "Enter your full name",
                      controller: nameController,
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),

                    buildLabel("PHONE NUMBER", isDark: isDark),
                    const SizedBox(height: 10),
                    buildField(
                      icon: Icons.phone_outlined,
                      hint: "Enter your mobile number",
                      controller: phoneController,
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),

                    buildLabel("APAAR / ABC ID", isDark: isDark),
                    const SizedBox(height: 10),
                    buildField(
                      icon: Icons.badge_outlined,
                      hint: "Enter your 12-digit ID",
                      controller: apaarController,
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),


                    const SizedBox(height: 16),

                    // ==================================================
                    // CHECKBOX ONLY AFTER NUMBER
                    // ==================================================
                    if (phoneController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isPhoneChecked = !isPhoneChecked;
                          });
                        },

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),

                            color: isDark
                                ? Colors.white.withOpacity(0.03)
                                : Colors.white,

                            border: Border.all(
                              color: isDark ? Colors.white10 : const Color(0xFFE7E2D8),
                            ),
                          ),

                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),

                                width: 22,
                                height: 22,

                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,

                                  color: isPhoneChecked
                                      ? primaryColor
                                      : Colors.transparent,

                                  border: Border.all(color: primaryColor),
                                ),

                                child: isPhoneChecked
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.black,
                                      )
                                    : null,
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  "This is my own phone number",

                                  style: GoogleFonts.poppins(
                                    fontSize: 12,

                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // APAAR FIELD
                    // ==================================================
                    // buildLabel("APAAR / ABC ID", isDark: isDark),

                    // const SizedBox(height: 10),

                    // buildField(
                    //   icon: Icons.badge_outlined,
                    //   hint: "Enter APAAR / ABC ID",
                    //   controller: apaarController,
                    //   primaryColor: primaryColor,
                    //   isDark: isDark,
                    // ),

                   // const SizedBox(height: 18),

                    // ==================================================
                    // NOT VERIFIED MESSAGE
                    // ==================================================
                    if (apaarController.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),

                          color: isDark
                              ? const Color(0xFF1A1628)
                              : const Color(0xFFF3EEFA),

                          border: Border.all(
                            color: isDark
                                ? Colors.purple.withOpacity(0.15)
                                : Colors.purple.withOpacity(0.08),
                          ),
                        ),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Icon(
                              Icons.info_outline,
                              color: isDark
                                  ? const Color(0xFFD0BFFF)
                                  : Colors.deepPurple,
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                "Institution has not uploaded verification records yet. You can proceed without verification.",

                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  height: 1.7,

                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    //const SizedBox(height: ),

                    // ==================================================
                    // WARNING CARD
                    // ==================================================
                    Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),

                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF2B1212),
                                  const Color(0xFF1B0909),
                                ]
                              : [
                                  const Color(0xFFFFF1E7),
                                  const Color(0xFFF8E8DB),
                                ],
                        ),

                        border: Border.all(
                          color: isDark
                              ? Colors.red.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.18),
                        ),
                      ),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Container(
                            width: 42,
                            height: 42,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              color: Colors.orange.withOpacity(0.15),
                            ),

                            child: const Icon(
                              Icons.warning_amber,
                              color: Colors.orange,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  "EMERGENCY\nESCALATION CONSENT",

                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 17,

                                    fontWeight: FontWeight.w600,

                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF5D4331),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  "I consent to the platform sharing my username and emergency contact with my institution's SPOC if the system or a qualified professional detects a high-risk situation requiring immediate intervention.",

                                  style: TextStyle(
                                    fontSize: 12,

                                    height: 1.8,

                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 34),

                    // ==================================================
                    // BUTTON
                    // ==================================================
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainNavigation(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const GlassButton(text: "Activate Account"),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLabel(String text, {required bool isDark}) {
    return Text(
      text,

      style: GoogleFonts.poppins(
        fontSize: 11,
        letterSpacing: 1,
        fontWeight: FontWeight.w500,

        color: isDark ? Colors.white70 : Colors.black54,
      ),
    );
  }

  Widget buildField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Container(
      height: 58,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),

        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,

        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),

      child: TextField(
        controller: controller,

        onChanged: (value) {
          setState(() {});
        },

        style: TextStyle(color: isDark ? Colors.white : Colors.black87),

        decoration: InputDecoration(
          border: InputBorder.none,

          hintText: hint,

          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),

          prefixIcon: Icon(icon, color: primaryColor),
        ),
      ),
    );
  }
}
