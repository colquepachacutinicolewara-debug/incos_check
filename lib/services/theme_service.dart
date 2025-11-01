// services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final String theme = prefs.getString('selected_theme') ?? 'Sistema';

    switch (theme) {
      case 'Claro':
        _themeMode = ThemeMode.light;
        break;
      case 'Oscuro':
        _themeMode = ThemeMode.dark;
        break;
      case 'Sistema':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  Future<void> updateTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', theme);

    switch (theme) {
      case 'Claro':
        _themeMode = ThemeMode.light;
        break;
      case 'Oscuro':
        _themeMode = ThemeMode.dark;
        break;
      case 'Sistema':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }
}
