// viewmodels/notas_viewmodel.dart - VERSIÓN CORREGIDA
import 'package:flutter/material.dart';
import '../models/nota_asistencia_model.dart';
import '../models/config_notas_model.dart';
import '../models/database_helper.dart';

class NotasViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  List<NotaAsistencia> _notas = [];
  List<NotaAsistencia> _notasFiltradas = [];
  ConfigNotasAsistencia? _configuracion;
  
  bool _isLoading = false;
  String? _error;
  String _filtroBimestre = 'Todos';
  String _filtroEstado = 'Todos';

  List<NotaAsistencia> get notas => _notas;
  List<NotaAsistencia> get notasFiltradas => _notasFiltradas;
  ConfigNotasAsistencia? get configuracion => _configuracion;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filtroBimestre => _filtroBimestre;
  String get filtroEstado => _filtroEstado;

  NotasViewModel() {
    _cargarConfiguracion();
    cargarNotas();
  }

  Future<void> _cargarConfiguracion() async {
    try {
      final result = await _databaseHelper.obtenerConfiguracionNotasAsistenciaActiva();
      if (result != null) {
        _configuracion = ConfigNotasAsistencia.fromMap(result);
      }
    } catch (e) {
      print('⚠️ Error cargando configuración: $e');
    }
  }

  Future<void> cargarNotas() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Cargar todas las notas (ajustar según tu lógica)
      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM notas_asistencia 
        ORDER BY estudiante_id, materia_id, bimestre_id
      ''');

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

  // 🆕 CALCULAR NOTAS PARA UN BIMESTRE
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
        
        try {
          // Calcular nota usando el método de DatabaseHelper
          await _databaseHelper.calcularNotaAsistencia(
            estudianteId, 
            'materia_general', // Ajustar según necesidad
            'periodo_2024',    // Ajustar según necesidad  
            bimestreId
          );
          
          print('✅ Nota calculada para: $estudianteId');
        } catch (e) {
          print('⚠️ Error calculando nota para $estudianteId: $e');
        }
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

  // 🆕 CALCULAR NOTA INDIVIDUAL
  Future<void> calcularNotaIndividual({
    required String estudianteId,
    required String materiaId,
    required String bimestreId,
  }) async {
    try {
      await _databaseHelper.calcularNotaAsistencia(
        estudianteId, materiaId, 'periodo_2024', bimestreId
      );
      
      await cargarNotas(); // Recargar lista
      print('✅ Nota individual calculada: $estudianteId');

    } catch (e) {
      _error = 'Error calculando nota individual: $e';
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

  // 🆕 OBTENER NOTAS POR ESTUDIANTE
  List<NotaAsistencia> obtenerNotasPorEstudiante(String estudianteId) {
    return _notas.where((nota) => nota.estudianteId == estudianteId).toList();
  }

  // 🆕 OBTENER NOTAS POR MATERIA
  List<NotaAsistencia> obtenerNotasPorMateria(String materiaId) {
    return _notas.where((nota) => nota.materiaId == materiaId).toList();
  }

  // 🆕 ESTADÍSTICAS MEJORADAS
  Map<String, dynamic> obtenerEstadisticas() {
    final total = _notas.length;
    final aprobados = _notas.where((n) => n.estaAprobado).length;
    final reprobados = _notas.where((n) => n.estaCalculado && !n.estaAprobado).length;
    final pendientes = _notas.where((n) => !n.estaCalculado).length;
    
    final promedio = _notas.isNotEmpty && _notas.any((n) => n.estaCalculado)
        ? _notas.where((n) => n.estaCalculado)
            .map((n) => n.notaCalculada)
            .reduce((a, b) => a + b) / _notas.where((n) => n.estaCalculado).length
        : 0.0;

    return {
      'total': total,
      'aprobados': aprobados,
      'reprobados': reprobados,
      'pendientes': pendientes,
      'promedio': promedio.roundToDouble(),
      'porcentaje_aprobacion': total > 0 ? (aprobados / total * 100).roundToDouble() : 0.0,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}