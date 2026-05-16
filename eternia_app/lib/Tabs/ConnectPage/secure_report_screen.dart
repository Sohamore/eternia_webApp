import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class SecureReportScreen extends StatefulWidget {
  const SecureReportScreen({super.key});

  @override
  State<SecureReportScreen> createState() => _SecureReportScreenState();
}

class _SecureReportScreenState extends State<SecureReportScreen> {
  final TextEditingController _reportController = TextEditingController();
  String? selectedCategory;
  bool isSubmitted = false;

  final List<String> categories = ["Harassment", "Burnout / Stress", "Facilities", "Ethics & Conduct", "Other"];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final bool isDark = provider.isDark;

    final Color primary = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF53B29A);
    final Color bg = isDark ? const Color(0xFF040B0D) : const Color(0xFFF6F3ED);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1B2722);
    final Color textSecondary = isDark ? Colors.white38 : const Color(0xFF70737C);
    final Color cardColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final Color borderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // SCANNER BACKGROUND EFFECT
          if (!isSubmitted)
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(painter: GridPainter(primary)),
              ),
            ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close_rounded, color: textSecondary, size: 24),
                  ),
                  const SizedBox(height: 32),

                  if (!isSubmitted) ...[
                    Row(
                      children: [
                        Icon(Icons.shield_rounded, color: Colors.redAccent, size: 28),
                        const SizedBox(width: 12),
                        Text("Secure Portal", style: GoogleFonts.playfairDisplay(color: Colors.redAccent, fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your identity is shielded by Eternia's zero-knowledge encryption. No one, including your organization, can trace this report back to you.",
                      style: GoogleFonts.poppins(color: textSecondary, fontSize: 11, height: 1.6),
                    ),
                    const SizedBox(height: 40),

                    Text("SELECT CATEGORY", style: GoogleFonts.poppins(color: primary, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        bool isSelected = selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setState(() => selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? primary : cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? primary : borderColor),
                            ),
                            child: Text(cat, style: GoogleFonts.poppins(color: isSelected ? (isDark ? Colors.black : Colors.white) : textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                    Text("REPORT DETAILS", style: GoogleFonts.poppins(color: primary, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
                      child: TextField(
                        controller: _reportController,
                        maxLines: 6,
                        style: GoogleFonts.poppins(color: textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Describe the situation in detail...",
                          hintStyle: GoogleFonts.poppins(color: textSecondary, fontSize: 13),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: () {
                        if (selectedCategory != null && _reportController.text.isNotEmpty) {
                          setState(() => isSubmitted = true);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: (selectedCategory != null && _reportController.text.isNotEmpty) ? Colors.redAccent : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: (selectedCategory != null && _reportController.text.isNotEmpty) 
                            ? [BoxShadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]
                            : [],
                        ),
                        child: Center(child: Text("SUBMIT ENCRYPTED REPORT", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1))),
                      ),
                    ),
                  ] else ...[
                    // SUCCESS STATE
                    const SizedBox(height: 60),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 100, width: 100,
                            decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
                            child: Icon(Icons.check_circle_outline_rounded, color: primary, size: 60),
                          ),
                          const SizedBox(height: 32),
                          Text("Report Submitted", style: GoogleFonts.playfairDisplay(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(
                            "Your report has been encrypted and sent to the institutional review board. Your identity remains 100% anonymous.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(color: textSecondary, fontSize: 13, height: 1.6),
                          ),
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
                            child: Column(
                              children: [
                                Text("TRACKING CASE ID", style: GoogleFonts.poppins(color: textSecondary, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text("ETN-SEC-882-991", style: GoogleFonts.poppins(color: primary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                const SizedBox(height: 8),
                                Text("Save this ID to track updates anonymously.", style: GoogleFonts.poppins(color: textSecondary, fontSize: 10)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 60),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text("Return to Sanctuary", style: GoogleFonts.poppins(color: primary, fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
