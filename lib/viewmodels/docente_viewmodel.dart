// viewmodels/docente_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/docente_model.dart';
import '../models/database_helper.dart';
import '../utils/constants.dart';

class DocentesViewModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

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

  DocentesViewModel() {
    _searchController.addListener(_filtrarEstudiantes);
    _agregarDocentesIniciales();
  }

  // ✅ MÉTODO PARA AGREGAR DOCENTES INICIALES
  void _agregarDocentesIniciales() async {
    try {
      // Verificar si ya existen docentes en la base de datos
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM docentes
      ''');
      
      final count = (result.first['count'] as int?) ?? 0;
      
      // Si no hay docentes, agregar la lista inicial
      if (count == 0) {
        await _insertarDocentesIniciales();
      }
    } catch (e) {
      print('Error al verificar docentes existentes: $e');
    }
  }

  // ✅ MÉTODO PARA INSERTAR DOCENTES INICIALES
  Future<void> _insertarDocentesIniciales() async {
    final List<Map<String, dynamic>> docentesIniciales = [
      {
        'apellido_paterno': 'Condori',
        'apellido_materno': '',
        'nombres': 'Omar',
        'ci': '1234567',
        'carrera': 'Informática',
        'turno': 'AMBOS',
        'email': 'omar.condori@email.com',
        'telefono': '78945612',
        'estado': 'ACTIVO'
      },
      {
        'apellido_paterno': 'Saavedra',
        'apellido_materno': '',
        'nombres': 'Carlos',
        'ci': '2345678',
        'carrera': 'Sistemas',
        'turno': 'MAÑANA',
        'email': 'carlos.saavedra@email.com',
        'telefono': '78945613',
        'estado': 'ACTIVO'
      },
      {
        'apellido_paterno': 'Alvarado',
        'apellido_materno': '',
        'nombres': 'Mamerito',
        'ci': '3456789',
        'carrera': 'Informática',
        'turno': 'NOCHE',
        'email': 'mamerito.alvarado@email.com',
        'telefono': '78945614',
        'estado': 'ACTIVO'
      },
      {
        'apellido_paterno': 'Machaca',
        'apellido_materno': '',
        'nombres': 'Miguel',
        'ci': '4567890',
        'carrera': 'Sistemas',
        'turno': 'AMBOS',
        'email': 'miguel.machaca@email.com',
        'telefono': '78945615',
        'estado': 'ACTIVO'
      },
      {
        'apellido_paterno': 'Ramos',
        'apellido_materno': '',
        'nombres': 'Víctor',
        'ci': '5678901',
        'carrera': 'Informática',
        'turno': 'MAÑANA',
        'email': 'victor.ramos@email.com',
        'telefono': '78945616',
        'estado': 'ACTIVO'
      },
      {
        'apellido_paterno': 'Gutiérrez',
        'apellido_materno': '',
        'nombres': 'Edith',
        'ci': '6789012',
        'carrera': 'Sistemas',
        'turno': 'NOCHE',
        'email': 'edith.gutierrez@email.com',
        'telefono': '78945617',
        'estado': 'ACTIVO'
      },
      {
        'apellido_paterno': 'Quispe',
        'apellido_materno': '',
        'nombres': 'Rubén',
        'ci': '7890123',
        'carrera': 'Informática',
        'turno': 'AMBOS',
        'email': 'ruben.quispe@email.com',
        'telefono': '78945618',
        'estado': 'ACTIVO'
      },
      {
        'apellido_paterno': 'Méndez',
        'apellido_materno': '',
        'nombres': 'Marisol',
        'ci': '8901234',
        'carrera': 'Sistemas',
        'turno': 'MAÑANA',
        'email': 'marisol.mendez@email.com',
        'telefono': '78945619',
        'estado': 'ACTIVO'
      },
      {
        'apellido_paterno': 'Rodríguez',
        'apellido_materno': '',
        'nombres': 'Remmy',
        'ci': '9012345',
        'carrera': 'Informática',
        'turno': 'NOCHE',
        'email': 'remmy.rodriguez@email.com',
        'telefono': '78945620',
        'estado': 'ACTIVO'
      },
      {
        'apellido_paterno': 'Huiza',
        'apellido_materno': '',
        'nombres': 'Fredy',
        'ci': '0123456',
        'carrera': 'Sistemas',
        'turno': 'AMBOS',
        'email': 'fredy.huiza@email.com',
        'telefono': '78945621',
        'estado': 'ACTIVO'
      },
      {
        'apellido_paterno': 'Condori',
        'apellido_materno': '',
        'nombres': 'Inés',
        'ci': '1122334',
        'carrera': 'Informática',
        'turno': 'MAÑANA',
        'email': 'ines.condori@email.com',
        'telefono': '78945622',
        'estado': 'ACTIVO'
      },
    ];

    try {
      for (final docenteData in docentesIniciales) {
        final docenteId = 'docente_${DateTime.now().millisecondsSinceEpoch}_${docenteData['ci']}';
        final now = DateTime.now().toIso8601String();

        await _databaseHelper.rawInsert('''
          INSERT INTO docentes (id, apellido_paterno, apellido_materno, nombres, ci, 
          carrera, turno, email, telefono, estado, fecha_creacion, fecha_actualizacion)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          docenteId,
          docenteData['apellido_paterno'],
          docenteData['apellido_materno'],
          docenteData['nombres'],
          docenteData['ci'],
          docenteData['carrera'],
          docenteData['turno'],
          docenteData['email'],
          docenteData['telefono'],
          docenteData['estado'],
          now,
          now
        ]);

        // Pequeña pausa para evitar conflictos con los IDs
        await Future.delayed(const Duration(milliseconds: 10));
      }
      
      print('✅ Docentes iniciales agregados exitosamente');
    } catch (e) {
      print('❌ Error al agregar docentes iniciales: $e');
    }
  }

  // ✅ MÉTODO DE INICIALIZACIÓN MEJORADO
  void initialize(Map<String, dynamic> carrera) {
    _carreraColor = _parseColor(carrera['color']);
    _selectedCarrera = carrera['nombre'] as String;
    _loadDocentes();
  }

  // ✅ CARGA DE DOCENTES DESDE SQLITE
  void _loadDocentes() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _loadDocentesFromDatabase();
    } catch (e) {
      _error = 'Error al cargar docentes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadDocentesFromDatabase() async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM docentes ORDER BY apellido_paterno, apellido_materno, nombres
      ''');

      _docentes = result.map((row) => 
        Docente.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      // Extraer carreras únicas de los docentes
      _carreras = _docentes.map((d) => d.carrera).toSet().toList();
      _carreras.sort();

      // Asegurar que la carrera seleccionada esté en la lista
      if (!_carreras.contains(_selectedCarrera) && _selectedCarrera.isNotEmpty) {
        _carreras.add(_selectedCarrera);
      }

      _filterDocentesByCarreraAndTurno();
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar docentes: $e';
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

  void _filtrarEstudiantes() {
    final query = _searchController.text.toLowerCase();
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

  // ✅ CRUD ACTUALIZADO CON SQLITE
  Future<bool> addDocente(Docente docente) async {
    try {
      _guardando = true;
      notifyListeners();

      // Verificar si el CI ya existe
      final ciExiste = await existeCi(docente.ci);
      if (ciExiste) {
        _error = 'El CI ${docente.ci} ya está registrado';
        _guardando = false;
        notifyListeners();
        return false;
      }

      // Generar ID único si no se proporciona
      final docenteId = docente.id.isEmpty 
          ? 'docente_${DateTime.now().millisecondsSinceEpoch}'
          : docente.id;

      final now = DateTime.now().toIso8601String();

      await _databaseHelper.rawInsert('''
        INSERT INTO docentes (id, apellido_paterno, apellido_materno, nombres, ci, 
        carrera, turno, email, telefono, estado, fecha_creacion, fecha_actualizacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        docenteId,
        docente.apellidoPaterno,
        docente.apellidoMaterno ?? '', // ✅ Apellido materno opcional
        docente.nombres,
        docente.ci,
        docente.carrera.isNotEmpty ? docente.carrera : 'Informática', // ✅ Carrera por defecto
        docente.turno,
        docente.email,
        docente.telefono,
        docente.estado,
        now,
        now
      ]);

      await _loadDocentesFromDatabase(); // Recargar lista
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

      // Verificar si el CI ya existe (excluyendo el docente actual)
      final ciExiste = await existeCi(docente.ci, excludeId: docente.id);
      if (ciExiste) {
        _error = 'El CI ${docente.ci} ya está registrado por otro docente';
        _guardando = false;
        notifyListeners();
        return false;
      }

      await _databaseHelper.rawUpdate('''
        UPDATE docentes 
        SET apellido_paterno = ?, apellido_materno = ?, nombres = ?, ci = ?,
            carrera = ?, turno = ?, email = ?, telefono = ?, estado = ?,
            fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        docente.apellidoPaterno,
        docente.apellidoMaterno ?? '', // ✅ Apellido materno opcional
        docente.nombres,
        docente.ci,
        docente.carrera.isNotEmpty ? docente.carrera : 'Informática', // ✅ Carrera por defecto
        docente.turno,
        docente.email,
        docente.telefono,
        docente.estado,
        DateTime.now().toIso8601String(),
        docente.id
      ]);

      await _loadDocentesFromDatabase(); // Recargar lista
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

      await _databaseHelper.rawDelete('''
        DELETE FROM docentes WHERE id = ?
      ''', [id]);

      await _loadDocentesFromDatabase(); // Recargar lista
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

  // ✅ MÉTODO PARA REINTENTAR CARGA
  Future<void> reintentarCarga() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    await _loadDocentesFromDatabase();
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

  // ✅ MÉTODO PARA VERIFICAR SI UN CI YA EXISTE
  Future<bool> existeCi(String ci, {String? excludeId}) async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM docentes 
        WHERE ci = ? ${excludeId != null ? 'AND id != ?' : ''}
      ''', excludeId != null ? [ci, excludeId] : [ci]);

      final count = (result.first['count'] as int?) ?? 0;
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  // ✅ MÉTODO PARA OBTENER DOCENTES POR CARREA Y TURNO
  List<Docente> getDocentesPorCarreraYTurno(String carrera, String turno) {
    return _docentes.where((docente) => 
      docente.carrera == carrera && docente.turno == turno
    ).toList();
  }

  // ✅ MÉTODO PARA OBTENER ESTADÍSTICAS GENERALES
  Map<String, dynamic> getEstadisticasGenerales() {
    final totalDocentes = _docentes.length;
    final docentesActivos = _docentes.where((d) => d.estaActivo).length;
    final docentesInactivos = totalDocentes - docentesActivos;

    return {
      'total': totalDocentes,
      'activos': docentesActivos,
      'inactivos': docentesInactivos,
      'por_carrera': _getEstadisticasPorCarrera(),
    };
  }

  Map<String, int> _getEstadisticasPorCarrera() {
    final Map<String, int> estadisticas = {};
    for (final docente in _docentes) {
      estadisticas[docente.carrera] = (estadisticas[docente.carrera] ?? 0) + 1;
    }
    return estadisticas;
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