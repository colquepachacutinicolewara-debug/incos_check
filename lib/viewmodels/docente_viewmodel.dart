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
// // viewmodels/docente_viewmodel.dart - VERSIÓN COMPLETA CORREGIDA
// import 'package:flutter/material.dart';
// import 'dart:async';
// import '../models/docente_model.dart';
// import '../models/database_helper.dart';
// import '../utils/constants.dart';

// class DocentesViewModel with ChangeNotifier {
//   List<Docente> _docentes = [];
//   List<Docente> _docentesFiltrados = [];
//   final TextEditingController searchController = TextEditingController();
//   Timer? _searchDebounce;

//   final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

//   // Listas para los dropdowns
//   List<String> _carreras = [];
//   List<String> _turnos = ['MAÑANA', 'NOCHE', 'AMBOS'];

//   String tipo;
//   String carrera;
//   String turno;
//   Color carreraColor;

//   bool _isLoading = true;
//   bool get isLoading => _isLoading;

//   String? _error;
//   String? get error => _error;

//   bool _guardando = false;
//   bool get guardando => _guardando;

//   // ✅ SISTEMA DE CACHÉ PARA VELOCIDAD
//   final Map<String, dynamic> _cache = {};
//   DateTime? _lastCacheUpdate;
//   static const Duration _cacheDuration = Duration(minutes: 5);
//   bool _datosCargados = false;

//   // Getters para las listas
//   List<String> get carreras => _carreras;
//   List<String> get turnos => _turnos;

//   // CONSTRUCTOR
//   DocentesViewModel({
//     this.tipo = 'Docentes',
//     String? carrera,
//     String? turno,
//     Color? carreraColor,
//   }) : carrera = carrera ?? 'Sistemas Informáticos',
//        turno = turno ?? 'MAÑANA',
//        carreraColor = carreraColor ?? AppColors.primary {
//     _inicializarViewModel();
//   }

//   void _inicializarViewModel() {
//     _cargarDatosIniciales();
//     searchController.addListener(_filtrarDocentes);
//   }

//   // Getters
//   List<Docente> get docentes => _docentes;
//   List<Docente> get docentesFiltrados => _docentesFiltrados;

//   // ✅ MÉTODO PÚBLICO PARA RECARGAR DOCENTES
//   Future<void> recargarDocentes() async {
//     print('🔄 Recargando docentes...');
//     await _cargarDatosIniciales();
//   }

//   // ✅ ACTUALIZAR FILTROS
//   void actualizarFiltros({
//     String? nuevaCarrera,
//     String? nuevoTurno,
//     Color? nuevoColor,
//   }) {
//     bool cambios = false;

//     if (nuevaCarrera != null && nuevaCarrera != carrera) {
//       carrera = nuevaCarrera;
//       cambios = true;
//       print('🎯 Carrera cambiada a: $carrera');
//     }

//     if (nuevoTurno != null && nuevoTurno != turno) {
//       turno = nuevoTurno;
//       cambios = true;
//       print('🎯 Turno cambiado a: $turno');
//     }

//     if (nuevoColor != null && nuevoColor != carreraColor) {
//       carreraColor = nuevoColor;
//       cambios = true;
//       print('🎯 Color cambiado');
//     }

//     if (cambios) {
//       // Limpiar caché cuando cambian los filtros
//       _cache.clear();
//       _filtrarDocentes();
//       notifyListeners();
//     }
//   }

//   // ✅ MÉTODO PARA ACTUALIZAR CACHÉ
//   void _updateCache(String key, dynamic data) {
//     _cache[key] = {
//       'data': data,
//       'timestamp': DateTime.now(),
//     };
//     _lastCacheUpdate = DateTime.now();
//     print('💾 Cache actualizado para: $key');
//   }

//   // ✅ MÉTODO PARA OBTENER DEL CACHÉ
//   dynamic _getFromCache(String key) {
//     final cached = _cache[key];
//     if (cached != null) {
//       final timestamp = cached['timestamp'] as DateTime;
//       if (DateTime.now().difference(timestamp) < _cacheDuration) {
//         print('📦 Datos obtenidos del caché: $key');
//         return cached['data'];
//       } else {
//         print('🗑️ Cache expirado para: $key');
//         _cache.remove(key);
//       }
//     }
//     return null;
//   }

