import 'package:flutter/material.dart';
import '../models/carrera_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/data_repository.dart';

class CarreraViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DataRepository _dataRepository; // Tu repositorio existente

  List<Carrera> _carreras = [];
  bool _isLoading = false;
  String? _error;

  List<Carrera> get carreras => _carreras;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CarreraViewModel(this._dataRepository);

  Future<void> cargarCarreras() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final querySnapshot = await _firestore.collection('carreras').get();

      _carreras = querySnapshot.docs.map((doc) {
        return Carrera.fromMap({'id': doc.id, ...doc.data()});
      }).toList();

      // Si no hay carreras en Firestore, usar datos locales
      if (_carreras.isEmpty) {
        _carreras = [
          Carrera(
            id: '1',
            nombre: 'Sistemas Informáticos',
            color: '#1565C0',
            icon: Icons.computer,
            activa: true,
          ),
        ];
      }
    } catch (e) {
      _error = 'Error al cargar carreras: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> agregarCarrera(Carrera carrera) async {
    try {
      _isLoading = true;
      notifyListeners();

      final docRef = await _firestore
          .collection('carreras')
          .add(carrera.toMap());

      final nuevaCarrera = carrera.copyWith(id: docRef.id);
      _carreras.add(nuevaCarrera);

      notifyListeners();
    } catch (e) {
      _error = 'Error al agregar carrera: $e';
      notifyListeners();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> actualizarCarrera(Carrera carrera) async {
    try {
      await _firestore
          .collection('carreras')
          .doc(carrera.id)
          .update(carrera.toMap());

      final index = _carreras.indexWhere((c) => c.id == carrera.id);
      if (index != -1) {
        _carreras[index] = carrera;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al actualizar carrera: $e';
      notifyListeners();
      throw e;
    }
  }

  Future<void> eliminarCarrera(String id) async {
    try {
      await _firestore.collection('carreras').doc(id).delete();
      _carreras.removeWhere((carrera) => carrera.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar carrera: $e';
      notifyListeners();
      throw e;
    }
  }

  Future<void> toggleActivarCarrera(Carrera carrera) async {
    final carreraActualizada = carrera.copyWith(activa: !carrera.activa);
    await actualizarCarrera(carreraActualizada);
  }

  List<String> get nombresCarrerasActivas {
    return _carreras
        .where((carrera) => carrera.activa)
        .map((carrera) => carrera.nombre)
        .toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
