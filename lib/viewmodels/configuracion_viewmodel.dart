// viewmodels/configuracion_viewmodel.dart - VERSIÓN COMPLETA ACTUALIZADA
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../models/configuracion_model.dart';
import '../models/database_helper.dart';
import '../viewmodels/auth_viewmodel.dart';

class ConfiguracionViewModel with ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  ConfiguracionModel _configuracion = ConfiguracionModel.defaultValues();

  ConfiguracionModel get configuracion => _configuracion;

  final List<String> _languages = ['Español'];
  final List<String> _themes = ['Sistema', 'Claro', 'Oscuro'];

  List<String> get languages => _languages;
  List<String> get themes => _themes;

  bool _guardando = false;
  bool get guardando => _guardando;

  String? _errorCambioPassword;
  String? get errorCambioPassword => _errorCambioPassword;

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
        await _saveToDatabase();
      }
      notifyListeners();
    } catch (e) {
      print('Error cargando desde base de datos: $e');
    }
  }

  Future<void> _saveToDatabase() async {
    try {
      _guardando = true;
      notifyListeners();

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
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  // ✅ ACTUALIZADO: Método para cambiar contraseña
  Future<Map<String, dynamic>> cambiarPassword({
    required String currentPassword,
    required String newPassword,
    required AuthViewModel authViewModel,
  }) async {
    try {
      _guardando = true;
      _errorCambioPassword = null;
      notifyListeners();

      print('🔐 ConfiguracionViewModel: Iniciando cambio de contraseña...');
      
      // Usar el AuthViewModel para cambiar la contraseña
      final resultado = await authViewModel.cambiarPassword(currentPassword, newPassword);
      
      _guardando = false;
      notifyListeners();
      
      if (resultado) {
        print('✅ ConfiguracionViewModel: Contraseña cambiada exitosamente');
        return {
          'success': true,
          'message': 'Contraseña cambiada exitosamente'
        };
      } else {
        _errorCambioPassword = authViewModel.error ?? 'Error desconocido al cambiar contraseña';
        notifyListeners();
        print('❌ ConfiguracionViewModel: Error - $_errorCambioPassword');
        return {
          'success': false,
          'message': _errorCambioPassword
        };
      }
    } catch (e) {
      _guardando = false;
      _errorCambioPassword = 'Error: ${e.toString()}';
      notifyListeners();
      print('❌ ConfiguracionViewModel: Error en cambiarPassword - $e');
      return {
        'success': false,
        'message': _errorCambioPassword
      };
    }
  }

  // ✅ NUEVO: Método para validar fortaleza de contraseña
  Map<String, dynamic> validarFortalezaPassword(String password) {
    final errores = <String>[];
    final recomendaciones = <String>[];
    
    if (password.length < 6) {
      errores.add('La contraseña debe tener al menos 6 caracteres');
    }
    
    // Verificar recomendaciones (no obligatorias)
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      recomendaciones.add('Incluir al menos una letra mayúscula');
    }
    
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      recomendaciones.add('Incluir al menos una letra minúscula');
    }
    
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      recomendaciones.add('Incluir al menos un número');
    }
    
    // Calcular fortaleza
    int fortaleza = 0;
    if (password.length >= 8) fortaleza++;
    if (RegExp(r'[A-Z]').hasMatch(password)) fortaleza++;
    if (RegExp(r'[a-z]').hasMatch(password)) fortaleza++;
    if (RegExp(r'[0-9]').hasMatch(password)) fortaleza++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) fortaleza++;
    
    String nivelFortaleza = 'Débil';
    Color colorFortaleza = Colors.red;
    
    if (fortaleza >= 4) {
      nivelFortaleza = 'Fuerte';
      colorFortaleza = Colors.green;
    } else if (fortaleza >= 3) {
      nivelFortaleza = 'Media';
      colorFortaleza = Colors.orange;
    }
    
    return {
      'esValida': errores.isEmpty,
      'errores': errores,
      'recomendaciones': recomendaciones,
      'fortaleza': nivelFortaleza,
      'colorFortaleza': colorFortaleza,
      'puntuacion': fortaleza,
    };
  }

  // Limpiar error de cambio de contraseña
  void limpiarErrorPassword() {
    _errorCambioPassword = null;
    notifyListeners();
  }

  Future<void> updateNotificationsEnabled(bool value) async {
    _configuracion = _configuracion.copyWith(notificationsEnabled: value);
    await _saveToDatabase();
    
    // Activar/desactivar notificaciones
    if (value) {
      _activarNotificaciones();
    } else {
      _desactivarNotificaciones();
    }
    
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
      _configuracion = _configuracion.copyWith(biometricEnabled: false);
      await _saveToDatabase();
      notifyListeners();
    } else {
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
        throw Exception('No hay métodos biométricos configurados. Ve a Configuración del dispositivo para agregar huellas digitales.');
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

  // ✅ ACTUALIZADO: Limpiar caché de forma segura
  Future<void> clearCache() async {
    try {
      // Limpiar solo caché no crítico
      await _databaseHelper.rawDelete('''
        DELETE FROM cache_temporal 
        WHERE tipo IN ('imagenes', 'thumbnails', 'logs')
      ''');
      
      _configuracion = _configuracion.copyWith(cacheSize: "0 MB");
      await _saveToDatabase();
      notifyListeners();
    } catch (e) {
      throw Exception('Error limpiando caché: $e');
    }
  }

  // ✅ NUEVO: Activar notificaciones
  void _activarNotificaciones() {
    // Programar recordatorios
    _programarRecordatorios();
    print('🔔 Notificaciones activadas');
  }

  // ✅ NUEVO: Desactivar notificaciones
  void _desactivarNotificaciones() {
    // Cancelar recordatorios
    print('🔕 Notificaciones desactivadas');
  }

  // ✅ NUEVO: Programar recordatorios
  void _programarRecordatorios() {
    print('⏰ Programando recordatorios de asistencia...');
    // Aquí se integraría con NotificationService
  }

  Future<void> syncSettings() async {
    try {
      await _saveToDatabase();
    } catch (e) {
      throw Exception('Error sincronizando configuración: $e');
    }
  }

  Future<void> resetToDefaults() async {
    _configuracion = ConfiguracionModel.defaultValues();
    await _saveToDatabase();
    notifyListeners();
  }

  String get resumenConfiguracion {
    final config = _configuracion;
    return 'Idioma: ${config.selectedLanguage} | Tema: ${config.selectedTheme} | '
           'Notificaciones: ${config.notificationsEnabled ? "On" : "Off"} | '
           'Biometría: ${config.biometricEnabled ? "On" : "Off"}';
  }
}