// ==========================================================
// PRIVATE PROFILE SCREEN - PREMIUM ADAPTIVE
// private_profile_screen.dart
// ==========================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eternia_ef/Screens/onboarding_screen.dart/sign_in_screen.dart';
import 'package:eternia_ef/Screens/onboarding_screen.dart/onboarding_screen.dart';
import 'package:eternia_ef/Tabs/ProfilePage/settings_screen.dart';
import 'package:eternia_ef/Tabs/ProfilePage/notifications_screen.dart';
import 'package:eternia_ef/Tabs/ProfilePage/edit_profile_screen.dart';
import 'package:eternia_ef/Tabs/ProfilePage/emergency_support_screen.dart';
import 'package:eternia_ef/Tabs/ProfilePage/premium_screen.dart';
import 'package:eternia_ef/Tabs/ProfilePage/privacy_safety_screen.dart';
import 'package:eternia_ef/Tabs/ProfilePage/search_screen.dart';
import 'package:eternia_ef/Tabs/ProfilePage/session_history_screen.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class PrivateProfileScreen extends StatefulWidget {
  const PrivateProfileScreen({super.key});

  @override
  State<PrivateProfileScreen> createState() => _PrivateProfileScreenState();
}

class _PrivateProfileScreenState extends State<PrivateProfileScreen> {
  final Color dangerColor = const Color(0xFFD9534F);

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
    final provider = Provider.of<ThemeProvider>(context);
    final bool isDark = provider.isDark;

