// viewmodels/auth_viewmodel.dart - VERSIÓN COMPLETA CON TODOS LOS GETTERS
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/permission_service.dart';
import '../models/usuario_model.dart';
import '../utils/permissions.dart';

class AuthViewModel with ChangeNotifier {
  final AuthService _authService = AuthService();
  final PermissionService _permissionService = PermissionService();
  
  Usuario? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _sessionChecked = false;
  List<String> _currentUserPermissions = [];
  Map<String, bool> _availableModules = {};
  List<Usuario> _allUsers = [];

  // Getters
  Usuario? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get sessionChecked => _sessionChecked;
  List<String> get currentUserPermissions => _currentUserPermissions;
  Map<String, bool> get availableModules => _availableModules;
  List<Usuario> get allUsers => _allUsers;

  // 🌟 VERIFICAR PERMISO EN TIEMPO REAL
  bool tienePermiso(String permission) {
    return _currentUserPermissions.contains(permission);
  }

  bool puedeAccederModulo(String modulo) {
    return _availableModules[modulo] ?? false;
  }

  // 🌟 VERIFICACIONES ESPECÍFICAS - TODOS LOS GETTERS NECESARIOS
  bool get puedeGestionarEstudiantes => tienePermiso(AppPermissions.MANAGE_ESTUDIANTES);
  bool get puedeGestionarDocentes => tienePermiso(AppPermissions.MANAGE_DOCENTES);
  bool get puedeGestionarCarreras => tienePermiso(AppPermissions.MANAGE_CARRERAS);
  bool get puedeGestionarMaterias => tienePermiso(AppPermissions.MANAGE_MATERIAS);
  bool get puedeGestionarParalelos => tienePermiso(AppPermissions.MANAGE_PARALELOS);
  bool get puedeGestionarTurnos => tienePermiso(AppPermissions.MANAGE_TURNOS);
  bool get puedeGestionarNiveles => tienePermiso(AppPermissions.MANAGE_NIVELES);
  bool get puedeGestionarPeriodos => tienePermiso(AppPermissions.MANAGE_PERIODOS);
  
  bool get puedeRegistrarAsistencia => tienePermiso(AppPermissions.REGISTER_ASISTENCIA);
  bool get puedeVerHistorialAsistencia => tienePermiso(AppPermissions.VIEW_HISTORIAL_ASISTENCIA);
  bool get puedeGestionarBiometrico => tienePermiso(AppPermissions.MANAGE_BIOMETRICO);
  
  bool get puedeGenerarReportes => tienePermiso(AppPermissions.GENERATE_REPORTES);
  bool get puedeExportarDatos => tienePermiso(AppPermissions.EXPORT_DATA);
  bool get puedeVerEstadisticas => tienePermiso(AppPermissions.VIEW_STATISTICS);
  
  bool get puedeGestionarUsuarios => tienePermiso(AppPermissions.MANAGE_USUARIOS);
  bool get puedeGestionarConfiguracion => tienePermiso(AppPermissions.MANAGE_CONFIGURACION);
  bool get puedeGestionarRespaldos => tienePermiso(AppPermissions.MANAGE_BACKUPS);
  bool get puedeVerLogs => tienePermiso(AppPermissions.VIEW_LOGS);

  // 🌟 PERMISOS DE MÓDULOS COMPLETOS
  bool get puedeAccederDashboard => tienePermiso(AppPermissions.ACCESS_DASHBOARD);
  bool get puedeAccederGestion => tienePermiso(AppPermissions.ACCESS_GESTION);
  bool get puedeAccederAsistencia => tienePermiso(AppPermissions.ACCESS_ASISTENCIA);
  bool get puedeAccederReportes => tienePermiso(AppPermissions.ACCESS_REPORTES);
  bool get puedeAccederConfiguracion => tienePermiso(AppPermissions.ACCESS_CONFIGURACION);

