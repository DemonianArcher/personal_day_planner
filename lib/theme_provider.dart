import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  ThemeData get themeData => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF36393F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 153, 36, 36), 
          brightness: Brightness.dark,
          surface: const Color(0xFF36393F),
        ),
      );
}
