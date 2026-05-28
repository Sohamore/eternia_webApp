// ==========================================================
// SESSION HISTORY SCREEN - TIMELINE VIEW
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:eternia_ef/providers/appointments_provider.dart';
import 'package:eternia_ef/providers/videosdk_provider.dart';
import 'package:eternia_ef/Tabs/ConnectPage/chat_screen.dart';
import 'package:eternia_ef/screens/onboarding_screen.dart/calling_screen.dart';

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

    final Color primaryColor = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF335848);
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
                    return Center(
                      child: Text(
                        appointmentsProvider.error!,
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                    );
                  }
                  final sessions = appointmentsProvider.appointments;
                  if (sessions == null || sessions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_outlined,
                            color: primaryColor.withValues(alpha: 0.5),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No session history yet",
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final s = sessions[index];
                      final isLast = index == sessions.length - 1;
                      final sessionMap = <String, String>{
                        "counselor":
                            s['expertName'] as String? ??
                            (s['expert'] != null ? s['expert']['username'] as String? : null) ??
                            s['expert_name'] as String? ??
                            "Counselor",
                        "type":
                            s['sessionType'] as String? ??
                            s['session_type'] as String? ??
                            "Session",
                        "date": _formatDate(
                          s['slotTime'] as String? ??
                              s['slot_time'] as String? ??
                              "",
                        ),
                        "time": _formatTimeOnly(
                          s['slotTime'] as String? ??
                              s['slot_time'] as String? ??
                              "",
                        ),
                        "duration": s['duration'] as String? ?? "50 min",
                        "status": s['status'] as String? ?? "Completed",
                      };
                      return _buildTimelineItem(
                        context,
                        sessionMap,
                        s,
                        isDark,
                        primaryColor,
                        dangerColor,
                        isLast,
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
      final months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
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

  Widget _buildHeader(
    BuildContext context,
    Color textColor,
    Color primaryColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Journey",
                style: GoogleFonts.playfairDisplay(
                  color: textColor,
                  fontSize: 38,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "A timeline of your healing and growth.",
                style: GoogleFonts.poppins(
                  color: primaryColor.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _joinSession(BuildContext context, Map<String, dynamic> sessionData) async {
    final String type = sessionData['session_type'] as String? ?? 'video';
    final String? roomId = sessionData['room_id'] as String?;
    final String? appointmentId = sessionData['id'] as String?;
    final String expertName = (sessionData['expert'] != null ? sessionData['expert']['username'] as String? : null) ?? 'Expert';
    
    if (appointmentId == null) return;
    
    if (type == 'chat') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            sessionId: appointmentId,
            counselorName: expertName,
            isExpertChat: true,
          ),
        ),
      );
    } else {
      final String? slotTimeStr = sessionData['slot_time'] as String? ?? sessionData['slotTime'] as String?;
      if (slotTimeStr == null) return;
      
      final DateTime slotTime = DateTime.parse(slotTimeStr).toLocal();
      final DateTime now = DateTime.now();
      final DateTime allowedJoinTime = slotTime.subtract(const Duration(minutes: 5));
      
      if (now.isBefore(allowedJoinTime)) {
        final remainingMin = allowedJoinTime.difference(now).inMinutes;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Not Time Yet"),
            content: Text("Your session is scheduled for ${_formatTimeOnly(slotTimeStr)}.\n\nYou can join 5 minutes before the scheduled time (in $remainingMin minutes)."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        if (roomId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Call room has not been initiated by the expert yet.")),
          );
          return;
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        final videoSDKProvider = Provider.of<VideoSDKProvider>(context, listen: false);
        await videoSDKProvider.fetchToken();

        if (mounted) Navigator.pop(context); // Dismiss loading

        if (videoSDKProvider.token != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallingScreen(
                roomId: roomId,
                token: videoSDKProvider.token!,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(videoSDKProvider.error ?? "Failed to fetch VideoSDK token.")),
          );
        }
      }
    }
  }

  Widget _buildTimelineItem(
    BuildContext context,
    Map<String, String> session,
    Map<String, dynamic> rawSession,
    bool isDark,
    Color primaryColor,
    Color dangerColor,
    bool isLast,
  ) {
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
                  color: isDark
                      ? const Color(0xFF071011)
                      : const Color(0xFFF9F8F4),
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor, width: 3),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: statusColor.withValues(alpha: 0.3),
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
                        ? dangerColor.withValues(alpha: 0.3)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.withValues(alpha: 0.2)),
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
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
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            session["status"]!,
                            style: GoogleFonts.poppins(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
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
                            color: statusColor.withValues(alpha: 0.15),
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
                                style: GoogleFonts.poppins(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1B2722),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "with ${session["counselor"]}",
                                style: GoogleFonts.poppins(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.2),
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${session["time"]} • ${session["duration"]}",
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        if (session["status"] == "completed" || session["status"] == "Completed")
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Notes: ${rawSession['session_notes_encrypted'] ?? 'No notes recorded.'}"),
                                ),
                              );
                            },
                            child: Text(
                              "View Notes",
                              style: GoogleFonts.poppins(
                                color: primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else if (session["status"] == "pending" || session["status"] == "confirmed")
                          GestureDetector(
                            onTap: () => _joinSession(context, rawSession),
                            child: Text(
                              "Join Session",
                              style: GoogleFonts.poppins(
                                color: primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
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
