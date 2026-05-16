// ==========================================================
// MAIN NAVIGATION - PREMIUM ADAPTIVE
// ==========================================================

import 'package:eternia_ef/Tabs/ConnectPage/ConnectTabWrapper.dart';
import 'package:flutter/material.dart';
import 'package:eternia_ef/Tabs/home_screen/EterniaHomeScreen.dart';
import 'package:eternia_ef/widgets/tab_wrappers.dart';
import 'package:eternia_ef/Tabs/ProfilePage/private_profile_screen.dart';
import 'package:eternia_ef/widgets/custom_bottom_bar.dart';
import 'package:eternia_ef/utils/eternia_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const EterniaHomeScreen(),
    const ConnectTabWrapper(),
    const BlackBoxTabWrapper(),
    const ToolsTabWrapper(),
    const PrivateProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = EterniaTheme.of(context);

    return PopScope(
      canPop: _selectedIndex == 0,

      onPopInvoked: (didPop) {
        if (didPop) return;

        // If user is on Connect / BlackBox / Tools / Profile
        // go back to EterniaHomeScreen tab
        setState(() {
          _selectedIndex = 0;
        });
      },

      child: Scaffold(
        backgroundColor: theme.bg,
        body: Stack(
          children: [

            // Background glow
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.primary.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: CustomBottomBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
