// ==========================================================
// DAILY CHECK-IN SCREEN - PREMIUM ADAPTIVE
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eternia_ef/utils/eternia_theme.dart';

class DailyCheckinScreen extends StatefulWidget {
  const DailyCheckinScreen({super.key});

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen> {
  int _selectedMood = -1;
  double _energyLevel = 0.6;
  double _stressLevel = 0.3;

  final List<Map<String, dynamic>> _moods = [
    {"emoji": "😊", "label": "Great"},
    {"emoji": "🙂", "label": "Good"},
    {"emoji": "😐", "label": "Okay"},
    {"emoji": "😔", "label": "Low"},
    {"emoji": "😰", "label": "Anxious"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = EterniaTheme.of(context);
    final isDark = theme.isDark;

    return Scaffold(
      backgroundColor: theme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // ===================================================
              // ELEGANT TOP BAR
              // ===================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.border),
                      ),
                      child: Icon(Icons.close, color: theme.iconSecondary, size: 18),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.primary.withOpacity(0.2)),
                    ),
                    child: Icon(Icons.history_rounded, color: theme.primary, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ===================================================
              // HEADER
              // ===================================================
              Text("Daily Check-in", style: GoogleFonts.cormorantGaramond(color: theme.primary, fontSize: 42, fontWeight: FontWeight.bold, height: 1.1)),
              const SizedBox(height: 8),
              Text("Take a mindful moment to reflect on your energy and emotions.", style: GoogleFonts.poppins(color: theme.textTertiary, fontSize: 13, height: 1.5)),
              const SizedBox(height: 40),

              // ===================================================
              // MOOD SELECTION
              // ===================================================
              Text("HOW ARE YOU FEELING?", style: GoogleFonts.poppins(color: theme.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: theme.border),
                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_moods.length, (i) {
                      final selected = _selectedMood == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMood = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? theme.primary.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: selected ? theme.primary.withOpacity(0.4) : Colors.transparent),
                            boxShadow: selected ? [BoxShadow(color: theme.primary.withOpacity(0.2), blurRadius: 15)] : [],
                          ),
                          child: Column(
                            children: [
                              Text(_moods[i]["emoji"], style: TextStyle(fontSize: selected ? 36 : 28)),
                              const SizedBox(height: 8),
                              Text(_moods[i]["label"], style: GoogleFonts.poppins(color: selected ? theme.primary : theme.textTertiary, fontSize: 10, fontWeight: selected ? FontWeight.bold : FontWeight.w500)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ===================================================
              // ENERGY & STRESS LEVELS (GLASSMORPHIC CARDS)
              // ===================================================
              Row(
                children: [
                  Expanded(
                    child: _buildSliderCard(
                      "ENERGY", 
                      Icons.bolt_rounded, 
                      _energyLevel, 
                      (v) => setState(() => _energyLevel = v), 
                      theme, 
                      isDark
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSliderCard(
                      "STRESS", 
                      Icons.waves_rounded, 
                      _stressLevel, 
                      (v) => setState(() => _stressLevel = v), 
                      theme, 
                      isDark
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // ===================================================
              // SUBMIT BUTTON
              // ===================================================
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Check-in Saved', style: GoogleFonts.poppins()),
                    backgroundColor: theme.primary,
                  ));
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.primary, 
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: theme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text("Save Reflection", style: GoogleFonts.poppins(color: theme.buttonText, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderCard(String title, IconData icon, double value, ValueChanged<double> onChanged, EterniaTheme theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.primary, size: 16),
              ),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.poppins(color: theme.textSecondary, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: theme.primary,
              inactiveTrackColor: theme.primary.withOpacity(0.15),
              thumbColor: theme.primary,
              overlayColor: theme.primary.withOpacity(0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(value: value, onChanged: onChanged),
          ),
          Center(
            child: Text(
              "${(value * 100).toInt()}%", 
              style: GoogleFonts.poppins(color: theme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }
}
