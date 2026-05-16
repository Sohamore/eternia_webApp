// ==========================================================
// BREATHING EXERCISE SCREEN - PREMIUM ADAPTIVE
// ==========================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eternia_ef/utils/eternia_theme.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isActive = false;
  String _phase = "Tap to Begin";
  int _selectedDurationIndex = 1;
  final List<String> _durations = ["2 min", "5 min", "10 min"];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _controller.reverse();
              setState(() => _phase = "Exhale...");
            } else if (status == AnimationStatus.dismissed && _isActive) {
              _controller.forward();
              setState(() => _phase = "Inhale...");
            }
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isActive = !_isActive;
      if (_isActive) {
        _controller.forward();
        _phase = "Inhale...";
      } else {
        _controller.stop();
        _phase = "Tap to Begin";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = EterniaTheme.of(context);
    final isDark = theme.isDark;

    return Scaffold(
      backgroundColor: theme.bg,
      body: Stack(
        children: [
          // ===================================================
          // BACKGROUND GLOW EFFECTS
          // ===================================================
          if (_isActive) ...[
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: -50,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primary.withOpacity(
                        0.05 + (_controller.value * 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primary.withOpacity(0.1),
                          blurRadius: 100,
                          spreadRadius: 50,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.1,
              right: -50,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primary.withOpacity(
                        0.03 + ((1 - _controller.value) * 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primary.withOpacity(0.1),
                          blurRadius: 120,
                          spreadRadius: 40,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],

          SafeArea(
            child: Column(
              children: [
                // ===================================================
                // TOP BAR (GLASSMORPHIC)
                // ===================================================
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
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
                            color: theme.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        "Breath Guide",
                        style: GoogleFonts.cormorantGaramond(
                          color: theme.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ===================================================
                // BREATHING CIRCLE ANIMATION
                // ===================================================
                GestureDetector(
                  onTap: _toggle,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final scale = 0.65 + (_controller.value * 0.45);
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          Transform.scale(
                            scale: scale * 1.15,
                            child: Container(
                              height: 280,
                              width: 280,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.primary.withOpacity(
                                  _isActive ? 0.05 : 0.02,
                                ),
                                border: Border.all(
                                  color: theme.primary.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          // Main animated circle
                          Transform.scale(
                            scale: scale,
                            child: Container(
                              height: 250,
                              width: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    theme.primary.withOpacity(0.4),
                                    theme.primary.withOpacity(0.05),
                                  ],
                                ),
                                border: Border.all(
                                  color: theme.primary.withOpacity(0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primary.withOpacity(
                                      _isActive ? 0.3 : 0.1,
                                    ),
                                    blurRadius: 80,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Inner stable icon circle
                          Container(
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.primary.withOpacity(
                                isDark ? 0.2 : 0.15,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primary.withOpacity(0.2),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isActive
                                  ? Icons.air_rounded
                                  : Icons.play_arrow_rounded,
                              color: theme.primary,
                              size: 42,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 50),

                // ===================================================
                // PHASE TEXT
                // ===================================================
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _phase,
                    key: ValueKey<String>(_phase),
                    style: GoogleFonts.cormorantGaramond(
                      color: theme.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isActive
                      ? "Follow the rhythm"
                      : "4-4-4 Box Breathing Technique",
                  style: GoogleFonts.poppins(
                    color: theme.textTertiary,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),

                const Spacer(),

                // ===================================================
                // DURATION SELECTOR
                // ===================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.03)
                          : Colors.black.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.border),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = (constraints.maxWidth) / 3;
                        return Stack(
                          children: [
                            // SLIDING BACKGROUND
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              left: _selectedDurationIndex * width,
                              child: Container(
                                width: width,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // TEXT BUTTONS
                            Row(
                              children: List.generate(_durations.length, (index) {
                                final isSelected = _selectedDurationIndex == index;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedDurationIndex = index),
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      height: 44,
                                      alignment: Alignment.center,
                                      child: Text(
                                        _durations[index],
                                        style: GoogleFonts.poppins(
                                          color: isSelected
                                              ? (isDark ? Colors.black : Colors.white)
                                              : theme.textTertiary,
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuration(String label, bool selected, EterniaTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? theme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: theme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: selected
              ? (theme.isDark ? Colors.black : Colors.white)
              : theme.textTertiary,
          fontSize: 13,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}
