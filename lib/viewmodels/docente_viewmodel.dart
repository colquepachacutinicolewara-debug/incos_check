// docente_viewmodel.dart - VERSIÓN INTEGRADA CON FIRESTORE
import 'package:flutter/material.dart';
import 'package:incos_check/models/docente_model.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/repositories/data_repository.dart';

class DocentesViewModel extends ChangeNotifier {
  final DataRepository _repository;

  // Lista de turnos disponibles
  final List<String> _turnos = ['MAÑANA', 'NOCHE', 'AMBOS'];

  List<Docente> _docentes = [];
  List<Docente> _filteredDocentes = [];
  List<String> _carreras = [];
  String _selectedCarrera = '';
  String _selectedTurno = 'MAÑANA';
  Color _carreraColor = AppColors.primary;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _guardando = false;

  DocentesViewModel(this._repository);

  // Getters
  List<String> get turnos => _turnos;
  List<Docente> get docentes => _docentes;
  List<Docente> get filteredDocentes => _filteredDocentes;
  List<String> get carreras => _carreras;
  String get selectedCarrera => _selectedCarrera;
  String get selectedTurno => _selectedTurno;
  Color get carreraColor => _carreraColor;
  TextEditingController get searchController => _searchController;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get guardando => _guardando;

  // Setters
  set selectedCarrera(String value) {
    _selectedCarrera = value;
    _filterDocentesByCarreraAndTurno();
    notifyListeners();
  }

  set selectedTurno(String value) {
    _selectedTurno = value;
    _filterDocentesByCarreraAndTurno();
    notifyListeners();
  }

  set carreraColor(Color value) {
    _carreraColor = value;
    notifyListeners();
  }

  // ✅ MÉTODO DE INICIALIZACIÓN MEJORADO
  void initialize(Map<String, dynamic> carrera) {
    _carreraColor = _parseColor(carrera['color']);
    _selectedCarrera = carrera['nombre'] as String;
    _loadDocentes();
  }

  // ✅ CARGA DE DOCENTES CON STREAM (COMO EN CARRERAS)
  void _loadDocentes() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _repository.getDocentesStream().listen(
        (snapshot) {
          _docentes = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Docente.fromFirestore(doc.id, data);
          }).toList();

          // Extraer carreras únicas de los docentes
          _carreras = _docentes.map((d) => d.carrera).toSet().toList();
          _carreras.sort();

          // Asegurar que la carrera seleccionada esté en la lista
          if (!_carreras.contains(_selectedCarrera) &&
              _selectedCarrera.isNotEmpty) {
            _carreras.add(_selectedCarrera);
          }

          _filterDocentesByCarreraAndTurno();
          _error = null;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Error al cargar docentes: $error';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Error inesperado al cargar docentes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  // ✅ MÉTODOS DE FILTRADO (MANTENIDOS)
  void _filterDocentesByCarreraAndTurno() {
    _filteredDocentes = _docentes.where((docente) {
      final matchesCarrera = docente.carrera == _selectedCarrera;
      final matchesTurno = docente.turno == _selectedTurno;
      return matchesCarrera && matchesTurno;
    }).toList();

    _sortDocentesAlphabetically();
  }

  void _sortDocentesAlphabetically() {
    _filteredDocentes.sort((a, b) {
      int comparePaterno = a.apellidoPaterno.compareTo(b.apellidoPaterno);
      if (comparePaterno != 0) return comparePaterno;

      int compareMaterno = a.apellidoMaterno.compareTo(b.apellidoMaterno);
      if (compareMaterno != 0) return compareMaterno;

      return a.nombres.compareTo(b.nombres);
    });
  }

  void filterDocentes(String query) {
    if (query.isEmpty) {
      _filterDocentesByCarreraAndTurno();
    } else {
      _filteredDocentes = _docentes.where((docente) {
        final nombreCompleto =
            '${docente.apellidoPaterno} ${docente.apellidoMaterno} ${docente.nombres}'
                .toLowerCase();
        final ci = docente.ci.toLowerCase();
        final matchesSearch =
            nombreCompleto.contains(query.toLowerCase()) ||
            ci.contains(query.toLowerCase());
        final matchesCarreraTurno =
            docente.carrera == _selectedCarrera &&
            docente.turno == _selectedTurno;

        return matchesSearch && matchesCarreraTurno;
      }).toList();
    }
    _sortDocentesAlphabetically();
    notifyListeners();
  }

  // ✅ CRUD ACTUALIZADO CON MANEJO DE ERRORES MEJORADO
  Future<bool> addDocente(Docente docente) async {
    try {
      _guardando = true;
      notifyListeners();

      final docenteData = docente.toFirestore();
      await _repository.addDocente(docenteData);

      _guardando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _guardando = false;
      _error = 'Error al agregar docente: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDocente(Docente docente) async {
    try {
      _guardando = true;
      notifyListeners();

      final docenteData = docente.toFirestore();
      await _repository.updateDocente(docente.id, docenteData);

      _guardando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _guardando = false;
      _error = 'Error al actualizar docente: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDocente(String id) async {
    try {
      _guardando = true;
      notifyListeners();

      await _repository.deleteDocente(id);

      _guardando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _guardando = false;
      _error = 'Error al eliminar docente: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ MÉTODO PARA REINTENTAR CARGA (COMO EN CARRERAS)
  Future<void> reintentarCarga() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    _loadDocentes();
  }

  Docente? getDocenteById(String id) {
    try {
      return _docentes.firstWhere((docente) => docente.id == id);
    } catch (e) {
      return null;
    }
  }

  // ✅ MÉTODOS PARA ESTADÍSTICAS
  Map<String, int> getEstadisticasPorTurno() {
    final docentesCarrera = _docentes
        .where((d) => d.carrera == _selectedCarrera)
        .toList();

    return {
      'MAÑANA': docentesCarrera.where((d) => d.turno == 'MAÑANA').length,
      'NOCHE': docentesCarrera.where((d) => d.turno == 'NOCHE').length,
      'AMBOS': docentesCarrera.where((d) => d.turno == 'AMBOS').length,
      'TOTAL': docentesCarrera.length,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
