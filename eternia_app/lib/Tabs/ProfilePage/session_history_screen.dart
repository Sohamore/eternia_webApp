// ==========================================================
// SESSION HISTORY SCREEN - TIMELINE VIEW
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:eternia_ef/providers/appointments_provider.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentsProvider>(context, listen: false).fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDark;

    final Color primaryColor = isDark ? const Color(0xFF67F5D4) : const Color(0xFF335848);
    final Color dangerColor = const Color(0xFFD9534F);
    final Color bg = isDark ? const Color(0xFF071011) : const Color(0xFFF9F8F4);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1B2722);

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
              child: Consumer<AppointmentsProvider>(
                builder: (context, appointmentsProvider, _) {
                  if (appointmentsProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (appointmentsProvider.error != null) {
                    return Center(child: Text(appointmentsProvider.error!, style: GoogleFonts.poppins(color: Colors.red)));
                  }
                  final sessions = appointmentsProvider.appointments;
                  if (sessions == null || sessions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_outlined, color: primaryColor.withOpacity(0.5), size: 48),
                          const SizedBox(height: 16),
                          Text("No session history yet", style: GoogleFonts.poppins(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final s = sessions[index];
                      final isLast = index == sessions.length - 1;
                      final sessionMap = <String, String>{
                        "counselor": s['expertName'] as String? ?? s['expert_name'] as String? ?? "Counselor",
                        "type": s['sessionType'] as String? ?? s['session_type'] as String? ?? "Session",
                        "date": _formatDate(s['slotTime'] as String? ?? s['slot_time'] as String? ?? ""),
                        "time": _formatTimeOnly(s['slotTime'] as String? ?? s['slot_time'] as String? ?? ""),
                        "duration": s['duration'] as String? ?? "50 min",
                        "status": s['status'] as String? ?? "Completed",
                      };
                      return _buildTimelineItem(
                        context,
                        sessionMap,
                        isDark,
                        primaryColor,
                        dangerColor,
                        isLast
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
    } catch (_) {
      return isoDate;
    }
  }

  String _formatTimeOnly(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final amPm = date.hour >= 12 ? "PM" : "AM";
      return "${hour == 0 ? 12 : hour}:${date.minute.toString().padLeft(2, '0')} $amPm";
    } catch (_) {
      return "";
    }
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
