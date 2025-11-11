import 'package:flutter/material.dart';
import '../models/inicio_model.dart';
import '../utils/helpers.dart';

class InicioViewModel extends ChangeNotifier {
  InicioModel _model = InicioModel(
    currentDate: DateTime.now(),
    systemStatus: 'Sistema Activo',
  );

  InicioModel get model => _model;

  // SOLO lógica de negocio, NO colores
  void updateTime() {
    _model = InicioModel(
      currentDate: DateTime.now(),
      systemStatus: 'Sistema Activo',
    );
    notifyListeners();
  }
}