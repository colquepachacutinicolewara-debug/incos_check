// viewmodels/gestion_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/gestion_model.dart';
import '../models/database_helper.dart';

class GestionViewModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

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
      final result = await _databaseHelper.rawQuery('''
        SELECT nombre FROM carreras WHERE activa = 1 ORDER BY nombre
      ''');

      final carrerasUnicas = result
          .map((row) => row['nombre'] as String)
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

  // ========== CARRERAS SYNC ==========
  Future<void> sincronizarCarreras() async {
    try {
      _loading = true;
      notifyListeners();
      
      await _loadCarreras();
      if (_estado.carreras.isNotEmpty && 
          !_estado.carreras.contains(_estado.carreraSeleccionada)) {
        await seleccionarCarrera(_estado.carreras.first);
      } else if (_estado.carreras.isNotEmpty) {
        await _loadAllDataForCarrera(_estado.carreraSeleccionada);
      }
      
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = 'Error al sincronizar carreras: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> actualizarCarreras(List<String> nuevasCarreras) async {
    final carrerasUnicas = nuevasCarreras.toSet().toList();
    
    _estado = _estado.copyWith(carreras: carrerasUnicas);
    
    // Si la carrera seleccionada ya no existe, seleccionar la primera disponible
    if (!carrerasUnicas.contains(_estado.carreraSeleccionada) && carrerasUnicas.isNotEmpty) {
      await seleccionarCarrera(carrerasUnicas.first);
    } else if (carrerasUnicas.isNotEmpty) {
      // Recargar datos de la carrera actual
      await _loadAllDataForCarrera(_estado.carreraSeleccionada);
    } else {
      // Si no hay carreras, resetear a valores por defecto
      _estado = GestionEstado(
        carreraSeleccionada: 'Sistemas Informáticos',
        carreras: ['Sistemas Informáticos'],
      );
    }
    
    notifyListeners();
  }

  // ========== COUNTS MANAGEMENT ==========
  Future<void> _loadCountsForCarrera(String carrera) async {
    try {
      final estudianteCount = await _getEstudiantesCount(carrera);
      final docenteCount = await _getDocentesCount(carrera);
      final cursoCount = await _getCursosCount(carrera);
      final turnoCount = await _getTurnosCount(carrera);
      final paraleloCount = await _getParalelosCount(carrera);
      final nivelCount = await _getNivelesCount(carrera);

      _counts['${carrera}_estudiantes'] = estudianteCount;
      _counts['${carrera}_docentes'] = docenteCount;
      _counts['${carrera}_cursos'] = cursoCount;
      _counts['${carrera}_turnos'] = turnoCount;
      _counts['${carrera}_paralelos'] = paraleloCount;
      _counts['${carrera}_niveles'] = nivelCount;
    } catch (e) {
      print('Error loading counts for $carrera: $e');
      _counts['${carrera}_estudiantes'] = 0;
      _counts['${carrera}_docentes'] = 0;
      _counts['${carrera}_cursos'] = 0;
      _counts['${carrera}_turnos'] = 0;
      _counts['${carrera}_paralelos'] = 0;
      _counts['${carrera}_niveles'] = 0;
    }
  }

  Future<int> _getEstudiantesCount(String carrera) async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM estudiantes e
        JOIN carreras c ON e.carrera_id = c.id
        WHERE c.nombre = ?
      ''', [carrera]);
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getDocentesCount(String carrera) async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM docentes WHERE carrera = ?
      ''', [carrera]);
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getCursosCount(String carrera) async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM materias WHERE carrera = ?
      ''', [carrera]);
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getTurnosCount(String carrera) async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(DISTINCT turno_id) as count FROM estudiantes e
        JOIN carreras c ON e.carrera_id = c.id
        WHERE c.nombre = ? AND e.turno_id IS NOT NULL
      ''', [carrera]);
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getParalelosCount(String carrera) async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(DISTINCT paralelo_id) as count FROM estudiantes e
        JOIN carreras c ON e.carrera_id = c.id
        WHERE c.nombre = ? AND e.paralelo_id IS NOT NULL
      ''', [carrera]);
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getNivelesCount(String carrera) async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(DISTINCT nivel_id) as count FROM estudiantes e
        JOIN carreras c ON e.carrera_id = c.id
        WHERE c.nombre = ? AND e.nivel_id IS NOT NULL
      ''', [carrera]);
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ========== TURNOS MANAGEMENT ==========
  Future<void> _loadTurnosForCarrera(String carrera) async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT DISTINCT t.nombre FROM turnos t
        JOIN estudiantes e ON e.turno_id = t.id
        JOIN carreras c ON e.carrera_id = c.id
        WHERE c.nombre = ? AND t.activo = 1
        ORDER BY t.nombre
      ''', [carrera]);
      
      _turnos[carrera] = result.map((row) => row['nombre'] as String).toList();
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
      // Implementar lógica para agregar turno si es necesario
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
      final result = await _databaseHelper.rawQuery('''
        SELECT DISTINCT p.nombre FROM paralelos p
        JOIN estudiantes e ON e.paralelo_id = p.id
        JOIN carreras c ON e.carrera_id = c.id
        WHERE c.nombre = ? AND p.activo = 1
        ORDER BY p.nombre
      ''', [carrera]);
      
      _paralelos[carrera] = result.map((row) => row['nombre'] as String).toList();
    } catch (e) {
      print('Error loading paralelos for $carrera: $e');
      _paralelos[carrera] = ['A', 'B', 'C'];
    }
  }

  List<String> getParalelos(String carrera) {
    return _paralelos[carrera] ?? ['A', 'B', 'C'];
  }

  // ========== NIVELES MANAGEMENT ==========
  Future<void> _loadNivelesForCarrera(String carrera) async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT DISTINCT n.nombre FROM niveles n
        JOIN estudiantes e ON e.nivel_id = n.id
        JOIN carreras c ON e.carrera_id = c.id
        WHERE c.nombre = ? AND n.activo = 1
        ORDER BY n.orden
      ''', [carrera]);
      
      _niveles[carrera] = result.map((row) => row['nombre'] as String).toList();
    } catch (e) {
      print('Error loading niveles for $carrera: $e');
      _niveles[carrera] = ['Primero', 'Segundo', 'Tercero', 'Cuarto', 'Quinto', 'Sexto'];
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

  int getNivelesCount(String carrera) {
    return _counts['${carrera}_niveles'] ?? 0;
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

  // ========== ERROR HANDLING =======
  void clearError() {
    if (_error.isNotEmpty) {
      _error = '';
      notifyListeners();
    }
  }

  // En tu gestion_viewmodel.dart, agrega:
int getHorariosCount() {
  // Lógica para contar horarios activos
  return 18; // Ejemplo
}


  // ========== REFRESH ==========
  Future<void> refresh() async {
    await initialize();
  }
}