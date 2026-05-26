// ==========================================================
// SIGN IN SCREEN - ETERNIA
// sign_in_screen.dart
// ==========================================================

import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eternia_ef/Tabs/home_screen/MainNavigation.dart';
import 'package:eternia_ef/Screens/onboarding_screen.dart/sign_up_screen.dart';
import 'package:eternia_ef/Screens/onboarding_screen.dart/onboarding_screen.dart';
import 'package:eternia_ef/Screens/onboarding_screen.dart/reset_password_screen.dart';

import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/theme_config.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool obscurePassword = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final isDark = provider.isDark;
    final primaryColor = isDark
        ? SanctuaryTheme.darkPrimary
        : SanctuaryTheme.lightPrimary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ...SanctuaryTheme.buildBackgroundGlow(isDark),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // =================================================
                  // BACK BUTTON
                  // =================================================
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => OnboardingScreen()),
                        );
                      }
                    },

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: isDark
                              ? Colors.white
                              : SanctuaryTheme.lightPrimary,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          "Back",

                          style: GoogleFonts.playfairDisplay(
                            color: isDark
                                ? Colors.white
                                : SanctuaryTheme.lightPrimary,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 34),

                  // =================================================
                  // LOGO
                  // =================================================
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "ETERNIA",

                          style: GoogleFonts.cormorantGaramond(
                            color: primaryColor,
                            fontSize: 36,
                            letterSpacing: 6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.only(top: 8),

                          width: 72,
                          height: 1.4,

                          color: primaryColor.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 42),

                  // =================================================
                  // GLASS CARD
                  // =================================================
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),

                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),

                      child: Container(
                        padding: const EdgeInsets.all(26),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),

                          color: (isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.white.withValues(alpha: 0.92)),

                          border: Border.all(
                            color: (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE7E2D8)),
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.08),

                              blurRadius: 28,
                              spreadRadius: 1,
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // =========================================
                            // TITLE + IMAGE
                            // =========================================
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        "Sign in",

                                        style: GoogleFonts.playfairDisplay(
                                          color: isDark
                                              ? Colors.white
                                              : SanctuaryTheme.lightPrimary,

                                          fontSize: 54,

                                          height: 1,
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      Text(
                                        "Use your username or\nemail to access your\ndashboard",

                                        style: GoogleFonts.poppins(
                                          color: isDark
                                              ? Colors.white70
                                              : const Color(0xFF70737C),

                                          fontSize: 15,

                                          height: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 10),

                                SizedBox(
                                  width: 135,
                                  height: 150,

                                  child: Image.asset(
                                    "assets/figma/Meditation.png",

                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 34),

                            // =========================================
                            // EMAIL LABEL
                            // =========================================
                            Text(
                              "USERNAME OR EMAIL",

                              style: GoogleFonts.poppins(
                                color: primaryColor,

                                fontSize: 12,

                                letterSpacing: 2,

                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 12),

                            buildTextField(
                              controller: emailController,

                              hint: "Enter username or email",

                              icon: Icons.person_outline,

                              isPassword: false,
                              isDark: isDark,
                            ),

                            const SizedBox(height: 24),

                            // =========================================
                            // PASSWORD ROW
                            // =========================================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Text(
                                  "PASSWORD",

                                  style: GoogleFonts.poppins(
                                    color: primaryColor,

                                    fontSize: 12,

                                    letterSpacing: 2,

                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ResetPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Forgot password?",

                                    style: GoogleFonts.poppins(
                                      color: primaryColor,

                                      fontSize: 12,

                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            buildTextField(
                              controller: passwordController,

                              hint: "Enter your password",

                              icon: Icons.lock_outline,

                              isPassword: true,
                              isDark: isDark,
                            ),

                            const SizedBox(height: 36),

                            // =========================================
                            // SIGN IN BUTTON
                            // =========================================
                            SizedBox(
                              width: double.infinity,

                              child: Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return GestureDetector(
                                    onTap: auth.isLoading
                                        ? null
                                        : () async {
                                            final username = emailController
                                                .text
                                                .trim();
                                            final password =
                                                passwordController.text;

                                            if (username.isEmpty ||
                                                password.isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Please enter username and password",
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            final success = await auth.login(
                                              username,
                                              password,
                                            );
                                            if (success) {
                                              if (mounted) {
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MainNavigation(),
                                                  ),
                                                  (route) => false,
                                                );
                                              }
                                            } else {
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      auth.error ??
                                                          "Invalid username or password",
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                    child: Container(
                                      height: 62,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF2CA999),
                                            Color(0xFF8CF8D6),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor.withValues(
                                              alpha: 0.28,
                                            ),
                                            blurRadius: 24,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          auth.isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.black,
                                                      ),
                                                )
                                              : Text(
                                                  "SIGN IN",
                                                  style: GoogleFonts.poppins(
                                                    color: const Color.fromARGB(
                                                      255,
                                                      16,
                                                      16,
                                                      16,
                                                    ),
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                          const SizedBox(width: 12),
                                          if (!auth.isLoading)
                                            const Icon(
                                              Icons.arrow_forward,
                                              color: Color.fromARGB(
                                                255,
                                                2,
                                                2,
                                                2,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 26),

                            // =========================================
                            // FOOTER
                            // =========================================
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "New to Eternia? ",

                                      style: GoogleFonts.poppins(
                                        color: isDark
                                            ? Colors.white70
                                            : SanctuaryTheme.lightPrimary
                                                  .withValues(alpha: 0.6),

                                        fontSize: 14,
                                      ),
                                    ),

                                    TextSpan(
                                      text: "Get started",

                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,

                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUpScreen(),
                                            ),
                                          );
                                        },

                                      style: GoogleFonts.poppins(
                                        color: primaryColor,

                                        fontWeight: FontWeight.w600,

                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 34),

                  // =================================================
                  // BOTTOM FOOTER
                  // =================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: [
                      footerItem(Icons.shield_outlined, "ENCRYPTED", isDark),

                      footerItem(
                        Icons.visibility_off_outlined,
                        "ANONYMOUS",
                        isDark,
                      ),

                      footerItem(Icons.gpp_good_outlined, "DPDP", isDark),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TEXTFIELD
  // =========================================================

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isPassword,
    required bool isDark,
  }) {
    return Container(
      height: 62,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),

        color: isDark ? Colors.black.withValues(alpha: 0.28) : Colors.white,

        border: Border.all(
          color: isDark
              ? (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE7E2D8))
              : SanctuaryTheme.lightPrimary.withValues(alpha: 0.1),
        ),
      ),

      child: TextField(
        controller: controller,

        obscureText: isPassword ? obscurePassword : false,

        style: TextStyle(
          color: isDark ? Colors.white : SanctuaryTheme.lightPrimary,
        ),

        decoration: InputDecoration(
          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(vertical: 20),

          hintText: hint,

          hintStyle: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.35)
                : SanctuaryTheme.lightPrimary.withValues(alpha: 0.35),
          ),

          prefixIcon: Icon(
            icon,
            color: isDark
                ? Colors.white70
                : SanctuaryTheme.lightPrimary.withValues(alpha: 0.7),
          ),

          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },

                  child: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility,

                    color: isDark
                        ? Colors.white54
                        : SanctuaryTheme.lightPrimary.withValues(alpha: 0.54),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  // =========================================================
  // FOOTER ITEM
  // =========================================================

  Widget footerItem(IconData icon, String title, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark
              ? Colors.white38
              : SanctuaryTheme.lightPrimary.withValues(alpha: 0.38),
        ),

        const SizedBox(width: 6),

        Text(
          title,

          style: GoogleFonts.poppins(
            color: isDark
                ? Colors.white38
                : const Color.fromARGB(
                    255,
                    63,
                    118,
                    104,
                  ).withValues(alpha: 0.38),
            fontSize: 10,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}
