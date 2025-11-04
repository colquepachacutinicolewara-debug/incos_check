import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/configuracion_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ConfiguracionViewModel with ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  ConfiguracionModel _configuracion = ConfiguracionModel.defaultValues();

  ConfiguracionModel get configuracion => _configuracion;

  final List<String> _languages = ['Español', 'English', 'Português'];
  final List<String> _themes = ['Sistema', 'Claro', 'Oscuro'];

  List<String> get languages => _languages;
  List<String> get themes => _themes;

  ConfiguracionViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _configuracion = ConfiguracionModel(
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      darkModeEnabled: prefs.getBool('dark_mode_enabled') ?? false,
      biometricEnabled: prefs.getBool('biometric_enabled') ?? false,
      autoSyncEnabled: prefs.getBool('auto_sync_enabled') ?? true,
      selectedLanguage: prefs.getString('selected_language') ?? 'Español',
      selectedTheme: prefs.getString('selected_theme') ?? 'Sistema',
      cacheSize: "15.2 MB",
    );
    notifyListeners();
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Future<void> updateNotificationsEnabled(bool value) async {
    _configuracion = _configuracion.copyWith(notificationsEnabled: value);
    await _saveSetting('notifications_enabled', value);
    notifyListeners();
  }

  Future<void> updateAutoSyncEnabled(bool value) async {
    _configuracion = _configuracion.copyWith(autoSyncEnabled: value);
    await _saveSetting('auto_sync_enabled', value);
    notifyListeners();
  }

  Future<void> updateLanguage(String value) async {
    _configuracion = _configuracion.copyWith(selectedLanguage: value);
    await _saveSetting('selected_language', value);
    notifyListeners();
  }

  Future<void> updateTheme(String value) async {
    _configuracion = _configuracion.copyWith(selectedTheme: value);
    await _saveSetting('selected_theme', value);
    notifyListeners();
  }

  Future<void> toggleBiometricEnabled() async {
    if (_configuracion.biometricEnabled) {
      // Desactivar biometría
      _configuracion = _configuracion.copyWith(biometricEnabled: false);
      await _saveSetting('biometric_enabled', false);
    } else {
      // Activar biometría - requiere autenticación
      await _checkBiometricAvailability();
    }
    notifyListeners();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics;

      if (!canAuthenticate) {
        throw Exception('Biometría no disponible en este dispositivo');
      }

      final List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        throw Exception('No hay métodos biométricos configurados');
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason:
            'Autentícate para habilitar el acceso biométrico en IncosCheck',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        _configuracion = _configuracion.copyWith(biometricEnabled: true);
        await _saveSetting('biometric_enabled', true);
      } else {
        throw Exception('Autenticación cancelada o fallida');
      }
    } catch (e) {
      rethrow;
    }
  }

  void clearCache() {
    _configuracion = _configuracion.copyWith(cacheSize: "0 MB");
    notifyListeners();
  }
}
