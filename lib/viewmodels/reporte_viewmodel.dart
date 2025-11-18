// viewmodels/reportes_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/reporte_generado_model.dart';

class ReportesViewModel with ChangeNotifier {
  List<ReporteGenerado> _reportes = [];
  List<ReporteGenerado> _reportesFiltrados = [];
  bool _isLoading = false;
  String? _error;
  String _filtroTipo = 'Todos';
  String _filtroFormato = 'Todos';

  // Listas simuladas para datos de prueba
  final List<Map<String, dynamic>> _alumnosSimulados = [
    {'id': '1', 'nombre': 'Juan Pérez', 'matricula': '2024001'},
    {'id': '2', 'nombre': 'María García', 'matricula': '2024002'},
    {'id': '3', 'nombre': 'Carlos López', 'matricula': '2024003'},
  ];

  final List<Map<String, dynamic>> _asistenciasSimuladas = [
    {'alumno_id': '1', 'fecha': '2024-01-15', 'asistio': true, 'materia_id': 'mat1'},
    {'alumno_id': '1', 'fecha': '2024-01-16', 'asistio': false, 'materia_id': 'mat1'},
    {'alumno_id': '2', 'fecha': '2024-01-15', 'asistio': true, 'materia_id': 'mat1'},
    {'alumno_id': '3', 'fecha': '2024-01-15', 'asistio': true, 'materia_id': 'mat1'},
  ];

  List<ReporteGenerado> get reportes => _reportes;
  List<ReporteGenerado> get reportesFiltrados => _reportesFiltrados;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filtroTipo => _filtroTipo;
  String get filtroFormato => _filtroFormato;

  ReportesViewModel() {
    _cargarReportesIniciales();
  }

  // Cargar reportes de ejemplo al iniciar
  void _cargarReportesIniciales() {
    _reportes = [
      ReporteGenerado(
        id: '1',
        tipoReporte: 'ASISTENCIA_BIMESTRAL',
        titulo: 'Reporte de Asistencia - Bimestre 1',
        periodoId: 'periodo_2024',
        materiaId: 'mat1',
        bimestreId: 'bim1',
        formato: 'PDF',
        parametros: {'bimestre': '1', 'materia': 'Matemáticas'},
        rutaArchivo: 'reports/reporte1.pdf',
        fechaGeneracion: DateTime(2024, 1, 20),
        usuarioGenerador: 'admin',
        tamanoBytes: 1024,
      ),
      ReporteGenerado(
        id: '2',
        tipoReporte: 'ASISTENCIA_ESTADISTICAS',
        titulo: 'Estadísticas de Asistencia General',
        periodoId: 'periodo_2024',
        materiaId: 'mat1',
        bimestreId: 'bim1',
        formato: 'EXCEL',
        parametros: {'periodo': '2024', 'tipo': 'estadisticas'},
        rutaArchivo: 'reports/estadisticas.xlsx',
        fechaGeneracion: DateTime(2024, 1, 18),
        usuarioGenerador: 'profesor',
        tamanoBytes: 2048,
      ),
    ];
    _aplicarFiltros();
  }

