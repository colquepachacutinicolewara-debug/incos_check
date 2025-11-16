//lib/viewmodels/horario_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/horario_clase_model.dart';
import '../models/database_helper.dart';

class HorarioViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  List<HorarioClase> _horarios = [];
  List<HorarioClase> _horariosFiltrados = [];
  bool _isLoading = false;
  String? _error;
  String _filtroDia = 'Todos';
  String _filtroPeriodo = 'Todos';

  List<HorarioClase> get horarios => _horarios;
  List<HorarioClase> get horariosFiltrados => _horariosFiltrados;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filtroDia => _filtroDia;
  String get filtroPeriodo => _filtroPeriodo;

  // Días de la semana
  final List<String> diasSemana = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'
  ];

  HorarioViewModel() {
    cargarHorarios();
  }

  Future<void> cargarHorarios() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _databaseHelper.obtenerHorariosOrdenados();

      _horarios = result.map((row) => 
        HorarioClase.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      _aplicarFiltros();
      
      print('✅ ${_horarios.length} horarios cargados');

    } catch (e) {
      _error = 'Error al cargar horarios: $e';
      print('❌ Error cargando horarios: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> agregarHorario(HorarioClase horario) async {
    try {
      // Verificar si ya existe un horario en el mismo día y período
      final existe = await _databaseHelper.existeHorarioEnMismoDiaYPeriodo(
        horario.diaSemana, 
        horario.periodoNumero, 
        horario.paraleloId
      );

      if (existe) {
        _error = 'Ya existe un horario en ese día y período para el paralelo';
        notifyListeners();
        return false;
      }

      await _databaseHelper.insertarHorario({
        'id': horario.id,
        'materia_id': horario.materiaId,
        'paralelo_id': horario.paraleloId,
        'docente_id': horario.docenteId,
        'dia_semana': horario.diaSemana,
        'periodo_numero': horario.periodoNumero,
        'hora_inicio': horario.horaInicio,
        'hora_fin': horario.horaFin,
        'activo': horario.activo,
        'fecha_creacion': horario.fechaCreacion,
      });

      await cargarHorarios();
      return true;

    } catch (e) {
      _error = 'Error al agregar horario: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarHorario(HorarioClase horario) async {
    try {
      await _databaseHelper.actualizarHorario({
        'id': horario.id,
        'materia_id': horario.materiaId,
        'paralelo_id': horario.paraleloId,
        'docente_id': horario.docenteId,
        'dia_semana': horario.diaSemana,
        'periodo_numero': horario.periodoNumero,
        'hora_inicio': horario.horaInicio,
        'hora_fin': horario.horaFin,
        'activo': horario.activo,
      });

      await cargarHorarios();
      return true;

    } catch (e) {
      _error = 'Error al actualizar horario: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarHorario(String id) async {
    try {
      await _databaseHelper.eliminarHorario(id);
      await cargarHorarios();
      return true;

    } catch (e) {
      _error = 'Error al eliminar horario: $e';
      notifyListeners();
      return false;
    }
  }

  void cambiarFiltroDia(String dia) {
    _filtroDia = dia;
    _aplicarFiltros();
    notifyListeners();
  }

  void cambiarFiltroPeriodo(String periodo) {
    _filtroPeriodo = periodo;
    _aplicarFiltros();
    notifyListeners();
  }

  void _aplicarFiltros() {
    _horariosFiltrados = _horarios.where((horario) {
      final cumpleDia = _filtroDia == 'Todos' || horario.diaSemana == _filtroDia;
      final cumplePeriodo = _filtroPeriodo == 'Todos' || 
          horario.periodoNumero.toString() == _filtroPeriodo;
      
      return cumpleDia && cumplePeriodo;
    }).toList();
  }

  Future<List<HorarioClase>> obtenerHorariosPorDia(String dia) async {
    try {
      final result = await _databaseHelper.obtenerHorariosPorDia(dia);
      return result.map((row) => 
        HorarioClase.fromMap(Map<String, dynamic>.from(row))
      ).toList();
    } catch (e) {
      print('❌ Error obteniendo horarios por día: $e');
      return [];
    }
  }

  List<HorarioClase> obtenerHorariosDeHoy() {
    final hoy = _obtenerDiaActual();
    return _horarios.where((h) => h.diaSemana == hoy).toList();
  }

  String _obtenerDiaActual() {
    final now = DateTime.now();
    final dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    return dias[now.weekday - 1];
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Métodos para colores según el tema
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

  Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}