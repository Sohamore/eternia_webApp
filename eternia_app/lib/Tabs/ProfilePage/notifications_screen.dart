// ==========================================================
// NOTIFICATIONS SCREEN - IMMERSIVE FLOATING CARDS
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:eternia_ef/providers/notifications_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationsProvider>(context, listen: false).fetchNotifications();
    });
  }

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
              child: Consumer<NotificationsProvider>(
                builder: (context, notifProvider, _) {
                  if (notifProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (notifProvider.error != null) {
                    return Center(child: Text(notifProvider.error!, style: GoogleFonts.poppins(color: Colors.red)));
                  }
                  final notifications = notifProvider.notifications;
                  if (notifications == null || notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined, color: primaryColor.withOpacity(0.5), size: 48),
                          const SizedBox(height: 16),
                          Text("No notifications yet", style: GoogleFonts.poppins(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return _buildNotificationCard(n, isDark, primaryColor, textColor);
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

  Widget _buildNotificationCard(Map<String, dynamic> n, bool isDark, Color primaryColor, Color textColor) {
    final bool isRead = n["is_read"] == true;
    final String type = n["type"] as String? ?? "activity";
    final String title = n["title"] as String? ?? "Notification";
    final String body = n["body"] as String? ?? "";
    final String time = n["created_at"] != null
        ? _formatTime(n["created_at"] as String)
        : "";

    IconData icon = Icons.notifications_outlined;
    Color iconColor = primaryColor;
    if (type == "alert") { icon = Icons.event_available_outlined; iconColor = const Color(0xFFE53935); }
    if (type == "achievement") { icon = Icons.local_fire_department_outlined; iconColor = const Color(0xFFFFB300); }
    if (type == "social") { icon = Icons.chat_bubble_outline; iconColor = const Color(0xFF42A5F5); }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (!isRead) {
            Provider.of<NotificationsProvider>(context, listen: false).markAsRead(n['id'].toString());
          }
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
                child: Icon(icon, color: isRead ? (isDark ? Colors.grey[500] : Colors.grey[600]) : iconColor, size: 22),
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
                            title,
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold
                            )
                          ),
                        ),
                        Text(
                          time,
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
                      body,
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

  String _formatTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      if (diff.inDays < 7) return "${diff.inDays}d ago";
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return "";
    }
  }
}