//   // ✅ CARGA PERMANENTE EN MEMORIA
//   Future<void> _cargarDatosIniciales() async {
//     try {
//       // ✅ SI YA CARGAMOS LOS DATOS PERMANENTES, SOLO USAMOS CACHÉ PARA RAPIDEZ
//       if (_datosCargados) {
//         print('🎯 Datos ya cargados permanentemente en memoria');
        
//         // Verificar caché para respuesta ultra-rápida
//         final cachedDocentes = _getFromCache('docentes_lista');
//         if (cachedDocentes != null) {
//           _docentesFiltrados = List<Docente>.from(cachedDocentes);
//           _isLoading = false;
//           notifyListeners();
//           return;
//         }
        
//         // Si no hay caché, pero los datos permanentes están cargados
//         _filtrarDocentes();
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }

//       _isLoading = true;
//       _error = null;
//       notifyListeners();

//       print('🔄 Cargando docentes PERMANENTEMENTE en memoria...');
      
//       // ✅ CARGAR DOCENTES DIRECTAMENTE EN MEMORIA (PERMANENTE)
//       _cargarTodosLosDocentesCompletos();

//       // ✅ MARCAR COMO CARGADO PERMANENTEMENTE
//       _datosCargados = true;

//       // ✅ GUARDAR EN CACHÉ PARA VELOCIDAD EXTRA
//       _updateCache('docentes_lista', _docentes);

//       _isLoading = false;
//       notifyListeners();

//       print('✅ ${_docentes.length} docentes cargados PERMANENTEMENTE en memoria');
      
//     } catch (e) {
//       _onDocentesError(e);
//     }
//   }

//   // ✅ CARGA TODOS LOS DOCENTES DIRECTAMENTE EN MEMORIA (PERMANENTE)
//   void _cargarTodosLosDocentesCompletos() {
//     // ✅ SOLO AGREGAMOS SI NO EXISTEN
//     if (_docentes.isEmpty) {
//       final now = DateTime.now();
      
