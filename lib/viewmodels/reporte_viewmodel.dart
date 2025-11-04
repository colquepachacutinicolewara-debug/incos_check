import 'package:flutter/material.dart';
import '../models/reporte_model.dart';

class ReporteViewModel with ChangeNotifier {
  ReporteModel _model = const ReporteModel();

  ReporteModel get model => _model;

  // Método para mostrar notificación
  void showNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Te notificaremos cuando los reportes estén disponibles",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            Colors.blue, // Usaremos AppColors.primary desde la vista
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Método para actualizar progreso si es necesario en el futuro
  void updateProgress(double newProgress) {
    _model = ReporteModel(progress: newProgress);
    notifyListeners();
  }
}
