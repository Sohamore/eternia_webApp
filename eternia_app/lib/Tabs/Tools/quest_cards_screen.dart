// ==========================================================
// QUEST CARDS - LUXURY REFLECTION
// quest_cards_screen.dart
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:eternia_ef/utils/theme_config.dart';

class QuestCardsScreen extends StatefulWidget {
  const QuestCardsScreen({super.key});

  @override
  State<QuestCardsScreen> createState() => _QuestCardsScreenState();
}

class _QuestCardsScreenState extends State<QuestCardsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Set<int> _completedQuests = {};

  final List<Map<String, String>> _quests = [
    {
      "title": "The Inner Sanctuary",
      "desc": "Identify one thing in your life that makes you feel completely safe.",
      "icon": "🛡️",
    },
    {
      "title": "Echoes of Silence",
      "desc": "Spend 2 minutes observing the sounds around you without judgment.",
      "icon": "👂",
    },
    {
      "title": "The Root of Joy",
      "desc": "What was the last thing that made you smile without any external reason?",
      "icon": "✨",
    },
    {
      "title": "Grateful Heart",
      "desc": "List three small things you are grateful for today.",
      "icon": "💝",
    },
    {
      "title": "Present Moment",
      "desc": "Take five deep breaths and focus purely on the sensation of air.",
      "icon": "🌬️",
    },
  ];

  void _onReflect(int index) {
    if (_completedQuests.contains(index)) return;

    setState(() {
      _completedQuests.add(index);
    });

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Provider.of<ThemeProvider>(context).isDark 
                ? const Color(0xFF0E1718) 
                : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFF53B29A).withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("✨", style: TextStyle(fontSize: 50)),
              const SizedBox(height: 16),
              Text(
                "Quest Completed",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF53B29A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Your reflection has been recorded in your journey.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Provider.of<ThemeProvider>(context).isDark 
                      ? Colors.white70 
                      : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF53B29A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDark;
    final primaryColor = isDark
        ? SanctuaryTheme.darkPrimary
        : SanctuaryTheme.lightPrimary;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF071011)
          : const Color(0xFFF6F3ED),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, isDark, primaryColor),
            const SizedBox(height: 20),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                physics: const BouncingScrollPhysics(),
                itemCount: _quests.length,
                itemBuilder: (context, index) {
                  return _buildQuestCard(
                    _quests[index], 
                    index,
                    isDark, 
                    primaryColor
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            _buildPagination(primaryColor),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.black87,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Text(
            "Quest Cards",
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          //
        ],
      ),
    );
  }

  Widget _buildQuestCard(
    Map<String, String> quest,
    int index,
    bool isDark,
    Color primaryColor,
  ) {
    final bool isCompleted = _completedQuests.contains(index);
    final cardColor = isDark ? const Color(0xFF111C1E) : Colors.white;
    final borderColor = isDark
        ? (isCompleted ? primaryColor.withOpacity(0.3) : Colors.white.withOpacity(0.08))
        : (isCompleted ? primaryColor.withOpacity(0.3) : const Color(0xFFE7E2D8));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? primaryColor.withOpacity(0.03)
                : Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(isDark ? 0.1 : 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Icon(Icons.auto_awesome, color: primaryColor, size: 48),
          ),
          const SizedBox(height: 50),
          Text(
            quest["title"]!,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1B2722),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            quest["desc"]!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white70 : const Color(0xFF5C6A64),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _onReflect(index),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.transparent : primaryColor,
                borderRadius: BorderRadius.circular(24),
                border: isCompleted ? Border.all(color: primaryColor) : null,
                boxShadow: isCompleted ? [] : [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isCompleted) ...[
                    Icon(Icons.check_circle_rounded, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    isCompleted ? "COMPLETED" : "Reflect Now",
                    style: GoogleFonts.poppins(
                      color: isCompleted 
                          ? primaryColor 
                          : (isDark ? const Color(0xFF071011) : Colors.white),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_quests.length, (index) {
        final bool isCurrent = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 24 : 8,
          height: 6,
          decoration: BoxDecoration(
            color: isCurrent ? primaryColor : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
            boxShadow: isCurrent ? [
              BoxShadow(color: primaryColor.withOpacity(0.5), blurRadius: 8),
            ] : [],
          ),
        );
      }),
    );
  }
}
