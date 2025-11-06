// viewmodels/gestion_viewmodel.dart (ACTUALIZADO)
import 'package:flutter/material.dart';
import '../models/gestion_model.dart';
import '../repositories/gestion_repository.dart';

class GestionViewModel extends ChangeNotifier {
  final GestionRepository _repository = GestionRepository();

  // Estado
  GestionEstado _estado = GestionEstado(
    carreraSeleccionada: 'Sistemas Informáticos',
    carreras: ['Sistemas Informáticos'],
  );

  bool _loading = false;
  String _error = '';
  Map<String, int> _counts = {};
  Map<String, List<String>> _turnos = {};
  Map<String, List<String>> _paralelos = {};
  Map<String, List<String>> _niveles = {};

  // Getters
  GestionEstado get estado => _estado;
  bool get loading => _loading;
  String get error => _error;
  Map<String, int> get counts => _counts;

  String get carreraSeleccionada => _estado.carreraSeleccionada;
  List<String> get carreras => _estado.carreras;

  // ========== INITIALIZATION ==========
  Future<void> initialize() async {
    try {
      _loading = true;
      _error = '';
      notifyListeners();

      await _loadCarreras();
      await _loadAllDataForCarrera(_estado.carreraSeleccionada);

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = 'Error al inicializar: ${e.toString()}';
      notifyListeners();
    }
  }

  // ========== CARRERAS MANAGEMENT ==========
  Future<void> _loadCarreras() async {
    try {
      final carrerasConfig = await _repository.getCarreras();

      final carrerasUnicas = carrerasConfig
          .map((c) => c.nombre)
          .toSet()
          .toList();

      _estado = GestionEstado(
        carreraSeleccionada: carrerasUnicas.isNotEmpty
            ? carrerasUnicas.first
            : 'Sistemas Informáticos',
        carreras: carrerasUnicas.isNotEmpty
            ? carrerasUnicas
            : ['Sistemas Informáticos'],
      );
    } catch (e) {
      print('Error loading carreras: $e');
    }
  }

