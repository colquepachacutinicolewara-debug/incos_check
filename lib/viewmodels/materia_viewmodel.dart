// viewmodels/materia_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/materia_model.dart';
import '../models/database_helper.dart';
import '../utils/constants.dart';

class MateriaViewModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance; // ✅ Cambio aquí
  
  List<Materia> _materias = [];
  List<Materia> _materiasFiltradas = [];
  final TextEditingController _searchController = TextEditingController();

  // Filtros para gestión de cursos
  int _anioFiltro = 0;
  String _carreraFiltro = 'Todas';
  String _paraleloFiltro = 'Todos';
  String _turnoFiltro = 'Todos';
  int _anioSeleccionado = 1;

  // Estados
  bool _isLoading = false;
  String? _error;
  bool _mostrarBurbuja = false;
  String _mensajeBurbuja = '';
  Color _colorBurbuja = Colors.green;
  
  // Controladores para el formulario
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();

  // Variables para el formulario
  int _anioSeleccionadoForm = 1;
  Color _colorSeleccionado = MateriaColors.programacion;
  String _paraleloSeleccionadoForm = 'A';
  String _turnoSeleccionadoForm = 'Mañana';
  String _carreraSeleccionadaForm = 'Sistemas Informáticos';
  String _materiaEditandoId = '';
  int get anioSeleccionado => _anioSeleccionado;

  // Opciones dinámicas
  List<String> _carrerasDisponibles = ['Sistemas Informáticos'];
  List<String> _paralelosDisponibles = ['A', 'B'];
  List<String> _turnosDisponibles = ['Mañana', 'Noche'];

  // Getters
  List<Materia> get materias => _materias;
  List<Materia> get materiasFiltradas => _materiasFiltradas;
  List<Materia> get materiasFiltradasGestion => _getMateriasFiltradasGestion();
  int get anioFiltro => _anioFiltro;
  String get carreraFiltro => _carreraFiltro;
  String get paraleloFiltro => _paraleloFiltro;
  String get turnoFiltro => _turnoFiltro;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get mostrarBurbuja => _mostrarBurbuja;
  String get mensajeBurbuja => _mensajeBurbuja;
  Color get colorBurbuja => _colorBurbuja;
  TextEditingController get searchController => _searchController;

  // Getters para opciones
  List<String> get carrerasDisponibles => _carrerasDisponibles;
  List<String> get paralelosDisponibles => _paralelosDisponibles;
  List<String> get turnosDisponibles => _turnosDisponibles;
  List<String> get paralelosFiltro => ['Todos', ..._paralelosDisponibles];
  List<String> get turnosFiltro => ['Todos', ..._turnosDisponibles];
  List<String> get carrerasFiltro => ['Todas', ..._carrerasDisponibles];

  // Getters para el formulario
  TextEditingController get codigoController => _codigoController;
  TextEditingController get nombreController => _nombreController;
  int get anioSeleccionadoForm => _anioSeleccionadoForm;
  Color get colorSeleccionado => _colorSeleccionado;
  String get paraleloSeleccionadoForm => _paraleloSeleccionadoForm;
  String get turnoSeleccionadoForm => _turnoSeleccionadoForm;
  String get carreraSeleccionadaForm => _carreraSeleccionadaForm;
  String get materiaEditandoId => _materiaEditandoId;

  void setAnioSeleccionado(int value) {
    _anioSeleccionado = value;
    notifyListeners();
  }

  MateriaViewModel() { // ✅ Constructor sin parámetros
    _initialize();
    _searchController.addListener(_filtrarMateriasHistorial);
  }

  void _initialize() async {
    await _cargarMateriasDesdeDatabase();
  }

  // ✅ CARGA DESDE SQLITE - MANTIENE TUS MATERIAS PREDEFINIDAS
  Future<void> _cargarMateriasDesdeDatabase() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Primero verificar si hay materias en la base de datos
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM materias 
        WHERE carrera = 'Sistemas Informáticos'
      ''');

      final count = (result.first['count'] as int?) ?? 0;

      if (count == 0) {
        // Si no hay materias, insertar todas las predefinidas
        await _insertarMateriasPredefinidas();
      } else {
        // Si ya hay materias, cargarlas desde la base de datos
        await _cargarMateriasExistentes();
      }

      _aplicarFiltros();
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar materias: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ INSERTAR TODAS TUS MATERIAS PREDEFINIDAS EN SQLITE
  Future<void> _insertarMateriasPredefinidas() async {
    try {
      _materias.clear();
      
      // Cargar todas tus materias predefinidas
      _cargarTodasLasMateriasCompletas();
      
      // Insertar cada materia en SQLite
      for (final materia in _materias) {
        await _databaseHelper.rawInsert('''
          INSERT INTO materias (id, codigo, nombre, carrera, anio, color, activo,
          paralelo, turno, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          materia.id,
          materia.codigo,
          materia.nombre,
          materia.carrera,
          materia.anio,
          materia.color.value.toRadixString(16).padLeft(8, '0').toUpperCase(),
          materia.activo ? 1 : 0,
          materia.paralelo,
          materia.turno,
          DateTime.now().toIso8601String(),
          DateTime.now().toIso8601String()
        ]);
      }

      print('✅ ${_materias.length} materias predefinidas insertadas en SQLite');
    } catch (e) {
      print('❌ Error insertando materias predefinidas: $e');
    }
  }

  // ✅ CARGAR MATERIAS EXISTENTES DESDE SQLITE
  Future<void> _cargarMateriasExistentes() async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM materias 
        WHERE activo = 1 
        ORDER BY carrera, anio, paralelo, turno, nombre
      ''');

      _materias = result.map((row) => 
        Materia.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      print('✅ ${_materias.length} materias cargadas desde SQLite');
    } catch (e) {
      print('❌ Error cargando materias desde SQLite: $e');
      // Si hay error, cargar las predefinidas en memoria
      _cargarTodasLasMateriasCompletas();
    }
  }

  // ========== TUS MATERIAS PREDEFINIDAS - EXACTAMENTE COMO LAS TIENES ==========

  void _cargarTodasLasMateriasCompletas() {
    _materias.clear();
    _cargarParaleloANoche();
    _cargarParaleloBNoche();
    _cargarParaleloAManana();
    _cargarParaleloBManana();
  }

  // ========== PARALELO A - TURNO NOCHE ==========
  void _cargarParaleloANoche() {
    // PRIMER AÑO - Paralelo A - Noche
    _materias.addAll([
      Materia(
        id: 'hardware_a_noche',
        codigo: 'HARD101',
        nombre: 'Hardware de Computadoras',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.redes,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'matematica_a_noche',
        codigo: 'MAT101',
        nombre: 'Matemática para la Informática',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.matematica,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'ingles_a_noche',
        codigo: 'ING101',
        nombre: 'Inglés Técnico',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.ingles,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'web1_a_noche',
        codigo: 'WEB101',
        nombre: 'Diseño y Programación Web I',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.programacion,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'ofimatica_a_noche',
        codigo: 'OFI101',
        nombre: 'Ofimática y Tecnología Multimedia',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.etica,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'sistemas-op_a_noche',
        codigo: 'SO101',
        nombre: 'Taller de Sistemas Operativos',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.fisica,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'programacion1_a_noche',
        codigo: 'PROG101',
        nombre: 'Programación I',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.programacion,
        paralelo: 'A',
        turno: 'Noche',
      ),
    ]);

    // SEGUNDO AÑO - Paralelo A - Noche
    _materias.addAll([
      Materia(
        id: 'programacion2_a_noche',
        codigo: 'PROG201',
        nombre: 'Programación II',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'estructura_a_noche',
        codigo: 'ED201',
        nombre: 'Estructura de Datos',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.matematica,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'estadistica_a_noche',
        codigo: 'EST201',
        nombre: 'Estadística',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.matematica,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'basedatos1_a_noche',
        codigo: 'BD201',
        nombre: 'Base de Datos I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.baseDatos,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'redes1_a_noche',
        codigo: 'RED201',
        nombre: 'Redes de Computadoras I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.redes,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'analisis1_a_noche',
        codigo: 'ADS201',
        nombre: 'Análisis y Diseño de Sistemas I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.etica,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'moviles1_a_noche',
        codigo: 'PM201',
        nombre: 'Programación para Dispositivos Móviles I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'web2_a_noche',
        codigo: 'WEB201',
        nombre: 'Diseño y Programación Web II',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
        paralelo: 'A',
        turno: 'Noche',
      ),
    ]);

    // TERCER AÑO - Paralelo A - Noche
    _materias.addAll([
      Materia(
        id: 'redes2_a_noche',
        codigo: 'RED301',
        nombre: 'Redes de Computadoras II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.redes,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'web3_a_noche',
        codigo: 'WEB301',
        nombre: 'Diseño y Programación Web III',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.programacion,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'moviles2_a_noche',
        codigo: 'PM301',
        nombre: 'Programación para Dispositivos Móviles II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.programacion,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'analisis2_a_noche',
        codigo: 'ADS301',
        nombre: 'Análisis y Diseño de Sistemas II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.etica,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'taller-grado_a_noche',
        codigo: 'TMG301',
        nombre: 'Taller de Modalidad de Graduación',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.ingles,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'gestion-calidad_a_noche',
        codigo: 'GMC301',
        nombre: 'Gestión y Mejoramiento de la Calidad de Software',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.etica,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'basedatos2_a_noche',
        codigo: 'BD301',
        nombre: 'Base de Datos II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.baseDatos,
        paralelo: 'A',
        turno: 'Noche',
      ),
      Materia(
        id: 'emprendimiento_a_noche',
        codigo: 'EMP301',
        nombre: 'Emprendimiento Productivo',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.ingles,
        paralelo: 'A',
        turno: 'Noche',
      ),
    ]);
  }

  // ========== PARALELO B - TURNO NOCHE ==========
  void _cargarParaleloBNoche() {
    // PRIMER AÑO - Paralelo B - Noche
    _materias.addAll([
      Materia(
        id: 'hardware_b_noche',
        codigo: 'HARD101',
        nombre: 'Hardware de Computadoras',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.redes,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'matematica_b_noche',
        codigo: 'MAT101',
        nombre: 'Matemática para la Informática',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.matematica,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'ingles_b_noche',
        codigo: 'ING101',
        nombre: 'Inglés Técnico',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.ingles,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'web1_b_noche',
        codigo: 'WEB101',
        nombre: 'Diseño y Programación Web I',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.programacion,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'ofimatica_b_noche',
        codigo: 'OFI101',
        nombre: 'Ofimática y Tecnología Multimedia',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.etica,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'sistemas-op_b_noche',
        codigo: 'SO101',
        nombre: 'Taller de Sistemas Operativos',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.fisica,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'programacion1_b_noche',
        codigo: 'PROG101',
        nombre: 'Programación I',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.programacion,
        paralelo: 'B',
        turno: 'Noche',
      ),
    ]);

    // SEGUNDO AÑO - Paralelo B - Noche
    _materias.addAll([
      Materia(
        id: 'programacion2_b_noche',
        codigo: 'PROG201',
        nombre: 'Programación II',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'estructura_b_noche',
        codigo: 'ED201',
        nombre: 'Estructura de Datos',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.matematica,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'estadistica_b_noche',
        codigo: 'EST201',
        nombre: 'Estadística',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.matematica,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'basedatos1_b_noche',
        codigo: 'BD201',
        nombre: 'Base de Datos I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.baseDatos,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'redes1_b_noche',
        codigo: 'RED201',
        nombre: 'Redes de Computadoras I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.redes,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'analisis1_b_noche',
        codigo: 'ADS201',
        nombre: 'Análisis y Diseño de Sistemas I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.etica,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'moviles1_b_noche',
        codigo: 'PM201',
        nombre: 'Programación para Dispositivos Móviles I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'web2_b_noche',
        codigo: 'WEB201',
        nombre: 'Diseño y Programación Web II',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
        paralelo: 'B',
        turno: 'Noche',
      ),
    ]);

    // TERCER AÑO - Paralelo B - Noche
    _materias.addAll([
      Materia(
        id: 'redes2_b_noche',
        codigo: 'RED301',
        nombre: 'Redes de Computadoras II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.redes,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'web3_b_noche',
        codigo: 'WEB301',
        nombre: 'Diseño y Programación Web III',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.programacion,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'moviles2_b_noche',
        codigo: 'PM301',
        nombre: 'Programación para Dispositivos Móviles II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.programacion,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'analisis2_b_noche',
        codigo: 'ADS301',
        nombre: 'Análisis y Diseño de Sistemas II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.etica,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'taller-grado_b_noche',
        codigo: 'TMG301',
        nombre: 'Taller de Modalidad de Graduación',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.ingles,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'gestion-calidad_b_noche',
        codigo: 'GMC301',
        nombre: 'Gestión y Mejoramiento de la Calidad de Software',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.etica,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'basedatos2_b_noche',
        codigo: 'BD301',
        nombre: 'Base de Datos II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.baseDatos,
        paralelo: 'B',
        turno: 'Noche',
      ),
      Materia(
        id: 'emprendimiento_b_noche',
        codigo: 'EMP301',
        nombre: 'Emprendimiento Productivo',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.ingles,
        paralelo: 'B',
        turno: 'Noche',
      ),
    ]);
  }

  // ========== PARALELO A - TURNO MAÑANA ==========
  void _cargarParaleloAManana() {
    // PRIMER AÑO - Paralelo A - Mañana
    _materias.addAll([
      Materia(
        id: 'hardware_a_manana',
        codigo: 'HARD101',
        nombre: 'Hardware de Computadoras',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.redes,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'matematica_a_manana',
        codigo: 'MAT101',
        nombre: 'Matemática para la Informática',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.matematica,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'ingles_a_manana',
        codigo: 'ING101',
        nombre: 'Inglés Técnico',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.ingles,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'web1_a_manana',
        codigo: 'WEB101',
        nombre: 'Diseño y Programación Web I',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.programacion,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'ofimatica_a_manana',
        codigo: 'OFI101',
        nombre: 'Ofimática y Tecnología Multimedia',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.etica,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'sistemas-op_a_manana',
        codigo: 'SO101',
        nombre: 'Taller de Sistemas Operativos',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.fisica,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'programacion1_a_manana',
        codigo: 'PROG101',
        nombre: 'Programación I',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.programacion,
        paralelo: 'A',
        turno: 'Mañana',
      ),
    ]);

    // SEGUNDO AÑO - Paralelo A - Mañana
    _materias.addAll([
      Materia(
        id: 'programacion2_a_manana',
        codigo: 'PROG201',
        nombre: 'Programación II',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'estructura_a_manana',
        codigo: 'ED201',
        nombre: 'Estructura de Datos',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.matematica,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'estadistica_a_manana',
        codigo: 'EST201',
        nombre: 'Estadística',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.matematica,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'basedatos1_a_manana',
        codigo: 'BD201',
        nombre: 'Base de Datos I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.baseDatos,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'redes1_a_manana',
        codigo: 'RED201',
        nombre: 'Redes de Computadoras I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.redes,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'analisis1_a_manana',
        codigo: 'ADS201',
        nombre: 'Análisis y Diseño de Sistemas I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.etica,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'moviles1_a_manana',
        codigo: 'PM201',
        nombre: 'Programación para Dispositivos Móviles I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'web2_a_manana',
        codigo: 'WEB201',
        nombre: 'Diseño y Programación Web II',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
        paralelo: 'A',
        turno: 'Mañana',
      ),
    ]);

    // TERCER AÑO - Paralelo A - Mañana
    _materias.addAll([
      Materia(
        id: 'redes2_a_manana',
        codigo: 'RED301',
        nombre: 'Redes de Computadoras II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.redes,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'web3_a_manana',
        codigo: 'WEB301',
        nombre: 'Diseño y Programación Web III',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.programacion,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'moviles2_a_manana',
        codigo: 'PM301',
        nombre: 'Programación para Dispositivos Móviles II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.programacion,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'analisis2_a_manana',
        codigo: 'ADS301',
        nombre: 'Análisis y Diseño de Sistemas II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.etica,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'taller-grado_a_manana',
        codigo: 'TMG301',
        nombre: 'Taller de Modalidad de Graduación',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.ingles,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'gestion-calidad_a_manana',
        codigo: 'GMC301',
        nombre: 'Gestión y Mejoramiento de la Calidad de Software',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.etica,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'basedatos2_a_manana',
        codigo: 'BD301',
        nombre: 'Base de Datos II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.baseDatos,
        paralelo: 'A',
        turno: 'Mañana',
      ),
      Materia(
        id: 'emprendimiento_a_manana',
        codigo: 'EMP301',
        nombre: 'Emprendimiento Productivo',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.ingles,
        paralelo: 'A',
        turno: 'Mañana',
      ),
    ]);
  }

  // ========== PARALELO B - TURNO MAÑANA ==========
  void _cargarParaleloBManana() {
    // PRIMER AÑO - Paralelo B - Mañana
    _materias.addAll([
      Materia(
        id: 'hardware_b_manana',
        codigo: 'HARD101',
        nombre: 'Hardware de Computadoras',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.redes,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'matematica_b_manana',
        codigo: 'MAT101',
        nombre: 'Matemática para la Informática',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.matematica,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'ingles_b_manana',
        codigo: 'ING101',
        nombre: 'Inglés Técnico',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.ingles,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'web1_b_manana',
        codigo: 'WEB101',
        nombre: 'Diseño y Programación Web I',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.programacion,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'ofimatica_b_manana',
        codigo: 'OFI101',
        nombre: 'Ofimática y Tecnología Multimedia',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.etica,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'sistemas-op_b_manana',
        codigo: 'SO101',
        nombre: 'Taller de Sistemas Operativos',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.fisica,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'programacion1_b_manana',
        codigo: 'PROG101',
        nombre: 'Programación I',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.programacion,
        paralelo: 'B',
        turno: 'Mañana',
      ),
    ]);

    // SEGUNDO AÑO - Paralelo B - Mañana
    _materias.addAll([
      Materia(
        id: 'programacion2_b_manana',
        codigo: 'PROG201',
        nombre: 'Programación II',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'estructura_b_manana',
        codigo: 'ED201',
        nombre: 'Estructura de Datos',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.matematica,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'estadistica_b_manana',
        codigo: 'EST201',
        nombre: 'Estadística',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.matematica,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'basedatos1_b_manana',
        codigo: 'BD201',
        nombre: 'Base de Datos I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.baseDatos,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'redes1_b_manana',
        codigo: 'RED201',
        nombre: 'Redes de Computadoras I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.redes,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'analisis1_b_manana',
        codigo: 'ADS201',
        nombre: 'Análisis y Diseño de Sistemas I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.etica,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'moviles1_b_manana',
        codigo: 'PM201',
        nombre: 'Programación para Dispositivos Móviles I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'web2_b_manana',
        codigo: 'WEB201',
        nombre: 'Diseño y Programación Web II',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
        paralelo: 'B',
        turno: 'Mañana',
      ),
    ]);

    // TERCER AÑO - Paralelo B - Mañana
    _materias.addAll([
      Materia(
        id: 'redes2_b_manana',
        codigo: 'RED301',
        nombre: 'Redes de Computadoras II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.redes,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'web3_b_manana',
        codigo: 'WEB301',
        nombre: 'Diseño y Programación Web III',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.programacion,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'moviles2_b_manana',
        codigo: 'PM301',
        nombre: 'Programación para Dispositivos Móviles II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.programacion,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'analisis2_b_manana',
        codigo: 'ADS301',
        nombre: 'Análisis y Diseño de Sistemas II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.etica,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'taller-grado_b_manana',
        codigo: 'TMG301',
        nombre: 'Taller de Modalidad de Graduación',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.ingles,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'gestion-calidad_b_manana',
        codigo: 'GMC301',
        nombre: 'Gestión y Mejoramiento de la Calidad de Software',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.etica,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'basedatos2_b_manana',
        codigo: 'BD301',
        nombre: 'Base de Datos II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.baseDatos,
        paralelo: 'B',
        turno: 'Mañana',
      ),
      Materia(
        id: 'emprendimiento_b_manana',
        codigo: 'EMP301',
        nombre: 'Emprendimiento Productivo',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.ingles,
        paralelo: 'B',
        turno: 'Mañana',
      ),
    ]);
  }

  // ========== FILTRADO ==========

  void _aplicarFiltros() {
    _filtrarMateriasHistorial();
  }

  List<Materia> _getMateriasFiltradasGestion() {
    return _materias.where((materia) {
      bool anioOk = _anioFiltro == 0 || materia.anio == _anioFiltro;
      bool carreraOk = _carreraFiltro == 'Todas' || materia.carrera == _carreraFiltro;
      bool paraleloOk = _paraleloFiltro == 'Todos' || materia.paralelo == _paraleloFiltro;
      bool turnoOk = _turnoFiltro == 'Todos' || materia.turno == _turnoFiltro;
      
      return anioOk && carreraOk && paraleloOk && turnoOk;
    }).toList();
  }

  void _filtrarMateriasHistorial() {
    final query = _searchController.text.toLowerCase();
    _materiasFiltradas.clear();

    if (query.isEmpty) {
      _materiasFiltradas.addAll(_materias);
    } else {
      _materiasFiltradas.addAll(
        _materias.where(
          (materia) =>
              materia.nombre.toLowerCase().contains(query) ||
              materia.codigo.toLowerCase().contains(query) ||
              materia.carrera.toLowerCase().contains(query),
        ),
      );
    }
    notifyListeners();
  }

  // ========== MÉTODOS CRUD PARA SQLITE ==========

  // ✅ AGREGAR NUEVA MATERIA
  Future<void> agregarMateria() async {
    try {
      if (_codigoController.text.isEmpty || _nombreController.text.isEmpty) {
        _mostrarMensajeBurbuja('Código y nombre son requeridos', Colors.orange);
        return;
      }

      _isLoading = true;
      notifyListeners();

      final materiaId = 'materia_${DateTime.now().millisecondsSinceEpoch}';
      final nuevaMateria = Materia(
        id: materiaId,
        codigo: _codigoController.text.trim(),
        nombre: _nombreController.text.trim(),
        carrera: _carreraSeleccionadaForm,
        anio: _anioSeleccionadoForm,
        color: _colorSeleccionado,
        paralelo: _paraleloSeleccionadoForm,
        turno: _turnoSeleccionadoForm,
        activo: true,
      );

      await _databaseHelper.rawInsert('''
        INSERT INTO materias (id, codigo, nombre, carrera, anio, color, activo,
        paralelo, turno, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        nuevaMateria.id,
        nuevaMateria.codigo,
        nuevaMateria.nombre,
        nuevaMateria.carrera,
        nuevaMateria.anio,
        nuevaMateria.color.value.toRadixString(16).padLeft(8, '0').toUpperCase(),
        nuevaMateria.activo ? 1 : 0,
        nuevaMateria.paralelo,
        nuevaMateria.turno,
        DateTime.now().toIso8601String(),
        DateTime.now().toIso8601String()
      ]);

      // Recargar desde la base de datos
      await _cargarMateriasExistentes();
      
      _limpiarFormulario();
      _mostrarMensajeBurbuja('Materia agregada correctamente', Colors.green);
      
    } catch (e) {
      _mostrarMensajeBurbuja('Error al agregar materia: $e', Colors.red);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ CARGAR MATERIA PARA EDITAR
  void cargarMateriaParaEditar(Materia materia) {
    _materiaEditandoId = materia.id;
    _codigoController.text = materia.codigo;
    _nombreController.text = materia.nombre;
    _carreraSeleccionadaForm = materia.carrera;
    _anioSeleccionadoForm = materia.anio;
    _colorSeleccionado = materia.color;
    _paraleloSeleccionadoForm = materia.paralelo;
    _turnoSeleccionadoForm = materia.turno;
    notifyListeners();
  }

  // ✅ ACTUALIZAR MATERIA
  Future<void> actualizarMateria() async {
    try {
      if (_codigoController.text.isEmpty || _nombreController.text.isEmpty) {
        _mostrarMensajeBurbuja('Código y nombre son requeridos', Colors.orange);
        return;
      }

      _isLoading = true;
      notifyListeners();

      await _databaseHelper.rawUpdate('''
        UPDATE materias 
        SET codigo = ?, nombre = ?, carrera = ?, anio = ?, color = ?,
        paralelo = ?, turno = ?, updated_at = ?
        WHERE id = ?
      ''', [
        _codigoController.text.trim(),
        _nombreController.text.trim(),
        _carreraSeleccionadaForm,
        _anioSeleccionadoForm,
        _colorSeleccionado.value.toRadixString(16).padLeft(8, '0').toUpperCase(),
        _paraleloSeleccionadoForm,
        _turnoSeleccionadoForm,
        DateTime.now().toIso8601String(),
        _materiaEditandoId
      ]);

      // Recargar desde la base de datos
      await _cargarMateriasExistentes();
      
      _limpiarFormulario();
      _mostrarMensajeBurbuja('Materia actualizada correctamente', Colors.green);
      
    } catch (e) {
      _mostrarMensajeBurbuja('Error al actualizar materia: $e', Colors.red);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ DESACTIVAR MATERIA
  Future<void> desactivarMateria(String id) async {
    try {
      await _databaseHelper.rawUpdate('''
        UPDATE materias SET activo = 0, updated_at = ? WHERE id = ?
      ''', [DateTime.now().toIso8601String(), id]);

      await _cargarMateriasExistentes();
      _mostrarMensajeBurbuja('Materia desactivada', Colors.orange);
    } catch (e) {
      _mostrarMensajeBurbuja('Error al desactivar materia: $e', Colors.red);
    }
  }

  // ✅ ACTIVAR MATERIA
  Future<void> activarMateria(String id) async {
    try {
      await _databaseHelper.rawUpdate('''
        UPDATE materias SET activo = 1, updated_at = ? WHERE id = ?
      ''', [DateTime.now().toIso8601String(), id]);

      await _cargarMateriasExistentes();
      _mostrarMensajeBurbuja('Materia activada', Colors.green);
    } catch (e) {
      _mostrarMensajeBurbuja('Error al activar materia: $e', Colors.red);
    }
  }

  // ✅ ELIMINAR MATERIA
  Future<void> eliminarMateria(String id) async {
    try {
      await _databaseHelper.rawDelete('''
        DELETE FROM materias WHERE id = ?
      ''', [id]);

      await _cargarMateriasExistentes();
      _mostrarMensajeBurbuja('Materia eliminada', Colors.red);
    } catch (e) {
      _mostrarMensajeBurbuja('Error al eliminar materia: $e', Colors.red);
    }
  }

  // ✅ LIMPIAR FORMULARIO
  void _limpiarFormulario() {
    _materiaEditandoId = '';
    _codigoController.clear();
    _nombreController.clear();
    _carreraSeleccionadaForm = 'Sistemas Informáticos';
    _anioSeleccionadoForm = 1;
    _colorSeleccionado = MateriaColors.programacion;
    _paraleloSeleccionadoForm = 'A';
    _turnoSeleccionadoForm = 'Mañana';
    notifyListeners();
  }

  // ========== UTILIDADES ==========

  void limpiarFiltros() {
    _anioFiltro = 0;
    _carreraFiltro = 'Todas';
    _paraleloFiltro = 'Todos';
    _turnoFiltro = 'Todos';
    _searchController.clear();
    _aplicarFiltros();
    notifyListeners();
  }

  void _mostrarMensajeBurbuja(String mensaje, Color color) {
    _mensajeBurbuja = mensaje;
    _colorBurbuja = color;
    _mostrarBurbuja = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      _mostrarBurbuja = false;
      notifyListeners();
    });
  }

  void ocultarBurbuja() {
    _mostrarBurbuja = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Setters para gestión de cursos
  void setAnioFiltro(int value) {
    _anioFiltro = value;
    _aplicarFiltros();
    notifyListeners();
  }

  void setCarreraFiltro(String value) {
    _carreraFiltro = value;
    _aplicarFiltros();
    notifyListeners();
  }

  void setParaleloFiltro(String value) {
    _paraleloFiltro = value;
    _aplicarFiltros();
    notifyListeners();
  }

  void setTurnoFiltro(String value) {
    _turnoFiltro = value;
    _aplicarFiltros();
    notifyListeners();
  }

  // Setters para el formulario
  void setAnioSeleccionadoForm(int value) {
    _anioSeleccionadoForm = value;
    notifyListeners();
  }

  void setColorSeleccionado(Color color) {
    _colorSeleccionado = color;
    notifyListeners();
  }

  void setParaleloSeleccionadoForm(String value) {
    _paraleloSeleccionadoForm = value;
    notifyListeners();
  }

  void setTurnoSeleccionadoForm(String value) {
    _turnoSeleccionadoForm = value;
    notifyListeners();
  }

  void setCarreraSeleccionadaForm(String value) {
    _carreraSeleccionadaForm = value;
    notifyListeners();
  }

  void setMateriaEditandoId(String id) {
    _materiaEditandoId = id;
    notifyListeners();
  }

  // Métodos de utilidad para colores e íconos
  Color getColorAnio(int anio) {
    switch (anio) {
      case 1: return Colors.amber;
      case 2: return Colors.green;
      case 3: return Colors.blue;
      default: return Colors.grey;
    }
  }

  Color getColorParalelo(String paralelo) {
    switch (paralelo) {
      case 'A': return Colors.red;
      case 'B': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData obtenerIconoTurno(String turno) {
    switch (turno.toLowerCase()) {
      case 'mañana': return Icons.wb_sunny;
      case 'noche': return Icons.nights_stay;
      default: return Icons.schedule;
    }
  }

  IconData obtenerIconoMateria(String nombreMateria) {
    if (nombreMateria.toLowerCase().contains('programación') ||
        nombreMateria.toLowerCase().contains('web')) {
      return Icons.code;
    } else if (nombreMateria.toLowerCase().contains('base de datos')) {
      return Icons.storage;
    } else if (nombreMateria.toLowerCase().contains('redes')) {
      return Icons.lan;
    } else if (nombreMateria.toLowerCase().contains('matemática') ||
        nombreMateria.toLowerCase().contains('estadística')) {
      return Icons.calculate;
    } else if (nombreMateria.toLowerCase().contains('inglés')) {
      return Icons.language;
    } else if (nombreMateria.toLowerCase().contains('hardware')) {
      return Icons.computer;
    } else if (nombreMateria.toLowerCase().contains('sistemas operativos')) {
      return Icons.settings;
    } else {
      return Icons.book;
    }
  }

  String obtenerTextoFiltros() {
    List<String> filtros = [];
    if (_anioFiltro != 0) filtros.add('$_anioFiltro° Año');
    if (_carreraFiltro != 'Todas') filtros.add(_carreraFiltro);
    if (_paraleloFiltro != 'Todos') filtros.add('Paralelo $_paraleloFiltro');
    if (_turnoFiltro != 'Todos') filtros.add('Turno $_turnoFiltro');
    return filtros.isEmpty ? 'Sin filtros aplicados' : 'Filtros: ${filtros.join(' • ')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _codigoController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  // ✅ MÉTODO PÚBLICO PARA RECARGAR MATERIAS
Future<void> recargarMaterias() async {
  print('🔄 Recargando materias desde historial...');
  await _cargarMateriasDesdeDatabase();
}
}

