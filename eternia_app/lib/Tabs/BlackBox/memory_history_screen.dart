import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class MemoryHistoryScreen extends StatelessWidget {
  const MemoryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final bool isDark = provider.isDark;
    final Color textColor = isDark ? Colors.white : const Color(0xFF28312D);
    final Color bg = isDark ? const Color(0xFF040707) : const Color(0xFFF7F4EC);
    final Color primary = const Color(0xFF7CF5D7);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Activity History",
          style: GoogleFonts.playfairDisplay(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _historyItem(
            context,
            "Voice Entry Sent",
            "Today, 10:45 AM",
            Icons.mic,
            primary,
          ),
          _historyItem(
            context,
            "Journal Entry Saved",
            "Yesterday, 11:20 PM",
            Icons.edit_note,
            const Color(0xFFB47CFF),
          ),
          _historyItem(
            context,
            "Voice Entry Deleted",
            "2 days ago",
            Icons.delete_outline,
            Colors.redAccent,
          ),
          _historyItem(
            context,
            "Reflection Created",
            "May 10, 2026",
            Icons.auto_awesome,
            Colors.amberAccent,
          ),
        ],
      ),
    );
  }

  Widget _historyItem(
    BuildContext context,
    String action,
    String time,
    IconData icon,
    Color color,
  ) {
    bool isDark = Provider.of<ThemeProvider>(context).isDark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                action,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                time,
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
