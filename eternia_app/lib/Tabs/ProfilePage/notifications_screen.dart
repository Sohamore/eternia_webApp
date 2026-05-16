// ==========================================================
// NOTIFICATIONS SCREEN - IMMERSIVE FLOATING CARDS
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _todayNotifications = [
    {"title": "Session Reminder", "body": "Your session with Dr. Aria starts in 30 minutes.", "time": "2m ago", "icon": Icons.event_available_outlined, "read": false, "type": "alert"},
    {"title": "New Message", "body": "Resident #AQ-441 sent you a message.", "time": "15m ago", "icon": Icons.chat_bubble_outline, "read": false, "type": "social"},
  ];

  final List<Map<String, dynamic>> _earlierNotifications = [
    {"title": "Mood Streak", "body": "You've logged your mood for 7 days straight!", "time": "1h ago", "icon": Icons.local_fire_department_outlined, "read": true, "type": "achievement"},
    {"title": "Community Update", "body": "Peer Circle #242 has a new discussion.", "time": "3h ago", "icon": Icons.people_outline, "read": true, "type": "social"},
    {"title": "Breathing Complete", "body": "Great job! You completed today's breathing exercise.", "time": "5h ago", "icon": Icons.air_outlined, "read": true, "type": "activity"},
    {"title": "Weekly Report", "body": "Your wellness summary for this week is ready.", "time": "1d ago", "icon": Icons.analytics_outlined, "read": true, "type": "insight"},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDark;

    final Color primaryColor = isDark ? const Color(0xFF67F5D4) : const Color(0xFF335848);
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
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                children: [
                  _buildSectionLabel("TODAY", primaryColor),
                  const SizedBox(height: 12),
                  ..._todayNotifications.map((n) => _buildFloatingCard(n, isDark, primaryColor, textColor)).toList(),
                  const SizedBox(height: 24),
                  _buildSectionLabel("EARLIER", primaryColor),
                  const SizedBox(height: 12),
                  ..._earlierNotifications.map((n) => _buildFloatingCard(n, isDark, primaryColor, textColor)).toList(),
                  const SizedBox(height: 40),
                ],
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
              Text("Notifications", style: GoogleFonts.playfairDisplay(color: textColor, fontSize: 38, height: 1.1, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Stay updated with your emotional journey.", style: GoogleFonts.poppins(color: primaryColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: primaryColor.withOpacity(0.6),
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFloatingCard(Map<String, dynamic> n, bool isDark, Color primaryColor, Color textColor) {
    final bool isRead = n["read"] as bool;
    final String type = n["type"] as String;
    
    // Determine icon color based on type
    Color iconColor = primaryColor;
    if (type == "alert") iconColor = const Color(0xFFE53935);
    if (type == "achievement") iconColor = const Color(0xFFFFB300);
    if (type == "social") iconColor = const Color(0xFF42A5F5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            n["read"] = true;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141D1F) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isRead 
                  ? (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.2))
                  : iconColor.withOpacity(0.3),
              width: isRead ? 1 : 1.5,
            ),
            boxShadow: isRead ? [] : [
              BoxShadow(
                color: iconColor.withOpacity(0.08),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isRead ? (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)) : iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(n["icon"] as IconData, color: isRead ? (isDark ? Colors.grey[500] : Colors.grey[600]) : iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            n["title"] as String, 
                            style: GoogleFonts.poppins(
                              color: textColor, 
                              fontSize: 14, 
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold
                            )
                          ),
                        ),
                        Text(
                          n["time"] as String, 
                          style: GoogleFonts.poppins(
                            color: isRead ? (isDark ? Colors.grey[600] : Colors.grey[500]) : iconColor, 
                            fontSize: 10,
                            fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n["body"] as String, 
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.grey[400] : Colors.grey[700], 
                        fontSize: 12, 
                        height: 1.4
                      )
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  margin: const EdgeInsets.only(left: 12, top: 4),
                  width: 8, height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
