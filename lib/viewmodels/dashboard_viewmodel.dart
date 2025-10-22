// viewmodels/dashboard_viewmodel.dart
import 'package:flutter/foundation.dart';

class DashboardViewModel with ChangeNotifier {
  int _selectedIndex = 2; // Inicio como página central

  int get selectedIndex => _selectedIndex;

  void changeIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Datos de prueba para estadísticas
  final Map<String, dynamic> estadisticas = {
    'totalEstudiantes': 45,
    'asistenciasHoy': 38,
    'faltasHoy': 7,
    'tardanzasHoy': 3,
    'porcentajeAsistencia': 84.4,
  };

  final List<Map<String, dynamic>> cursosHoy = [
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

  final List<Map<String, dynamic>> actividadesRecientes = [
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
}