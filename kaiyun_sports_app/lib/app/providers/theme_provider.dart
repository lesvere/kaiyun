import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() {
    _loadThemeMode();
  }
  
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      _isDarkMode = true;
    } else {
      _themeMode = ThemeMode.light;
      _isDarkMode = false;
    }
    _saveThemeMode();
    notifyListeners();
  }
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;
    _saveThemeMode();
    notifyListeners();
  }
  
  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    _isDarkMode = _themeMode == ThemeMode.dark;
    notifyListeners();
  }
  
  void _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', _themeMode.index);
  }
}