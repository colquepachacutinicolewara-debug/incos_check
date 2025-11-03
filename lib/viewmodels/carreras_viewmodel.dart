import 'package:flutter/material.dart';
import '../models/carrera_model.dart';

class CarrerasViewModel extends ChangeNotifier {
  List<CarreraModel> _carreras = [
    CarreraModel(
      id: 1,
      nombre: 'Sistemas Informáticos',
      color: '#1565C0',
      icon: Icons.computer,
      activa: true,
    ),
  ];

  List<CarreraModel> get carreras => _carreras;

  List<CarreraModel> get carrerasActivas {
    return _carreras.where((carrera) => carrera.activa).toList();
  }

  void agregarCarrera(String nombre, String color, IconData icono) {
    final nuevaCarrera = CarreraModel(
      id: DateTime.now().millisecondsSinceEpoch,
      nombre: nombre,
      color: color,
      icon: icono,
      activa: true,
    );

    _carreras.add(nuevaCarrera);
    notifyListeners();
  }

  void editarCarrera(int id, String nombre, String color, IconData icono) {
    final index = _carreras.indexWhere((carrera) => carrera.id == id);
    if (index != -1) {
      _carreras[index] = _carreras[index].copyWith(
        nombre: nombre,
        color: color,
        icon: icono,
      );
      notifyListeners();
    }
  }

  void toggleActivarCarrera(int id) {
    final index = _carreras.indexWhere((carrera) => carrera.id == id);
    if (index != -1) {
      _carreras[index] = _carreras[index].copyWith(
        activa: !_carreras[index].activa,
      );
      notifyListeners();
    }
  }

  void eliminarCarrera(int id) {
    _carreras.removeWhere((carrera) => carrera.id == id);
    notifyListeners();
  }

  CarreraModel? obtenerCarreraPorId(int id) {
    try {
      return _carreras.firstWhere((carrera) => carrera.id == id);
    } catch (e) {
      return null;
    }
  }

  List<String> get nombresCarrerasActivas {
    return carrerasActivas.map((carrera) => carrera.nombre).toList();
  }

  // Métodos de utilidad
  static Color parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue; // Color por defecto
    }
  }
}
