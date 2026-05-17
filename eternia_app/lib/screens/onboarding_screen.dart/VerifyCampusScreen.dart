import 'package:eternia_ef/Screens/onboarding_screen.dart/sign_in_screen.dart';
import 'package:eternia_ef/Screens/onboarding_screen.dart/sign_up_screen.dart';
import 'package:eternia_ef/Screens/onboarding_screen.dart/InstitutionalScanScreen.dart';
import 'package:eternia_ef/widgets/glass_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_config.dart';

class VerifyCampusScreen extends StatefulWidget {
  const VerifyCampusScreen({super.key});

  @override
  State<VerifyCampusScreen> createState() => _VerifyCampusScreenState();
}

class _VerifyCampusScreenState extends State<VerifyCampusScreen> {
  final TextEditingController codeController = TextEditingController();
  bool _isVerifying = false;
  String? _errorMessage;

  Future<void> _verifyCode() async {
    final code = codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorMessage = "Please enter your institution code");
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final result = await auth.verifyInstitutionalCode(code);

      if (!mounted) return;

      if (result != null && result['success'] == true) {
        final institutionName = result['institutionName'] as String? ?? '';
        final institutionId = result['institutionId'] as String?;

        // Show success toast then navigate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verified: $institutionName'),
            backgroundColor: const Color(0xFF53B29A),
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpScreen(institutionId: institutionId),
          ),
        );
      } else {
        setState(
          () => _errorMessage = auth.error ?? "Invalid institution code",
        );
      }
    } catch (e) {
      setState(() => _errorMessage = "Verification failed. Please try again.");
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

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
                  horizontal: 22,
                  vertical: 14,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const SizedBox(height: 10),

                    // TOP BAR
                    // Row(
                    //   children: [
                    //     activeBar(),
                    //     inactiveBar(),
                    //     inactiveBar(),
                    //     inactiveBar(),
                    //   ],
                    // ),
                    const SizedBox(height: 28),

                    // LOGO
                    Row(
                      children: [
                        Icon(
                          Icons.hub_outlined,
                          size: 18,
                          color: isDark
                              ? const Color(0xFF67F5D4)
                              : const Color(0xFF53B29A),
                        ),

                        const SizedBox(width: 8),

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
                      ],
                    ),

                    const SizedBox(height: 22),

                    // TITLE + BG ORBIT LOGO
                    SizedBox(
                      height: 230,

                      child: Stack(
                        children: [
                          // RIGHT SIDE ORBIT LOGO
                          Positioned(
                            right: -20,
                            top: -10,

                            child: Opacity(
                              opacity: isDark ? 0.95 : 0.8,

                              child: SizedBox(
                                width: 220,
                                height: 220,

                                child: Stack(
                                  alignment: Alignment.center,

                                  children: [
                                    // OUTER GLOW
                                    Container(
                                      width: 170,
                                      height: 170,

                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,

                                        gradient: RadialGradient(
                                          colors: [
                                            const Color(
                                              0xFF00F0D0,
                                            ).withOpacity(0.35),

                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),

                                    // MAIN PLANET
                                    Container(
                                      width: 115,
                                      height: 115,

                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,

                                        gradient: RadialGradient(
                                          colors: [
                                            const Color(0xFF79FFE1),

                                            const Color(0xFF0E6B69),

                                            const Color(0xFF042F32),
                                          ],
                                        ),

                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF52FFE0,
                                            ).withOpacity(0.5),

                                            blurRadius: 35,
                                            spreadRadius: 4,
                                          ),
                                        ],
                                      ),

                                      child: Center(
                                        child: Container(
                                          width: 55,
                                          height: 55,

                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),

                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),

                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.15,
                                              ),
                                            ),
                                          ),

                                          child: const Icon(
                                            Icons.account_balance_rounded,

                                            size: 30,
                                            color: Color(0xFFC8FFF5),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ORBIT RING 1
                                    Transform.rotate(
                                      angle: 0.3,

                                      child: Container(
                                        width: 200,
                                        height: 95,

                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),

                                          border: Border.all(
                                            color: const Color(
                                              0xFF4FFFE3,
                                            ).withOpacity(0.55),

                                            width: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ORBIT RING 2
                                    Transform.rotate(
                                      angle: -0.2,

                                      child: Container(
                                        width: 185,
                                        height: 82,

                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),

                                          border: Border.all(
                                            color: const Color(
                                              0xFF3DD8C3,
                                            ).withOpacity(0.2),

                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // SMALL GLOW DOTS
                                    Positioned(
                                      top: 30,
                                      left: 50,
                                      child: glowDot(),
                                    ),

                                    Positioned(
                                      top: 50,
                                      right: 35,
                                      child: glowDot(),
                                    ),

                                    Positioned(
                                      bottom: 40,
                                      left: 45,
                                      child: glowDot(),
                                    ),

                                    Positioned(
                                      bottom: 25,
                                      right: 55,
                                      child: glowDot(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // TITLE
                          Positioned(
                            left: 0,
                            top: 25,

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Verify Your\n",

                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 50,
                                          height: 1.05,
                                          fontWeight: FontWeight.w500,

                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF262626),
                                        ),
                                      ),

                                      TextSpan(
                                        text: "Campus",

                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 50,
                                          height: 1.05,
                                          fontWeight: FontWeight.w600,

                                          color: isDark
                                              ? const Color(0xFF67F5D4)
                                              : const Color(0xFF53B29A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 18),

                                Text(
                                  "Your college provides a unique code\nfor access. Contact your institution\nif you don't have one.",

                                  style: TextStyle(
                                    height: 1.8,
                                    fontSize: 14,

                                    color: isDark
                                        ? Colors.white60
                                        : const Color(0xFF70737C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // LABEL
                    Text(
                      "INSTITUTION CODE",

                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 3,

                        color: isDark
                            ? const Color(0xFF67F5D4)
                            : const Color(0xFF53B29A),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // INPUT
                    Container(
                      height: 62,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),

                        color: isDark
                            ? (isDark
                                  ? Colors.white.withOpacity(0.04)
                                  : Colors.white.withOpacity(0.92))
                            : Colors.white,

                        border: Border.all(
                          color: isDark
                              ? Colors.white10
                              : const Color(0xFFE7E2D8),
                        ),
                      ),

                      child: TextField(
                        controller: codeController,

                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),

                        decoration: InputDecoration(
                          border: InputBorder.none,

                          prefixIcon: Icon(
                            Icons.account_balance,

                            color: isDark
                                ? const Color(0xFF67F5D4)
                                : const Color(0xFF53B29A),
                          ),

                          hintText: "E.g. UNIV2024",

                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFF9DA3A8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // CONTINUE BUTTON
                    GestureDetector(
                      onTap: _isVerifying ? null : _verifyCode,
                      child: _isVerifying
                          ? Container(
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color(0xFF53B29A).withOpacity(0.5),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : const GlassButton(text: "Continue"),
                    ),

                    const SizedBox(height: 22),

                    // SIGN IN
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Already have an account? ",

                              style: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF70737C),
                              ),
                            ),

                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignInScreen(),
                                    ),
                                  );
                                },
                              text: "Sign in",

                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF67F5D4)
                                    : const Color(0xFF53B29A),

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ERROR MESSAGE
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.red.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // INFO CARD
                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),

                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF67F5D4).withOpacity(0.15)
                              : const Color(0xFF53B29A).withOpacity(0.15),
                        ),

                        color: isDark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.white.withOpacity(0.75),
                      ),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Container(
                            width: 38,
                            height: 38,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF67F5D4)
                                    : const Color(0xFF53B29A),
                              ),
                            ),

                            child: Icon(
                              Icons.info_outline,
                              size: 20,

                              color: isDark
                                  ? const Color(0xFF67F5D4)
                                  : const Color(0xFF53B29A),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  "What is an Institution Code?",

                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,

                                    fontSize: 14,

                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "A unique code provided by your college when they partner with Eternia. It ensures only verified students can access the platform ecosystem and secure resources.",

                                  style: TextStyle(
                                    height: 1.7,
                                    fontSize: 12,

                                    color: isDark
                                        ? Colors.white60
                                        : const Color(0xFF70737C),
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }

  Widget glowDot() {
    return Container(
      width: 7,
      height: 7,

      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF7CFFF0),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7CFFF0).withOpacity(0.8),

            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget activeBar() {
    return Container(
      margin: const EdgeInsets.only(right: 6),

      height: 4,
      width: 34,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF53B29A),
      ),
    );
  }

  Widget inactiveBar() {
    return Container(
      margin: const EdgeInsets.only(right: 6),

      height: 4,
      width: 34,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.withOpacity(0.3),
      ),
    );
  }
}
