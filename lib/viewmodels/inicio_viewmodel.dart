import 'package:flutter/material.dart';
import '../models/inicio_model.dart';
import '../utils/helpers.dart';

class InicioViewModel extends ChangeNotifier {
  InicioModel _model = InicioModel(
    currentDate: DateTime.now(),
    systemStatus: 'Sistema Activo',
  );

  InicioModel get model => _model;

  // Métodos helper para colores
  Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }
}
