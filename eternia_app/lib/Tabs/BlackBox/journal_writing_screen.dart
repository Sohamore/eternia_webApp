import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class JournalWritingScreen extends StatefulWidget {
  const JournalWritingScreen({super.key});

  @override
  State<JournalWritingScreen> createState() => _JournalWritingScreenState();
}

class _JournalWritingScreenState extends State<JournalWritingScreen> {
  final TextEditingController _controller = TextEditingController();

  void _showSuccessPopup() {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF120F18) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFB47CFF), size: 60),
            const SizedBox(height: 20),
            Text(
              "Journal Entry Saved",
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Your reflections have been archived in your private digital sanctuary.",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to BlackBox
              },
              child: Text(
                "Return to Sanctuary",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFB47CFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final bool isDark = provider.isDark;
    final Color primary = const Color(0xFFB47CFF);
    final Color bg = isDark ? const Color(0xFF0A070E) : const Color(0xFFF6F3ED);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? Colors.white54 : const Color(0xFF70737C),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Journal Entry",
          style: GoogleFonts.cormorantGaramond(
            color: primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _showSuccessPopup,
            child: Text(
              "Send",
              style: GoogleFonts.poppins(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                autofocus: true,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: "Transcribe your inner dialogue here...",
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white24,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: primary.withOpacity(0.4),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  "End-to-end encrypted",
                  style: GoogleFonts.poppins(
                    color: Colors.white24,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
