// viewmodels/reportes_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/reporte_generado_model.dart';
import '../models/database_helper.dart';

class ReportesViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  List<ReporteGenerado> _reportes = [];
  List<ReporteGenerado> _reportesFiltrados = [];
  bool _isLoading = false;
  String? _error;
  String _filtroTipo = 'Todos';
  String _filtroFormato = 'Todos';

  List<ReporteGenerado> get reportes => _reportes;
  List<ReporteGenerado> get reportesFiltrados => _reportesFiltrados;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filtroTipo => _filtroTipo;
  String get filtroFormato => _filtroFormato;

  ReportesViewModel() {
    cargarReportes();
  }

  Future<void> cargarReportes() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _databaseHelper.obtenerHistorialReportes();

      _reportes = result.map((row) => 
        ReporteGenerado.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      _aplicarFiltros();
      
      print('✅ ${_reportes.length} reportes cargados');

    } catch (e) {
      _error = 'Error al cargar reportes: $e';
      print('❌ Error cargando reportes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🆕 GENERAR REPORTE DE ASISTENCIA BIMESTRAL
  Future<Map<String, dynamic>> generarReporteAsistenciaBimestral({
    required String bimestreId,
    required String materiaId,
    required String formato,
    required String usuarioGenerador,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 Generando reporte bimestral: $bimestreId - $materiaId');

      // Generar datos del reporte
      final datosReporte = await _databaseHelper.generarReporteAsistenciaBimestral(
        bimestreId, materiaId, formato
      );

      // Crear objeto de reporte
      final reporteId = 'reporte_${DateTime.now().millisecondsSinceEpoch}';
      final reporte = ReporteGenerado(
        id: reporteId,
        tipoReporte: 'ASISTENCIA_BIMESTRAL',
        titulo: 'Reporte de Asistencia Bimestral - $bimestreId',
        periodoId: 'periodo_2024', // Ajustar según tu lógica
        materiaId: materiaId,
        bimestreId: bimestreId,
        formato: formato,
        parametros: {
          'bimestre_id': bimestreId,
          'materia_id': materiaId,
          'formato': formato,
          'fecha_generacion': DateTime.now().toIso8601String(),
        },
        rutaArchivo: 'reports/$reporteId.${formato.toLowerCase()}',
        fechaGeneracion: DateTime.now(),
        usuarioGenerador: usuarioGenerador,
        tamanoBytes: datosReporte.toString().length,
      );

      // Guardar en base de datos
      await _databaseHelper.guardarReporteGenerado(reporte.toMap());

      // Recargar lista
      await cargarReportes();

      _isLoading = false;
      notifyListeners();

      return {
        'success': true,
        'reporte': reporte,
        'datos': datosReporte,
        'mensaje': 'Reporte generado exitosamente'
      };

    } catch (e) {
      _isLoading = false;
      _error = 'Error generando reporte: $e';
      notifyListeners();
      
      return {
        'success': false,
        'error': 'Error generando reporte: $e'
      };
    }
  }

  // 🆕 GENERAR REPORTE ESTADÍSTICO
  Future<Map<String, dynamic>> generarReporteEstadistico({
    required String periodoId,
    required String materiaId,
    required String usuarioGenerador,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final datosEstadisticas = await _databaseHelper.generarReporteEstadistico(
        periodoId, materiaId
      );

      final reporteId = 'reporte_estadistico_${DateTime.now().millisecondsSinceEpoch}';
      final reporte = ReporteGenerado(
        id: reporteId,
        tipoReporte: 'ASISTENCIA_ESTADISTICAS',
        titulo: 'Reporte Estadístico de Asistencia',
        periodoId: periodoId,
        materiaId: materiaId,
        formato: 'PDF',
        parametros: {
          'periodo_id': periodoId,
          'materia_id': materiaId,
          'tipo': 'estadisticas',
        },
        rutaArchivo: 'reports/$reporteId.pdf',
        fechaGeneracion: DateTime.now(),
        usuarioGenerador: usuarioGenerador,
        tamanoBytes: datosEstadisticas.toString().length,
      );

      await _databaseHelper.guardarReporteGenerado(reporte.toMap());
      await cargarReportes();

      _isLoading = false;
      notifyListeners();

      return {
        'success': true,
        'reporte': reporte,
        'estadisticas': datosEstadisticas,
      };

    } catch (e) {
      _isLoading = false;
      _error = 'Error generando reporte estadístico: $e';
      notifyListeners();
      
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  // 🆕 ELIMINAR REPORTE
  Future<bool> eliminarReporte(String reporteId) async {
    try {
      await _databaseHelper.rawDelete(
        'DELETE FROM reportes_generados WHERE id = ?',
        [reporteId]
      );

      await cargarReportes();
      print('✅ Reporte eliminado: $reporteId');
      return true;

    } catch (e) {
      _error = 'Error eliminando reporte: $e';
      notifyListeners();
      return false;
    }
  }

  void cambiarFiltroTipo(String tipo) {
    _filtroTipo = tipo;
    _aplicarFiltros();
    notifyListeners();
  }

  void cambiarFiltroFormato(String formato) {
    _filtroFormato = formato;
    _aplicarFiltros();
    notifyListeners();
  }

  void _aplicarFiltros() {
    _reportesFiltrados = _reportes.where((reporte) {
      final cumpleTipo = _filtroTipo == 'Todos' || reporte.tipoReporte == _filtroTipo;
      final cumpleFormato = _filtroFormato == 'Todos' || reporte.formato == _filtroFormato;
      
      return cumpleTipo && cumpleFormato;
    }).toList();
  }

  // 🆕 OBTENER ESTADÍSTICAS DE REPORTES
  Map<String, dynamic> obtenerEstadisticasReportes() {
    final total = _reportes.length;
    final pdfCount = _reportes.where((r) => r.esPDF).length;
    final excelCount = _reportes.where((r) => r.esExcel).length;
    final completados = _reportes.where((r) => r.estaCompletado).length;
    
    final ultimaSemana = _reportes.where((r) => 
      r.fechaGeneracion.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).length;

    return {
      'total': total,
      'pdf': pdfCount,
      'excel': excelCount,
      'completados': completados,
      'ultima_semana': ultimaSemana,
      'tamano_total': _reportes.fold(0, (sum, r) => sum + (r.tamanoBytes ?? 0)),
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}