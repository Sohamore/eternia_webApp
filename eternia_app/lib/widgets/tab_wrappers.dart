// ==========================================================
// TAB WRAPPERS
// tab_wrappers.dart
// ==========================================================

import 'package:flutter/material.dart';
import 'package:eternia_ef/Tabs/BlackBox/black_box_screen.dart';
import 'package:eternia_ef/Tabs/Tools/tools_screen.dart';

// ==========================================================
// BLACKBOX TAB WRAPPER — No nested navigator
// Sub-screens open via rootNavigator (full screen, no bottom bar)
// ==========================================================

class BlackBoxTabWrapper extends StatelessWidget {
  const BlackBoxTabWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const BlackBoxScreen();
  }
}

// ==========================================================
// TOOLS TAB WRAPPER — No nested navigator
// Sub-screens open via rootNavigator (full screen, no bottom bar)
// ==========================================================

class ToolsTabWrapper extends StatelessWidget {
  const ToolsTabWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const ToolsScreen();
  }
}
