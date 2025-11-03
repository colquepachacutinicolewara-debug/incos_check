import 'package:flutter/material.dart';
import '../models/programa_model.dart';

class ProgramasViewModel with ChangeNotifier {
  final List<Programa> _programas = const [
    Programa(nombre: "Secretariado Ejecutivo", iconoNombre: "assignment"),
    Programa(
      nombre: "Comercio Internacional y Administración Aduanera",
      iconoNombre: "public",
    ),
    Programa(nombre: "Contaduría General", iconoNombre: "calculate"),
    Programa(
      nombre: "Administración de Empresas",
      iconoNombre: "business_center",
    ),
    Programa(nombre: "Sistemas Informáticos", iconoNombre: "computer"),
    Programa(nombre: "Idioma Inglés", iconoNombre: "language"),
  ];

  final TextEditingController _searchController = TextEditingController();
  int _expandedIndex = -1;
  List<Programa> _filteredProgramas = [];

  List<Programa> get programas => _programas;
  TextEditingController get searchController => _searchController;
  int get expandedIndex => _expandedIndex;
  List<Programa> get filteredProgramas => _filteredProgramas;

  ProgramasViewModel() {
    _filteredProgramas = _programas;
    _searchController.addListener(_filterProgramas);
  }

  void _filterProgramas() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredProgramas = _programas;
    } else {
      _filteredProgramas = _programas
          .where((programa) => programa.nombre.toLowerCase().contains(query))
          .toList();
    }
    notifyListeners();
  }

  void toggleExpand(int index) {
    if (_expandedIndex == index) {
      _expandedIndex = -1;
    } else {
      _expandedIndex = index;
    }
    notifyListeners();
  }

  int getRealIndex(String nombrePrograma) {
    return _programas.indexWhere(
      (programa) => programa.nombre == nombrePrograma,
    );
  }

  // Método para obtener el icono a partir del nombre
  IconData getIconFromName(String iconName) {
    switch (iconName) {
      case "assignment":
        return Icons.assignment;
      case "public":
        return Icons.public;
      case "calculate":
        return Icons.calculate;
      case "business_center":
        return Icons.business_center;
      case "computer":
        return Icons.computer;
      case "language":
        return Icons.language;
      default:
        return Icons.school; // Icono por defecto
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
