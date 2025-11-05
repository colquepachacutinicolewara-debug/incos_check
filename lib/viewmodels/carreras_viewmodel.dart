import 'package:flutter/material.dart';
import '../models/carrera_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/data_repository.dart';

class CarrerasViewModel extends ChangeNotifier {
  final DataRepository _repository;
  List<CarreraModel> _carreras = [];
  bool _isLoading = false;
  String? _error;

  CarrerasViewModel(this._repository) {
    _loadCarreras();
  }

  List<CarreraModel> get carreras => _carreras;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CarreraModel> get carrerasActivas {
    return _carreras.where((carrera) => carrera.activa).toList();
  }

  List<String> get nombresCarrerasActivas {
    return carrerasActivas.map((carrera) => carrera.nombre).toList();
  }

  void _loadCarreras() {
    _isLoading = true;
    notifyListeners();

    // Escuchar cambios en tiempo real de Firestore
    _repository.getCarrerasStream().listen(
      (snapshot) {
        _carreras = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return CarreraModel.fromFirestore(doc.id, data);
        }).toList();

        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _error = 'Error al cargar carreras: $error';
        notifyListeners();
      },
    );
  }

  Future<void> agregarCarrera(
    String nombre,
    String color,
    IconData icono,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final carreraData = {
        'nombre': nombre,
        'color': color,
        'icon': _iconDataToString(icono),
        'activa': true,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      await _repository.addCarrera(carreraData);

      // El stream se actualizará automáticamente
    } catch (e) {
      _error = 'Error al agregar carrera: $e';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editarCarrera(
    String id,
    String nombre,
    String color,
    IconData icono,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updateData = {
        'nombre': nombre,
        'color': color,
        'icon': _iconDataToString(icono),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      await _repository.updateCarrera(id, updateData);

      // El stream se actualizará automáticamente
    } catch (e) {
      _error = 'Error al editar carrera: $e';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleActivarCarrera(String id) async {
    try {
      final carrera = _carreras.firstWhere((c) => c.id == id);
      final nuevoEstado = !carrera.activa;

      final updateData = {
        'activa': nuevoEstado,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      await _repository.updateCarrera(id, updateData);

      // El stream se actualizará automáticamente
    } catch (e) {
      _error = 'Error al cambiar estado de carrera: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> eliminarCarrera(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deleteCarrera(id);

      // El stream se actualizará automáticamente
    } catch (e) {
      _error = 'Error al eliminar carrera: $e';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CarreraModel? obtenerCarreraPorId(String id) {
    try {
      return _carreras.firstWhere((carrera) => carrera.id == id);
    } catch (e) {
      return null;
    }
  }

  // Métodos de utilidad
  static Color parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue; // Color por defecto
    }
  }

  String _iconDataToString(IconData icon) {
    return icon.codePoint.toString();
  }

  IconData _stringToIconData(String iconString) {
    return IconData(int.parse(iconString), fontFamily: 'MaterialIcons');
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