  Future<void> seleccionarCarrera(String carrera) async {
    if (carrera != _estado.carreraSeleccionada) {
      _loading = true;
      notifyListeners();

      _estado = _estado.copyWith(carreraSeleccionada: carrera);
      await _loadAllDataForCarrera(carrera);

      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAllDataForCarrera(String carrera) async {
    await Future.wait([
      _loadCountsForCarrera(carrera),
      _loadTurnosForCarrera(carrera),
      _loadParalelosForCarrera(carrera),
      _loadNivelesForCarrera(carrera),
    ]);
  }

  Future<void> actualizarCarreras(List<String> nuevasCarreras) async {
    final carrerasUnicas = nuevasCarreras.toSet().toList();

    _estado = _estado.copyWith(carreras: carrerasUnicas);

    if (!carrerasUnicas.contains(_estado.carreraSeleccionada) &&
        carrerasUnicas.isNotEmpty) {
      await seleccionarCarrera(carrerasUnicas.first);
    } else {
      notifyListeners();
    }
  }

  // ========== COUNTS MANAGEMENT ==========
  Future<void> _loadCountsForCarrera(String carrera) async {
    try {
      final estudianteCount = await _repository.getEstudiantesCount(carrera);
      final docenteCount = await _repository.getDocentesCount(carrera);
      final cursoCount = await _repository.getCursosCount(carrera);
      final turnoCount = await _getTurnosCount(carrera);
      final paraleloCount = await _getParalelosCount(carrera);

      _counts['${carrera}_estudiantes'] = estudianteCount;
      _counts['${carrera}_docentes'] = docenteCount;
      _counts['${carrera}_cursos'] = cursoCount;
      _counts['${carrera}_turnos'] = turnoCount;
      _counts['${carrera}_paralelos'] = paraleloCount;
    } catch (e) {
      print('Error loading counts for $carrera: $e');
      _counts['${carrera}_estudiantes'] = 0;
      _counts['${carrera}_docentes'] = 0;
      _counts['${carrera}_cursos'] = 0;
      _counts['${carrera}_turnos'] = 0;
      _counts['${carrera}_paralelos'] = 0;
    }
  }

  Future<int> _getTurnosCount(String carrera) async {
    try {
      final turnos = await _repository.getTurnos(carrera);
      return turnos.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getParalelosCount(String carrera) async {
    try {
      final paralelos = await _repository.getParalelos(carrera);
      return paralelos.length;
    } catch (e) {
      return 0;
    }
  }

  // ========== TURNOS MANAGEMENT ==========
  Future<void> _loadTurnosForCarrera(String carrera) async {
    try {
      final turnos = await _repository.getTurnos(carrera);
      _turnos[carrera] = turnos;
    } catch (e) {
      print('Error loading turnos for $carrera: $e');
      _turnos[carrera] = ['Mañana', 'Tarde', 'Noche'];
    }
  }

  List<String> getTurnos(String carrera) {
    return _turnos[carrera] ?? ['Mañana', 'Tarde', 'Noche'];
  }

  Future<void> addTurno(String turno) async {
    try {
      await _repository.addTurno(_estado.carreraSeleccionada, turno);
      await _loadTurnosForCarrera(_estado.carreraSeleccionada);
      await _loadCountsForCarrera(_estado.carreraSeleccionada);
      notifyListeners();
    } catch (e) {
      throw Exception('No se pudo agregar el turno: ${e.toString()}');
    }
  }

  // ========== PARALELOS MANAGEMENT ==========
  Future<void> _loadParalelosForCarrera(String carrera) async {
    try {
      final paralelos = await _repository.getParalelos(carrera);
      _paralelos[carrera] = paralelos;
    } catch (e) {
      print('Error loading paralelos for $carrera: $e');
      _paralelos[carrera] = ['A', 'B', 'C'];
    }
  }

  List<String> getParalelos(String carrera) {
    return _paralelos[carrera] ?? ['A', 'B', 'C'];
  }

  Future<void> addParalelo(String paralelo) async {
    try {
      await _repository.addParalelo(_estado.carreraSeleccionada, paralelo);
      await _loadParalelosForCarrera(_estado.carreraSeleccionada);
      await _loadCountsForCarrera(_estado.carreraSeleccionada);
      notifyListeners();
    } catch (e) {
      throw Exception('No se pudo agregar el paralelo: ${e.toString()}');
    }
  }

  // ========== NIVELES MANAGEMENT ==========
  Future<void> _loadNivelesForCarrera(String carrera) async {
    try {
      final niveles = await _repository.getNiveles(carrera);
      _niveles[carrera] = niveles;
    } catch (e) {
      print('Error loading niveles for $carrera: $e');
      _niveles[carrera] = [
        'Primero',
        'Segundo',
        'Tercero',
        'Cuarto',
        'Quinto',
        'Sexto',
      ];
    }
  }

  List<String> getNiveles(String carrera) {
    return _niveles[carrera] ??
        ['Primero', 'Segundo', 'Tercero', 'Cuarto', 'Quinto', 'Sexto'];
  }

  // ========== GETTERS PARA COUNTS ==========
  int getEstudiantesCount(String carrera) {
    return _counts['${carrera}_estudiantes'] ?? 0;
  }

  int getDocentesCount(String carrera) {
    return _counts['${carrera}_docentes'] ?? 0;
  }

  int getCursosCount(String carrera) {
    return _counts['${carrera}_cursos'] ?? 0;
  }

  int getTurnosCount(String carrera) {
    return _counts['${carrera}_turnos'] ?? 0;
  }

  int getParalelosCount(String carrera) {
    return _counts['${carrera}_paralelos'] ?? 0;
  }

  // ========== CARRERA CONFIG ==========
  CarreraConfig getCarreraConfig(String carrera) {
    return CarreraConfig(
      id: carrera.hashCode,
      nombre: carrera,
      color: _getColorForCarrera(carrera),
      icon: _getIconForCarrera(carrera),
      activa: true,
    );
  }

  String _getColorForCarrera(String carrera) {
    final colors = {
      'Sistemas Informáticos': '#1565C0',
      'Idioma Inglés': '#F44336',
      'Contaduría': '#4CAF50',
      'Enfermería': '#E91E63',
    };
    return colors[carrera] ?? '#9C27B0';
  }

  IconData _getIconForCarrera(String carrera) {
    final icons = {
      'Sistemas Informáticos': Icons.computer,
      'Idioma Inglés': Icons.language,
      'Contaduría': Icons.calculate,
      'Enfermería': Icons.medical_services,
    };
    return icons[carrera] ?? Icons.school;
  }

  // ========== THEME METHODS ==========
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.grey.shade100;
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

  // ========== ERROR HANDLING ==========
  void clearError() {
    if (_error.isNotEmpty) {
      _error = '';
      notifyListeners();
    }
  }

  // ========== REFRESH ==========
  Future<void> refresh() async {
    await initialize();
  }
}
