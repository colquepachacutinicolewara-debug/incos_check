// viewmodels/gestion_viewmodel.dart
import 'package:flutter/material.dart';

class GestionViewModel extends ChangeNotifier {
  // Listas vacías
  final List<Map<String, String>> _cursosMaterias = [];
  final List<Map<String, String>> _estudiantes = [];

  // Controladores para búsqueda
  final TextEditingController _searchController = TextEditingController();
  
  // Controladores para CURSOS
  final TextEditingController _cursoController = TextEditingController();
  final TextEditingController _materiaController = TextEditingController();
  final TextEditingController _carreraController = TextEditingController();
  final TextEditingController _nivelController = TextEditingController();
  final TextEditingController _turnoController = TextEditingController();

  // Controladores para ESTUDIANTES
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _paternoController = TextEditingController();
  final TextEditingController _maternoController = TextEditingController();
  final TextEditingController _cursoEstudianteController = TextEditingController();
  final TextEditingController _materiaEstudianteController = TextEditingController();
  final TextEditingController _carreraEstudianteController = TextEditingController();
  final TextEditingController _nivelEstudianteController = TextEditingController();
  final TextEditingController _turnoEstudianteController = TextEditingController();

  // Índice expandido
  int _expandedIndex = -1;

  // GETTERS públicos para los controladores
  // Cursos
  TextEditingController get cursoController => _cursoController;
  TextEditingController get materiaController => _materiaController;
  TextEditingController get carreraController => _carreraController;
  TextEditingController get nivelController => _nivelController;
  TextEditingController get turnoController => _turnoController;
  
  // Estudiantes
  TextEditingController get nombreController => _nombreController;
  TextEditingController get paternoController => _paternoController;
  TextEditingController get maternoController => _maternoController;
  TextEditingController get cursoEstudianteController => _cursoEstudianteController;
  TextEditingController get materiaEstudianteController => _materiaEstudianteController;
  TextEditingController get carreraEstudianteController => _carreraEstudianteController;
  TextEditingController get nivelEstudianteController => _nivelEstudianteController;
  TextEditingController get turnoEstudianteController => _turnoEstudianteController;

  // Getters existentes
  List<Map<String, String>> get cursosMaterias => _cursosMaterias;
  List<Map<String, String>> get estudiantes => _estudiantes;
  TextEditingController get searchController => _searchController;
  int get expandedIndex => _expandedIndex;

  // Lista filtrada de estudiantes
  List<Map<String, String>> get filteredEstudiantes {
    if (_searchController.text.isEmpty) {
      return _estudiantes;
    }
    return _estudiantes.where((estudiante) {
      return estudiante['nombre']!.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          estudiante['paterno']!.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          estudiante['curso']!.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
    }).toList();
  }

  // Función para agregar curso y materia
  void agregarCursoMateria() {
    if (_cursoController.text.isNotEmpty && 
        _materiaController.text.isNotEmpty && 
        _carreraController.text.isNotEmpty) {
      _cursosMaterias.add({
        'curso': _cursoController.text,
        'materia': _materiaController.text,
        'carrera': _carreraController.text,
        'nivel': _nivelController.text,
        'turno': _turnoController.text,
      });
      // Limpiar todos los campos de curso
      _cursoController.clear();
      _materiaController.clear();
      _carreraController.clear();
      _nivelController.clear();
      _turnoController.clear();
      notifyListeners();
    }
  }

  // Función para registrar estudiante
  void registrarEstudiante() {
    if (_nombreController.text.isNotEmpty && 
        _paternoController.text.isNotEmpty &&
        _cursoEstudianteController.text.isNotEmpty) {
      _estudiantes.add({
        'nombre': _nombreController.text,
        'paterno': _paternoController.text,
        'materno': _maternoController.text,
        'curso': _cursoEstudianteController.text,
        'materia': _materiaEstudianteController.text,
        'carrera': _carreraEstudianteController.text,
        'nivel': _nivelEstudianteController.text,
        'turno': _turnoEstudianteController.text,
      });
      // Limpiar todos los campos de estudiante
      _nombreController.clear();
      _paternoController.clear();
      _maternoController.clear();
      _cursoEstudianteController.clear();
      _materiaEstudianteController.clear();
      _carreraEstudianteController.clear();
      _nivelEstudianteController.clear();
      _turnoEstudianteController.clear();
      notifyListeners();
    }
  }

  // Función para eliminar estudiante
  void eliminarEstudiante(int index) {
    if (index >= 0 && index < _estudiantes.length) {
      _estudiantes.removeAt(index);
      notifyListeners();
    }
  }

  // Función para eliminar curso
  void eliminarCurso(int index) {
    if (index >= 0 && index < _cursosMaterias.length) {
      _cursosMaterias.removeAt(index);
      notifyListeners();
    }
  }

  // Función para expandir/contraer secciones
  void toggleExpand(int index) {
    if (_expandedIndex == index) {
      _expandedIndex = -1;
    } else {
      _expandedIndex = index;
    }
    notifyListeners();
  }

  // Obtener ícono según la sección
  IconData getIconFromIndex(int index) {
    switch (index) {
      case 0:
        return Icons.school;
      case 1:
        return Icons.people;
      case 2:
        return Icons.app_registration;
      default:
        return Icons.category;
    }
  }

  @override
  void dispose() {
    // Dispose de todos los controladores
    _searchController.dispose();
    
    // Cursos
    _cursoController.dispose();
    _materiaController.dispose();
    _carreraController.dispose();
    _nivelController.dispose();
    _turnoController.dispose();
    
    // Estudiantes
    _nombreController.dispose();
    _paternoController.dispose();
    _maternoController.dispose();
    _cursoEstudianteController.dispose();
    _materiaEstudianteController.dispose();
    _carreraEstudianteController.dispose();
    _nivelEstudianteController.dispose();
    _turnoEstudianteController.dispose();
    
    super.dispose();
  }
}