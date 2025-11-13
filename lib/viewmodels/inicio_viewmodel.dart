// viewmodels/inicio_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/inicio_model.dart';
import '../models/database_helper.dart';
import '../utils/helpers.dart';

class InicioViewModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance; // ✅ Cambio aquí
  InicioModel _model = InicioModel(
    currentDate: DateTime.now(),
    systemStatus: 'Sistema Activo',
  );

  bool _isLoading = false;
  String? _error;

  InicioModel get model => _model;
  bool get isLoading => _isLoading;
  String? get error => _error;

  InicioViewModel() { // ✅ Constructor sin parámetros
    _cargarDatosInicio();
  }

  // Cargar datos de inicio desde SQLite
  Future<void> _cargarDatosInicio() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM inicio WHERE id = 'inicio_actual'
      ''');

      if (result.isNotEmpty) {
        final data = Map<String, dynamic>.from(result.first);
        _model = InicioModel.fromMap(data);
      } else {
        // Insertar datos por defecto si no existen
        await _insertarDatosPorDefecto();
      }

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar datos de inicio: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _insertarDatosPorDefecto() async {
    try {
      await _databaseHelper.rawInsert('''
        INSERT INTO inicio (id, fecha_actual, system_status, fecha_actualizacion)
        VALUES (?, ?, ?, ?)
      ''', [
        'inicio_actual',
        DateTime.now().toIso8601String(),
        'Sistema Operativo Correctamente',
        DateTime.now().toIso8601String()
      ]);

      _model = InicioModel(
        currentDate: DateTime.now(),
        systemStatus: 'Sistema Operativo Correctamente',
      );
    } catch (e) {
      print('Error insertando datos por defecto: $e');
    }
  }

  // Actualizar hora del sistema
  void updateTime() {
    _model = InicioModel(
      currentDate: DateTime.now(),
      systemStatus: _model.systemStatus,
    );
    notifyListeners();
  }

  // Actualizar estado del sistema
  Future<void> updateSystemStatus(String newStatus) async {
    try {
      _model = InicioModel(
        currentDate: _model.currentDate,
        systemStatus: newStatus,
      );

      await _databaseHelper.rawUpdate('''
        UPDATE inicio 
        SET system_status = ?, fecha_actualizacion = ?
        WHERE id = 'inicio_actual'
      ''', [newStatus, DateTime.now().toIso8601String()]);

      notifyListeners();
    } catch (e) {
      _error = 'Error al actualizar estado del sistema: $e';
      notifyListeners();
    }
  }

  // Obtener estadísticas rápidas
  Future<Map<String, dynamic>> getEstadisticasRapidas() async {
    try {
      final estudiantesCount = await _getCount('estudiantes');
      final docentesCount = await _getCount('docentes');
      final materiasCount = await _getCount('materias');
      final asistenciasHoy = await _getAsistenciasHoy();

      return {
        'estudiantes': estudiantesCount,
        'docentes': docentesCount,
        'materias': materiasCount,
        'asistencias_hoy': asistenciasHoy,
        'ultima_actualizacion': DateTime.now(),
      };
    } catch (e) {
      return {
        'estudiantes': 0,
        'docentes': 0,
        'materias': 0,
        'asistencias_hoy': 0,
        'ultima_actualizacion': DateTime.now(),
      };
    }
  }

  Future<int> _getCount(String tableName) async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM $tableName
      ''');
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getAsistenciasHoy() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM asistencias 
        WHERE date(ultima_actualizacion) = date(?)
      ''', [today]);
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Verificar salud del sistema
  Future<Map<String, dynamic>> verificarSaludSistema() async {
    try {
      final tables = ['estudiantes', 'docentes', 'materias', 'carreras', 'asistencias'];
      final results = <String, bool>{};

      for (final table in tables) {
        try {
          final result = await _databaseHelper.rawQuery('''
            SELECT COUNT(*) as count FROM $table LIMIT 1
          ''');
          results[table] = result.isNotEmpty;
        } catch (e) {
          results[table] = false;
        }
      }

      final todasLasTablasFuncionan = results.values.every((v) => v);
      
      return {
        'salud': todasLasTablasFuncionan ? 'Óptima' : 'Con problemas',
        'tablas': results,
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      return {
        'salud': 'Error',
        'tablas': {},
        'timestamp': DateTime.now(),
      };
    }
  }

  Future<void> reintentarCarga() async {
    _error = null;
    await _cargarDatosInicio();
  }
}