// viewmodels/gestion_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/gestion_model.dart';

class GestionViewModel extends ChangeNotifier {
  // Estado
  GestionEstado _estado = GestionEstado(
    carreraSeleccionada: 'Sistemas Informáticos',
    carreras: ['Sistemas Informáticos'],
  );

  // Configuración de carreras predefinidas
  final Map<String, CarreraConfig> _carrerasConfig = {
    'Sistemas Informáticos': CarreraConfig(
      id: 1,
      nombre: 'Sistemas Informáticos',
      color: '#1565C0',
      icon: Icons.computer,
      activa: true,
    ),
    'Idioma Inglés': CarreraConfig(
      id: 2,
      nombre: 'Idioma Inglés',
      color: '#F44336',
      icon: Icons.language,
      activa: true,
    ),
  };

  // Getters
  GestionEstado get estado => _estado;
  Map<String, CarreraConfig> get carrerasConfig => _carrerasConfig;

  String get carreraSeleccionada => _estado.carreraSeleccionada;
  List<String> get carreras => _estado.carreras;

  // Métodos para actualizar el estado
  void seleccionarCarrera(String carrera) {
    _estado = _estado.copyWith(carreraSeleccionada: carrera);
    notifyListeners();
  }

  void actualizarCarreras(List<String> nuevasCarreras) {
    _estado = _estado.copyWith(carreras: nuevasCarreras);

    // Si la carrera seleccionada ya no existe, seleccionar la primera disponible
    if (!nuevasCarreras.contains(_estado.carreraSeleccionada) &&
        nuevasCarreras.isNotEmpty) {
      _estado = _estado.copyWith(carreraSeleccionada: nuevasCarreras.first);
    }

    notifyListeners();
  }

  // Método para obtener configuración de carrera
  CarreraConfig getCarreraConfig(String carrera) {
    return _carrerasConfig[carrera] ??
        CarreraConfig(
          id: DateTime.now().millisecondsSinceEpoch,
          nombre: carrera,
          color: '#9C27B0',
          icon: Icons.school,
          activa: true,
        );
  }

  // Funciones para obtener colores según el tema
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors
              .grey
              .shade100; // Asumiendo que AppColors.background es gris claro
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

  Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color getDropdownBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }
}
