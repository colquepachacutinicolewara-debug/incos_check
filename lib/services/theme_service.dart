import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  static const String _themeKey = 'selected_theme';

  ThemeMode get themeMode => _themeMode;

  Future<void> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String theme = prefs.getString(_themeKey) ?? 'Sistema';
      _applyTheme(theme);
    } catch (e) {
      // En caso de error, usar tema por defecto del sistema
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> updateTheme(String theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, theme);
      _applyTheme(theme);
    } catch (e) {
      // Manejar error silenciosamente o mostrar snackbar según necesidad
      print('Error al guardar preferencia de tema: $e');
    }
    notifyListeners();
  }

  void _applyTheme(String theme) {
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
  }

  // Método útil para obtener el tema actual como String
  String get currentThemeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
      default:
        return 'Sistema';
    }
  }

  // Método para verificar si está en modo oscuro (considerando el tema del sistema)
  bool isDarkMode(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
      default:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }

  // Método para alternar entre temas
  Future<void> toggleTheme() async {
    String newTheme;
    switch (_themeMode) {
      case ThemeMode.light:
        newTheme = 'Oscuro';
        break;
      case ThemeMode.dark:
        newTheme = 'Sistema';
        break;
      case ThemeMode.system:
      default:
        newTheme = 'Claro';
        break;
    }
    await updateTheme(newTheme);
  }

  // Método para resetear a tema por defecto
  Future<void> resetToDefault() async {
    await updateTheme('Sistema');
  }
}
