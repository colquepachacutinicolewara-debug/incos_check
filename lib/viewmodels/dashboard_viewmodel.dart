// viewmodels/dashboard_viewmodel.dart - VERSIÓN CORREGIDA
import 'package:flutter/foundation.dart';
import '../models/database_helper.dart';

class DashboardViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Estados
  int _selectedIndex = 2;
  bool _loading = false;
  bool _initialized = false;
  String _error = '';
  Map<String, dynamic> _dashboardData = {};
  Map<String, dynamic>? _currentUser;
  Map<String, int> _stats = {};

  // Cache para evitar recargas innecesarias
  DateTime? _lastDataLoad;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Getters
  int get selectedIndex => _selectedIndex;
  bool get loading => _loading;
  bool get initialized => _initialized;
  String get error => _error;
  Map<String, dynamic> get dashboardData => _dashboardData;
  Map<String, dynamic>? get currentUser => _currentUser;
  Map<String, int> get stats => _stats;

  DashboardViewModel({Map<String, dynamic>? userData}) {
    _currentUser = userData;
    _initialize();
  }

  void _initialize() {
    _loadInitialData();
  }

  void _loadInitialData() {
    if (_currentUser != null) {
      loadDashboardData();
    }
    _initialized = true;
    notifyListeners();
  }

  void changeIndex(int index) {
    if (index >= 0 && index <= 4 && _selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  Future<void> loadDashboardData({bool forceRefresh = false}) async {
    // Verificar cache para evitar cargas innecesarias
    if (!forceRefresh &&
        _lastDataLoad != null &&
        DateTime.now().difference(_lastDataLoad!) < _cacheDuration) {
      return;
    }

    try {
      _loading = true;
      _error = '';
      notifyListeners();

      await Future.wait([
        _loadDashboardStats(),
        _loadUserData(),
      ], eagerError: true);

      _lastDataLoad = DateTime.now();
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = 'Error al cargar datos: ${e.toString()}';
      notifyListeners();
      print('Error en loadDashboardData: $e');
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final counts = await Future.wait([
        _getTableCount('estudiantes'),
        _getTableCount('docentes'),
        _getTableCount('carreras'),
        _getTableCount('materias'),
        _getAsistenciasHoy(),
        _getTotalAsistencias(),
      ], eagerError: true);

      _stats = {
        'estudiantes': counts[0],
        'docentes': counts[1],
        'carreras': counts[2],
        'cursos': counts[3],
        'asistencias_hoy': counts[4],
        'total_asistencias': counts[5],
      };

      _dashboardData['stats'] = _stats;
    } catch (e) {
      print('Error en _loadDashboardStats: $e');
      _stats = {
        'estudiantes': 0,
        'docentes': 0,
        'carreras': 0,
        'cursos': 0,
        'asistencias_hoy': 0,
        'total_asistencias': 0,
      };
    }
  }

  Future<void> _loadUserData() async {
    if (_currentUser != null) {
      _dashboardData['user'] = {
        'email': _currentUser!['email'] ?? 'No especificado',
        'displayName': _currentUser!['nombre'] ?? 'Usuario',
        'role': _currentUser!['role'] ?? 'Usuario',
        'carnet': _currentUser!['carnet'] ?? 'No especificado',
        'departamento': _currentUser!['departamento'] ?? 'No especificado',
        'fecha_registro': _currentUser!['fecha_registro'] ?? 'No especificado',
      };
    }
  }

  Future<int> _getTableCount(String tableName) async {
    try {
      final result = await _databaseHelper.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      print('Error en _getTableCount para $tableName: $e');
      return 0;
    }
  }

  Future<int> _getAsistenciasHoy() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day).toIso8601String();
      
      final result = await _databaseHelper.rawQuery(
        'SELECT COUNT(*) as count FROM asistencias WHERE date(fecha) = date(?)',
        [today]
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      print('Error en _getAsistenciasHoy: $e');
      return 0;
    }
  }

  Future<int> _getTotalAsistencias() async {
    try {
      final result = await _databaseHelper.rawQuery('SELECT COUNT(*) as count FROM asistencias');
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      print('Error en _getTotalAsistencias: $e');
      return 0;
    }
  }

  Future<void> logout() async {
    try {
      _loading = true;
      notifyListeners();

      // Simular proceso de logout
      await Future.delayed(const Duration(milliseconds: 500));
      _clearData();

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = 'Error al cerrar sesión: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  void _clearData() {
    _selectedIndex = 2;
    _dashboardData = {};
    _stats = {};
    _error = '';
    _lastDataLoad = null;
    _currentUser = null;
  }

  // ========== MÉTODOS ADICIONALES ==========

  Future<bool> isUserAdmin() async {
    try {
      return _currentUser != null && _currentUser!['role'] == 'Administrador';
    } catch (e) {
      print('Error en isUserAdmin: $e');
      return false;
    }
  }

  /// Obtener estadísticas detalladas por carrera - CORREGIDO
  Future<Map<String, dynamic>> getDetailedStats() async {
    try {
      final estudiantesByCarrera = await _getEstudiantesByCarrera();
      final asistenciasByDate = await _getAsistenciasByDate();

      return {
        'estudiantes_by_carrera': estudiantesByCarrera,
        'asistencias_by_date': asistenciasByDate,
        'total_stats': _stats,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error en getDetailedStats: $e');
      return {};
    }
  }

  Future<Map<String, int>> _getEstudiantesByCarrera() async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT c.nombre as carrera, COUNT(e.id) as cantidad 
        FROM estudiantes e 
        LEFT JOIN carreras c ON e.carrera_id = c.id 
        GROUP BY c.nombre
      ''');
      
      final Map<String, int> estudiantesByCarrera = {};
      for (final row in result) {
        final carrera = (row['carrera'] as String?) ?? 'Sin carrera';
        final cantidad = (row['cantidad'] as int?) ?? 0;
        estudiantesByCarrera[carrera] = cantidad;
      }
      
      return estudiantesByCarrera;
    } catch (e) {
      print('Error en _getEstudiantesByCarrera: $e');
      return {};
    }
  }

  Future<Map<String, int>> _getAsistenciasByDate() async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT date(fecha) as fecha, COUNT(*) as cantidad 
        FROM asistencias 
        WHERE date(fecha) >= date('now', '-7 days')
        GROUP BY date(fecha)
      ''');
      
      final Map<String, int> asistenciasByDate = {};
      for (final row in result) {
        final fecha = (row['fecha'] as String?) ?? 'Fecha inválida';
        final cantidad = (row['cantidad'] as int?) ?? 0;
        asistenciasByDate[fecha] = cantidad;
      }
      
      return asistenciasByDate;
    } catch (e) {
      print('Error en _getAsistenciasByDate: $e');
      return {};
    }
  }

  /// Obtener datos rápidos del dashboard
  Future<Map<String, dynamic>> getQuickStats() async {
    try {
      final estudiantesCount = await _getTableCount('estudiantes');
      final asistenciasHoy = await _getAsistenciasHoy();
      final carrerasCount = await _getTableCount('carreras');

      return {
        'estudiantes_total': estudiantesCount,
        'asistencias_hoy': asistenciasHoy,
        'carreras_total': carrerasCount,
        'ultima_actualizacion': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error en getQuickStats: $e');
      return {};
    }
  }

  /// Verificar si el usuario está autenticado
  bool get isAuthenticated => _currentUser != null;

  /// Obtener el nombre del usuario
  String get userName => _currentUser?['nombre'] ?? 'Usuario';

  /// Obtener el rol del usuario
  String get userRole => _currentUser?['role'] ?? 'Usuario';

}