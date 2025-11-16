//lib/viewmodels/asistencia_diaria_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/asistencia_diaria_model.dart';
import '../models/horario_clase_model.dart';
import '../models/estudiante_model.dart';
import '../models/database_helper.dart';

class AsistenciaDiariaViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  List<AsistenciaDiaria> _asistencias = [];
  List<HorarioClase> _horariosDelDia = [];
  List<Estudiante> _estudiantes = [];
  bool _isLoading = false;
  String? _error;
  DateTime _fechaSeleccionada = DateTime.now();
  String _materiaSeleccionada = '';

  List<AsistenciaDiaria> get asistencias => _asistencias;
  List<HorarioClase> get horariosDelDia => _horariosDelDia;
  List<Estudiante> get estudiantes => _estudiantes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get fechaSeleccionada => _fechaSeleccionada;
  String get materiaSeleccionada => _materiaSeleccionada;

  AsistenciaDiariaViewModel() {
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    await cargarHorariosDelDia();
    await cargarEstudiantes();
    await cargarAsistenciasDelDia();
  }

  Future<void> cargarHorariosDelDia() async {
    try {
      final diaActual = _obtenerDiaActual();
      
      final result = await _databaseHelper.obtenerHorariosPorDia(diaActual);

      _horariosDelDia = result.map((row) => 
        HorarioClase.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      print('✅ ${_horariosDelDia.length} horarios para hoy');

    } catch (e) {
      print('❌ Error cargando horarios del día: $e');
    }
  }

  Future<void> cargarEstudiantes() async {
    try {
      final result = await _databaseHelper.obtenerEstudiantesOrdenados();

      _estudiantes = result.map((row) => 
        Estudiante.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      print('✅ ${_estudiantes.length} estudiantes cargados');

    } catch (e) {
      print('❌ Error cargando estudiantes: $e');
    }
  }

  Future<void> cargarAsistenciasDelDia() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final fechaStr = _fechaSeleccionada.toIso8601String().split('T')[0];
      
      final result = await _databaseHelper.obtenerAsistenciasPorFecha(fechaStr);

      _asistencias = result.map((row) => 
        AsistenciaDiaria.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      print('✅ ${_asistencias.length} asistencias cargadas para $fechaStr');

    } catch (e) {
      _error = 'Error cargando asistencias: $e';
      print('❌ Error cargando asistencias: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registrarAsistencia({
    required String estudianteId,
    required String materiaId,
    required String horarioClaseId,
    required int periodoNumero,
    required String estado,
    int minutosRetraso = 0,
    String? observaciones,
    String? usuarioRegistro,
  }) async {
    try {
      final fechaStr = _fechaSeleccionada.toIso8601String().split('T')[0];
      final now = DateTime.now();

      // Verificar si ya existe registro
      final existe = await _databaseHelper.existeAsistenciaRegistrada(
        estudianteId, materiaId, fechaStr, periodoNumero
      );
      
      final asistenciaData = {
        'estudiante_id': estudianteId,
        'materia_id': materiaId,
        'fecha': fechaStr,
        'periodo_numero': periodoNumero,
        'estado': estado,
        'minutos_retraso': minutosRetraso,
        'observaciones': observaciones,
        'usuario_registro': usuarioRegistro,
      };

      if (existe) {
        // Actualizar registro existente
        await _databaseHelper.actualizarAsistenciaDiaria(asistenciaData);
      } else {
        // Crear nuevo registro
        asistenciaData['id'] = 'asist_${estudianteId}_${fechaStr}_$periodoNumero';
        asistenciaData['horario_clase_id'] = horarioClaseId;
        asistenciaData['fecha_creacion'] = now;
        
        await _databaseHelper.insertarAsistenciaDiaria(asistenciaData);
      }

      // Recargar asistencias
      await cargarAsistenciasDelDia();

      print('✅ Asistencia registrada: $estudianteId - $estado');

    } catch (e) {
      _error = 'Error registrando asistencia: $e';
      notifyListeners();
      print('❌ Error registrando asistencia: $e');
    }
  }

  Future<void> cambiarFecha(DateTime nuevaFecha) async {
    _fechaSeleccionada = nuevaFecha;
    await cargarAsistenciasDelDia();
  }

  void cambiarMateria(String materiaId) {
    _materiaSeleccionada = materiaId;
    notifyListeners();
  }

  String _obtenerDiaActual() {
    final now = DateTime.now();
    final dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    return dias[now.weekday - 1];
  }

  // Obtener asistencias por período
  List<AsistenciaDiaria> obtenerAsistenciasPorPeriodo(int periodoNumero) {
    return _asistencias.where((a) => a.periodoNumero == periodoNumero).toList();
  }

  // Obtener asistencia de un estudiante específico
  AsistenciaDiaria? obtenerAsistenciaEstudiante(String estudianteId, int periodoNumero) {
    try {
      return _asistencias.firstWhere((a) => 
        a.estudianteId == estudianteId && a.periodoNumero == periodoNumero
      );
    } catch (e) {
      return null;
    }
  }

  // Estadísticas del día
  Map<String, dynamic> obtenerEstadisticasDia() {
    final totalRegistros = _asistencias.length;
    final presentes = _asistencias.where((a) => a.estaPresente).length;
    final ausentes = _asistencias.where((a) => a.estaAusente).length;
    final retrasos = _asistencias.where((a) => a.estaRetraso).length;
    
    final porcentajeAsistencia = totalRegistros > 0 
        ? (presentes / totalRegistros * 100) 
        : 0;

    return {
      'total': totalRegistros,
      'presentes': presentes,
      'ausentes': ausentes,
      'retrasos': retrasos,
      'porcentaje': porcentajeAsistencia.roundToDouble(),
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Métodos para colores
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : const Color(0xFFF5F5F5);
  }

  Color getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.green.shade700
        : Colors.green;
  }
}