import 'package:eternia_ef/Tabs/ConnectPage/group_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class RecommendScreen extends StatefulWidget {
  const RecommendScreen({super.key});

  @override
  State<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> {
  // Track state for each group: null (not joined), 'loading', 'joined'
  final Map<String, String?> _joinStates = {};

  void _handleJoin(String groupName, Color primary) {
    if (_joinStates[groupName] == 'joined') {
      // Already joined, just navigate
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => GroupChatScreen(
          groupName: groupName,
          onLeave: () => setState(() => _joinStates[groupName] = null),
        ),
      ));
      return;
    }

    setState(() => _joinStates[groupName] = 'loading');

    // Simulate joining process
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _joinStates[groupName] = 'joined');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome to $groupName! Your safe space is ready.", style: GoogleFonts.poppins(fontSize: 12)),
          backgroundColor: primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate after a small delay to let user see the checkmark
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => GroupChatScreen(
            groupName: groupName,
            onLeave: () => setState(() => _joinStates[groupName] = null),
          ),
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final bool isDark = provider.isDark;

    final Color primary = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF53B29A);
    final Color bg = isDark ? const Color(0xFF071011) : const Color(0xFFF6F3ED);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1B2722);
    final Color textSecondary = isDark ? Colors.white38 : const Color(0xFF70737C);
    final Color cardColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.85);
    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFFE7E2D8);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(textPrimary, textSecondary, primary, isDark),
              const SizedBox(height: 32),
              _buildRecommendationCard(
                "Peer Circle #242", "Anxiety Support", "12 Active Nodes",
                isDark, primary, cardColor, borderColor, textPrimary,
              ),
              const SizedBox(height: 16),
              _buildRecommendationCard(
                "Meditation Club", "Mindfulness", "45 Active Nodes",
                isDark, primary, cardColor, borderColor, textPrimary,
              ),
              const SizedBox(height: 16),
              _buildRecommendationCard(
                "Academic Hub", "Study Stress", "28 Active Nodes",
                isDark, primary, cardColor, borderColor, textPrimary,
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textPrimary, Color textSecondary, Color primary, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, size: 20, color: isDark ? Colors.white70 : Colors.black54),
        ),
        const SizedBox(height: 20),
        Text(
          "Peer\nRecommendations",
          style: GoogleFonts.cormorantGaramond(color: primary, fontSize: 36, fontWeight: FontWeight.bold, height: 1),
        ),
        const SizedBox(height: 8),
        Text(
          "Based on your recent journey and reflections.",
          style: GoogleFonts.poppins(color: textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    String title, String tag, String nodes,
    bool isDark, Color primary, Color cardColor, Color borderColor, Color textPrimary,
  ) {
    final state = _joinStates[title];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            height: 54, width: 54,
            decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
            child: Icon(Icons.people_outline, color: primary),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tag.toUpperCase(), style: GoogleFonts.poppins(color: primary, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                Text(title, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
                Text(nodes, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _handleJoin(title, primary),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(state == 'loading' ? 8 : 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: state == 'joined' ? primary : Colors.transparent,
                border: Border.all(color: state == 'joined' ? primary : primary.withOpacity(0.2)),
              ),
              child: state == 'loading'
                  ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: primary))
                  : Icon(
                      state == 'joined' ? Icons.check : Icons.add,
                      color: state == 'joined' ? (isDark ? Colors.black : Colors.white) : primary,
                      size: 18,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

