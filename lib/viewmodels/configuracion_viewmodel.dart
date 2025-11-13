// viewmodels/configuracion_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../models/configuracion_model.dart';
import '../models/database_helper.dart';

class ConfiguracionViewModel with ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
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
    try {
      await _loadFromDatabase();
    } catch (e) {
      print('Error cargando configuración: $e');
    }
  }

  Future<void> _loadFromDatabase() async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM configuraciones WHERE id = 'config_default'
      ''');

      if (result.isNotEmpty) {
        _configuracion = ConfiguracionModel.fromMap(
          Map<String, dynamic>.from(result.first)
        );
      } else {
        // Insertar configuración por defecto si no existe
        await _saveToDatabase();
      }
      notifyListeners();
    } catch (e) {
      print('Error cargando desde base de datos: $e');
    }
  }

  Future<void> _saveToDatabase() async {
    try {
      await _databaseHelper.rawInsert('''
        INSERT OR REPLACE INTO configuraciones 
        (id, notifications_enabled, dark_mode_enabled, biometric_enabled, 
         auto_sync_enabled, selected_language, selected_theme, cache_size, last_updated)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        _configuracion.id ?? 'config_default',
        _configuracion.notificationsEnabled ? 1 : 0,
        _configuracion.darkModeEnabled ? 1 : 0,
        _configuracion.biometricEnabled ? 1 : 0,
        _configuracion.autoSyncEnabled ? 1 : 0,
        _configuracion.selectedLanguage,
        _configuracion.selectedTheme,
        _configuracion.cacheSize,
        DateTime.now().toIso8601String(),
      ]);
    } catch (e) {
      print('Error guardando configuración: $e');
      rethrow;
    }
  }

  // MÉTODOS DE ACTUALIZACIÓN
  Future<void> updateNotificationsEnabled(bool value) async {
    _configuracion = _configuracion.copyWith(notificationsEnabled: value);
    await _saveToDatabase();
    notifyListeners();
  }

  Future<void> updateDarkModeEnabled(bool value) async {
    _configuracion = _configuracion.copyWith(darkModeEnabled: value);
    await _saveToDatabase();
    notifyListeners();
  }

  Future<void> updateAutoSyncEnabled(bool value) async {
    _configuracion = _configuracion.copyWith(autoSyncEnabled: value);
    await _saveToDatabase();
    notifyListeners();
  }

  Future<void> updateLanguage(String value) async {
    _configuracion = _configuracion.copyWith(selectedLanguage: value);
    await _saveToDatabase();
    notifyListeners();
  }

  Future<void> updateTheme(String value) async {
    _configuracion = _configuracion.copyWith(selectedTheme: value);
    await _saveToDatabase();
    notifyListeners();
  }

  Future<void> toggleBiometricEnabled() async {
    if (_configuracion.biometricEnabled) {
      // Desactivar biometría
      _configuracion = _configuracion.copyWith(biometricEnabled: false);
      await _saveToDatabase();
      notifyListeners();
    } else {
      // Activar biometría - requiere autenticación
      await _checkBiometricAvailability();
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics;

      if (!canAuthenticate) {
        throw Exception('Biometría no disponible en este dispositivo');
      }

      final List<BiometricType> availableBiometrics = 
          await _localAuth.getAvailableBiometrics();

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
        await _saveToDatabase();
        notifyListeners();
      } else {
        throw Exception('Autenticación cancelada o fallida');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearCache() async {
    _configuracion = _configuracion.copyWith(cacheSize: "0 MB");
    await _saveToDatabase();
    notifyListeners();
  }

  // Nuevo método para sincronizar manualmente
  Future<void> syncSettings() async {
    try {
      await _saveToDatabase();
    } catch (e) {
      throw Exception('Error sincronizando configuración: $e');
    }
  }

  // Método para resetear a valores por defecto
  Future<void> resetToDefaults() async {
    _configuracion = ConfiguracionModel.defaultValues();
    await _saveToDatabase();
    notifyListeners();
  }

  // Método para obtener resumen de configuración
  String get resumenConfiguracion {
    final config = _configuracion;
    return 'Idioma: ${config.selectedLanguage} | Tema: ${config.selectedTheme} | '
           'Notificaciones: ${config.notificationsEnabled ? "On" : "Off"} | '
           'Biometría: ${config.biometricEnabled ? "On" : "Off"}';
  }
}