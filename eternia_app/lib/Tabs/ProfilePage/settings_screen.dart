// ==========================================================
// SETTINGS SCREEN - PREMIUM ADAPTIVE
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/Tabs/ProfilePage/about_screen.dart';
import 'package:eternia_ef/Tabs/ProfilePage/edit_profile_screen.dart';
import 'package:eternia_ef/Tabs/ProfilePage/emergency_support_screen.dart';
import 'package:eternia_ef/Tabs/ProfilePage/privacy_safety_screen.dart';
import 'package:eternia_ef/Screens/onboarding_screen.dart/sign_in_screen.dart';
import 'package:eternia_ef/Screens/onboarding_screen.dart/onboarding_screen.dart';
import 'package:eternia_ef/providers/theme_provider.dart';
import 'dart:ui';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _messageAlerts = true;
  final Color dangerColor = const Color(0xFFD9534F);

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showConfirmation(String title, String desc, VoidCallback onConfirm) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor:
              (isDark ? const Color(0xFF071011) : const Color(0xFFF6F3ED))
                  .withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1B2722),
            ),
          ),
          content: Text(
            desc,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: Text(
                "Confirm",
                style: GoogleFonts.poppins(
                  color: isDark
                      ? const Color(0xFF67F5D4)
                      : const Color(0xFF53B29A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDark;

    final Color primaryColor = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF335848);
    final Color iconAccent = const Color(0xFF53B29A);
    final Color bg = isDark ? const Color(0xFF071011) : const Color(0xFFF9F8F4);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1B2722);
    final Color innerCardColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.white;
    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE7E2D8);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: _buildHeader(textColor, primaryColor),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0B1412)
                      : const Color(0xFFF5F3EC),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.white.withOpacity(0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                  gradient: isDark
                      ? null
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Color(0xFFF5F3EC),
                            Color(0xFFEFECE2),
                          ],
                        ),
                ),
                child: Column(
                  children: [
                    _buildSectionTitle(
                      "APPEARANCE",
                      primaryColor,
                      Icons.palette_outlined,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildGroupCard(isDark, innerCardColor, borderColor, [
                      _buildToggleItem(
                        Icons.dark_mode_outlined,
                        "Dark Mode",
                        "Switch between light and dark themes",
                        isDark,
                        iconAccent,
                        themeProvider.isDark,
                        (val) => themeProvider.toggleTheme(val),
                      ),
                    ]),
                    const SizedBox(height: 32),

                    _buildSectionTitle(
                      "NOTIFICATIONS",
                      primaryColor,
                      Icons.notifications_none,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildGroupCard(isDark, innerCardColor, borderColor, [
                      _buildToggleItem(
                        Icons.notifications_active_outlined,
                        "Push Notifications",
                        "Session reminders and updates",
                        isDark,
                        iconAccent,
                        _pushNotifications,
                        (val) => setState(() => _pushNotifications = val),
                      ),
                      Divider(height: 1, color: borderColor, indent: 64),
                      _buildToggleItem(
                        Icons.chat_bubble_outline,
                        "Message Alerts",
                        "Peer and counselor messages",
                        isDark,
                        iconAccent,
                        _messageAlerts,
                        (val) => setState(() => _messageAlerts = val),
                      ),
                    ]),
                    const SizedBox(height: 32),

                    _buildSectionTitle(
                      "ACCOUNT",
                      primaryColor,
                      Icons.person_outline,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildGroupCard(isDark, innerCardColor, borderColor, [
                      _buildNavItem(
                        Icons.edit_outlined,
                        "Edit Profile",
                        "Update your public persona",
                        isDark,
                        iconAccent,
                        () => _open(const EditProfileScreen()),
                      ),
                      Divider(height: 1, color: borderColor, indent: 64),
                      _buildNavItem(
                        Icons.lock_outline,
                        "Account Security",
                        "Manage passwords and pins",
                        isDark,
                        iconAccent,
                        () => _open(const PrivacySafetyScreen()),
                      ),

                      // Divider(height: 1, color: borderColor, indent: 64),
                    ]),
                    const SizedBox(height: 32),

                    _buildSectionTitle(
                      "SUPPORT",
                      primaryColor,
                      Icons.support_agent_outlined,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildGroupCard(isDark, innerCardColor, borderColor, [
                      _buildNavItem(
                        Icons.help_outline,
                        "Help & Support",
                        "Get assistance and FAQs",
                        isDark,
                        iconAccent,
                        () => _open(const EmergencySupportScreen()),
                      ),
                      Divider(height: 1, color: borderColor, indent: 64),
                      _buildNavItem(
                        Icons.info_outline,
                        "About Eternia",
                        "Version, mission, and team",
                        isDark,
                        iconAccent,
                        () => _open(const AboutScreen()),
                      ),
                      Divider(height: 1, color: borderColor, indent: 64),
                      _buildNavItem(
                        Icons.description_outlined,
                        "Terms & Privacy",
                        "Legal agreements and policies",
                        isDark,
                        iconAccent,
                        () => _open(const PrivacySafetyScreen()),
                      ),
                    ]),
                    const SizedBox(height: 48),

                    _buildLogoutButton(isDark),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color primaryColor) {
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
              Text(
                "Settings",
                style: GoogleFonts.playfairDisplay(
                  color: textColor,
                  fontSize: 38,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Customize your Eternia experience.",
                style: GoogleFonts.poppins(
                  color: primaryColor.withOpacity(0.7),
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

  Widget _buildSectionTitle(
    String title,
    Color color,
    IconData icon,
    Color borderColor,
  ) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: borderColor)),
        const SizedBox(width: 12),
        Icon(icon, size: 16, color: color),
      ],
    );
  }

  Widget _buildGroupCard(
    bool isDark,
    Color cardColor,
    Color borderColor,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleItem(
    IconData icon,
    String title,
    String subtitle,
    bool isDark,
    Color iconColor,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1B2722);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: iconColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String title,
    String subtitle,
    bool isDark,
    Color iconColor,
    VoidCallback onTap,
  ) {
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1B2722);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return GestureDetector(
      onTap: () => _showConfirmation(
        "Log Out?",
        "Are you sure you want to exit Eternia?",
        () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false,
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
          );
        },
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: dangerColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dangerColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: dangerColor, size: 20),
            const SizedBox(width: 10),
            Text(
              "Log Out Securely",
              style: GoogleFonts.poppins(
                color: dangerColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
