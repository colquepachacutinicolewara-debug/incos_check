// viewmodels/estudiantes_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/estudiante_model.dart';

class EstudiantesViewModel with ChangeNotifier {
  // Lista de estudiantes
  List<Estudiante> _estudiantes = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _filterCurso = '3ro "B"';
  String _filterCarrera = 'Sistemas Informáticos';
  String _searchQuery = '';

  // Getters
  List<Estudiante> get estudiantes => _estudiantes;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get filterCurso => _filterCurso;
  String get filterCarrera => _filterCarrera;
  String get searchQuery => _searchQuery;

  // Estudiantes filtrados
  List<Estudiante> get estudiantesFiltrados {
    var filtered = _estudiantes;

    // Filtrar por curso
    if (_filterCurso.isNotEmpty) {
      filtered = filtered.where((e) => e.curso == _filterCurso).toList();
    }

    // Filtrar por carrera
    if (_filterCarrera.isNotEmpty) {
      filtered = filtered.where((e) => e.carrera == _filterCarrera).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) =>
          e.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.apellidos.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.ci.contains(_searchQuery)).toList();
    }

    return filtered;
  }

  // RFM3-003: Agregar estudiante
  Future<bool> agregarEstudiante({
    required String nombre,
    required String apellidos,
    required String ci,
    required String carrera,
    required String curso,
  }) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      // Validar datos
      if (nombre.isEmpty || apellidos.isEmpty || ci.isEmpty) {
        _errorMessage = 'Todos los campos son obligatorios';
        _setLoading(false);
        return false;
      }

      // Verificar si ya existe el CI
      if (_estudiantes.any((e) => e.ci == ci)) {
        _errorMessage = 'Ya existe un estudiante con este CI';
        _setLoading(false);
        return false;
      }

      // Crear nuevo estudiante
      final nuevoEstudiante = Estudiante(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre.trim(),
        apellidos: apellidos.trim(),
        ci: ci.trim(),
        carrera: carrera,
        curso: curso,
        fechaRegistro: DateTime.now(),
      );

      // Agregar a la lista
      _estudiantes.add(nuevoEstudiante);
      
      _setLoading(false);
      notifyListeners();
      
      return true;

    } catch (e) {
      _errorMessage = 'Error al agregar estudiante: $e';
      _setLoading(false);
      return false;
    }
  }

  // RFM3-003: Editar estudiante
  Future<bool> editarEstudiante({
    required String id,
    required String nombre,
    required String apellidos,
    required String ci,
    required String carrera,
    required String curso,
    bool? activo,
  }) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      // Buscar estudiante
      final index = _estudiantes.indexWhere((e) => e.id == id);
      if (index == -1) {
        _errorMessage = 'Estudiante no encontrado';
        _setLoading(false);
        return false;
      }

      // Verificar si el CI ya existe en otro estudiante
      if (_estudiantes.any((e) => e.ci == ci && e.id != id)) {
        _errorMessage = 'Ya existe otro estudiante con este CI';
        _setLoading(false);
        return false;
      }

      // Actualizar estudiante
      _estudiantes[index] = _estudiantes[index].copyWith(
        nombre: nombre.trim(),
        apellidos: apellidos.trim(),
        ci: ci.trim(),
        carrera: carrera,
        curso: curso,
        activo: activo,
      );

      _setLoading(false);
      notifyListeners();
      
      return true;

    } catch (e) {
      _errorMessage = 'Error al editar estudiante: $e';
      _setLoading(false);
      return false;
    }
  }

  // RFM3-003: Eliminar estudiante
  Future<bool> eliminarEstudiante(String id) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      // Buscar estudiante
      final index = _estudiantes.indexWhere((e) => e.id == id);
      if (index == -1) {
        _errorMessage = 'Estudiante no encontrado';
        _setLoading(false);
        return false;
      }

      // Verificar si tiene huella registrada
      if (_estudiantes[index].huellaId != null) {
        _errorMessage = 'No se puede eliminar. El estudiante tiene huella registrada.';
        _setLoading(false);
        return false;
      }

      // Eliminar estudiante
      _estudiantes.removeAt(index);

      _setLoading(false);
      notifyListeners();
      
      return true;

    } catch (e) {
      _errorMessage = 'Error al eliminar estudiante: $e';
      _setLoading(false);
      return false;
    }
  }

  // Desactivar estudiante (eliminación lógica)
  Future<bool> desactivarEstudiante(String id) async {
    try {
      final index = _estudiantes.indexWhere((e) => e.id == id);
      if (index == -1) return false;

      _estudiantes[index] = _estudiantes[index].copyWith(activo: false);
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = 'Error al desactivar estudiante: $e';
      return false;
    }
  }

  // Activar estudiante
  Future<bool> activarEstudiante(String id) async {
    try {
      final index = _estudiantes.indexWhere((e) => e.id == id);
      if (index == -1) return false;

      _estudiantes[index] = _estudiantes[index].copyWith(activo: true);
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = 'Error al activar estudiante: $e';
      return false;
    }
  }

  // RFM2-002: Asociar huella a estudiante
  Future<bool> asociarHuella(String estudianteId, String huellaId) async {
    try {
      final index = _estudiantes.indexWhere((e) => e.id == estudianteId);
      if (index == -1) return false;

      _estudiantes[index] = _estudiantes[index].copyWith(huellaId: huellaId);
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = 'Error al asociar huella: $e';
      return false;
    }
  }

  // Remover huella de estudiante
  Future<bool> removerHuella(String estudianteId) async {
    try {
      final index = _estudiantes.indexWhere((e) => e.id == estudianteId);
      if (index == -1) return false;

      _estudiantes[index] = _estudiantes[index].copyWith(huellaId: null);
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = 'Error al remover huella: $e';
      return false;
    }
  }

  // Buscar estudiante por ID
  Estudiante? obtenerEstudiantePorId(String id) {
    try {
      return _estudiantes.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  // Buscar estudiante por CI
  Estudiante? obtenerEstudiantePorCi(String ci) {
    try {
      return _estudiantes.firstWhere((e) => e.ci == ci);
    } catch (e) {
      return null;
    }
  }

  // Obtener estudiantes por curso
  List<Estudiante> obtenerEstudiantesPorCurso(String curso) {
    return _estudiantes.where((e) => e.curso == curso).toList();
  }

  // Actualizar filtros
  void actualizarFiltros({String? curso, String? carrera}) {
    if (curso != null) _filterCurso = curso;
    if (carrera != null) _filterCarrera = carrera;
    notifyListeners();
  }

  // Actualizar búsqueda
  void actualizarBusqueda(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Limpiar filtros
  void limpiarFiltros() {
    _filterCurso = '';
    _filterCarrera = '';
    _searchQuery = '';
    notifyListeners();
  }

  // Cargar datos de ejemplo (para desarrollo)
  void cargarDatosEjemplo() {
    _estudiantes = [
      Estudiante(
        id: '1',
        nombre: 'Juan',
        apellidos: 'Pérez García',
        ci: '1234567',
        carrera: 'Sistemas Informáticos',
        curso: '3ro "B"',
        huellaId: 'huella_001',
        fechaRegistro: DateTime(2024, 1, 15),
      ),
      Estudiante(
        id: '2',
        nombre: 'María',
        apellidos: 'López Fernández',
        ci: '1234568',
        carrera: 'Sistemas Informáticos',
        curso: '3ro "B"',
        huellaId: 'huella_002',
        fechaRegistro: DateTime(2024, 1, 15),
      ),
      Estudiante(
        id: '3',
        nombre: 'Carlos',
        apellidos: 'Gómez Martínez',
        ci: '1234569',
        carrera: 'Sistemas Informáticos',
        curso: '3ro "B"',
        huellaId: null,
        fechaRegistro: DateTime(2024, 1, 16),
      ),
      Estudiante(
        id: '4',
        nombre: 'Ana',
        apellidos: 'Rodríguez Vargas',
        ci: '1234570',
        carrera: 'Sistemas Informáticos',
        curso: '3ro "B"',
        huellaId: 'huella_004',
        fechaRegistro: DateTime(2024, 1, 16),
      ),
    ];
    notifyListeners();
  }

  // Limpiar error
  void limpiarError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Método privado para loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}