import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../repositories/data_repository.dart';

class DashboardViewModel with ChangeNotifier {
  final DataRepository _repository;

  // Estados
  int _selectedIndex = 2;
  bool _loading = false;
  bool _initialized = false;
  String _error = '';
  Map<String, dynamic> _dashboardData = {};
  User? _currentUser;
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
  User? get currentUser => _currentUser;
  Map<String, int> get stats => _stats;

  DashboardViewModel(this._repository) {
    _initialize();
  }

  void _initialize() {
    _initializeUser();
    _loadInitialData();
  }

  void _initializeUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
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
      // Notificar solo si cambió realmente
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
        _getCollectionCount('estudiantes'),
        _getCollectionCount('docentes'),
        _getCollectionCount('carreras'),
        _getCollectionCount('cursos'),
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
        'email': _currentUser!.email,
        'displayName': _currentUser!.displayName ?? 'Usuario',
        'photoURL': _currentUser!.photoURL,
        'emailVerified': _currentUser!.emailVerified,
        'creationTime': _currentUser!.metadata.creationTime?.toString(),
        'lastSignInTime': _currentUser!.metadata.lastSignInTime?.toString(),
      };
    }
  }

  Future<int> _getCollectionCount(String collectionName) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .count()
          .get()
          .timeout(const Duration(seconds: 10));
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error en _getCollectionCount para $collectionName: $e');
      return 0;
    }
  }

  Future<int> _getAsistenciasHoy() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await FirebaseFirestore.instance
          .collection('asistencias')
          .where('fecha', isGreaterThanOrEqualTo: startOfDay)
          .where('fecha', isLessThanOrEqualTo: endOfDay)
          .count()
          .get()
          .timeout(const Duration(seconds: 10));

      return snapshot.count ?? 0;
    } catch (e) {
      print('Error en _getAsistenciasHoy: $e');
      return 0;
    }
  }

  Future<int> _getTotalAsistencias() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('asistencias')
          .count()
          .get()
          .timeout(const Duration(seconds: 10));
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error en _getTotalAsistencias: $e');
      return 0;
    }
  }

  Future<void> logout() async {
    try {
      _loading = true;
      notifyListeners();

      await FirebaseAuth.instance.signOut();
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
  }

  // ========== MÉTODOS ADICIONALES COMPLETOS ==========

  /// Actualizar perfil de usuario
  Future<void> updateUserProfile({
    required String displayName,
    String? photoURL,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }

        // Actualizar datos locales
        _initializeUser();
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error al actualizar perfil: ${e.toString()}');
    }
  }

  /// Verificar si el usuario es administrador
  Future<bool> isUserAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 5));

        return userDoc.exists && userDoc.data()?['role'] == 'admin';
      }
      return false;
    } catch (e) {
      print('Error en isUserAdmin: $e');
      return false;
    }
  }

  /// Obtener configuraciones del usuario
  Future<Map<String, dynamic>> getUserSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final settingsDoc = await FirebaseFirestore.instance
            .collection('user_settings')
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 5));

        if (settingsDoc.exists) {
          return settingsDoc.data() ?? {};
        }
      }
      return {};
    } catch (e) {
      print('Error en getUserSettings: $e');
      return {};
    }
  }

  /// Actualizar configuraciones del usuario
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('user_settings')
            .doc(user.uid)
            .set(settings, SetOptions(merge: true))
            .timeout(const Duration(seconds: 5));

        // Actualizar datos locales si es necesario
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error al actualizar configuraciones: ${e.toString()}');
    }
  }

  /// Forzar refresh de datos
  Future<void> refreshData() async {
    await loadDashboardData(forceRefresh: true);
  }

  /// Limpiar error
  void clearError() {
    if (_error.isNotEmpty) {
      _error = '';
      notifyListeners();
    }
  }

  /// Verificar conexión a internet
  Future<bool> checkConnection() async {
    try {
      await FirebaseFirestore.instance
          .collection('estudiantes')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      print('Error en checkConnection: $e');
      return false;
    }
  }

  /// Obtener estadística específica
  int getStat(String key) {
    return _stats[key] ?? 0;
  }

  /// Verificar si hay datos cargados
  bool get hasData => _stats.isNotEmpty && _dashboardData.isNotEmpty;

  /// Obtener el tiempo desde la última actualización
  String get lastUpdateTime {
    if (_lastDataLoad == null) return 'Nunca';

    final now = DateTime.now();
    final difference = now.difference(_lastDataLoad!);

    if (difference.inMinutes < 1) return 'Hace unos segundos';
    if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Hace ${difference.inHours} h';
    return 'Hace ${difference.inDays} días';
  }

  /// Obtener información del sistema
  Map<String, dynamic> get systemInfo {
    return {
      'user': _currentUser?.email ?? 'No autenticado',
      'lastUpdate': lastUpdateTime,
      'statsCount': _stats.length,
      'hasError': _error.isNotEmpty,
      'isLoading': _loading,
    };
  }

  /// Validar permisos de usuario para una sección específica
  Future<bool> hasPermissionForSection(String section) async {
    try {
      final isAdmin = await isUserAdmin();

      // Definir permisos por sección
      final permissions = {
        'Estudiantes': true, // Todos pueden ver estudiantes
        'Docentes': isAdmin, // Solo admin puede ver docentes
        'Carreras': isAdmin, // Solo admin puede ver carreras
        'Cursos': true, // Todos pueden ver cursos
        'Reportes': isAdmin, // Solo admin puede ver reportes
        'Configuración': isAdmin, // Solo admin puede ver configuración
      };

      return permissions[section] ?? false;
    } catch (e) {
      print('Error en hasPermissionForSection: $e');
      return false;
    }
  }

  /// Obtener estadísticas detalladas por carrera
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
      final snapshot = await FirebaseFirestore.instance
          .collection('estudiantes')
          .get()
          .timeout(const Duration(seconds: 10));

      final Map<String, int> result = {};

      for (final doc in snapshot.docs) {
        final carrera = doc.data()['carrera'] ?? 'Sin carrera';
        result[carrera] = (result[carrera] ?? 0) + 1;
      }

      return result;
    } catch (e) {
      print('Error en _getEstudiantesByCarrera: $e');
      return {};
    }
  }

  Future<Map<String, int>> _getAsistenciasByDate() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(const Duration(days: 7));

      final snapshot = await FirebaseFirestore.instance
          .collection('asistencias')
          .where('fecha', isGreaterThanOrEqualTo: startOfWeek)
          .get()
          .timeout(const Duration(seconds: 10));

      final Map<String, int> result = {};

      for (final doc in snapshot.docs) {
        final fecha = doc.data()['fecha'];
        if (fecha != null) {
          final dateKey = _formatDate(fecha);
          result[dateKey] = (result[dateKey] ?? 0) + 1;
        }
      }

      return result;
    } catch (e) {
      print('Error en _getAsistenciasByDate: $e');
      return {};
    }
  }

  String _formatDate(dynamic date) {
    try {
      if (date is Timestamp) {
        return date.toDate().toString().substring(0, 10);
      } else if (date is DateTime) {
        return date.toString().substring(0, 10);
      }
      return 'Fecha inválida';
    } catch (e) {
      return 'Error en fecha';
    }
  }

  /// Método para manejar errores de forma centralizada
  void handleError(String methodName, dynamic error) {
    _error = 'Error en $methodName: ${error.toString()}';
    _loading = false;
    notifyListeners();

    // Log del error para debugging
    print('ERROR en $methodName: $error');
  }

  /// Reiniciar el estado del ViewModel
  void reset() {
    _clearData();
    _initialized = false;
    notifyListeners();

    // Re-inicializar
    _initialize();
  }

  /// Verificar si la aplicación necesita actualización
  Future<bool> checkForUpdates() async {
    try {
      final updateDoc = await FirebaseFirestore.instance
          .collection('app_info')
          .doc('current_version')
          .get()
          .timeout(const Duration(seconds: 5));

      if (updateDoc.exists) {
        final requiredVersion =
            updateDoc.data()?['min_required_version'] ?? '1.0.0';
        final currentVersion =
            '1.0.0'; // Aquí deberías obtener la versión actual de tu app

        // Lógica simple de comparación de versiones
        return _compareVersions(currentVersion, requiredVersion) < 0;
      }

      return false;
    } catch (e) {
      print('Error en checkForUpdates: $e');
      return false;
    }
  }

  int _compareVersions(String version1, String version2) {
    final v1 = version1.split('.').map(int.parse).toList();
    final v2 = version2.split('.').map(int.parse).toList();

    for (int i = 0; i < v1.length; i++) {
      if (v1[i] > v2[i]) return 1;
      if (v1[i] < v2[i]) return -1;
    }

    return 0;
  }

  /// Dispose para limpiar recursos
  @override
  void dispose() {
    // Limpiar cualquier suscripción o recurso aquí si es necesario
    super.dispose();
  }
}
