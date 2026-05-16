// ==========================================================
// CUSTOM BOTTOM BAR - FULLY RESPONSIVE
// ==========================================================

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:eternia_ef/utils/eternia_theme.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;

  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = EterniaTheme.of(context);

    final size = MediaQuery.of(context).size;

    final width = size.width;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // =====================================================
    // RESPONSIVE VALUES
    // =====================================================

    final double navHeight = width < 360 ? 66 : 74;

    final double iconSize = width < 360 ? 20 : 23;

    final double textSize = width < 360 ? 8.5 : 9.5;

    final double horizontalPadding = width < 360 ? 6 : 10;

    final double itemHorizontal = width < 360 ? 10 : 14;

    return SafeArea(
      top: false,

      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding > 0 ? 10 : 18),

        child: SizedBox(
          height: navHeight,

          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),

            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

              child: Container(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),

                decoration: BoxDecoration(
                  color: theme.isDark
                      ? Colors.black.withOpacity(0.45)
                      : Colors.white.withOpacity(0.88),

                  borderRadius: BorderRadius.circular(32),

                  border: Border.all(color: theme.primary.withOpacity(0.18)),

                  boxShadow: theme.isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),

                            blurRadius: 20,

                            offset: const Offset(0, 4),
                          ),
                        ],
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,

                  children: [
                    _buildNavItem(
                      0,
                      Icons.home_outlined,
                      Icons.home_rounded,
                      "Home",
                      theme,
                      iconSize,
                      textSize,
                      itemHorizontal,
                    ),

                    _buildNavItem(
                      1,
                      Icons.people_outline,
                      Icons.people_rounded,
                      "Connect",
                      theme,
                      iconSize,
                      textSize,
                      itemHorizontal,
                    ),

                    _buildNavItem(
                      2,
                      Icons.grid_view_outlined,
                      Icons.grid_view_rounded,
                      "BlackBox",
                      theme,
                      iconSize,
                      textSize,
                      itemHorizontal,
                    ),

                    _buildNavItem(
                      3,
                      Icons.spa_outlined,
                      Icons.spa_rounded,
                      "Wellness",
                      theme,
                      iconSize,
                      textSize,
                      itemHorizontal,
                    ),

                    _buildNavItem(
                      4,
                      Icons.person_outline_rounded,
                      Icons.person_rounded,
                      "Profile",
                      theme,
                      iconSize,
                      textSize,
                      itemHorizontal,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // NAV ITEM
  // =========================================================

  Widget _buildNavItem(
    int index,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    EterniaTheme theme,
    double iconSize,
    double textSize,
    double itemHorizontal,
  ) {
    final bool isSelected = currentIndex == index;

    final Color inactiveColor = theme.isDark ? Colors.white38 : Colors.black38;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),

        behavior: HitTestBehavior.opaque,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),

          curve: Curves.easeInOut,

          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),

          padding: EdgeInsets.symmetric(
            horizontal: itemHorizontal,
            vertical: 6,
          ),

          decoration: BoxDecoration(
            color: isSelected
                ? theme.primary.withOpacity(0.12)
                : Colors.transparent,

            borderRadius: BorderRadius.circular(20),

            border: isSelected
                ? Border.all(color: theme.primary.withOpacity(0.25), width: 1)
                : null,
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(
                isSelected ? filledIcon : outlinedIcon,

                color: isSelected ? theme.primary : inactiveColor,

                size: iconSize,
              ),

              const SizedBox(height: 3),

              FittedBox(
                child: Text(
                  label,

                  style: TextStyle(
                    color: isSelected ? theme.primary : inactiveColor,

                    fontSize: textSize,

                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,

                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
