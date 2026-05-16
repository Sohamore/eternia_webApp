import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:eternia_ef/providers/blackbox_provider.dart';

class MemoryHistoryScreen extends StatefulWidget {
  const MemoryHistoryScreen({super.key});

  @override
  State<MemoryHistoryScreen> createState() => _MemoryHistoryScreenState();
}

class _MemoryHistoryScreenState extends State<MemoryHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BlackBoxProvider>(context, listen: false).fetchEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDark;
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
      body: Consumer<BlackBoxProvider>(
        builder: (context, blackBoxProvider, _) {
          if (blackBoxProvider.isLoading && blackBoxProvider.entries == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = blackBoxProvider.entries;
          if (entries == null || entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_outlined, color: primary.withOpacity(0.5), size: 48),
                  const SizedBox(height: 16),
                  Text("No activity history yet", style: GoogleFonts.poppins(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final contentType = entry['content_type'] as String? ?? entry['contentType'] as String? ?? "text";
              final createdAt = entry['created_at'] as String? ?? entry['createdAt'] as String? ?? "";
              final timeAgo = _formatTimeAgo(createdAt);
              final isVoice = contentType == 'voice' || contentType == 'audio';

              String action;
              IconData icon;
              Color color;
              if (isVoice) {
                action = "Voice Entry Sent";
                icon = Icons.mic;
                color = primary;
              } else {
                action = "Journal Entry Saved";
                icon = Icons.edit_note;
                color = const Color(0xFFB47CFF);
              }

              return _historyItem(context, action, timeAgo, icon, color);
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
      if (diff.inDays == 1) return "Yesterday";
      if (diff.inDays < 7) return "${diff.inDays} days ago";
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
    } catch (_) {
      return "";
    }
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
