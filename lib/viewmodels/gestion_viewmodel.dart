// viewmodels/gestion_viewmodel.dart
import 'package:flutter/material.dart';

class GestionViewModel extends ChangeNotifier {
  // Listas principales
  final List<Map<String, dynamic>> _carreras = [];
  final List<Map<String, dynamic>> _niveles = [];
  final List<Map<String, dynamic>> _paralelos = [];
  final List<Map<String, dynamic>> _estudiantes = [];
  final List<Map<String, dynamic>> _docentes = [];
  final List<Map<String, dynamic>> _turnos = [];

  // Controladores
  final TextEditingController _searchController = TextEditingController();
  
  // Controladores para Carreras
  final TextEditingController _nombreCarreraController = TextEditingController();
  final TextEditingController _colorCarreraController = TextEditingController();
  
  // Controladores para Niveles
  final TextEditingController _nombreNivelController = TextEditingController();
  
  // Controladores para Paralelos
  final TextEditingController _nombreParaleloController = TextEditingController();
  
  // Controladores para Estudiantes
  final TextEditingController _nombreEstudianteController = TextEditingController();
  final TextEditingController _apellidoPaternoController = TextEditingController();
  final TextEditingController _apellidoMaternoController = TextEditingController();
  final TextEditingController _ciController = TextEditingController();

  // Navegación
  String _currentScreen = 'carreras';
  Map<String, dynamic>? _selectedCarrera;
  Map<String, dynamic>? _selectedNivel;
  Map<String, dynamic>? _selectedParalelo;

  // Getters
  List<Map<String, dynamic>> get carreras => _carreras;
  List<Map<String, dynamic>> get niveles => _niveles;
  List<Map<String, dynamic>> get paralelos => _paralelos;
  List<Map<String, dynamic>> get estudiantes => _estudiantes;
  List<Map<String, dynamic>> get docentes => _docentes;
  List<Map<String, dynamic>> get turnos => _turnos;
  
  TextEditingController get searchController => _searchController;
  String get currentScreen => _currentScreen;
  Map<String, dynamic>? get selectedCarrera => _selectedCarrera;
  Map<String, dynamic>? get selectedNivel => _selectedNivel;
  Map<String, dynamic>? get selectedParalelo => _selectedParalelo;

  // Getters para controladores
  TextEditingController get nombreCarreraController => _nombreCarreraController;
  TextEditingController get colorCarreraController => _colorCarreraController;
  TextEditingController get nombreNivelController => _nombreNivelController;
  TextEditingController get nombreParaleloController => _nombreParaleloController;
  TextEditingController get nombreEstudianteController => _nombreEstudianteController;
  TextEditingController get apellidoPaternoController => _apellidoPaternoController;
  TextEditingController get apellidoMaternoController => _apellidoMaternoController;
  TextEditingController get ciController => _ciController;

  // ========== NAVEGACIÓN ==========
  void goToCarreras() {
    _currentScreen = 'carreras';
    _selectedCarrera = null;
    _selectedNivel = null;
    _selectedParalelo = null;
    notifyListeners();
  }

  void goToNiveles(Map<String, dynamic> carrera) {
    _currentScreen = 'niveles';
    _selectedCarrera = carrera;
    notifyListeners();
  }

  void goToParalelos(Map<String, dynamic> nivel) {
    _currentScreen = 'paralelos';
    _selectedNivel = nivel;
    notifyListeners();
  }

  void goToEstudiantes(Map<String, dynamic> paralelo) {
    _currentScreen = 'estudiantes';
    _selectedParalelo = paralelo;
    notifyListeners();
  }

  // ========== CRUD CARRERAS ==========
  void agregarCarrera() {
    if (_nombreCarreraController.text.isNotEmpty) {
      _carreras.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'nombre': _nombreCarreraController.text,
        'color': _colorCarreraController.text.isNotEmpty 
            ? _colorCarreraController.text 
            : '#1565C0', // Azul por defecto
        'fechaCreacion': DateTime.now(),
      });
      _nombreCarreraController.clear();
      _colorCarreraController.clear();
      notifyListeners();
    }
  }

  void eliminarCarrera(int index) {
    if (index >= 0 && index < _carreras.length) {
      _carreras.removeAt(index);
      notifyListeners();
    }
  }

  // ========== CRUD NIVELES ==========
  void agregarNivel() {
    if (_nombreNivelController.text.isNotEmpty && _selectedCarrera != null) {
      _niveles.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'nombre': _nombreNivelController.text,
        'carreraId': _selectedCarrera!['id'],
        'carreraNombre': _selectedCarrera!['nombre'],
        'fechaCreacion': DateTime.now(),
      });
      _nombreNivelController.clear();
      notifyListeners();
    }
  }

  void eliminarNivel(int index) {
    if (index >= 0 && index < _niveles.length) {
      _niveles.removeAt(index);
      notifyListeners();
    }
  }

  // ========== CRUD PARALELOS ==========
  void agregarParalelo() {
    if (_nombreParaleloController.text.isNotEmpty && _selectedNivel != null) {
      _paralelos.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'nombre': _nombreParaleloController.text,
        'nivelId': _selectedNivel!['id'],
        'nivelNombre': _selectedNivel!['nombre'],
        'carreraNombre': _selectedCarrera!['nombre'],
        'fechaCreacion': DateTime.now(),
      });
      _nombreParaleloController.clear();
      notifyListeners();
    }
  }

  void eliminarParalelo(int index) {
    if (index >= 0 && index < _paralelos.length) {
      _paralelos.removeAt(index);
      notifyListeners();
    }
  }

  // ========== CRUD ESTUDIANTES ==========
  void agregarEstudiante() {
    if (_nombreEstudianteController.text.isNotEmpty &&
        _apellidoPaternoController.text.isNotEmpty &&
        _apellidoMaternoController.text.isNotEmpty &&
        _ciController.text.isNotEmpty &&
        _selectedParalelo != null) {
      
      _estudiantes.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'nombre': _nombreEstudianteController.text,
        'apellidoPaterno': _apellidoPaternoController.text,
        'apellidoMaterno': _apellidoMaternoController.text,
        'ci': _ciController.text,
        'paraleloId': _selectedParalelo!['id'],
        'paraleloNombre': _selectedParalelo!['nombre'],
        'nivelNombre': _selectedNivel!['nombre'],
        'carreraNombre': _selectedCarrera!['nombre'],
        'fechaRegistro': DateTime.now(),
      });
      
      // Limpiar formulario
      _nombreEstudianteController.clear();
      _apellidoPaternoController.clear();
      _apellidoMaternoController.clear();
      _ciController.clear();
      notifyListeners();
    }
  }

  void eliminarEstudiante(int index) {
    if (index >= 0 && index < _estudiantes.length) {
      _estudiantes.removeAt(index);
      notifyListeners();
    }
  }

  // ========== FILTROS ==========
  List<Map<String, dynamic>> getNivelesPorCarrera(int carreraId) {
    return _niveles.where((nivel) => nivel['carreraId'] == carreraId).toList();
  }

  List<Map<String, dynamic>> getParalelosPorNivel(int nivelId) {
    return _paralelos.where((paralelo) => paralelo['nivelId'] == nivelId).toList();
  }

  List<Map<String, dynamic>> getEstudiantesPorParalelo(int paraleloId) {
    return _estudiantes.where((estudiante) => estudiante['paraleloId'] == paraleloId).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nombreCarreraController.dispose();
    _colorCarreraController.dispose();
    _nombreNivelController.dispose();
    _nombreParaleloController.dispose();
    _nombreEstudianteController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _ciController.dispose();
    super.dispose();
  }
}