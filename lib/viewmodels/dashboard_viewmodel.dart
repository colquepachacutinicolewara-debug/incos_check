import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../repositories/data_repository.dart';

class DashboardViewModel with ChangeNotifier {
  final DataRepository _repository;

  // Estados
  int _selectedIndex = 2; // Inicio por defecto
  bool _loading = false;
  bool _initialized = false;
  String _error = '';

  // Datos del dashboard
  Map<String, dynamic> _dashboardData = {};
  User? _currentUser;
  Map<String, int> _stats = {};

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

  // Inicialización completa
  void _initialize() {
    _initializeUser();
    _loadInitialData();
  }

  // Inicializar usuario actual
  void _initializeUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  // Cargar datos iniciales
  void _loadInitialData() {
    if (_currentUser != null) {
      loadDashboardData();
    }
    _initialized = true;
    notifyListeners();
  }

  // Cambiar índice de navegación
  void changeIndex(int index) {
    if (index >= 0 && index <= 4) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  // Cargar datos del dashboard
  Future<void> loadDashboardData() async {
    try {
      _loading = true;
      _error = '';
      notifyListeners();

      await _loadDashboardStats();
      await _loadUserData();

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = 'Error al cargar datos: ${e.toString()}';
      notifyListeners();
    }
  }

  // Cargar estadísticas
  Future<void> _loadDashboardStats() async {
    try {
      final counts = await Future.wait([
        _getCollectionCount('estudiantes'),
        _getCollectionCount('docentes'),
        _getCollectionCount('carreras'),
        _getCollectionCount('cursos'),
        _getAsistenciasHoy(),
        _getTotalAsistencias(),
      ]);

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

  // Cargar datos del usuario
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

  // Obtener conteo de una colección
  Future<int> _getCollectionCount(String collectionName) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Obtener asistencias del día actual
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
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Obtener total de asistencias
  Future<int> _getTotalAsistencias() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('asistencias')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Cerrar sesión - SIN BuildContext
  Future<void> logout() async {
    try {
      _loading = true;
      notifyListeners();

      // Cerrar sesión en Firebase
      await FirebaseAuth.instance.signOut();

      // Limpiar datos locales
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

  // Limpiar datos
  void _clearData() {
    _selectedIndex = 2;
    _dashboardData = {};
    _stats = {};
    _error = '';
  }

  // Actualizar perfil de usuario
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

  // Verificar si el usuario es administrador
  Future<bool> isUserAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        return userDoc.exists && userDoc.data()?['role'] == 'admin';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Obtener configuraciones del usuario
  Future<Map<String, dynamic>> getUserSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final settingsDoc = await FirebaseFirestore.instance
            .collection('user_settings')
            .doc(user.uid)
            .get();

        if (settingsDoc.exists) {
          return settingsDoc.data() ?? {};
        }
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // Actualizar configuraciones del usuario
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('user_settings')
            .doc(user.uid)
            .set(settings, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Error al actualizar configuraciones: ${e.toString()}');
    }
  }

  // Forzar refresh de datos
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  // Limpiar error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Verificar conexión a internet
  Future<bool> checkConnection() async {
    try {
      await FirebaseFirestore.instance.collection('estudiantes').limit(1).get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Obtener estadística específica
  int getStat(String key) {
    return _stats[key] ?? 0;
  }

  // Verificar si hay datos cargados
  bool get hasData => _stats.isNotEmpty && _dashboardData.isNotEmpty;
}
