// ==========================================================
// SESSION HISTORY SCREEN - TIMELINE VIEW
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class SessionHistoryScreen extends StatelessWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDark;

    final Color primaryColor = isDark ? const Color(0xFF67F5D4) : const Color(0xFF335848);
    final Color dangerColor = const Color(0xFFD9534F);
    final Color bg = isDark ? const Color(0xFF071011) : const Color(0xFFF9F8F4);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1B2722);

    final sessions = [
      {"counselor": "Dr. Aria Vance", "type": "Video Therapy", "date": "Dec 12, 2024", "time": "10:00 AM", "duration": "50 min", "status": "Completed"},
      {"counselor": "Julian Thorne", "type": "Peer Support Chat", "date": "Dec 8, 2024", "time": "02:30 PM", "duration": "35 min", "status": "Completed"},
      {"counselor": "Lila Chen", "type": "Guided Meditation", "date": "Dec 3, 2024", "time": "08:00 AM", "duration": "45 min", "status": "Completed"},
      {"counselor": "Dr. Silas Thorne", "type": "Video Therapy", "date": "Nov 28, 2024", "time": "11:00 AM", "duration": "50 min", "status": "Cancelled"},
      {"counselor": "Dr. Aria Vance", "type": "Initial Assessment", "date": "Nov 15, 2024", "time": "01:00 PM", "duration": "60 min", "status": "Completed"},
    ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _buildHeader(context, textColor, primaryColor),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final s = sessions[index];
                  final isLast = index == sessions.length - 1;
                  return _buildTimelineItem(
                    context, 
                    s, 
                    isDark, 
                    primaryColor, 
                    dangerColor, 
                    isLast
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color textColor, Color primaryColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your Journey", style: GoogleFonts.playfairDisplay(color: textColor, fontSize: 38, height: 1.1, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("A timeline of your healing and growth.", style: GoogleFonts.poppins(color: primaryColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, Map<String, String> session, bool isDark, Color primaryColor, Color dangerColor, bool isLast) {
    final bool isCancelled = session["status"] == "Cancelled";
    final Color statusColor = isCancelled ? dangerColor : primaryColor;
    final String type = session["type"]!;
    
    IconData getIcon() {
      if (type.contains("Video")) return Icons.videocam_outlined;
      if (type.contains("Chat")) return Icons.chat_bubble_outline;
      if (type.contains("Meditation")) return Icons.spa_outlined;
      return Icons.assignment_outlined;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TIMELINE AXIS
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF071011) : const Color(0xFFF9F8F4),
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor, width: 3),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: statusColor.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // CARD CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141D1F) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isCancelled 
                        ? dangerColor.withOpacity(0.3) 
                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.2))
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          session["date"]!,
                          style: GoogleFonts.poppins(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusColor.withOpacity(0.2)),
                          ),
                          child: Text(
                            session["status"]!,
                            style: GoogleFonts.poppins(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(getIcon(), color: statusColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session["type"]!,
                                style: GoogleFonts.poppins(color: isDark ? Colors.white : const Color(0xFF1B2722), fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "with ${session["counselor"]}",
                                style: GoogleFonts.poppins(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2), height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: isDark ? Colors.grey[500] : Colors.grey[600], size: 14),
                        const SizedBox(width: 6),
                        Text(
                          "${session["time"]} • ${session["duration"]}",
                          style: GoogleFonts.poppins(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 11),
                        ),
                        const Spacer(),
                        if (!isCancelled)
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Viewing session notes...")));
                            },
                            child: Text(
                              "View Notes",
                              style: GoogleFonts.poppins(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
