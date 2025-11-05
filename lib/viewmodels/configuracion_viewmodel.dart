import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/configuracion_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../repositories/data_repository.dart';

class ConfiguracionViewModel with ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final DataRepository _repository;
  ConfiguracionModel _configuracion = ConfiguracionModel.defaultValues();

  ConfiguracionModel get configuracion => _configuracion;

  final List<String> _languages = ['Español', 'English', 'Português'];
  final List<String> _themes = ['Sistema', 'Claro', 'Oscuro'];

  List<String> get languages => _languages;
  List<String> get themes => _themes;

  ConfiguracionViewModel(this._repository) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Intentar cargar desde Firestore primero
      await _loadFromFirestore();
    } catch (e) {
      // Si falla Firestore, cargar desde SharedPreferences
      print('Error cargando desde Firestore: $e');
      await _loadFromSharedPreferences();
    }
  }

  Future<void> _loadFromFirestore() async {
    try {
      const usuarioId = 'usuario_actual'; // Puedes ajustar esto por usuario

      final snapshot = await _repository.getConfiguracion(usuarioId);

      if (snapshot.exists) {
        // CORRECCIÓN: Convertir explícitamente a Map<String, dynamic>
        final data = snapshot.data() as Map<String, dynamic>? ?? {};

        _configuracion = ConfiguracionModel.fromFirestore(snapshot.id, data);
        // Sincronizar con SharedPreferences
        await _syncToSharedPreferences();
      } else {
        // Si no existe en Firestore, cargar desde SharedPreferences
        await _loadFromSharedPreferences();
        // Y guardar en Firestore
        await _saveToFirestore();
      }
      notifyListeners();
    } catch (e) {
      print('Error cargando desde Firestore: $e');
      // Fallback a SharedPreferences
      await _loadFromSharedPreferences();
    }
  }

  Future<void> _loadFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _configuracion = ConfiguracionModel(
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      darkModeEnabled: prefs.getBool('dark_mode_enabled') ?? false,
      biometricEnabled: prefs.getBool('biometric_enabled') ?? false,
      autoSyncEnabled: prefs.getBool('auto_sync_enabled') ?? true,
      selectedLanguage: prefs.getString('selected_language') ?? 'Español',
      selectedTheme: prefs.getString('selected_theme') ?? 'Sistema',
      cacheSize: prefs.getString('cache_size') ?? "15.2 MB",
    );
    notifyListeners();
  }

  Future<void> _syncToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'notifications_enabled',
      _configuracion.notificationsEnabled,
    );
    await prefs.setBool('dark_mode_enabled', _configuracion.darkModeEnabled);
    await prefs.setBool('biometric_enabled', _configuracion.biometricEnabled);
    await prefs.setBool('auto_sync_enabled', _configuracion.autoSyncEnabled);
    await prefs.setString('selected_language', _configuracion.selectedLanguage);
    await prefs.setString('selected_theme', _configuracion.selectedTheme);
    await prefs.setString('cache_size', _configuracion.cacheSize);
  }

  Future<void> _saveToFirestore() async {
    try {
      const usuarioId = 'usuario_actual'; // Puedes ajustar esto por usuario

      await _repository.saveConfiguracion(usuarioId, _configuracion.toMap());
    } catch (e) {
      print('Error guardando en Firestore: $e');
      // No relanzamos la excepción para no romper la funcionalidad
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }

      // Sincronizar con Firestore (en segundo plano, no esperamos)
      _saveToFirestore();
    } catch (e) {
      print('Error guardando configuración: $e');
      // Si falla Firestore, al menos tenemos SharedPreferences
    }
  }

  // MÉTODOS DE ACTUALIZACIÓN (MANTENIENDO FUNCIONALIDAD)
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

  // MÉTODOS EXISTENTES (SIN CAMBIOS)
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
    // También guardar en Firestore y SharedPreferences
    _saveSetting('cache_size', "0 MB");
    notifyListeners();
  }

  // Nuevo método para sincronizar manualmente
  Future<void> syncSettings() async {
    try {
      await _saveToFirestore();
      await _syncToSharedPreferences();
    } catch (e) {
      throw Exception('Error sincronizando configuración: $e');
    }
  }
}
