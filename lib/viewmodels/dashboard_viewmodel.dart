// viewmodels/dashboard_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../repositories/data_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardViewModel with ChangeNotifier {
  final DataRepository _repository;

  DashboardViewModel(this._repository);

  int _selectedIndex = 2;
  bool _loading = false;
  String _error = '';
  Map<String, dynamic> _estadisticas = {};
  List<Map<String, dynamic>> _cursosHoy = [];
  List<Map<String, dynamic>> _actividadesRecientes = [];

  // Getters
  int get selectedIndex => _selectedIndex;
  bool get loading => _loading;
  String get error => _error;
  Map<String, dynamic> get estadisticas => _estadisticas;
  List<Map<String, dynamic>> get cursosHoy => _cursosHoy;
  List<Map<String, dynamic>> get actividadesRecientes => _actividadesRecientes;

  void changeIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Cargar datos del dashboard
  Future<void> loadDashboardData() async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      // Cargar estadísticas
      _estadisticas = await _repository.getEstadisticasHoy();

      // Datos de ejemplo (reemplazar con llamadas reales a Firestore)
      _cursosHoy = [
        {
          'id': '1',
          'nombre': '3ro "B" - Sistemas',
          'materia': 'Programación Avanzada',
          'hora': '08:00 - 10:00',
          'estudiantes': 45,
          'asistenciaHoy': '38/45',
        },
        {
          'id': '2',
          'nombre': '3ro "B" - Sistemas',
          'materia': 'Base de Datos II',
          'hora': '10:30 - 12:30',
          'estudiantes': 45,
          'asistenciaHoy': '40/45',
        },
      ];

      _actividadesRecientes = [
        {
          'tipo': 'asistencia',
          'descripcion': 'Asistencia registrada - Programación',
          'hora': '08:15',
          'estudiante': 'Juan Pérez',
        },
        {
          'tipo': 'falta',
          'descripcion': 'Falta justificada - María López',
          'hora': '09:30',
          'estudiante': 'María López',
        },
      ];
    } catch (e) {
      _error = 'Error al cargar datos del dashboard: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Método para suscribirse a streams en tiempo real
  void initializeRealTimeData() {
    // Ejemplo: escuchar cambios en actividades recientes
    // _repository.getActividadesRecientesStream().listen((snapshot) {
    //   _actividadesRecientes = _parseActividades(snapshot);
    //   notifyListeners();
    // });
  }

  // Métodos auxiliares para parsear datos
  List<Map<String, dynamic>> _parseCursos(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {'id': doc.id, ...data};
    }).toList();
  }

  List<Map<String, dynamic>> _parseActividades(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {'id': doc.id, ...data};
    }).toList();
  }
}
