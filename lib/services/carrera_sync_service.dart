// services/carrera_sync_service.dart
import 'package:flutter/material.dart';

class CarreraSyncService with ChangeNotifier {
  static final CarreraSyncService _instance = CarreraSyncService._internal();
  factory CarreraSyncService() => _instance;
  CarreraSyncService._internal();

  List<String> _carreras = [];
  String _carreraSeleccionada = 'Sistemas Informáticos';

  List<String> get carreras => _carreras;
  String get carreraSeleccionada => _carreraSeleccionada;

  void actualizarCarreras(List<String> nuevasCarreras) {
    _carreras = nuevasCarreras.toSet().toList();
    notifyListeners();
  }

  void seleccionarCarrera(String carrera) {
    if (_carreras.contains(carrera)) {
      _carreraSeleccionada = carrera;
      notifyListeners();
    }
  }
}