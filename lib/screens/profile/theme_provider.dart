import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// 🔥 මෙන්න මේ කෑල්ල අනිවාර්යයෙන්ම theme_provider.dart එකේ තියෙන්න ඕනේ
class MyThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF131314), // Gemini Dark
    primaryColor: Colors.green[700],
    colorScheme: const ColorScheme.dark(
      primary: Colors.green,
      surface: Color(0xFF1E1E1F),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF131314),
      foregroundColor: Colors.white,
    ),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.green[700],
    colorScheme: const ColorScheme.light(
      primary: Colors.green,
    ),
  );
}