  Future<void> cargarReportes() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 1000));

      // En una app real, aquí harías una llamada a API o base de datos
      print('✅ ${_reportes.length} reportes cargados');

    } catch (e) {
      _error = 'Error al cargar reportes: $e';
      print('❌ Error cargando reportes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // GENERAR REPORTE DE ASISTENCIA BIMESTRAL
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

      // Simular procesamiento
      await Future.delayed(const Duration(seconds: 2));

      // Generar datos del reporte simulados
      final datosReporte = await _generarDatosReporteBimestral(bimestreId, materiaId);

      // Crear objeto de reporte
      final reporteId = 'reporte_${DateTime.now().millisecondsSinceEpoch}';
      final reporte = ReporteGenerado(
        id: reporteId,
        tipoReporte: 'ASISTENCIA_BIMESTRAL',
        titulo: 'Reporte de Asistencia Bimestral - $bimestreId',
        periodoId: 'periodo_2024',
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

      // Agregar a la lista
      _reportes.insert(0, reporte);
      _aplicarFiltros();

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

  // GENERAR REPORTE ESTADÍSTICO
  Future<Map<String, dynamic>> generarReporteEstadistico({
    required String periodoId,
    required String materiaId,
    required String usuarioGenerador,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simular procesamiento
      await Future.delayed(const Duration(seconds: 2));

      final datosEstadisticas = await _generarDatosEstadisticos(periodoId, materiaId);

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

      _reportes.insert(0, reporte);
      _aplicarFiltros();

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

  // ELIMINAR REPORTE
  Future<bool> eliminarReporte(String reporteId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simular delay
      await Future.delayed(const Duration(milliseconds: 500));

      _reportes.removeWhere((reporte) => reporte.id == reporteId);
      _aplicarFiltros();

      _isLoading = false;
      notifyListeners();

      print('✅ Reporte eliminado: $reporteId');
      return true;

    } catch (e) {
      _isLoading = false;
      _error = 'Error eliminando reporte: $e';
      notifyListeners();
      return false;
    }
  }

  // MÉTODOS PRIVADOS PARA GENERAR DATOS SIMULADOS

  Future<Map<String, dynamic>> _generarDatosReporteBimestral(String bimestreId, String materiaId) async {
    // Simular datos de asistencia bimestral
    final asistenciasBimestre = _asistenciasSimuladas.where((asistencia) {
      return asistencia['materia_id'] == materiaId;
    }).toList();

    final resumenAlumnos = _alumnosSimulados.map((alumno) {
      final asistenciasAlumno = asistenciasBimestre.where(
        (a) => a['alumno_id'] == alumno['id']
      ).toList();
      
      final totalClases = asistenciasAlumno.length;
      final asistencias = asistenciasAlumno.where((a) => a['asistio'] == true).length;
      final faltas = totalClases - asistencias;
      final porcentaje = totalClases > 0 ? (asistencias / totalClases * 100) : 0;

      return {
        'alumno': alumno,
        'asistencias': asistencias,
        'faltas': faltas,
        'porcentaje_asistencia': porcentaje.toStringAsFixed(1),
        'total_clases': totalClases,
      };
    }).toList();

    return {
      'bimestre': bimestreId,
      'materia': 'Matemáticas', // Simulado
      'fecha_generacion': DateTime.now().toIso8601String(),
      'total_alumnos': _alumnosSimulados.length,
      'total_clases': asistenciasBimestre.length,
      'asistencia_promedio': '85%',
      'resumen_alumnos': resumenAlumnos,
    };
  }

  Future<Map<String, dynamic>> _generarDatosEstadisticos(String periodoId, String materiaId) async {
    // Simular estadísticas detalladas
    final totalAlumnos = _alumnosSimulados.length;
    final totalAsistencias = _asistenciasSimuladas.where((a) => a['asistio'] == true).length;
    final totalFaltas = _asistenciasSimuladas.where((a) => a['asistio'] == false).length;
    final porcentajeAsistencia = totalAsistencias / (totalAsistencias + totalFaltas) * 100;

    // Distribución por días de la semana
    final distribucionDias = {
      'Lunes': 25,
      'Martes': 30,
      'Miércoles': 22,
      'Jueves': 28,
      'Viernes': 20,
    };

    // Tendencia mensual
    final tendenciaMensual = {
      'Enero': 85,
      'Febrero': 82,
      'Marzo': 88,
      'Abril': 90,
    };

    return {
      'periodo': periodoId,
      'materia': 'Matemáticas',
      'fecha_generacion': DateTime.now().toIso8601String(),
      'metricas_generales': {
        'total_alumnos': totalAlumnos,
        'total_asistencias': totalAsistencias,
        'total_faltas': totalFaltas,
        'porcentaje_asistencia': porcentajeAsistencia.toStringAsFixed(1),
        'alumnos_regular': (totalAlumnos * 0.7).round(),
        'alumnos_irregular': (totalAlumnos * 0.3).round(),
      },
      'distribucion_dias': distribucionDias,
      'tendencia_mensual': tendenciaMensual,
      'alumnos_destacados': _alumnosSimulados.take(2).map((a) => {
        'alumno': a,
        'porcentaje_asistencia': '95%',
        'asistencias_consecutivas': 15,
      }).toList(),
    };
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

  // OBTENER ESTADÍSTICAS DE REPORTES
  Map<String, dynamic> obtenerEstadisticasReportes() {
    final total = _reportes.length;
    final pdfCount = _reportes.where((r) => r.esPDF).length;
    final excelCount = _reportes.where((r) => r.esExcel).length;
    
    final ultimaSemana = _reportes.where((r) => 
      r.fechaGeneracion.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).length;

    return {
      'total': total,
      'pdf': pdfCount,
      'excel': excelCount,
      'ultima_semana': ultimaSemana,
      'tamano_total': _reportes.fold(0, (sum, r) => sum + (r.tamanoBytes ?? 0)),
      'ultimo_reporte': _reportes.isNotEmpty ? _reportes.first.fechaGeneracion : null,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Método para simular la descarga de un reporte
  Future<bool> descargarReporte(String reporteId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simular descarga
      await Future.delayed(const Duration(seconds: 2));

      final reporte = _reportes.firstWhere((r) => r.id == reporteId);
      print('📥 Descargando reporte: ${reporte.titulo}');

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _isLoading = false;
      _error = 'Error descargando reporte: $e';
      notifyListeners();
      return false;
    }
  }

  // Método para buscar reportes por título
  void buscarReportes(String query) {
    if (query.isEmpty) {
      _aplicarFiltros();
    } else {
      _reportesFiltrados = _reportes.where((reporte) =>
        reporte.titulo.toLowerCase().contains(query.toLowerCase()) ||
        reporte.tipoReporte.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }
}