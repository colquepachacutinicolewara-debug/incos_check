// PROBLEMA: Modelo no coincide con tu estructura de BD
// SOLUCIÓN: Reemplazar con este código corregido

import 'package:flutter/material.dart';
import '../models/nota_asistencia_model.dart';
import '../models/config_notas_model.dart';
import '../models/database_helper.dart';

class NotasViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  List<NotaAsistencia> _notas = [];
  List<NotaAsistencia> _notasFiltradas = [];
  
  bool _isLoading = false;
  String? _error;
  String _filtroBimestre = 'Todos';
  String _filtroEstado = 'Todos';

  List<NotaAsistencia> get notas => _notas;
  List<NotaAsistencia> get notasFiltradas => _notasFiltradas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filtroBimestre => _filtroBimestre;
  String get filtroEstado => _filtroEstado;

  NotasViewModel() {
    cargarNotas();
  }

  Future<void> cargarNotas() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Usar el método de tu DatabaseHelper
      final result = await _databaseHelper.obtenerNotasAsistenciaPorEstudiante('estudiante_ejemplo', 'periodo_2024');

      _notas = result.map((row) => 
        NotaAsistencia.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      _aplicarFiltros();
      
      print('✅ ${_notas.length} notas cargadas');

    } catch (e) {
      _error = 'Error al cargar notas: $e';
      print('❌ Error cargando notas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🆕 MÉTODO MEJORADO PARA CALCULAR NOTAS
  Future<void> calcularNotasBimestre(String bimestreId) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 Calculando notas para bimestre: $bimestreId');

      // Obtener estudiantes activos
      final estudiantes = await _databaseHelper.rawQuery('''
        SELECT id FROM estudiantes WHERE activo = 1
      ''');

      for (final estudiante in estudiantes) {
        final estudianteId = estudiante['id']?.toString() ?? '';
        
        // Calcular nota usando el método de DatabaseHelper
        final resultado = await _databaseHelper.calcularNotaAsistenciaCompleta(
          estudianteId, 
          'materia_general', 
          'periodo_2024', 
          bimestreId
        );

        print('✅ Nota calculada para $estudianteId: ${resultado['nota_calculada']}');
      }

      await cargarNotas(); // Recargar lista actualizada
      
      print('✅ Cálculo de notas completado para bimestre: $bimestreId');

    } catch (e) {
      _error = 'Error calculando notas: $e';
      print('❌ Error calculando notas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void cambiarFiltroBimestre(String bimestre) {
    _filtroBimestre = bimestre;
    _aplicarFiltros();
    notifyListeners();
  }

  void cambiarFiltroEstado(String estado) {
    _filtroEstado = estado;
    _aplicarFiltros();
    notifyListeners();
  }

  void _aplicarFiltros() {
    _notasFiltradas = _notas.where((nota) {
      final cumpleBimestre = _filtroBimestre == 'Todos' || nota.bimestreId == _filtroBimestre;
      final cumpleEstado = _filtroEstado == 'Todos' || nota.estado == _filtroEstado;
      
      return cumpleBimestre && cumpleEstado;
    }).toList();
  }

  // 🆕 ESTADÍSTICAS MEJORADAS
  Map<String, dynamic> obtenerEstadisticas() {
    final total = _notas.length;
    final aprobados = _notas.where((n) => n.estaAprobado).length;
    final reprobados = total - aprobados;
    final promedio = total > 0 
        ? _notas.map((n) => n.notaCalculada).reduce((a, b) => a + b) / total 
        : 0.0;

    return {
      'total': total,
      'aprobados': aprobados,
      'reprobados': reprobados,
      'promedio': promedio.roundToDouble(),
      'porcentaje_aprobacion': total > 0 ? (aprobados / total * 100).roundToDouble() : 0.0,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}