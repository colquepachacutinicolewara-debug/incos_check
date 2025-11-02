// carreras_viewmodel.dart
import 'package:flutter/material.dart';
import '../../models/carrera_model.dart';

class CarreraViewModel extends ChangeNotifier {
  List<Carrera> _carreras = [
    Carrera(
      id: 1,
      nombre: 'Sistemas Informáticos',
      color: '#1565C0',
      icon: Icons.computer,
      activa: true,
      seleccionada: true, // La primera carrera está seleccionada por defecto
    ),
  ];

  List<Carrera> get carreras => _carreras;

  List<Carrera> get carrerasActivas =>
      _carreras.where((carrera) => carrera.activa).toList();

  Carrera? get carreraSeleccionada => _carreras.firstWhere(
    (carrera) => carrera.seleccionada,
    orElse: () => _carreras.isNotEmpty
        ? _carreras.first
        : Carrera(id: 0, nombre: '', color: '', icon: Icons.school),
  );

  void agregarCarrera(String nombre, String color, IconData icono) {
    final nuevaCarrera = Carrera(
      id: DateTime.now().millisecondsSinceEpoch,
      nombre: nombre,
      color: color,
      icon: icono,
      activa: true,
      seleccionada:
          false, // Las nuevas carreras no están seleccionadas por defecto
    );

    _carreras.add(nuevaCarrera);
    notifyListeners();
  }

  void editarCarrera(
    Carrera carrera,
    String nombre,
    String color,
    IconData icono,
  ) {
    final index = _carreras.indexWhere((c) => c.id == carrera.id);
    if (index != -1) {
      _carreras[index] = carrera.copyWith(
        nombre: nombre,
        color: color,
        icon: icono,
      );
      notifyListeners();
    }
  }

  void toggleActivarCarrera(Carrera carrera) {
    final index = _carreras.indexWhere((c) => c.id == carrera.id);
    if (index != -1) {
      _carreras[index] = carrera.copyWith(activa: !carrera.activa);
      notifyListeners();
    }
  }

  void eliminarCarrera(Carrera carrera) {
    final bool eraSeleccionada = carrera.seleccionada;
    _carreras.removeWhere((c) => c.id == carrera.id);

    // Si eliminamos la carrera seleccionada, seleccionar la primera disponible
    if (eraSeleccionada && _carreras.isNotEmpty) {
      _carreras.first = _carreras.first.copyWith(seleccionada: true);
    }

    notifyListeners();
  }

  void seleccionarCarrera(Carrera carrera) {
    // Deseleccionar todas las carreras
    for (int i = 0; i < _carreras.length; i++) {
      _carreras[i] = _carreras[i].copyWith(seleccionada: false);
    }

    // Seleccionar la carrera específica
    final index = _carreras.indexWhere((c) => c.id == carrera.id);
    if (index != -1) {
      _carreras[index] = carrera.copyWith(seleccionada: true);
    }

    notifyListeners();
  }

  List<String> obtenerNombresCarrerasActivas() {
    return carrerasActivas.map((carrera) => carrera.nombre).toList();
  }

  String obtenerNombreCarreraSeleccionada() {
    return carreraSeleccionada?.nombre ?? '';
  }

  Color parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}
