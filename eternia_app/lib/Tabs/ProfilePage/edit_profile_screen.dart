// ==========================================================
// EDIT PROFILE SCREEN - PREMIUM ADAPTIVE
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static String _savedName = "Sejal Rai";
  static String _savedBio = "Finding peace in the digital sanctuary.";
  static String _savedEmail = "sejal@eternia.app";

  late final _nameController = TextEditingController(text: _savedName);
  late final _bioController = TextEditingController(text: _savedBio);
  late final _emailController = TextEditingController(text: _savedEmail);

  void _saveProfile() {
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Display name is required.")),
      );
      return;
    }

    if (email.isEmpty || !email.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid email address.")),
      );
      return;
    }

    setState(() {
      _savedName = name;
      _savedBio = bio;
      _savedEmail = email;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully.")),
    );

    Navigator.pop(context, {
      "name": _savedName,
      "bio": _savedBio,
      "email": _savedEmail,
    });
  }

  void _pickImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Opening camera / gallery...")),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDark;

    final Color primaryColor = isDark ? const Color(0xFF67F5D4) : const Color(0xFF335848);
    final Color iconAccent = const Color(0xFF53B29A);
    final Color bg = isDark ? const Color(0xFF071011) : const Color(0xFFF9F8F4);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1B2722);
    final Color innerCardColor = isDark ? Colors.white.withOpacity(0.03) : Colors.white;
    final Color borderColor = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE7E2D8);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _buildHeader(textColor, primaryColor),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B1412) : const Color(0xFFF5F3EC),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: primaryColor.withOpacity(0.05), blurRadius: 20, spreadRadius: 5)
                  ],
                  gradient: isDark ? null : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF5F3EC), Color(0xFFEFECE2)],
                  ),
                ),
                child: Column(
                  children: [
                    // AVATAR
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: iconAccent.withOpacity(0.5), width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset("assets/figma/boy_orb.png", height: 100, width: 100, fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              bottom: 2, right: 2,
                              child: Container(
                                height: 32, width: 32,
                                decoration: BoxDecoration(
                                  color: iconAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isDark ? const Color(0xFF0B1412) : Colors.white, width: 2),
                                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildField("Display Name", _nameController, Icons.person_outline, isDark, textColor, innerCardColor, borderColor, primaryColor),
                    const SizedBox(height: 20),
                    _buildField("Bio", _bioController, Icons.edit_note_outlined, isDark, textColor, innerCardColor, borderColor, primaryColor, maxLines: 3),
                    const SizedBox(height: 20),
                    _buildField("Email", _emailController, Icons.email_outlined, isDark, textColor, innerCardColor, borderColor, primaryColor),
                    const SizedBox(height: 40),

                    _buildSaveButton(iconAccent),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 40), // Bottom padding
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
              Text("Edit\nProfile", style: GoogleFonts.playfairDisplay(color: textColor, fontSize: 38, height: 1.1, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Update your public persona.", style: GoogleFonts.poppins(color: primaryColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, bool isDark, Color textColor, Color cardColor, Color borderColor, Color primaryColor, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.poppins(color: primaryColor.withOpacity(0.8), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: maxLines > 1 ? 16.0 : 0),
                child: Icon(icon, color: primaryColor.withOpacity(0.5), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  style: GoogleFonts.poppins(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.poppins(color: textColor.withOpacity(0.3)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(Color primaryColor) {
    return GestureDetector(
      onTap: _saveProfile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        alignment: Alignment.center,
        child: Text("Save Profile", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
