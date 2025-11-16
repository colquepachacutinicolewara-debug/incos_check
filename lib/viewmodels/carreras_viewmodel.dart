// viewmodels/carreras_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/carrera_model.dart';
import '../models/database_helper.dart';

class CarrerasViewModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance; // ✅ Cambio aquí
  List<CarreraModel> _carreras = [];
  bool _isLoading = false;
  String? _error;

  CarrerasViewModel() { // ✅ Constructor sin parámetros
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

  Future<void> _loadCarreras() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM carreras ORDER BY nombre
      ''');

      _carreras = result.map((row) => 
        CarreraModel.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar carreras: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reintentarCarga() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    await _loadCarreras();
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

      final carreraId = 'carrera_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();

      await _databaseHelper.rawInsert('''
        INSERT INTO carreras (id, nombre, color, icon_code_point, activa, 
        fecha_creacion, fecha_actualizacion)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', [
        carreraId,
        nombre.trim(),
        color,
        icono.codePoint,
        1,
        now,
        now
      ]);

      await _loadCarreras(); // Recargar la lista
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

      await _databaseHelper.rawUpdate('''
        UPDATE carreras 
        SET nombre = ?, color = ?, icon_code_point = ?, fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        nombre.trim(),
        color,
        icono.codePoint,
        DateTime.now().toIso8601String(),
        id
      ]);

      await _loadCarreras(); // Recargar la lista
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

      await _databaseHelper.rawUpdate('''
        UPDATE carreras 
        SET activa = ?, fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        nuevoEstado ? 1 : 0,
        DateTime.now().toIso8601String(),
        id
      ]);

      await _loadCarreras(); // Recargar la lista
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

      await _databaseHelper.rawDelete('''
        DELETE FROM carreras WHERE id = ?
      ''', [id]);

      await _loadCarreras(); // Recargar la lista
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
      return Colors.blue;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}