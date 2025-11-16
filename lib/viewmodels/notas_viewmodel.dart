//lib/viewmodels/notas_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/nota_asistencia_model.dart';
import '../models/config_notas_model.dart';
import '../models/database_helper.dart';

class NotasViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  List<NotaAsistencia> _notas = [];
  List<NotaAsistencia> _notasFiltradas = [];
  ConfigNotasAsistencia _configuracion = ConfigNotasAsistencia(
    id: 'config_default',
    nombre: 'Configuración Por Defecto',
    puntajeTotal: 10.0,
    reglasCalculo: ConfigNotasAsistencia.reglasPorDefecto,
    fechaCreacion: DateTime.now(),
    fechaActualizacion: DateTime.now(),
  );
  
  bool _isLoading = false;
  String? _error;
  String _filtroBimestre = 'Todos';
  String _filtroEstado = 'Todos'; 
  
  // Nuevo campo para almacenar el ID del Período Activo
  String _periodoActivoId = 'periodo_default'; 

  List<NotaAsistencia> get notas => _notas;
  List<NotaAsistencia> get notasFiltradas => _notasFiltradas;
  ConfigNotasAsistencia get configuracion => _configuracion;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filtroBimestre => _filtroBimestre;
  String get filtroEstado => _filtroEstado;

  NotasViewModel() {
    _cargarConfiguracion();
    _cargarPeriodoActivo();
    cargarNotas();
  }
  
  // 🆕 FUNCIÓN PARA CARGAR EL ID DEL PERÍODO ACTIVO
  Future<void> _cargarPeriodoActivo() async {
    try {
      final periodoId = await _databaseHelper.obtenerPeriodoActivo();
      if (periodoId != null) {
        _periodoActivoId = periodoId;
        print('✅ Período Activo: $_periodoActivoId');
      } else {
        print('⚠️ No se encontró período activo. Usando $_periodoActivoId');
      }
    } catch (e) {
      print('❌ Error cargando período activo: $e');
    }
  }

  Future<void> _cargarConfiguracion() async {
    try {
      final result = await _databaseHelper.obtenerConfiguracionNotasActiva();

      if (result.isNotEmpty) {
        _configuracion = ConfigNotasAsistencia.fromMap(
          Map<String, dynamic>.from(result.first)
        );
        print('✅ Configuración de notas cargada');
      }
    } catch (e) {
      print('❌ Error cargando configuración: $e');
    }
  }

  Future<void> cargarNotas() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _databaseHelper.obtenerTodasLasNotas();

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

  Future<void> calcularNotasBimestre(String bimestreId) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 Calculando notas para bimestre: $bimestreId');

      // 1. OBTENER FECHAS DEL BIMESTRE
      final fechas = await _databaseHelper.obtenerFechasBimestre(bimestreId);

      if (fechas == null) {
        _error = 'Error: No se encontró un rango de fechas válido para el bimestre $bimestreId.';
        notifyListeners();
        return;
      }
      
      final fechaInicio = fechas['inicio']!;
      final fechaFin = fechas['fin']!;

      // 2. OBTENER ESTUDIANTES ACTIVOS
      final estudiantes = await _databaseHelper.obtenerEstudiantesActivos();

      // 3. OBTENER TOTAL HORAS PROGRAMADAS
      final totalHorasProgramadas = 
          await _databaseHelper.obtenerTotalHorasProgramadas(fechaInicio, fechaFin);

      // 4. PARA CADA ESTUDIANTE, CALCULAR SU NOTA
      for (final estudiante in estudiantes) {
        final estudianteId = estudiante['id']?.toString() ?? '';
        
        // Obtener asistencias del estudiante en el bimestre
        final asistencias = await _databaseHelper.obtenerAsistenciasEstudianteEnRango(
          estudianteId, fechaInicio, fechaFin
        );

        int horasAsistidas = 0;
        int horasRetraso = 0;
        int horasFalta = 0;

        for (final asistencia in asistencias) {
          final estado = asistencia['estado']?.toString() ?? '';
          final cantidad = asistencia['cantidad'] as int? ?? 0;

          switch (estado) {
            case 'P': 
              horasAsistidas = cantidad;
              break;
            case 'R': 
              horasRetraso = cantidad;
              break;
            case 'A': 
              horasFalta = cantidad;
              break;
          }
        }

        // Calcular nota
        final notaCalculada = _calcularNota(
          totalHorasProgramadas,
          horasAsistidas,
          horasRetraso,
          horasFalta,
        );

        // Guardar o actualizar nota
        await _guardarNota(
          estudianteId: estudianteId,
          bimestreId: bimestreId,
          totalHorasProgramadas: totalHorasProgramadas,
          horasAsistidas: horasAsistidas,
          horasRetraso: horasRetraso,
          horasFalta: horasFalta,
          notaCalculada: notaCalculada,
        );
      }

      await cargarNotas();
      
      print('✅ Cálculo de notas completado para bimestre: $bimestreId');

    } catch (e) {
      _error = 'Error calculando notas: $e';
      print('❌ Error calculando notas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double _calcularNota(int totalHoras, int asistidas, int retrasos, int faltas) {
    if (totalHoras == 0) return 0.0;
    
    final horasEfectivas = asistidas + (retrasos * 0.5);
    final porcentaje = (horasEfectivas / totalHoras) * 100;
    
    return (porcentaje / 100) * _configuracion.puntajeTotal;
  }

  Future<void> _guardarNota({
    required String estudianteId,
    required String bimestreId,
    required int totalHorasProgramadas,
    required int horasAsistidas,
    required int horasRetraso,
    required int horasFalta,
    required double notaCalculada,
  }) async {
    try {
      final porcentajeAsistencia = totalHorasProgramadas > 0 
          ? (horasAsistidas / totalHorasProgramadas * 100) 
          : 0.0;

      final estado = notaCalculada >= _configuracion.minimoAprobatorio 
          ? 'APROBADO' 
          : 'REPROBADO';

      final notaId = 'nota_${estudianteId}_$bimestreId';

      final notaData = {
        'id': notaId,
        'estudiante_id': estudianteId,
        'materia_id': 'materia_general', // Ajustar según tu estructura
        'periodo_id': _periodoActivoId,
        'bimestre_id': bimestreId,
        'total_horas_programadas': totalHorasProgramadas,
        'horas_asistidas': horasAsistidas,
        'horas_retraso': horasRetraso,
        'horas_falta': horasFalta,
        'porcentaje_asistencia': porcentajeAsistencia,
        'nota_final': notaCalculada,
        'estado': estado,
        'fecha_calculo': DateTime.now(),
      };

      await _databaseHelper.guardarNotaAsistencia(notaData);

    } catch (e) {
      print('❌ Error guardando nota: $e');
      rethrow;
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
      
      bool cumpleEstado = true;
      
      if (_filtroEstado != 'Todos') {
        if (_filtroEstado == 'APROBADO') {
          cumpleEstado = nota.estado == 'APROBADO';
        } else if (_filtroEstado == 'REPROBADO') {
          cumpleEstado = nota.estado == 'REPROBADO';
        } else if (_filtroEstado == 'NS') {
          // NS (No Se Registró) = Nota calculada como 0.0 Y 0 horas programadas.
          cumpleEstado = nota.notaFinal == 0.0 && nota.totalHorasProgramadas == 0;
        }
      }
      
      return cumpleBimestre && cumpleEstado;
    }).toList();
  }

  // Estadísticas generales
  Map<String, dynamic> obtenerEstadisticas() {
    final notasReales = _notas.where((n) => n.totalHorasProgramadas > 0).toList(); 
    final total = notasReales.length;
    final nsNoRegistrado = _notas.length - total;
    
    final aprobados = notasReales.where((n) => n.estado == 'APROBADO').length;
    final reprobados = total - aprobados;
    final promedio = total > 0 
        ? notasReales.map((n) => n.notaFinal).reduce((a, b) => a + b) / total 
        : 0.0;

    return {
      'total': total,
      'aprobados': aprobados,
      'reprobados': reprobados,
      'ns_no_registrado': nsNoRegistrado,
      'promedio': promedio.roundToDouble(),
      'porcentaje_aprobacion': total > 0 ? (aprobados / total * 100).roundToDouble() : 0.0,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : const Color(0xFFF5F5F5);
  }

  Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }
}