    final Color primaryColor = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF335848); // Match image dark green text
    final Color bg = isDark ? const Color(0xFF071011) : const Color(0xFFF9F8F4);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1B2722);
    final Color cardColor = isDark
        ? const Color(0xFF111A18)
        : const Color(0xFFF0EFE9);
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
                child: _buildHeader(
                  textColor,
                  primaryColor,
                  innerCardColor,
                  borderColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 6),
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
                    _buildIdentity(
                      textColor,
                      primaryColor,
                      innerCardColor,
                      borderColor,
                    ),
                    const SizedBox(height: 24),
                    _buildStatsRow(
                      isDark,
                      primaryColor,
                      innerCardColor,
                      borderColor,
                    ),
                    const SizedBox(height: 20),
                    _buildThemeToggle(isDark, primaryColor),
                    const SizedBox(height: 32),
                    _buildSectionTitle(
                      "ANONYMITY & SAFETY",
                      primaryColor,
                      Icons.security_outlined,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildSafetyGroup(
                      isDark,
                      primaryColor,
                      innerCardColor,
                      borderColor,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle(
                      "DANGER ZONE",
                      dangerColor,
                      Icons.warning_amber_rounded,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildDangerGroup(isDark, innerCardColor, borderColor),
                    const SizedBox(height: 100), // Bottom padding for navbar
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    Color textColor,
    Color primaryColor,
    Color cardColor,
    Color borderColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Identity\nControl",
              style: GoogleFonts.playfairDisplay(
                color: textColor,
                fontSize: 42,
                height: 1.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your privacy. Your power.",
              style: GoogleFonts.poppins(
                color: primaryColor.withOpacity(0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // _buildTopIcon(
            //   Icons.search,
            //   () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => const SearchScreen()),
            //   ),
            //   cardColor,
            //   borderColor,
            //   textColor,
            // ),
            const SizedBox(width: 12),
            _buildTopIcon(
              Icons.notifications_none,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
              cardColor,
              borderColor,
              textColor,
            ),
            const SizedBox(width: 12),
            _buildTopIcon(
              Icons.settings_outlined,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              cardColor,
              borderColor,
              textColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopIcon(
    IconData icon,
    VoidCallback onTap,
    Color cardColor,
    Color borderColor,
    Color textColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, color: textColor, size: 22),
      ),
    );
  }

  Widget _buildIdentity(
    Color textColor,
    Color primaryColor,
    Color cardColor,
    Color borderColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF53B29A), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  "assets/figma/boy_orb.png",
                  height: 75,
                  width: 75,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                height: 18,
                width: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF53B29A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sejal Rai",
                style: GoogleFonts.playfairDisplay(
                  color: textColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    "NODE ID: 8629-X-21",
                    style: GoogleFonts.poppins(
                      color: textColor.withOpacity(0.5),
                      fontSize: 11,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.copy, size: 12, color: textColor.withOpacity(0.5)),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF53B29A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF53B29A).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit,
                        size: 12,
                        color: Color(0xFF53B29A),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Edit Profile",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF53B29A),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(
    bool isDark,
    Color primaryColor,
    Color cardColor,
    Color borderColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            "42",
            "SESSIONS",
            Icons.history,
            isDark,
            primaryColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SessionHistoryScreen()),
              );
            },
          ),
          Container(width: 1, height: 40, color: borderColor),
          _buildStatItem(
            "1.2k",
            "ECC",
            Icons.wallet_outlined,
            isDark,
            primaryColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
          ),
          Container(width: 1, height: 40, color: borderColor),
          _buildStatItem(
            "12",
            "STREAK",
            Icons.local_fire_department,
            isDark,
            const Color(0xFFE67E22),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("12-day streak active.")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String val,
    String label,
    IconData icon,
    bool isDark,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            val,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1B2722),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 94, 138, 122),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.light_mode_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Theme Mode",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Switch between light and dark",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDark,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF53B29A),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.black26,
            onChanged: (v) {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme(v);
            },
          ),
        ],
      ),
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

  Widget _buildSafetyGroup(
    bool isDark,
    Color primaryColor,
    Color cardColor,
    Color borderColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildListItem(
            Icons.group,
            "Emergency Contact",
            "Add or manage emergency contact",
            isDark,
            const Color(0xFF53B29A),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmergencySupportScreen(),
                ),
              );
            },
          ),
          Divider(height: 1, color: borderColor, indent: 64),
          _buildListItem(
            Icons.history,
            "Session History",
            "View your past sessions",
            isDark,
            const Color(0xFF53B29A),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SessionHistoryScreen()),
              );
            },
          ),
          Divider(height: 1, color: borderColor, indent: 64),
          _buildListItem(
            Icons.visibility_off,
            "Privacy Center",
            "Manage your privacy settings",
            isDark,
            const Color(0xFF53B29A),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacySafetyScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerGroup(bool isDark, Color cardColor, Color borderColor) {
    final Color dangerBg = isDark
        ? dangerColor.withOpacity(0.05)
        : const Color(0xFFFDF3F3);
    final Color dangerBorder = isDark
        ? dangerColor.withOpacity(0.2)
        : const Color(0xFFF5D6D6);

    return Container(
      decoration: BoxDecoration(
        color: dangerBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dangerBorder),
      ),
      child: Column(
        children: [
          _buildListItem(
            Icons.logout,
            "Log Out",
            "Sign out from your account",
            isDark,
            dangerColor,
            () => _showConfirmation(
              "Log Out?",
              "You will be returned to the sign in screen. Your node data remains intact.",
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
            isDanger: false,
          ),
          Divider(height: 1, color: dangerBorder, indent: 64),
          _buildListItem(
            Icons.delete_outline,
            "Delete Anonymous Node",
            "Permanently delete your node",
            isDark,
            dangerColor,
            () => _showConfirmation(
              "Delete Node?",
              "This will permanently wipe all your data, sessions, and identity. This cannot be undone.",
              () {
                // TODO: call delete API here
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
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
    IconData icon,
    String title,
    String subtitle,
    bool isDark,
    Color iconColor,
    VoidCallback onTap, {
    bool isDanger = false,
  }) {
    final Color titleColor = isDanger
        ? dangerColor
        : (isDark ? Colors.white : const Color(0xFF1B2722));

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
            Icon(
              Icons.chevron_right,
              color: isDanger ? dangerColor.withOpacity(0.5) : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
