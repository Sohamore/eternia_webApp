import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:eternia_ef/Tabs/ConnectPage/secure_report_screen.dart';

class InstitutionalSupportScreen extends StatefulWidget {
  const InstitutionalSupportScreen({super.key});

  @override
  State<InstitutionalSupportScreen> createState() => _InstitutionalSupportScreenState();
}

class _InstitutionalSupportScreenState extends State<InstitutionalSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isJoined = false;
  String? selectedOrg;

  final List<String> _popularOrgs = ["SJCEM College", "SteelWorks Corp", "St. John University", "Eternia Sanctuary"];

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
          // BACKGROUND DECORATION
          Positioned(
            top: -100, right: -100,
            child: Container(
              height: 300, width: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: primary.withOpacity(0.05)),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: textSecondary, size: 20),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Institutional\nSupport",
                    style: GoogleFonts.playfairDisplay(color: textPrimary, fontSize: 38, fontWeight: FontWeight.bold, height: 1.1),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Connect within your college, workspace, or community circle for exclusive, tailored support.",
                    style: GoogleFonts.poppins(color: textSecondary, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  // 1. SEARCH BAR (Organization Discovery)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.poppins(color: textPrimary),
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: primary),
                        hintText: "Find your organization...",
                        hintStyle: GoogleFonts.poppins(color: textSecondary, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (!isJoined) ...[
                    Text("POPULAR NEARBY", style: GoogleFonts.poppins(color: primary, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._popularOrgs.map((org) => _buildOrgItem(org, isDark, primary, cardColor, borderColor, textPrimary)),
                  ] else ...[
                    // JOINED VIEW
                    _buildActiveOrgHeader(selectedOrg!, primary, cardColor, borderColor, textPrimary),
                    const SizedBox(height: 32),
                    
                    // 2. EXCLUSIVE EXPERTS
                    _buildSectionHeader("INSTITUTIONAL EXPERTS", primary),
                    const SizedBox(height: 12),
                    _buildExpertSmall(
                      "Dr. Sarah Miller", 
                      "Campus Counselor", 
                      "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&q=80",
                      primary, cardColor, borderColor, textPrimary
                    ),
                    const SizedBox(height: 12),
                    _buildExpertSmall(
                      "Johnathan Wick", 
                      "Student Wellbeing Lead", 
                      "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&q=80",
                      primary, cardColor, borderColor, textPrimary
                    ),
                    
                    const SizedBox(height: 32),

                    // 3. CAMPUS EVENTS
                    _buildSectionHeader("UPCOMING EVENTS", primary),
                    const SizedBox(height: 12),
                    _buildEventCard("Mindfulness 101", "Mon, 10:00 AM • Auditorium A", primary, cardColor, borderColor, textPrimary),
                    const SizedBox(height: 12),
                    _buildEventCard("Exam Stress Circle", "Wed, 04:00 PM • Library Hub", primary, cardColor, borderColor, textPrimary),

                    const SizedBox(height: 32),

                    // 4. ANONYMOUS REPORT
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shield_outlined, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 12),
                              Text("Anonymous Reporting", style: GoogleFonts.playfairDisplay(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Securely report systemic issues or concerns directly to your organization's management.",
                            style: GoogleFonts.poppins(color: Colors.redAccent.withOpacity(0.7), fontSize: 11),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SecureReportScreen()));
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(14)),
                              child: Center(child: Text("Start Secure Report", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                            ),
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

  Widget _buildSectionHeader(String title, Color primary) {
    return Text(title, style: GoogleFonts.poppins(color: primary, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold));
  }

  Widget _buildOrgItem(String name, bool isDark, Color primary, Color cardColor, Color borderColor, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            isJoined = true;
            selectedOrg = name;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)),
          child: Row(
            children: [
              Container(
                height: 40, width: 40,
                decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.business_rounded, color: primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(name, style: GoogleFonts.playfairDisplay(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600))),
              Icon(Icons.add_circle_outline, color: primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOrgHeader(String name, Color primary, Color cardColor, Color borderColor, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary.withOpacity(0.2), primary.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: primary, child: const Icon(Icons.check, color: Colors.white)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("VERIFIED ACCESS", style: GoogleFonts.poppins(color: primary, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
                Text(name, style: GoogleFonts.playfairDisplay(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          TextButton(onPressed: () => setState(() => isJoined = false), child: const Text("Change", style: TextStyle(color: Colors.grey, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildExpertSmall(String name, String role, String imgUrl, Color primary, Color cardColor, Color borderColor, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
      child: Row(
        children: [
          Container(
            height: 40, width: 40, 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(role, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.chat_bubble_outline, color: primary, size: 18),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, String time, Color primary, Color cardColor, Color borderColor, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.calendar_today_rounded, color: primary, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(time, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
