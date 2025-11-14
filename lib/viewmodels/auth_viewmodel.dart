// viewmodels/auth_viewmodel.dart - VERSIÓN COMPLETA CORREGIDA
import 'package:flutter/foundation.dart';
import '../models/database_helper.dart';
import '../models/usuario_model.dart';
import 'package:sqflite/sqflite.dart';

class AuthViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  Usuario? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _sessionChecked = false;

  // Getters
  Usuario? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get sessionChecked => _sessionChecked;

  // Login con manejo de errores
  Future<bool> login(String username, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      print('🔐 Iniciando proceso de login para: $username');

      if (username.isEmpty || password.isEmpty) {
        _setError('Por favor, completa todos los campos');
        return false;
      }

      // Verificar credenciales en la base de datos
      final userData = await _databaseHelper.verificarCredenciales(username, password);
      
      if (userData != null && userData.isNotEmpty) {
        // Convertir a modelo de usuario
        _currentUser = Usuario.fromLoginData(userData);
        _setError(null);
        
        print('✅ Login exitoso para: ${_currentUser!.nombre}');
        
        // Guardar sesión en configuraciones
        await _guardarSesion();
        notifyListeners();
        return true;
      } else {
        _setError('Usuario o contraseña incorrectos');
        print('❌ Login fallido: credenciales incorrectas');
        return false;
      }
    } catch (e) {
      _setError('Error al iniciar sesión: $e');
      print('❌ Error en login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    print('🚪 Cerrando sesión...');
    _currentUser = null;
    _setError(null);
    await _limpiarSesion();
    notifyListeners();
    print('✅ Sesión cerrada exitosamente');
  }

  // ✅ CORREGIDO: Método para cambiar contraseña - VERSIÓN MEJORADA
  Future<bool> cambiarPassword(String currentPassword, String nuevaPassword) async {
    try {
      print('🔄 AuthViewModel.cambiarPassword iniciado');
      print('👤 Usuario actual: ${_currentUser?.username}');
      print('🔑 Contraseña actual proporcionada: $currentPassword');
      print('🆕 Nueva contraseña: $nuevaPassword');
      
      if (_currentUser == null) {
        print('❌ No hay usuario logueado');
        _setError('No hay usuario logueado');
        return false;
      }
      
      // Verificar contraseña actual
      print('🔍 Verificando contraseña actual...');
      final credencialesCorrectas = await _databaseHelper.verificarCredenciales(
        _currentUser!.username, 
        currentPassword
      );
      
      if (credencialesCorrectas == null) {
        print('❌ Contraseña actual incorrecta');
        _setError('La contraseña actual es incorrecta');
        return false;
      }
      
      print('✅ Contraseña actual verificada correctamente');
      
      _setLoading(true);
      
      print('💾 Guardando nueva contraseña en BD...');
      final resultado = await _databaseHelper.actualizarPassword(
        _currentUser!.id, 
        nuevaPassword
      );
      
      print('📊 Resultado de actualización: $resultado filas afectadas');
      
      if (resultado > 0) {
        print('✅ Contraseña actualizada en BD exitosamente');
        
        // Actualizar usuario local
        _currentUser = Usuario.fromLoginData({
          ..._currentUser!.toMap(),
          'password': nuevaPassword,
        });
        
        _setError(null);
        notifyListeners();
        
        // Verificar que funciona la nueva contraseña
        print('🔐 Verificando nueva contraseña...');
        final verificado = await _databaseHelper.verificarCredenciales(
          _currentUser!.username, 
          nuevaPassword
        );
        
        if (verificado != null) {
          print('🎉 Nueva contraseña verificada correctamente');
        } else {
          print('⚠️ La nueva contraseña no funciona después del cambio');
        }
        
        return true;
      }
      
      print('❌ Error: ninguna fila fue actualizada');
      _setError('Error al actualizar contraseña');
      return false;
    } catch (e) {
      print('❌ Error en cambiarPassword: $e');
      _setError('Error al cambiar contraseña: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verificar si hay sesión guardada
  Future<bool> verificarSesionGuardada() async {
    try {
      _setLoading(true);
      
      final db = await _databaseHelper.database;
      final result = await db.query(
        'configuraciones',
        where: 'id = ?',
        whereArgs: ['session_user'],
      );

      if (result.isNotEmpty) {
        final sessionData = result.first;
        final userId = sessionData['value']?.toString();
        
        if (userId != null && userId.isNotEmpty) {
          final userResult = await db.query(
            'usuarios',
            where: 'id = ? AND esta_activo = 1',
            whereArgs: [userId],
          );
          
          if (userResult.isNotEmpty) {
            _currentUser = Usuario.fromLoginData(userResult.first);
            _setError(null);
            _sessionChecked = true;
            notifyListeners();
            return true;
          }
        }
      }
      
      _sessionChecked = true;
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error verificando sesión: $e');
      }
      _sessionChecked = true;
      _setError('Error al verificar sesión: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      notifyListeners();
    }
  }

  // Guardar sesión en configuraciones
  Future<void> _guardarSesion() async {
    try {
      final db = await _databaseHelper.database;
      await db.insert(
        'configuraciones',
        {
          'id': 'session_user',
          'value': _currentUser?.id,
          'last_updated': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error guardando sesión: $e');
      }
    }
  }

  // Limpiar sesión
  Future<void> _limpiarSesion() async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'configuraciones',
        where: 'id = ?',
        whereArgs: ['session_user'],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error limpiando sesión: $e');
      }
    }
  }

  // Verificar permisos específicos
  bool puedeAccederAGestion() {
    return _currentUser?.puedeGestionarUsuarios == true ||
           _currentUser?.puedeGestionarCursos == true ||
           _currentUser?.puedeGestionarEstudiantes == true;
  }

  bool puedeAccederAAsistencias() {
    return _currentUser?.puedeRegistrarAsistencia == true;
  }

  bool puedeAccederAReportes() {
    return _currentUser?.puedeVerReportes == true;
  }

  // ✅ NUEVO: Método para limpiar errores
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}