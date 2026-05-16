import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class MemoryArchiveScreen extends StatelessWidget {
  const MemoryArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final bool isDark = provider.isDark;
    final Color primary = const Color(0xFF7CF5D7);
    final Color bg = isDark ? const Color(0xFF040707) : const Color(0xFFF7F4EC);
    final Color textColor = isDark ? Colors.white : const Color(0xFF28312D);
    final Color cardColor = isDark ? const Color(0xFF0A1111) : Colors.white;

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
          "All Memories",
          style: GoogleFonts.playfairDisplay(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        physics: const BouncingScrollPhysics(),
        children: [
          _archiveItem(
            isDark,
            cardColor,
            textColor,
            primary,
            "assets/figma/Forest.png",
            "CALM • 2h ago",
            "The weight of the morning fog...",
            true,
          ),
          const SizedBox(height: 16),
          _archiveItem(
            isDark,
            cardColor,
            textColor,
            const Color(0xFFB47CFF),
            "assets/figma/wave.png",
            "CONTEMPLATIVE • Yesterday",
            "Navigating the digital ocean",
            false,
          ),
          const SizedBox(height: 16),
          _archiveItem(
            isDark,
            cardColor,
            textColor,
            Colors.orangeAccent,
            "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=400&q=80",
            "REFLECTIVE • 3 days ago",
            "Mountains of the mind",
            false,
            isUrl: true,
          ),
          const SizedBox(height: 16),
          _archiveItem(
            isDark,
            cardColor,
            textColor,
            Colors.blueAccent,
            "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400&q=80",
            "JOYFUL • Last Week",
            "Sunsets and silence",
            true,
            isUrl: true,
          ),
        ],
      ),
    );
  }

  Widget _archiveItem(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color accent,
    String image,
    String tag,
    String title,
    bool voice, {
    bool isUrl = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: isUrl
                ? Image.network(image, width: 80, height: 80, fit: BoxFit.cover)
                : Image.asset(image, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag,
                  style: GoogleFonts.poppins(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            voice ? Icons.play_circle_outline : Icons.menu_book_outlined,
            color: accent,
            size: 24,
          ),
        ],
      ),
    );
  }
}