//       _docentes.addAll([
//         // Omar Condori - AMBOS
//         Docente(
//           id: 'doc_001',
//           apellidoPaterno: 'Condori',
//           apellidoMaterno: '',
//           nombres: 'Omar',
//           ci: '1234567',
//           carrera: 'Sistemas Informáticos',
//           turno: 'AMBOS',
//           email: 'omar.condori@email.com',
//           telefono: '78945612',
//           estado: 'ACTIVO',
//           fechaCreacion: now,
//           fechaActualizacion: now,
//         ),
//         // Carlos Saavedra - MAÑANA
//         Docente(
//           id: 'doc_002',
//           apellidoPaterno: 'Saavedra',
//           apellidoMaterno: '',
//           nombres: 'Carlos',
//           ci: '2345678',
//           carrera: 'Sistemas Informáticos',
//           turno: 'MAÑANA',
//           email: 'carlos.saavedra@email.com',
//           telefono: '78945613',
//           estado: 'ACTIVO',
//           fechaCreacion: now,
//           fechaActualizacion: now,
//         ),
//         // Mamerito Alvarado - NOCHE
//         Docente(
//           id: 'doc_003',
//           apellidoPaterno: 'Alvarado',
//           apellidoMaterno: '',
//           nombres: 'Mamerito',
//           ci: '3456789',
//           carrera: 'Sistemas Informáticos',
//           turno: 'NOCHE',
//           email: 'mamerito.alvarado@email.com',
//           telefono: '78945614',
//           estado: 'ACTIVO',
//           fechaCreacion: now,
//           fechaActualizacion: now,
//         ),
//         // Miguel Machaca - AMBOS
//         Docente(
//           id: 'doc_004',
//           apellidoPaterno: 'Machaca',
//           apellidoMaterno: '',
//           nombres: 'Miguel',
//           ci: '4567890',
//           carrera: 'Sistemas Informáticos',
//           turno: 'AMBOS',
//           email: 'miguel.machaca@email.com',
//           telefono: '78945615',
//           estado: 'ACTIVO',
//           fechaCreacion: now,
//           fechaActualizacion: now,
//         ),
//         // Víctor Ramos - MAÑANA
//         Docente(
//           id: 'doc_005',
//           apellidoPaterno: 'Ramos',
//           apellidoMaterno: '',
//           nombres: 'Víctor',
//           ci: '5678901',
//           carrera: 'Sistemas Informáticos',
//           turno: 'MAÑANA',
//           email: 'victor.ramos@email.com',
//           telefono: '78945616',
//           estado: 'ACTIVO',
//           fechaCreacion: now,
//           fechaActualizacion: now,
//         ),
//         // Edith Gutiérrez - NOCHE
//         Docente(
//           id: 'doc_006',
//           apellidoPaterno: 'Gutiérrez',
//           apellidoMaterno: '',
//           nombres: 'Edith',
//           ci: '6789012',
//           carrera: 'Sistemas Informáticos',
//           turno: 'NOCHE',
//           email: 'edith.gutierrez@email.com',
//           telefono: '78945617',
//           estado: 'ACTIVO',
//           fechaCreacion: now,
//           fechaActualizacion: now,
//         ),
//         // Rubén Quispe - AMBOS
//         Docente(
//           id: 'doc_007',
//           apellidoPaterno: 'Quispe',
//           apellidoMaterno: '',
//           nombres: 'Rubén',
//           ci: '7890123',
//           carrera: 'Sistemas Informáticos',
//           turno: 'AMBOS',
//           email: 'ruben.quispe@email.com',
//           telefono: '78945618',
//           estado: 'ACTIVO',
//           fechaCreacion: now,
//           fechaActualizacion: now,
//         ),
//         // Marisol Méndez - MAÑANA
//         Docente(
//           id: 'doc_008',
//           apellidoPaterno: 'Méndez',
//           apellidoMaterno: '',
//           nombres: 'Marisol',
//           ci: '8901234',
//           carrera: 'Sistemas Informáticos',
//           turno: 'MAÑANA',
//           email: 'marisol.mendez@email.com',
//           telefono: '78945619',
//           estado: 'ACTIVO',
//           fechaCreacion: now,
//           fechaActualizacion: now,
//         ),
//         // Remmy Rodríguez - NOCHE
//         Docente(
//           id: 'doc_009',
//           apellidoPaterno: 'Rodríguez',
//           apellidoMaterno: '',
//           nombres: 'Remmy',
//           ci: '9012345',
//           carrera: 'Sistemas Informáticos',
//           turno: 'NOCHE',
//           email: 'remmy.rodriguez@email.com',
//           telefono: '78945620',
//           estado: 'ACTIVO',
//           fechaCreacion: now,
//           fechaActualizacion: now,
//         ),
//         // Fredy Huiza - AMBOS
//         Docente(
//           id: 'doc_010',
//           apellidoPaterno: 'Huiza',
//           apellidoMaterno: '',
//           nombres: 'Fredy',
//           ci: '0123456',
//           carrera: 'Sistemas Informáticos',
//           turno: 'AMBOS',
//           email: 'fredy.huiza@email.com',
//           telefono: '78945621',
//           estado: 'ACTIVO',
//           fechaCreacion: now,
//           fechaActualizacion: now,
//         ),
//         // Inés Condori - MAÑANA
//         Docente(
//           id: 'doc_011',
//           apellidoPaterno: 'Condori',
//           apellidoMaterno: '',
//           nombres: 'Inés',
//           ci: '1122334',
//           carrera: 'Sistemas Informáticos',
//           turno: 'MAÑANA',
//           email: 'ines.condori@email.com',
//           telefono: '78945622',
//           estado: 'ACTIVO',
//           fechaCreacion: now,
//           fechaActualizacion: now,
//         ),
//       ]);

