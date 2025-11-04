import 'package:flutter/material.dart';
import '../models/historial_asistencia_model.dart';

class HistorialAsistenciaViewModel with ChangeNotifier {
  FiltroHistorial _filtro = FiltroHistorial(
    mostrarTodasMaterias: false,
    queryBusqueda: '',
  );

  // Getters
  bool get mostrarTodasMaterias => _filtro.mostrarTodasMaterias;
  String get queryBusqueda => _filtro.queryBusqueda;
  FiltroHistorial get filtro => _filtro;

  // Métodos para actualizar el estado
  void toggleMostrarTodasMaterias() {
    _filtro = _filtro.copyWith(
      mostrarTodasMaterias: !_filtro.mostrarTodasMaterias,
    );
    notifyListeners();
  }

  void setQueryBusqueda(String query) {
    _filtro = _filtro.copyWith(queryBusqueda: query);
    notifyListeners();
  }

  void limpiarFiltros() {
    _filtro = FiltroHistorial(mostrarTodasMaterias: false, queryBusqueda: '');
    notifyListeners();
  }

  // Método para obtener texto de filtros aplicados
  String obtenerTextoFiltros(int anioSeleccionado) {
    List<String> filtros = [];

    if (_filtro.mostrarTodasMaterias) {
      filtros.add('Todas las materias');
    } else {
      filtros.add('$anioSeleccionado° Año');
    }

    if (_filtro.queryBusqueda.isNotEmpty) {
      filtros.add('Búsqueda: "${_filtro.queryBusqueda}"');
    }

    return 'Filtros: ${filtros.join(' • ')}';
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

  Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color getFilterBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  Color getSearchBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color getDropdownBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }
}
