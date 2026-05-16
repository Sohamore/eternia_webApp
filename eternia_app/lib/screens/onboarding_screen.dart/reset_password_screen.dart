// ==========================================================
// RESET PASSWORD SCREEN
// FULL UPDATED UI
// ==========================================================

import 'package:eternia_ef/Screens/onboarding_screen.dart/otp_verificationScreen.dart';
import 'package:eternia_ef/widgets/glass_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/theme_config.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

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
                    // =================================================
                    // TOP BAR
                    // =================================================
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },

                          child: Container(
                            width: 40,
                            height: 40,

                            child: Icon(
                              Icons.arrow_back,

                              size: 28,

                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),

                        // const Spacer(),

                       Text(
                          "Eternia",

                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,

                            color: isDark ?  const Color(0xFF67F5D4)
        : const Color(0xFF53B29A),
                          ),
                        ),

                        const Spacer(),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // =================================================
                    // TOP DESIGN
                    // =================================================
                    Center(
                      child: Stack(
                        alignment: Alignment.center,

                        children: [
                          Container(
                            height: 180,
                            width: 180,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              gradient: RadialGradient(
                                colors: isDark
                                    ? [
                                        const Color(
                                          0xFF00FFE0,
                                        ).withOpacity(0.18),

                                        Colors.transparent,
                                      ]
                                    : [
                                        const Color(0xFFDDE9CB),

                                        Colors.transparent,
                                      ],
                              ),
                            ),
                          ),

                          Container(
                            height: 120,
                            width: 120,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              border: Border.all(
                                color: primaryColor.withOpacity(0.25),
                              ),
                            ),
                          ),

                          Icon(
                            Icons.shield_outlined,

                            size: 70,

                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // TITLE
                    // =================================================
                    Text(
                      "Reset Password",

                      style: GoogleFonts.playfairDisplay(
                        fontSize: 38,
                        fontWeight: FontWeight.w600,

                        color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Enter your email or pseudonym to receive a recovery code.",

                      style: TextStyle(
                        fontSize: 13,
                        height: 1.7,

                        color: isDark ? Colors.white60 : const Color(0xFF70737C),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // =================================================
                    // LABEL
                    // =================================================
                    Text(
                      "Account Identity",

                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,

                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // =================================================
                    // TEXTFIELD
                    // =================================================
                    Container(
                      height: 58,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),

                        color: isDark
                            ? (isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.92))
                            : Colors.white,

                        border: Border.all(
                          color: isDark
                              ? primaryColor.withOpacity(0.25)
                              : const Color(0xFFD9DFC8),
                        ),
                      ),

                      child: TextField(
                        controller: emailController,

                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),

                        decoration: InputDecoration(
                          border: InputBorder.none,

                          hintText: "pseudonym@eternia.io",

                          hintStyle: TextStyle(
                            color: isDark ? Colors.white38 : const Color(0xFF9DA3A8),
                          ),

                          prefixIcon: Icon(
                            Icons.email_outlined,

                            color: primaryColor,
                          ),

                          suffixIcon: Icon(
                            Icons.alternate_email,

                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =================================================
                    // INFO CARD
                    // =================================================
                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),

                        color: isDark
                            ? Colors.white.withOpacity(0.03)
                            : const Color(0xFFF1F0E8),

                        border: Border.all(
                          color: isDark ? Colors.white10 : const Color(0xFFE7E2D8),
                        ),
                      ),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Container(
                            width: 44,
                            height: 44,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              color: primaryColor.withOpacity(0.15),
                            ),

                            child: Icon(
                              Icons.shield_outlined,

                              color: primaryColor,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  "Secure Protocol",

                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,

                                    fontSize: 14,

                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "Your recovery request will be processed through our end-to-end encrypted sanctuary layer.",

                                  style: TextStyle(
                                    fontSize: 12,

                                    height: 1.7,

                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // =================================================
                    // SHIELD DESIGN
                    // =================================================
                    // Center(
                    //   child: Stack(
                    //     alignment: Alignment.center,

                    //     children: [
                    //       Container(
                    //         height: 230,
                    //         width: 230,

                    //         decoration: BoxDecoration(
                    //           shape: BoxShape.circle,

                    //           gradient: RadialGradient(
                    //             colors: isDark
                    //                 ? [
                    //                     const Color(
                    //                       0xFF00FFE0,
                    //                     ).withOpacity(0.15),

                    //                     Colors.transparent,
                    //                   ]
                    //                 : [
                    //                     const Color(0xFFDCE7CB),

                    //                     Colors.transparent,
                    //                   ],
                    //           ),
                    //         ),
                    //       ),

                    //       Container(
                    //         height: 170,
                    //         width: 170,

                    //         decoration: BoxDecoration(
                    //           shape: BoxShape.circle,

                    //           border: Border.all(
                    //             color: primaryColor.withOpacity(0.3),
                    //           ),
                    //         ),
                    //       ),

                    //       Icon(Icons.shield, size: 120, color: primaryColor),

                    //       Positioned(
                    //         bottom: 45,

                    //         child: Icon(
                    //           Icons.lock,
                    //           size: 38,

                    //           color: isDark ? Colors.white : Colors.white,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(height: 26),

                    // =================================================
                    // BUTTON
                    // =================================================
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return GestureDetector(
                          onTap: auth.isLoading ? null : () async {
                            final email = emailController.text.trim();
                            if (email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please enter your username/email")),
                              );
                              return;
                            }

                            final success = await auth.sendOTP(email);
                            if (success && mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OTPVerificationScreen(email: email),
                                ),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Failed to send OTP. Try again.")),
                              );
                            }
                          },
                          child: GlassButton(
                            text: auth.isLoading ? "Sending..." : "Send Reset Code",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: const Color.fromARGB(255, 7, 7, 7),
                            ),
                          ),
                        );
                      },
                    ),

                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,

                    //       MaterialPageRoute(
                    //         builder: (_) => const OTPVerificationScreen(),
                    //       ),
                    //     );
                    //   },

                    //   child: Container(
                    //     height: 60,
                    //     width: double.infinity,

                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(22),

                    //       gradient: LinearGradient(
                    //         colors: isDark
                    //             ? [
                    //                 const Color(0xFF67FFE2),
                    //                 const Color(0xFF2CC7B0),
                    //               ]
                    //             : [
                    //                 const Color(0xFFB3CC88),
                    //                 const Color(0xFF8BAE6A),
                    //               ],
                    //       ),

                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: primaryColor.withOpacity(0.35),

                    //           blurRadius: 24,
                    //           offset: const Offset(0, 10),
                    //         ),
                    //       ],
                    //     ),

                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,

                    //       children: [
                    //         Text(
                    //           "Send Reset Code",

                    //           style: GoogleFonts.poppins(
                    //             fontWeight: FontWeight.w600,
                    //             fontSize: 16,
                    //             color: Colors.white,
                    //           ),
                    //         ),

                    //         const SizedBox(width: 10),

                    //         const Icon(
                    //           Icons.flash_on,
                    //           size: 18,
                    //           color: Colors.white,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 24),

                    // =================================================
                    // FOOTER
                    // =================================================
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Remembered it? ",

                              style: TextStyle(
                                color: isDark ? Colors.white54 : const Color(0xFF70737C),
                              ),
                            ),

                            TextSpan(
                              text: "Sign In",

                              style: TextStyle(
                                fontWeight: FontWeight.w600,

                                color: primaryColor,
                              ),
                            ),
                          ],
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
}
