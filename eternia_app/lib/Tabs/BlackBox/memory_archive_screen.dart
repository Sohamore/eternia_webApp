import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:eternia_ef/providers/blackbox_provider.dart';

class MemoryArchiveScreen extends StatefulWidget {
  const MemoryArchiveScreen({super.key});

  @override
  State<MemoryArchiveScreen> createState() => _MemoryArchiveScreenState();
}

class _MemoryArchiveScreenState extends State<MemoryArchiveScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BlackBoxProvider>(context, listen: false).fetchEntries();
    });
  }

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
      body: Consumer<BlackBoxProvider>(
        builder: (context, blackBoxProvider, _) {
          if (blackBoxProvider.isLoading && blackBoxProvider.entries == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (blackBoxProvider.error != null) {
            return Center(child: Text(blackBoxProvider.error!, style: GoogleFonts.poppins(color: Colors.red)));
          }
          final entries = blackBoxProvider.entries;
          if (entries == null || entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, color: primary.withOpacity(0.5), size: 48),
                  const SizedBox(height: 16),
                  Text("No memories archived yet", style: GoogleFonts.poppins(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final content = entry['content'] as String? ?? "";
              final contentType = entry['content_type'] as String? ?? entry['contentType'] as String? ?? "text";
              final createdAt = entry['created_at'] as String? ?? entry['createdAt'] as String? ?? "";
              final isVoice = contentType == 'voice' || contentType == 'audio';
              final timeAgo = _formatTimeAgo(createdAt);
              final tag = "${isVoice ? 'VOICE' : 'WRITTEN'} • $timeAgo";
              final title = content.length > 40 ? "${content.substring(0, 40)}..." : content;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _archiveItem(
                  isDark,
                  cardColor,
                  textColor,
                  isVoice ? primary : const Color(0xFFB47CFF),
                  isVoice ? "assets/figma/Forest.png" : "assets/figma/wave.png",
                  tag,
                  title,
                  isVoice,
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimeAgo(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      if (diff.inDays < 7) return "${diff.inDays}d ago";
      return "Last week";
    } catch (_) {
      return "";
    }
  }

  Widget _archiveItem(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color accent,
    String image,
    String tag,
    String title,
    bool voice,
  ) {
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
            child: Image.asset(image, width: 80, height: 80, fit: BoxFit.cover),
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
