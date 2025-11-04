import 'package:flutter/material.dart';
import '../models/asistencia_model.dart';

class AsistenciaViewModel with ChangeNotifier {
  EstadoAsistencia _estado = EstadoAsistencia(
    asistenciaRegistradaHoy: false,
    datosAsistencia: [
      AsistenciaData('Lun', 85),
      AsistenciaData('Mar', 92),
      AsistenciaData('Mié', 78),
      AsistenciaData('Jue', 95),
      AsistenciaData('Vie', 88),
      AsistenciaData('Sáb', 70),
      AsistenciaData('Dom', 65),
    ],
  );

  // Getters
  bool get asistenciaRegistradaHoy => _estado.asistenciaRegistradaHoy;
  List<AsistenciaData> get datosAsistencia => _estado.datosAsistencia;
  EstadoAsistencia get estado => _estado;

  // Métodos para actualizar el estado
  void registrarAsistencia() {
    _estado = _estado.copyWith(asistenciaRegistradaHoy: true);
    notifyListeners();
  }

  void reiniciarAsistencia() {
    _estado = _estado.copyWith(asistenciaRegistradaHoy: false);
    notifyListeners();
  }

  void actualizarDatosAsistencia(List<AsistenciaData> nuevosDatos) {
    _estado = _estado.copyWith(datosAsistencia: nuevosDatos);
    notifyListeners();
  }

  // Métodos de utilidad para colores
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : const Color(0xFFF5F5F5);
  }

  Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }

  Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color getAppBarColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }

  Color getChartTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }
}
