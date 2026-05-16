// ==========================================================
// OTP VERIFICATION SCREEN
// otp_verification_screen.dart
// ==========================================================

import 'package:eternia_ef/Screens/onboarding_screen.dart/private_profile_screen.dart';
import 'package:eternia_ef/widgets/glass_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/theme_config.dart';
import 'create_new_password_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  const OTPVerificationScreen({super.key, required this.email});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  bool isOtpValid() {
    return otpControllers.every((controller) => controller.text.isNotEmpty);
  }

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

                            // decoration: BoxDecoration(
                            //   shape: BoxShape.circle,

                            //   color: isDark
                            //       ? Colors.white.withOpacity(0.05)
                            //       : Colors.white,

                            //   border: Border.all(
                            //     color: isDark ? Colors.white10 : const Color(0xFFE7E2D8),
                            //   ),
                            // ),

                            child: Icon(
                              Icons.arrow_back,

                              size: 28,

                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),

                        //const Spacer(),

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

                    const SizedBox(height: 40),

                    // =================================================
                    // SHIELD DESIGN
                    // =================================================
                    Stack(
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
                                      const Color(0xFF00FFE0).withOpacity(0.18),

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
                          height: 130,
                          width: 130,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
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

                    const SizedBox(height: 28),

                    // =================================================
                    // TITLE
                    // =================================================
                    Align(
                      alignment: Alignment.centerLeft,

                      child: Text(
                        "Enter verification code",

                        style: GoogleFonts.playfairDisplay(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,

                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2D2D2D),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Align(
                      alignment: Alignment.centerLeft,

                      child: Text(
                        "Check your email and enter the 4-digit code we sent to verify your sanctuary access.",

                        style: TextStyle(
                          fontSize: 13,
                          height: 1.7,

                          color: isDark ? Colors.white60 : const Color(0xFF70737C),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // =================================================
                    // OTP BOXES
                    // =================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: List.generate(4, (index) {
                        return SizedBox(
                          width: 68,

                          child: TextField(
                            controller: otpControllers[index],

                            keyboardType: TextInputType.number,

                            textAlign: TextAlign.center,

                            maxLength: 1,

                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,

                              color: primaryColor,
                            ),

                            decoration: InputDecoration(
                              counterText: "",

                              filled: true,

                              fillColor: isDark
                                  ? Colors.white.withOpacity(0.03)
                                  : Colors.white,

                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 18,
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),

                                borderSide: BorderSide(
                                  color: isDark
                                      ? primaryColor.withOpacity(0.25)
                                      : const Color(0xFFD6DCC9),
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),

                                borderSide: BorderSide(
                                  width: 1.6,
                                  color: primaryColor,
                                ),
                              ),
                            ),

                            onChanged: (value) {
                              if (value.length == 1 && index < 3) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 26),

                    // =================================================
                    // RESEND
                    // =================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          "Didn't receive a code? ",

                          style: TextStyle(
                            color: isDark ? Colors.white54 : const Color(0xFF70737C),
                          ),
                        ),

                        Text(
                          "Resend",

                          style: TextStyle(
                            fontWeight: FontWeight.w600,

                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // =================================================
                    // VERIFY BUTTON
                    // =================================================
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return GestureDetector(
                          onTap: auth.isLoading ? null : () async {
                            final otp = otpControllers.map((c) => c.text).join();
                            if (otp.length < 4) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Enter complete OTP")),
                              );
                              return;
                            }

                            final success = await auth.verifyOTP(widget.email, otp);
                            if (success && mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateNewPasswordScreen(
                                    username: widget.email,
                                    otp: otp,
                                  ),
                                ),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Invalid OTP. Hint: 1234")),
                              );
                            }
                          },
                          child: GlassButton(
                            text: auth.isLoading ? "Verifying..." : "Verify",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        );
                      },
                    ),

                    // GestureDetector(
                    //   onTap: () {
                    //     if (isOtpValid()) {
                    //       ScaffoldMessenger.of(
                    //         context,
                    //       ).showSnackBar(
                    //         const SnackBar(
                    //           content: Text(
                    //             "Verification Successful",
                    //           ),
                    //         ),
                    //       );

                    //       // NEXT SCREEN
                    //     } else {
                    //       ScaffoldMessenger.of(
                    //         context,
                    //       ).showSnackBar(
                    //         const SnackBar(
                    //           content: Text(
                    //             "Enter complete OTP",
                    //           ),
                    //         ),
                    //       );
                    //     }
                    //   },

                    //   child: Container(
                    //     height: 62,
                    //     width: double.infinity,

                    //     decoration:
                    //         BoxDecoration(
                    //       borderRadius:
                    //           BorderRadius.circular(
                    //             22,
                    //           ),

                    //       gradient:
                    //           LinearGradient(
                    //         colors:
                    //             isDark
                    //                 ? [
                    //                   const Color(
                    //                     0xFF67FFE2,
                    //                   ),
                    //                   const Color(
                    //                     0xFF2CC7B0,
                    //                   ),
                    //                 ]
                    //                 : [
                    //                   const Color(
                    //                     0xFFB3CC88,
                    //                   ),
                    //                   const Color(
                    //                     0xFF8BAE6A,
                    //                   ),
                    //                 ],
                    //       ),

                    //       boxShadow: [
                    //         BoxShadow(
                    //           color:
                    //               primaryColor
                    //                   .withOpacity(
                    //                     0.35,
                    //                   ),

                    //           blurRadius: 24,
                    //           offset:
                    //               const Offset(
                    //                 0,
                    //                 10,
                    //               ),
                    //         ),
                    //       ],
                    //     ),

                    //     child: Row(
                    //       mainAxisAlignment:
                    //           MainAxisAlignment
                    //               .center,

                    //       children: [
                    //         const Icon(
                    //           Icons.shield_outlined,

                    //           color:
                    //               Colors.white,
                    //         ),

                    //         const SizedBox(
                    //           width: 10,
                    //         ),

                    //         Text(
                    //           "Verify",

                    //           style:
                    //               GoogleFonts
                    //                   .poppins(
                    //             fontWeight:
                    //                 FontWeight
                    //                     .w600,

                    //             color:
                    //                 Colors.white,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 90),

                    // =================================================
                    // FOOTER
                    // =================================================
                    Column(
                      children: [
                        Icon(Icons.lock_outline, size: 20, color: primaryColor),

                        const SizedBox(height: 10),

                        Text(
                          "SECURE CONNECTION",

                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            letterSpacing: 4,

                            color: isDark ? Colors.white54 : Colors.black38,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
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
