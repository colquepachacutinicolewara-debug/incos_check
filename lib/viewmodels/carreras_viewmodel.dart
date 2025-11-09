// viewmodels/carreras_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/carrera_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/data_repository.dart';

class CarrerasViewModel extends ChangeNotifier {
  final DataRepository _repository;
  List<CarreraModel> _carreras = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _carrerasSubscription;

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

  @override
  void dispose() {
    _carrerasSubscription?.cancel();
    super.dispose();
  }

  void _loadCarreras() {
    _isLoading = true;
    notifyListeners();

    _carrerasSubscription?.cancel();
    
    try {
      _carrerasSubscription = _repository.getCarrerasStream().listen(
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
          final errorStr = error.toString();
          if (errorStr.contains('unavailable')) {
            _error =
                '⚠ El servicio de Firebase no está disponible temporalmente.\nPor favor, verifica tu conexión a internet y reintenta.';
          } else {
            _error = 'Error al cargar carreras: $error';
          }

          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Error inesperado al inicializar carreras: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reintentarCarga() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    _loadCarreras();
  }

  Future<void> agregarCarrera(
    String nombre,
    String color,
    IconData icono,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validación
      if (nombre.isEmpty) {
        throw Exception('El nombre de la carrera no puede estar vacío');
      }

      final carreraData = {
        'nombre': nombre.trim(),
        'color': color,
        'icon': _iconDataToString(icono),
        'activa': true,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      await _repository.addCarrera(carreraData);
    } catch (e) {
      _error = 'Error al agregar carrera: ${e.toString()}';
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

      // Validación
      if (nombre.isEmpty) {
        throw Exception('El nombre de la carrera no puede estar vacío');
      }

      final updateData = {
        'nombre': nombre.trim(),
        'color': color,
        'icon': _iconDataToString(icono),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      await _repository.updateCarrera(id, updateData);
    } catch (e) {
      _error = 'Error al editar carrera: ${e.toString()}';
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
    } catch (e) {
      _error = 'Error al cambiar estado de carrera: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> eliminarCarrera(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deleteCarrera(id);
    } catch (e) {
      _error = 'Error al eliminar carrera: ${e.toString()}';
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

  // 🔧 Métodos utilitarios
  static Color parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue; // Color por defecto
    }
  }

  String _iconDataToString(IconData icon) {
    return '${icon.codePoint}:${icon.fontFamily ?? "MaterialIcons"}';
  }

  IconData _stringToIconData(String iconString) {
    try {
      final parts = iconString.split(':');
      final codePoint = int.parse(parts[0]);
      final fontFamily = parts.length > 1 ? parts[1] : 'MaterialIcons';
      return IconData(codePoint, fontFamily: fontFamily);
    } catch (e) {
      return Icons.school; // Icono por defecto
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}