//       // Extraer carreras únicas
//       _carreras = _docentes.map((d) => d.carrera).toSet().toList();
//       _carreras.sort();

//       _ordenarDocentes();
//       print('🎯 ${_docentes.length} docentes cargados PERMANENTEMENTE - Sistemas Informáticos');
//     } else {
//       print('📊 Docentes ya existen en memoria: ${_docentes.length}');
//     }
//   }

//   void _onDocentesError(dynamic error) {
//     print('❌ Error cargando docentes: $error');
//     _isLoading = false;
//     _error = 'Error al cargar docentes: $error';
//     notifyListeners();
//   }

//   void _ordenarDocentes() {
//     _docentes.sort((a, b) {
//       int comparacion = a.apellidoPaterno.compareTo(b.apellidoPaterno);
//       if (comparacion != 0) return comparacion;
//       comparacion = a.apellidoMaterno.compareTo(b.apellidoMaterno);
//       if (comparacion != 0) return comparacion;
//       return a.nombres.compareTo(b.nombres);
//     });
//     _filtrarDocentes();
//   }

//   void _filtrarDocentes() {
//     _searchDebounce?.cancel();
//     _searchDebounce = Timer(const Duration(milliseconds: 300), () {
//       final query = searchController.text.toLowerCase().trim();
//       if (query.isEmpty) {
//         _docentesFiltrados = _docentes.where((docente) {
//           return docente.carrera == carrera && docente.turno == turno;
//         }).toList();
//       } else {
//         _docentesFiltrados = _docentes.where((docente) {
//           final nombreCompleto =
//               '${docente.apellidoPaterno} ${docente.apellidoMaterno} ${docente.nombres}'
//                   .toLowerCase();
//           final ci = docente.ci.toLowerCase();
//           final matchesSearch =
//               nombreCompleto.contains(query) || ci.contains(query);
//           final matchesCarreraTurno =
//               docente.carrera == carrera && docente.turno == turno;

//           return matchesSearch && matchesCarreraTurno;
//         }).toList();
//       }
//       notifyListeners();
//     });
//   }

//   // ✅ MÉTODO MEJORADO PARA OPERACIONES CRUD (EN MEMORIA PERMANENTE)
//   Future<bool> _executeDatabaseOperation(
//     String operation, 
//     Future<void> Function() operationFn
//   ) async {
//     try {
//       _guardando = true;
//       _error = null;
//       notifyListeners();
      
//       await operationFn();
      
//       _guardando = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _handleError(operation, e);
//       return false;
//     }
//   }

//   // ✅ AGREGAR DOCENTE - EN MEMORIA PERMANENTE
//   Future<bool> agregarDocente({
//     required String nombres,
//     required String paterno,
//     required String materno,
//     required String ci,
//     required String turno,
//     String? email,
//     String? telefono,
//     String? carrera,
//   }) async {
//     return _executeDatabaseOperation('agregar docente', () async {
//       // Verificar si ya existe un docente con el mismo CI
//       final ciExists = _docentes.any((doc) => doc.ci == ci.trim());
      
//       if (ciExists) {
//         throw Exception('Ya existe un docente con este CI: $ci');
//       }

//       // Crear el docente
//       final docenteId = 'doc_${DateTime.now().millisecondsSinceEpoch}';
//       final now = DateTime.now();

//       final nuevoDocente = Docente(
//         id: docenteId,
//         nombres: nombres.trim(),
//         apellidoPaterno: paterno.trim(),
//         apellidoMaterno: materno.isNotEmpty ? materno.trim() : '',
//         ci: ci.trim(),
//         carrera: carrera ?? this.carrera,
//         turno: turno,
//         email: email ?? '',
//         telefono: telefono ?? '',
//         estado: 'ACTIVO',
//         fechaCreacion: now,
//         fechaActualizacion: now,
//       );

//       // ✅ AGREGAR A LA LISTA PERMANENTE
//       _docentes.add(nuevoDocente);
      
//       // ✅ ACTUALIZAR CACHÉ PARA MANTENERLO RÁPIDO
//       _updateCache('docentes_lista', _docentes);
      
