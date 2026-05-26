import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:eternia_ef/Screens/onboarding_screen.dart/sign_in_screen.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/theme_config.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final String username;
  final String otp;

  const CreateNewPasswordScreen({
    super.key,
    required this.username,
    required this.otp,
  });

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  bool obscurePassword = true;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
                  // BACK BUTTON
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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

                  // LOGO
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

                  // GLASS CARD
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.03)
                              : Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Create New Password",
                              style: GoogleFonts.playfairDisplay(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Set a strong password for your sanctuary node.",
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // PASSWORD FIELD
                            _buildInputField(
                              label: "NEW PASSWORD",
                              hint: "••••••••",
                              controller: passwordController,
                              isDark: isDark,
                              primaryColor: primaryColor,
                              obscureText: obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: primaryColor.withValues(alpha: 0.6),
                                ),
                                onPressed: () => setState(
                                  () => obscurePassword = !obscurePassword,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // CONFIRM PASSWORD FIELD
                            _buildInputField(
                              label: "CONFIRM PASSWORD",
                              hint: "••••••••",
                              controller: confirmPasswordController,
                              isDark: isDark,
                              primaryColor: primaryColor,
                              obscureText: obscurePassword,
                            ),

                            const SizedBox(height: 40),

                            // SUBMIT BUTTON
                            Consumer<AuthProvider>(
                              builder: (context, auth, child) {
                                return GestureDetector(
                                  onTap: auth.isLoading
                                      ? null
                                      : () async {
                                          final pass = passwordController.text;
                                          final confirm =
                                              confirmPasswordController.text;

                                          if (pass.isEmpty || pass.length < 8) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Password must be at least 8 characters",
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          if (pass != confirm) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Passwords do not match",
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          final success = await auth
                                              .resetPasswordOTP(
                                                widget.username,
                                                pass,
                                                widget.otp,
                                              );

                                          if (success && mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Password updated! Please login.",
                                                ),
                                              ),
                                            );
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const SignInScreen(),
                                              ),
                                              (route) => false,
                                            );
                                          } else if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Failed to update password. Session may have expired.",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  child: Container(
                                    height: 58,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? [
                                                primaryColor,
                                                const Color(0xFF2CC7B0),
                                              ]
                                            : [
                                                primaryColor,
                                                const Color(0xFF4A9E89),
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: auth.isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.black,
                                            )
                                          : Text(
                                              "Update Password",
                                              style: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    required Color primaryColor,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black26
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDark ? Colors.white24 : Colors.black26,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
