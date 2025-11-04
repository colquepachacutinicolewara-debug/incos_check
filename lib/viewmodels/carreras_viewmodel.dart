import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/carrera_model.dart';
import '../repositories/data_repository.dart';

class CarrerasViewModel with ChangeNotifier {
  final DataRepository _repository;

  CarrerasViewModel(this._repository);

  List<CarreraModel> _carreras = [];
  bool _loading = false;
  String _error = '';
  Stream<QuerySnapshot>? _carrerasStream;

  // Getters
  List<CarreraModel> get carreras => _carreras;
  bool get loading => _loading;
  String get error => _error;
  List<CarreraModel> get carrerasActivas {
    return _carreras.where((carrera) => carrera.activa).toList();
  }

  // Inicializar stream de carreras
  void initializeCarrerasStream() {
    _carrerasStream = _repository.getCarrerasStream();
    _carrerasStream?.listen(
      (snapshot) {
        _carreras = _parseCarrerasFromSnapshot(snapshot);
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error al cargar carreras: $error';
        notifyListeners();
      },
    );
  }

  // Parsear carreras desde Firestore
  List<CarreraModel> _parseCarrerasFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return CarreraModel.fromFirestore(doc.id, data);
    }).toList();
  }

  // Agregar carrera
  Future<void> agregarCarrera(
    String nombre,
    String color,
    IconData icono,
  ) async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      final nuevaCarrera = {
        'nombre': nombre,
        'color': color,
        'iconCode': icono.codePoint,
        'activa': true,
        'fechaCreacion': FieldValue.serverTimestamp(),
      };

      await _repository.addCarrera(nuevaCarrera);
    } catch (e) {
      _error = 'Error al agregar carrera: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Editar carrera
  Future<void> editarCarrera(
    String id,
    String nombre,
    String color,
    IconData icono,
  ) async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      final datosActualizados = {
        'nombre': nombre,
        'color': color,
        'iconCode': icono.codePoint,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      await _repository.updateCarrera(id, datosActualizados);
    } catch (e) {
      _error = 'Error al editar carrera: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Activar/desactivar carrera
  Future<void> toggleActivarCarrera(String id, bool activa) async {
    try {
      await _repository.updateCarrera(id, {
        'activa': !activa,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _error = 'Error al cambiar estado de carrera: $e';
      notifyListeners();
    }
  }

  // Eliminar carrera
  Future<void> eliminarCarrera(String id) async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      await _repository.deleteCarrera(id);
    } catch (e) {
      _error = 'Error al eliminar carrera: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Obtener carrera por ID
  CarreraModel? obtenerCarreraPorId(String id) {
    try {
      return _carreras.firstWhere((carrera) => carrera.id == id);
    } catch (e) {
      return null;
    }
  }

  // Nombres de carreras activas
  List<String> get nombresCarrerasActivas {
    return carrerasActivas.map((carrera) => carrera.nombre).toList();
  }

  // Métodos de utilidad
  static Color parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  static IconData getIconFromCode(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }
}