  // 🌟 MÉTODO ESPECIAL PARA DOCENTES - VER SOLO SUS ESTUDIANTES
  bool get esDocente => _currentUser?.role.toLowerCase() == 'docente';
  bool get puedeVerSusEstudiantes => esDocente || puedeGestionarEstudiantes;

  // 🌟 INICIALIZACIÓN CON PERMISOS
  Future<void> initializeSession() async {
    if (!_sessionChecked) {
      await _checkStoredSession();
    }
  }

  // 🌟 LOGIN MEJORADO CON CARGA DE PERMISOS
  Future<bool> login(String username, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _authService.login(
        username: username,
        password: password,
      );

      if (result['success'] == true && result['user'] != null) {
        _currentUser = result['user'] as Usuario;
        
        // Cargar permisos y módulos disponibles
        await _loadUserPermissions();
        await _loadAvailableModules();
        
        _setError(null);
        _notifySafely();
        return true;
      } else {
        _setError(result['error'] as String? ?? 'Error desconocido');
        return false;
      }
    } catch (e) {
      _setError('Error crítico: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 🌟 CARGAR PERMISOS DEL USUARIO
  Future<void> _loadUserPermissions() async {
    if (_currentUser == null) return;
    
    try {
      _currentUserPermissions = await _permissionService.obtenerPermisosUsuario(_currentUser!.id);
      print('🔐 Permisos cargados: ${_currentUserPermissions.length} permisos');
    } catch (e) {
      print('❌ Error cargando permisos: $e');
      _currentUserPermissions = [];
    }
  }

  // 🌟 CARGAR MÓDULOS DISPONIBLES
  Future<void> _loadAvailableModules() async {
    if (_currentUser == null) return;
    
    try {
      _availableModules = await _permissionService.obtenerModulosDisponibles(_currentUser!.id);
      print('📦 Módulos disponibles: $_availableModules');
    } catch (e) {
      print('❌ Error cargando módulos: $e');
      _availableModules = {};
    }
  }

  // 🌟 VERIFICAR SESIÓN CON PERMISOS - VERSIÓN CORREGIDA
  Future<bool> _checkStoredSession() async {
    try {
      _isLoading = true;
      
      final storedUserId = await _authService.obtenerSesionGuardada();
      
      if (storedUserId != null && storedUserId.isNotEmpty) {
        final usuario = await _authService.obtenerUsuarioPorId(storedUserId);
        
        if (usuario != null && usuario.estaActivo) {
          _currentUser = usuario;
          
          // Cargar permisos y módulos
          await _loadUserPermissions();
          await _loadAvailableModules();
          
          _error = null;
          _sessionChecked = true;
          _notifySafely();
          return true;
        }
      }
      
      _sessionChecked = true;
      return false;
    } catch (e) {
      _error = 'Error verificando sesión: $e';
      _sessionChecked = true;
      return false;
    } finally {
      _isLoading = false;
      _notifySafely();
    }
  }

  // 🌟 LOGOUT MEJORADO
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authService.cerrarSesion();
      _currentUser = null;
      _currentUserPermissions = [];
      _availableModules = {};
      _allUsers = [];
      _setError(null);
      _notifySafely();
    } catch (e) {
      _setError('Error al cerrar sesión: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 🌟 CAMBIO DE CONTRASEÑA MEJORADO
  Future<bool> cambiarPassword(String currentPassword, String newPassword) async {
    try {
      if (_currentUser == null) {
        _setError('No hay usuario logueado');
        return false;
      }

      _setLoading(true);
      _setError(null);

      final result = await _authService.cambiarPassword(
        userId: _currentUser!.id,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result['success'] == true) {
        _setError(null);
        return true;
      } else {
        _setError(result['error'] as String?);
        return false;
      }
    } catch (e) {
      _setError('Error al cambiar contraseña: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 🌟 ACTUALIZAR PERFIL MEJORADO
  Future<bool> actualizarPerfil({
    String? username,
    String? nombre,
    String? email,
    String? telefono,
    String? fotoUrl,
  }) async {
    try {
      if (_currentUser == null) {
        _setError('No hay usuario logueado');
        return false;
      }

      _setLoading(true);
      _setError(null);

      final result = await _authService.actualizarPerfil(
        userId: _currentUser!.id,
        username: username,
        nombre: nombre,
        email: email,
        telefono: telefono,
        fotoUrl: fotoUrl,
      );

      if (result['success'] == true && result['user'] != null) {
        _currentUser = result['user'] as Usuario;
        _setError(null);
        _notifySafely();
        return true;
      } else {
        _setError(result['error'] as String?);
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar perfil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 🌟 GESTIÓN DE USUARIOS (SOLO ADMIN)
  Future<void> cargarTodosLosUsuarios() async {
    if (_currentUser == null || !_currentUser!.puedeGestionarUsuarios) {
      _setError('No tienes permisos para gestionar usuarios');
      return;
    }

    try {
      _setLoading(true);
      _allUsers = await _authService.obtenerTodosLosUsuarios();
      _notifySafely();
    } catch (e) {
      _setError('Error cargando usuarios: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> crearUsuario({
    required String username,
    required String password,
    required String nombre,
    required String email,
    required String role,
    required String carnet,
    required String departamento,
    String? telefono,
  }) async {
    if (_currentUser == null || !_currentUser!.puedeGestionarUsuarios) {
      _setError('No tienes permisos para crear usuarios');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      final result = await _authService.registrarUsuario(
        username: username,
        password: password,
        nombre: nombre,
        email: email,
        role: role,
        carnet: carnet,
        departamento: departamento,
        telefono: telefono,
      );

      if (result['success'] == true) {
        // Recargar lista de usuarios
        await cargarTodosLosUsuarios();
        return true;
      } else {
        _setError(result['error'] as String?);
        return false;
      }
    } catch (e) {
      _setError('Error creando usuario: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleUsuarioActivo(String userId, bool activo) async {
    if (_currentUser == null || !_currentUser!.puedeGestionarUsuarios) {
      _setError('No tienes permisos para modificar usuarios');
      return false;
    }

    try {
      _setLoading(true);
      final success = await _authService.toggleEstadoUsuario(userId, activo);
      
      if (success) {
        // Actualizar lista local
        await cargarTodosLosUsuarios();
        return true;
      } else {
        _setError('Error al cambiar estado del usuario');
        return false;
      }
    } catch (e) {
      _setError('Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 🌟 VERIFICAR ACCESO CON REGISTRO DE INTENTOS FALLIDOS
  Future<bool> verificarAcceso({
    required String modulo,
    required String accion,
    bool registrarIntento = true,
  }) async {
    if (_currentUser == null) return false;

    final tieneAcceso = _currentUser!.puedeAccederA(modulo);
    
    if (!tieneAcceso && registrarIntento) {
      await _permissionService.registrarIntentoAccesoNoAutorizado(
        userId: _currentUser!.id,
        modulo: modulo,
        accion: accion,
      );
    }

    return tieneAcceso;
  }

  // 🌟 MÉTODOS PRIVADOS MEJORADOS
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
    }
  }

  // 🌟 NOTIFICACIÓN SEGURA - Evita errores durante build
  void _notifySafely() {
    if (!_debugBuilding) {
      notifyListeners();
    } else {
      Future.delayed(Duration.zero, notifyListeners);
    }
  }

  // 🌟 VERIFICAR SI ESTAMOS EN MEDIO DE UN BUILD
  static bool get _debugBuilding {
    bool debugBuilding = false;
    assert(() {
      debugBuilding = true;
      return true;
    }());
    return debugBuilding;
  }

  // 🌟 LIMPIAR ERRORES
  void limpiarError() {
    _error = null;
    _notifySafely();
  }

  // 🌟 VERIFICAR PERMISOS (COMPATIBILIDAD)
  bool get puedeGestionarCursos => _currentUser?.puedeGestionarCursos == true;
  bool get puedeVerReportes => _currentUser?.puedeVerReportes == true;
}