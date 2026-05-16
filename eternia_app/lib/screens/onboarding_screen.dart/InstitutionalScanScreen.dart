// ==========================================================
// institutional_scan_screen.dart
// ==========================================================

import 'package:eternia_ef/widgets/glass_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'reset_password_screen.dart';

import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_config.dart';

class InstitutionalScanScreen extends StatefulWidget {
  const InstitutionalScanScreen({super.key});

  @override
  State<InstitutionalScanScreen> createState() =>
      _InstitutionalScanScreenState();
}

class _InstitutionalScanScreenState extends State<InstitutionalScanScreen> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MobileScannerController controller = MobileScannerController();

  bool scanned = false;
  String scannedCode = "";

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void moveToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final isDark = provider.isDark;

    return Scaffold(
      // key: _scaffoldKey,
     // drawer: _buildDrawer(isDark, context),
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ...SanctuaryTheme.buildBackgroundGlow(isDark),
          SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // TOP BAR
                // ==================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Row(
                      children: [ GestureDetector(
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
                        

                        const SizedBox(width: 10),

                        Text(
                          "Eternia",

                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,

                            color: isDark ?  const Color(0xFF67F5D4)
        : const Color(0xFF53B29A),
                          ),
                        ),
                      ],
                    ),

                    Container(
                      width: 38,
                      height: 38,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),

                      child: Icon(
                        Icons.qr_code_scanner,

                        size: 18,

                        color: isDark ?  const Color(0xFF67F5D4)
        : const Color(0xFF53B29A),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ==================================================
                // TITLE
                // ==================================================
                Text(
                  "Institutional Scan",

                  style: GoogleFonts.playfairDisplay(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,

                    color: isDark ? Colors.white : const Color(0xFF2B2B2B),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Position the QR code within the frame to verify your affiliation with the ETERNIA educational network.",

                  style: TextStyle(
                    height: 1.7,
                    fontSize: 13,

                    color: isDark ? Colors.white60 : const Color(0xFF70737C),
                  ),
                ),

                const SizedBox(height: 26),

                // ==================================================
                // SCANNER
                // ==================================================
                Container(
                  height: 320,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),

                    color: isDark ? const Color(0xFF071B1C) : Colors.white,

                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF0FA89B).withOpacity(0.4)
                          : const Color(0xFFB7D3A5),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0xFF00FFE1).withOpacity(0.08)
                            : const Color(0xFF7BA268).withOpacity(0.08),

                        blurRadius: 20,
                      ),
                    ],
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),

                    child: Stack(
                      children: [
                        // ======================================
                        // REAL SCANNER
                        // ======================================
                        MobileScanner(
                          controller: controller,

                          onDetect: (capture) async {
                            if (scanned) return;

                            final List<Barcode> barcodes = capture.barcodes;

                            if (barcodes.isNotEmpty) {
                              setState(() {
                                scanned = true;

                                scannedCode = barcodes.first.rawValue ?? "";
                              });

                              moveToNextScreen();
                            }
                          },
                        ),

                        // ======================================
                        // OVERLAY
                        // ======================================
                        Container(
                          color: isDark
                              ? Colors.black.withOpacity(0.35)
                              : Colors.white.withOpacity(0.25),
                        ),

                        // ======================================
                        // SCAN LINE
                        // ======================================
                        Positioned(
                          top: 150,
                          left: 25,
                          right: 25,

                          child: Container(
                            height: 2,

                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,

                                  isDark ? const Color(0xFF67F5D4)
                                      : const Color(0xFF7BA268),

                                  Colors.transparent,
                                ],
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? const Color(0xFF67F5D4)
                                      : const Color(0xFF7BA268),

                                  blurRadius: 14,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ======================================
                        // QR ICON
                        // ======================================
                        Center(
                          child: Icon(
                            Icons.qr_code_2_rounded,

                            size: 90,

                            color: isDark ?  const Color(0xFF67F5D4)
        : const Color(0xFF53B29A)
                          ),
                        ),

                        // ======================================
                        // CORNERS
                        // ======================================
                        scannerCorner(top: 22, left: 22, isDark: isDark),

                        scannerCorner(top: 22, right: 22, isDark: isDark),

                        scannerCorner(bottom: 22, left: 22, isDark: isDark),

                        scannerCorner(bottom: 22, right: 22, isDark: isDark),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // STATUS
                // ==================================================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),

                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white,
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,

                        child: CircularProgressIndicator(
                          strokeWidth: 2,

                          color: isDark ? const Color(0xFF67F5D4)
                              : const Color(0xFF7BA268),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Flexible(
                        child: Text(
                          scanned
                              ? "QR Successfully Scanned"
                              : "Initializing scanner...",

                          overflow: TextOverflow.ellipsis,

                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,

                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // BUTTON
                // ==================================================
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResetPasswordScreen(),
                      ),
                    );
                  },
                  child: const GlassButton(text: "Scan QR Code"),
                ),

                // GestureDetector(
                //   onTap: () {
                //     moveToNextScreen();
                //   },

                //   child: Container(
                //     height: 60,
                //     width:
                //         double.infinity,

                //     decoration:
                //         BoxDecoration(
                //       borderRadius:
                //           BorderRadius.circular(
                //             20,
                //           ),

                //       gradient:
                //           LinearGradient(
                //         colors:
                //             isDark
                //                 ? [
                //                   const Color(
                //                     0xFF046B68,
                //                   ),
                //                   const Color(
                //                     0xFF0FB3A2,
                //                   ),
                //                 ]
                //                 : [
                //                   const Color(
                //                     0xFFA8C97C,
                //                   ),
                //                   const Color(
                //                     0xFF7BA268,
                //                   ),
                //                 ],
                //       ),
                //     ),

                //     child: Row(
                //       mainAxisAlignment:
                //           MainAxisAlignment
                //               .center,

                //       children: [
                //         const Icon(
                //           Icons.qr_code_2,
                //           color:
                //               Colors.white,
                //         ),

                //         const SizedBox(
                //           width: 10,
                //         ),

                //         Text(
                //           "Scan QR Code",

                //           style:
                //               GoogleFonts
                //                   .poppins(
                //             color:
                //                 Colors.white,

                //             fontWeight:
                //                 FontWeight
                //                     .w600,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                const SizedBox(height: 14),

                // ==================================================
                // MANUAL
                // ==================================================
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Can't scan? ",
                              style: TextStyle(
                                color: isDark ? Colors.white54 : const Color(0xFF70737C),
                              ),
                            ),
                            TextSpan(
                              text: "Enter code manually →",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ?  const Color(0xFF67F5D4)
        : const Color(0xFF53B29A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // INFO CARD
                // ==================================================
                Container(
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),

                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFE7E2D8),
                    ),

                    color: isDark
                        ? Colors.white.withOpacity(0.03)
                        : Colors.white,
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Container(
                        width: 42,
                        height: 42,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          color: isDark
                              ? const Color(0xFF0D2A2A)
                              : const Color.fromARGB(255, 179, 204, 198)
                        ),

                        child: Icon(
                          Icons.shield_outlined,

                          color: isDark ?  const Color(0xFF67F5D4)
        : const Color(0xFF53B29A),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Why is this needed?",

                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,

                                fontWeight: FontWeight.w600,

                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Verification ensures a secure and exclusive digital environment for verified students.",

                              style: TextStyle(
                                height: 1.7,

                                fontSize: 12,

                                color: isDark ? Colors.white60 : const Color(0xFF70737C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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

  Widget scannerCorner({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required bool isDark,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,

      child: Align(
        alignment: Alignment.center,

        child: Container(
          width: 34,
          height: 34,

          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF67F5D4)
        : const Color(0xFF53B29A),

                width: 3,
              ),

              left: BorderSide(
                color: isDark ? const Color(0xFF67F5D4)
        : const Color(0xFF53B29A),

                width: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildDrawer(bool isDark, BuildContext context) {
  //   return Drawer(
  //     backgroundColor: isDark ? const Color(0xFF040F0F) : const Color(0xFFF6FBF6),
  //     child: ListView(
  //       padding: EdgeInsets.zero,
  //       children: [
  //         DrawerHeader(
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               colors: isDark
  //                   ? [const Color(0xFF014B50), const Color(0xFF0DA8A0)]
  //                   : [const Color(0xFF9BC283), const Color(0xFF7EAA68)],
  //             ),
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: [
  //               const CircleAvatar(
  //                 radius: 30,
  //                 backgroundColor: Colors.white24,
  //                 child: Icon(Icons.person, color: Colors.white, size: 35),
  //               ),
  //               const SizedBox(height: 12),
  //               Text(
  //                 "ETERNIA USER",
  //                 style: GoogleFonts.poppins(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 18,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         _drawerTile(Icons.home_outlined, "Home", isDark, () => Navigator.pop(context)),
  //         _drawerTile(Icons.info_outline, "About Us", isDark, () {}),
  //         _drawerTile(Icons.help_outline, "Support", isDark, () {}),
  //         _drawerTile(Icons.privacy_tip_outlined, "Privacy", isDark, () {}),
  //         const Divider(),
  //         _drawerTile(Icons.logout, "Logout", isDark, () {}),
  //       ],
  //     ),
  //   );
  // }

  // Widget _drawerTile(IconData icon, String title, bool isDark, VoidCallback onTap) {
  //   return ListTile(
  //     leading: Icon(icon, color: isDark ? const Color(0xFF67F5D4) : const Color(0xFF7BA268)),
  //     title: Text(
  //       title,
  //       style: GoogleFonts.poppins(
  //         color: isDark ? Colors.white : Colors.black87,
  //         fontSize: 15,
  //       ),
  //     ),
  //     onTap: onTap,
  //   );
  // }
}
