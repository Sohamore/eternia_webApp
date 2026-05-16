// import 'package:flutter/material.dart';

// class ThemeProvider extends ChangeNotifier {
//   bool isDark = true;

//   ThemeMode get themeMode =>
//       isDark ? ThemeMode.dark : ThemeMode.light;

//   void toggleTheme(bool value) {
//     isDark = value;
//     notifyListeners();
//   }
// }


import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {

  bool _isDark = true;

  bool get isDark => _isDark;

  ThemeMode get themeMode =>
      _isDark
          ? ThemeMode.dark
          : ThemeMode.light;

  void toggleTheme(bool value) {
    _isDark = value;
    notifyListeners();
  }
}