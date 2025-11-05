import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/docente_model.dart';
import '../repositories/data_repository.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class DocentesViewModel extends ChangeNotifier {
  final DataRepository _repository;

  // Lista de turnos disponibles
  final List<String> _turnos = ['MAÑANA', 'NOCHE', 'AMBOS'];

  // Datos REALES desde Firestore
  List<Docente> _docentes = [];
  List<String> _carreras = [];
  List<Docente> _filteredDocentes = [];
  String _selectedCarrera = '';
  String _selectedTurno = 'MAÑANA';
  Color _carreraColor = AppColors.primary;
  final TextEditingController _searchController = TextEditingController();

  // Estados
  bool _loading = false;
  bool _syncing = false;
  bool _guardando = false; // ✅ NUEVO: Estado específico para guardado
  String _error = '';
  Stream<QuerySnapshot>? _docentesStream;

  DocentesViewModel(this._repository) {
    _initializeFirestore();
  }

  // Getters
  List<String> get turnos => _turnos;
  List<Docente> get docentes => _docentes;
  List<Docente> get filteredDocentes => _filteredDocentes;
  List<String> get carreras => _carreras;
  String get selectedCarrera => _selectedCarrera;
  String get selectedTurno => _selectedTurno;
  Color get carreraColor => _carreraColor;
  TextEditingController get searchController => _searchController;
  bool get loading => _loading;
  bool get syncing => _syncing;
  bool get guardando => _guardando; // ✅ NUEVO
  String get error => _error;

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

  // INICIALIZAR FIRESTORE (CONEXIÓN REAL)
  void _initializeFirestore() {
    _loading = true;
    notifyListeners();

    _docentesStream = _repository.getDocentesStream();
    _docentesStream?.listen(
      (QuerySnapshot snapshot) {
        _docentes = _parseDocentesFromSnapshot(snapshot);
        _updateCarrerasFromDocentes();
        _filterDocentesByCarreraAndTurno();
        _loading = false;
        _error = '';
        notifyListeners();
      },
      onError: (error) {
        _loading = false;
        _error = 'Error cargando docentes: $error';
        notifyListeners();
      },
    );
  }

  // Parsear docentes desde Firestore
  List<Docente> _parseDocentesFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Docente.fromFirestore(doc.id, data);
    }).toList();
  }

  // Actualizar lista de carreras desde docentes
  void _updateCarrerasFromDocentes() {
    final carrerasSet = <String>{};
    for (final docente in _docentes) {
      if (docente.carrera.isNotEmpty) {
        carrerasSet.add(docente.carrera);
      }
    }
    _carreras = carrerasSet.toList()..sort();

    // Si no hay carrera seleccionada, usar la primera disponible
    if (_selectedCarrera.isEmpty && _carreras.isNotEmpty) {
      _selectedCarrera = _carreras.first;
    }
  }

  // MÉTODOS DE INICIALIZACIÓN
  void initialize(Map<String, dynamic> carrera) {
    _carreraColor = _parseColor(carrera['color']);
    _selectedCarrera = carrera['nombre'] as String;

    // Agregar la carrera actual si no existe
    if (!_carreras.contains(_selectedCarrera)) {
      _carreras.add(_selectedCarrera);
      _carreras.sort();
    }

    _filterDocentesByCarreraAndTurno();
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  // FILTRADO Y BÚSQUEDA
  void _filterDocentesByCarreraAndTurno() {
    _filteredDocentes = _docentes.where((docente) {
      return docente.carrera == _selectedCarrera &&
          docente.turno == _selectedTurno;
    }).toList();
    _sortDocentesAlphabetically();
    notifyListeners();
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

  // ESTADÍSTICAS
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

  // ✅ CORREGIDO: CRUD CON RETORNO DE ÉXITO/FALLO
  Future<bool> addDocente(Docente docente) async {
    _guardando = true; // ✅ Usar estado específico de guardado
    _error = '';
    notifyListeners();

    try {
      final docenteData = docente.toFirestore();
      await _repository.addDocente(docenteData);
      _error = '';
      return true; // ✅ Retornar éxito
    } catch (e) {
      _error = 'Error agregando docente: $e';
      return false; // ✅ Retornar fallo
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  // ✅ CORREGIDO: Actualizar con retorno de bool
  Future<bool> updateDocente(Docente docente) async {
    _guardando = true; // ✅ Usar estado específico de guardado
    _error = '';
    notifyListeners();

    try {
      final docenteData = docente.toFirestore();
      await _repository.updateDocente(docente.id, docenteData);
      _error = '';
      return true; // ✅ Retornar éxito
    } catch (e) {
      _error = 'Error actualizando docente: $e';
      return false; // ✅ Retornar fallo
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  // ✅ CORREGIDO: Eliminar con retorno de bool
  Future<bool> deleteDocente(String id) async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      await _repository.deleteDocente(id);
      _error = '';
      return true; // ✅ Retornar éxito
    } catch (e) {
      _error = 'Error eliminando docente: $e';
      return false; // ✅ Retornar fallo
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // MÉTODOS AUXILIARES
  Docente? getDocenteById(String id) {
    try {
      return _docentes.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  String formatTelefono(String telefono) {
    if (!telefono.startsWith('+591')) {
      if (RegExp(r'^\d+$').hasMatch(telefono)) {
        return '+591$telefono';
      }
    }
    return telefono;
  }

  String generateEmail(String nombres, String apellidoPaterno) {
    final nombre = nombres.split(' ')[0].toLowerCase();
    final apellido = apellidoPaterno.toLowerCase();
    return '$nombre.$apellido@gmail.com';
  }

  Color getTurnoColor(String turno) {
    switch (turno) {
      case 'MAÑANA':
        return Colors.orange;
      case 'NOCHE':
        return Colors.blue;
      case 'AMBOS':
        return Colors.purple;
      default:
        return _carreraColor;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Recargar datos
  void reload() {
    _initializeFirestore();
  }
}
