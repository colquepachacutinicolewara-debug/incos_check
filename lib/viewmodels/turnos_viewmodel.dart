import 'dart:async';
import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';
import '../models/turnos_model.dart';

class TurnosViewModel with ChangeNotifier {
  final DataRepository _repository;
  final String tipo;
  final Map<String, dynamic> carrera;

  List<TurnoModel> _turnos = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _turnosSubscription;

  List<TurnoModel> get turnos => _turnos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TurnosViewModel({
    required this.tipo,
    required this.carrera,
    required DataRepository repository,
  }) : _repository = repository {
    _inicializarCarrera();
  }

  @override
  void dispose() {
    _turnosSubscription?.cancel();
    super.dispose();
  }

  // ==================== INICIALIZACIÓN MEJORADA ====================
  Future<void> _inicializarCarrera() async {
    final carreraId = carrera['id'].toString();
    _setLoading(true);
    _error = null;

    try {
      // Intentar conectar con Firestore con timeout
      final carreraExists = await _documentExistsWithTimeout(
        'carreras',
        carreraId,
      );

      if (!carreraExists) {
        await _inicializarCarreraEnFirestore(carreraId);
        await _agregarTurnosPorDefecto(carreraId);
      }

      _setupTurnosStream(carreraId);
    } catch (e) {
      _handleError('Error al inicializar carrera: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Método con timeout para evitar esperas infinitas
  Future<bool> _documentExistsWithTimeout(
    String collection,
    String documentId,
  ) async {
    try {
      final task = _repository.documentExists(collection, documentId);
      return await task.timeout(Duration(seconds: 10));
    } on TimeoutException {
      throw Exception('Timeout: No se pudo conectar con Firestore');
    }
  }

  Future<void> _inicializarCarreraEnFirestore(String carreraId) async {
    await _repository.crearCarrera(carreraId, {
      'id': carreraId,
      'nombre': carrera['nombre'],
      'color': carrera['color'],
      'tipo': tipo,
      'turnos': {},
    });
  }

  Future<void> _agregarTurnosPorDefecto(String carreraId) async {
    final turnosPorDefecto = [
      {
        'id': '${carreraId}_manana',
        'nombre': 'Mañana',
        'icon': Icons.wb_sunny.codePoint,
        'horario': '08:00 - 13:00',
        'rangoAsistencia': '07:45 - 08:15',
        'dias': 'Lunes a Viernes',
        'color': '#FFA000',
        'activo': true,
        'niveles': [],
      },
      {
        'id': '${carreraId}_tarde',
        'nombre': 'Tarde',
        'icon': Icons.brightness_6.codePoint,
        'horario': '14:00 - 18:00',
        'rangoAsistencia': '13:45 - 14:15',
        'dias': 'Lunes a Viernes',
        'color': '#FF9800',
        'activo': true,
        'niveles': [],
      },
    ];

    for (final turnoData in turnosPorDefecto) {
      final turnoId = turnoData['id'] as String;
      await _repository.agregarTurno(carreraId, turnoId, turnoData);
    }
  }

  // ==================== STREAM CON RECONEXIÓN ====================
  void _setupTurnosStream(String carreraId) {
    _turnosSubscription?.cancel();

    _turnosSubscription = _repository
        .getCarreraStream(carreraId)
        .listen(
          (documentSnapshot) {
            if (documentSnapshot.exists) {
              final data = documentSnapshot.data() as Map<String, dynamic>?;
              if (data != null && data.containsKey('turnos')) {
                final turnosData =
                    data['turnos'] as Map<String, dynamic>? ?? {};
                _procesarTurnosDesdeFirestore(turnosData);
              } else {
                _turnos = [];
                notifyListeners();
              }
            } else {
              _turnos = [];
              notifyListeners();
            }
          },
          onError: (error) {
            _handleError('Error en conexión con Firestore: $error');
          },
        );
  }

  void _procesarTurnosDesdeFirestore(Map<String, dynamic> turnosData) {
    try {
      final List<TurnoModel> turnosProcesados = [];

      turnosData.forEach((turnoId, turnoMap) {
        try {
          final turnoData = Map<String, dynamic>.from(turnoMap as Map);
          final turno = TurnoModel.fromMap(turnoId, turnoData);
          turnosProcesados.add(turno);
        } catch (e) {
          print('Error procesando turno $turnoId: $e');
        }
      });

      turnosProcesados.sort((a, b) => a.nombre.compareTo(b.nombre));
      _turnos = turnosProcesados;
      notifyListeners();
    } catch (e) {
      _handleError('Error al procesar turnos: $e');
    }
  }

  // ==================== CRUD COMPLETO ====================
  Future<void> agregarTurno(TurnoModel nuevoTurno) async {
    _setLoading(true);
    _error = null;

    try {
      final carreraId = carrera['id'].toString();
      final turnoData = nuevoTurno.toMap();

      await _repository.agregarTurno(carreraId, nuevoTurno.id, turnoData);
    } catch (e) {
      _handleError('Error al agregar turno: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> actualizarTurno(
    String turnoId,
    TurnoModel turnoActualizado,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final carreraId = carrera['id'].toString();
      final turnoData = turnoActualizado.toMap();

      await _repository.actualizarTurno(carreraId, turnoId, turnoData);
    } catch (e) {
      _handleError('Error al actualizar turno: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> eliminarTurno(String turnoId) async {
    _setLoading(true);
    _error = null;

    try {
      final carreraId = carrera['id'].toString();
      await _repository.eliminarTurno(carreraId, turnoId);
    } catch (e) {
      _handleError('Error al eliminar turno: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void toggleActivarTurno(TurnoModel turno) {
    final turnoActualizado = turno.copyWith(activo: !turno.activo);
    actualizarTurno(turno.id, turnoActualizado);
  }

  // ==================== MÉTODOS AUXILIARES ====================
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String error) {
    _error = error;
    _setLoading(false);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> recargarTurnos() async {
    await _inicializarCarrera();
  }

  Color parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  // Generar ID único para nuevo turno
  String generarTurnoId() {
    return '${carrera['id']}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