//       _ordenarDocentes();

//       print('✅ Docente agregado PERMANENTEMENTE en memoria: $nombres $paterno');
//     });
//   }

//   // ✅ EDITAR DOCENTE - EN MEMORIA PERMANENTE
//   Future<bool> editarDocente({
//     required String id,
//     required String nombres,
//     required String paterno,
//     required String materno,
//     required String ci,
//     required String turno,
//     String? email,
//     String? telefono,
//     String? carrera,
//   }) async {
//     return _executeDatabaseOperation('editar docente', () async {
//       // Verificar si el CI ya existe en otro docente
//       final ciExists = _docentes.any((doc) => doc.ci == ci.trim() && doc.id != id);
      
//       if (ciExists) {
//         throw Exception('Ya existe otro docente con este CI: $ci');
//       }

//       final index = _docentes.indexWhere((doc) => doc.id == id);
//       if (index == -1) {
//         throw Exception('Docente no encontrado');
//       }

//       // ✅ ACTUALIZAR EN LA LISTA PERMANENTE
//       _docentes[index] = Docente(
//         id: _docentes[index].id,
//         nombres: nombres.trim(),
//         apellidoPaterno: paterno.trim(),
//         apellidoMaterno: materno.isNotEmpty ? materno.trim() : '',
//         ci: ci.trim(),
//         carrera: carrera ?? this.carrera,
//         turno: turno,
//         email: email ?? '',
//         telefono: telefono ?? '',
//         estado: _docentes[index].estado,
//         fechaCreacion: _docentes[index].fechaCreacion,
//         fechaActualizacion: DateTime.now(),
//       );

//       // ✅ ACTUALIZAR CACHÉ PARA MANTENERLO RÁPIDO
//       _updateCache('docentes_lista', _docentes);

//       _ordenarDocentes();
//       print('✅ Docente editado PERMANENTEMENTE en memoria: $id');
//     });
//   }

//   // ✅ ELIMINAR DOCENTE - DE LA MEMORIA PERMANENTE
//   Future<bool> eliminarDocente(String id) async {
//     return _executeDatabaseOperation('eliminar docente', () async {
//       // ✅ ELIMINAR DE LA LISTA PERMANENTE
//       _docentes.removeWhere((doc) => doc.id == id);
      
//       // ✅ ACTUALIZAR CACHÉ PARA MANTENERLO RÁPIDO
//       _updateCache('docentes_lista', _docentes);
      
//       _filtrarDocentes();
//       print('✅ Docente eliminado PERMANENTEMENTE de memoria: $id');
//     });
//   }

//   // ✅ REINTENTAR CARGA
//   Future<void> reintentarCarga() async {
//     _error = null;
//     _isLoading = true;
//     notifyListeners();
//     await _cargarDatosIniciales();
//   }

//   // ✅ MÉTODO HELPER PARA ERRORES
//   void _handleError(String operation, dynamic error) {
//     print('❌ Error $operation: $error');
//     _error = 'Error al $operation: ${error.toString()}';
//     _guardando = false;
//     notifyListeners();
//   }

//   // ✅ MÉTODOS PARA ESTADÍSTICAS
//   Map<String, int> getEstadisticasPorTurno() {
//     final docentesCarrera = _docentes
//         .where((d) => d.carrera == carrera)
//         .toList();

//     return {
//       'MAÑANA': docentesCarrera.where((d) => d.turno == 'MAÑANA').length,
//       'NOCHE': docentesCarrera.where((d) => d.turno == 'NOCHE').length,
//       'AMBOS': docentesCarrera.where((d) => d.turno == 'AMBOS').length,
//       'TOTAL': docentesCarrera.length,
//     };
//   }

//   // ✅ MÉTODO PARA OBTENER DOCENTE POR ID
//   Docente? getDocenteById(String id) {
//     try {
//       return _docentes.firstWhere((docente) => docente.id == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   @override
//   void dispose() {
//     _searchDebounce?.cancel();
//     searchController.dispose();
//     super.dispose();
//   }
// }