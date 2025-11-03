import 'package:flutter/material.dart';
import 'package:incos_check/utils/data_manager.dart';
import '.././models/turnos_model.dart';

class TurnosViewModel with ChangeNotifier {
  final DataManager _dataManager = DataManager();
  final String tipo;
  final Map<String, dynamic> carrera;

  List<TurnoModel> _turnos = [];
  bool _isLoading = false;

  List<TurnoModel> get turnos => _turnos;
  bool get isLoading => _isLoading;

  TurnosViewModel({required this.tipo, required this.carrera}) {
    _inicializarCarrera();
  }

  void _inicializarCarrera() {
    final carreraId = carrera['id'].toString();

    // Obtener los turnos primero para verificar si la carrera existe
    final turnosData = _dataManager.getTurnos(carreraId);
    _turnos = turnosData
        .map((turnoMap) => TurnoModel.fromMap(turnoMap))
        .toList();

    // Si no hay turnos, significa que es una carrera nueva y debemos inicializarla
    if (_turnos.isEmpty) {
      _dataManager.inicializarCarrera(
        carreraId,
        carrera['nombre'],
        carrera['color'],
      );
      // Volver a cargar los turnos (ahora debería estar inicializada)
      final nuevosTurnos = _dataManager.getTurnos(carreraId);
      _turnos = nuevosTurnos
          .map((turnoMap) => TurnoModel.fromMap(turnoMap))
          .toList();
    }
    notifyListeners();
  }

  void agregarTurno(TurnoModel nuevoTurno) {
    _dataManager.agregarTurno(carrera['id'].toString(), nuevoTurno.toMap());
    _turnos = _dataManager
        .getTurnos(carrera['id'].toString())
        .map((turnoMap) => TurnoModel.fromMap(turnoMap))
        .toList();
    notifyListeners();
  }

  void actualizarTurno(String turnoId, TurnoModel turnoActualizado) {
    _dataManager.actualizarTurno(
      carrera['id'].toString(),
      turnoId,
      turnoActualizado.toMap(),
    );
    _turnos = _dataManager
        .getTurnos(carrera['id'].toString())
        .map((turnoMap) => TurnoModel.fromMap(turnoMap))
        .toList();
    notifyListeners();
  }

  void eliminarTurno(String turnoId) {
    _dataManager.eliminarTurno(carrera['id'].toString(), turnoId);
    _turnos = _dataManager
        .getTurnos(carrera['id'].toString())
        .map((turnoMap) => TurnoModel.fromMap(turnoMap))
        .toList();
    notifyListeners();
  }

  void toggleActivarTurno(TurnoModel turno) {
    final turnoActualizado = turno.copyWith(activo: !turno.activo);
    actualizarTurno(turno.id, turnoActualizado);
  }

  Color parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue; // Color por defecto
    }
  }
}
