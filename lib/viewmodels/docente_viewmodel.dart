import 'package:flutter/material.dart';
import 'package:incos_check/models/docente_model.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/validators.dart';

class DocentesViewModel extends ChangeNotifier {
  // Lista de turnos disponibles
  final List<String> _turnos = ['MAÑANA', 'NOCHE', 'AMBOS'];

  // Datos de ejemplo
  List<Docente> _docentes = [
    Docente(
      id: 1,
      apellidoPaterno: 'FERNANDEZ',
      apellidoMaterno: 'GARCIA',
      nombres: 'MARIA ELENA',
      ci: '6543210',
      carrera: 'SISTEMAS INFORMÁTICOS',
      turno: 'MAÑANA',
      email: 'mfernandez@gmail.com',
      telefono: '+59170012345',
      estado: Estados.activo,
    ),
    Docente(
      id: 2,
      apellidoPaterno: 'BUSTOS',
      apellidoMaterno: 'MARTINEZ',
      nombres: 'CARLOS ALBERTO',
      ci: '6543211',
      carrera: 'SISTEMAS INFORMÁTICOS',
      turno: 'NOCHE',
      email: 'cbustos@gmail.com',
      telefono: '+59170012346',
      estado: Estados.activo,
    ),
  ];

  // Lista de carreras disponibles
  List<String> _carreras = ['SISTEMAS INFORMÁTICOS'];
  List<Docente> _filteredDocentes = [];
  String _selectedCarrera = '';
  String _selectedTurno = 'MAÑANA';
  Color _carreraColor = AppColors.primary;
  final TextEditingController _searchController = TextEditingController();

  // Getters
  List<String> get turnos => _turnos;
  List<Docente> get docentes => _docentes;
  List<Docente> get filteredDocentes => _filteredDocentes;
  List<String> get carreras => _carreras;
  String get selectedCarrera => _selectedCarrera;
  String get selectedTurno => _selectedTurno;
  Color get carreraColor => _carreraColor;
  TextEditingController get searchController => _searchController;

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

  // Métodos de inicialización
  void initialize(Map<String, dynamic> carrera) {
    _carreraColor = _parseColor(carrera['color']);
    _selectedCarrera = carrera['nombre'] as String;

    _limpiarCarrerasDuplicadas();

    if (!_carreras.contains(_selectedCarrera)) {
      _carreras.add(_selectedCarrera);
    }

    _filteredDocentes = _docentes;
    _filterDocentesByCarreraAndTurno();
  }

  void _limpiarCarrerasDuplicadas() {
    _carreras = _carreras.toSet().toList();
    notifyListeners();
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  // Métodos de filtrado y búsqueda
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

  // Métodos CRUD
  void addDocente(Docente docente) {
    _docentes.add(docente);
    if (!_carreras.contains(docente.carrera)) {
      _carreras.add(docente.carrera);
    }
    _filterDocentesByCarreraAndTurno();
    notifyListeners();
  }

  void updateDocente(Docente docente) {
    final index = _docentes.indexWhere((d) => d.id == docente.id);
    if (index != -1) {
      _docentes[index] = docente;
      _filterDocentesByCarreraAndTurno();
      notifyListeners();
    }
  }

  void deleteDocente(int id) {
    _docentes.removeWhere((d) => d.id == id);
    _filterDocentesByCarreraAndTurno();
    notifyListeners();
  }

  Docente? getDocenteById(int id) {
    try {
      return _docentes.firstWhere((docente) => docente.id == id);
    } catch (e) {
      return null;
    }
  }

  // Métodos para estadísticas
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

  // Método para generar nuevo ID
  int getNextId() {
    return _docentes.isNotEmpty ? (_docentes.last.id + 1) : 1;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
