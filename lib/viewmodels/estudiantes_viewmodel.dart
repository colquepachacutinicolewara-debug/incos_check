// viewmodels/estudiantes_viewmodel.dart - VERSIÓN SIMPLIFICADA COMO MATERIAS
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:async';
import '../models/estudiante_model.dart';
import '../models/database_helper.dart';

class EstudiantesViewModel with ChangeNotifier {
  List<Estudiante> _estudiantes = [];
  List<Estudiante> _estudiantesFiltrados = [];
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Listas para los dropdowns
  List<Map<String, dynamic>> _carreras = [];
  List<Map<String, dynamic>> _turnos = [];
  List<Map<String, dynamic>> _niveles = [];
  List<Map<String, dynamic>> _paralelos = [];

  String tipo;
  Map<String, dynamic> carrera;
  Map<String, dynamic> turno;
  Map<String, dynamic> nivel;
  Map<String, dynamic> paralelo;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Getters para las listas
  List<Map<String, dynamic>> get carreras => _carreras;
  List<Map<String, dynamic>> get turnos => _turnos;
  List<Map<String, dynamic>> get niveles => _niveles;
  List<Map<String, dynamic>> get paralelos => _paralelos;

  // CONSTRUCTOR
  EstudiantesViewModel({
    this.tipo = 'Estudiantes',
    Map<String, dynamic>? carrera,
    Map<String, dynamic>? turno,
    Map<String, dynamic>? nivel,
    Map<String, dynamic>? paralelo,
  }) : carrera = carrera ?? {'id': 'sistemas', 'nombre': 'Sistemas Informáticos', 'color': '#1565C0'},
       turno = turno ?? {'id': 'noche', 'nombre': 'Noche'},
       nivel = nivel ?? {'id': 'tercero', 'nombre': 'Tercero'},
       paralelo = paralelo ?? {'id': 'b', 'nombre': 'B'} {
    _inicializarViewModel();
  }

  void _inicializarViewModel() {
    _cargarDatosIniciales();
    searchController.addListener(_filtrarEstudiantes);
  }

  // Getters
  List<Estudiante> get estudiantes => _estudiantes;
  List<Estudiante> get estudiantesFiltrados => _estudiantesFiltrados;

  // ✅ MÉTODO PÚBLICO PARA RECARGAR ESTUDIANTES (COMO EN MATERIAS)
  Future<void> recargarEstudiantes() async {
    print('🔄 Recargando estudiantes desde historial...');
    await _cargarDatosIniciales();
  }

  // ✅ CARGA DIRECTA EN MEMORIA COMO MATERIAS
  Future<void> _cargarDatosIniciales() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Cargando estudiantes en memoria...');
      
      // Cargar estudiantes directamente en memoria
      _cargarTodosLosEstudiantesCompletos();

      _isLoading = false;
      notifyListeners();

      print('✅ ${_estudiantes.length} estudiantes cargados en memoria');
      
    } catch (e) {
      _onEstudiantesError(e);
    }
  }

  // ✅ CARGA TODOS LOS ESTUDIANTES DIRECTAMENTE EN MEMORIA
  void _cargarTodosLosEstudiantesCompletos() {
    _estudiantes.clear();
    
    // ESTUDIANTES DE TERCERO "B" - NOCHE - SISTEMAS INFORMÁTICOS
    _estudiantes.addAll([
      // NRO 1-8 con CIs 15590001-15590008
      Estudiante(
        id: 'est_001',
        nombres: 'Jhoshanes Israel',
        apellidoPaterno: 'Anllon',
        apellidoMaterno: 'Martínez',
        ci: '15590001',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_002',
        nombres: 'Jade Silvia',
        apellidoPaterno: 'Anti',
        apellidoMaterno: 'Quispe',
        ci: '15590002',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_003',
        nombres: 'Vladimir',
        apellidoPaterno: 'Apaza',
        apellidoMaterno: 'Choque',
        ci: '15590003',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_004',
        nombres: 'Mario Edwin',
        apellidoPaterno: 'Apaza',
        apellidoMaterno: 'Mamani',
        ci: '15590004',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_005',
        nombres: 'Jhonathan Rafael',
        apellidoPaterno: 'Aquise',
        apellidoMaterno: 'Mamani',
        ci: '15590005',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_006',
        nombres: 'Miguel Alejandro',
        apellidoPaterno: 'Calle',
        apellidoMaterno: 'Chipana',
        ci: '15590006',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_007',
        nombres: 'Esteban',
        apellidoPaterno: 'Callizaya',
        apellidoMaterno: 'Quispe',
        ci: '15590007',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_008',
        nombres: 'Brayan Rey',
        apellidoPaterno: 'Choque',
        apellidoMaterno: 'Huanaca',
        ci: '15590008',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),

      // NRO 9-38 con CIs 15600433-15600462
      Estudiante(
        id: 'est_009',
        nombres: 'Nicole Wara',
        apellidoPaterno: 'Colque',
        apellidoMaterno: 'Pachacoti',
        ci: '15600433',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_010',
        nombres: 'Kevin Bernardo',
        apellidoPaterno: 'Espinoza',
        apellidoMaterno: 'Ramos',
        ci: '15600434',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      // ... Continúa con los demás estudiantes exactamente igual
      Estudiante(
        id: 'est_011',
        nombres: 'Edwin',
        apellidoPaterno: 'Flores',
        apellidoMaterno: 'Mita',
        ci: '15600435',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_012',
        nombres: 'Miguel Angel',
        apellidoPaterno: 'Flores',
        apellidoMaterno: 'Nina',
        ci: '15600436',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_013',
        nombres: 'Anahi Katherin',
        apellidoPaterno: 'Guarachi',
        apellidoMaterno: 'Anahi',
        ci: '15600437',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_014',
        nombres: 'Bladimir Denilson',
        apellidoPaterno: 'Huacho',
        apellidoMaterno: 'Ejido',
        ci: '15600438',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_015',
        nombres: 'Niko Dennis',
        apellidoPaterno: 'Huanca',
        apellidoMaterno: 'Gutierrez',
        ci: '15600439',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_016',
        nombres: 'Santos',
        apellidoPaterno: 'Huanca',
        apellidoMaterno: 'Limachi',
        ci: '15600440',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_017',
        nombres: 'Luz Fabiola',
        apellidoPaterno: 'Lima',
        apellidoMaterno: 'Espinoza',
        ci: '15600441',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_018',
        nombres: 'Edison Gonzalo',
        apellidoPaterno: 'Mamani',
        apellidoMaterno: 'Chuquvi',
        ci: '15600442',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_019',
        nombres: 'Yura Helen Yesica',
        apellidoPaterno: 'Mayta',
        apellidoMaterno: 'Mamani',
        ci: '15600443',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_020',
        nombres: 'Jhamil Raymer',
        apellidoPaterno: 'Mamani',
        apellidoMaterno: 'Mamani',
        ci: '15600444',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_021',
        nombres: 'Alvi Monzerrat',
        apellidoPaterno: 'Mela',
        apellidoMaterno: 'Mostajo',
        ci: '15600445',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_022',
        nombres: 'Reynaldo Brayan',
        apellidoPaterno: 'Mendoza',
        apellidoMaterno: 'Herrera',
        ci: '15600446',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_023',
        nombres: 'Luque Limber Rodrigo',
        apellidoPaterno: 'Nina',
        apellidoMaterno: 'Flores',
        ci: '15600447',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_024',
        nombres: 'Belinda Araceli',
        apellidoPaterno: 'Nina',
        apellidoMaterno: 'Flores',
        ci: '15600448',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_025',
        nombres: 'Patricia Jael',
        apellidoPaterno: 'Paco',
        apellidoMaterno: 'Huertas',
        ci: '15600449',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_026',
        nombres: 'Adriel Alejandro',
        apellidoPaterno: 'Paco',
        apellidoMaterno: 'Huertas',
        ci: '15600450',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_027',
        nombres: 'Ticona Natanael',
        apellidoPaterno: 'Paco',
        apellidoMaterno: 'Mamani',
        ci: '15600451',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_028',
        nombres: 'Alvin Kevin',
        apellidoPaterno: 'Patzi',
        apellidoMaterno: 'Mujica',
        ci: '15600452',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_029',
        nombres: 'Ilan Kevin',
        apellidoPaterno: 'Poma',
        apellidoMaterno: 'Condori',
        ci: '15600453',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_030',
        nombres: 'Jose Franz',
        apellidoPaterno: 'Pinto',
        apellidoMaterno: 'Callisaya',
        ci: '15600454',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_031',
        nombres: 'Juan Salvador',
        apellidoPaterno: 'Quispe',
        apellidoMaterno: 'Aluviri',
        ci: '15600455',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_032',
        nombres: 'Misael',
        apellidoPaterno: 'Quispe',
        apellidoMaterno: 'Condori',
        ci: '15600456',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_033',
        nombres: 'Cinthia',
        apellidoPaterno: 'Quispe',
        apellidoMaterno: 'Quispe',
        ci: '15600457',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_034',
        nombres: 'Juan Pablo',
        apellidoPaterno: 'Ramírez',
        apellidoMaterno: 'Aguilar',
        ci: '15600458',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_035',
        nombres: 'Briner Jordy',
        apellidoPaterno: 'Ronquillo',
        apellidoMaterno: 'Condori',
        ci: '15600459',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_036',
        nombres: 'Grover',
        apellidoPaterno: 'Tambo',
        apellidoMaterno: 'Mamani',
        ci: '15600460',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_037',
        nombres: 'Alan Yahir',
        apellidoPaterno: 'Tito',
        apellidoMaterno: 'Gutiérrez',
        ci: '15600461',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
      Estudiante(
        id: 'est_038',
        nombres: 'Alejandro Gabriel',
        apellidoPaterno: 'Villa',
        apellidoMaterno: 'Salinas',
        ci: '15600462',
        fechaRegistro: '2024-01-15',
        huellasRegistradas: 0,
        carreraId: 'sistemas',
        turnoId: 'noche',
        nivelId: 'tercero',
        paraleloId: 'b',
        fechaCreacion: DateTime.now().toIso8601String(),
        fechaActualizacion: DateTime.now().toIso8601String(),
      ),
    ]);

    _ordenarEstudiantes();
    print('🎯 ${_estudiantes.length} estudiantes cargados en memoria - Tercero B Noche');
  }

  void _onEstudiantesError(dynamic error) {
    print('❌ Error cargando estudiantes: $error');
    _isLoading = false;
    _error = 'Error al cargar estudiantes: $error';
    notifyListeners();
  }

  void _ordenarEstudiantes() {
    _estudiantes.sort((a, b) {
      int comparacion = a.apellidoPaterno.compareTo(b.apellidoPaterno);
      if (comparacion != 0) return comparacion;
      comparacion = a.apellidoMaterno.compareTo(b.apellidoMaterno);
      if (comparacion != 0) return comparacion;
      return a.nombres.compareTo(b.nombres);
    });
    _filtrarEstudiantes();
  }

  void _filtrarEstudiantes() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      final query = searchController.text.toLowerCase().trim();
      if (query.isEmpty) {
        _estudiantesFiltrados = List.from(_estudiantes);
      } else {
        _estudiantesFiltrados = _estudiantes.where((estudiante) {
          return estudiante.nombres.toLowerCase().contains(query) ||
              estudiante.apellidoPaterno.toLowerCase().contains(query) ||
              estudiante.apellidoMaterno.toLowerCase().contains(query) ||
              estudiante.ci.contains(query);
        }).toList();
      }
      notifyListeners();
    });
  }

  // ✅ MÉTODO MEJORADO PARA OPERACIONES CRUD (EN MEMORIA)
  Future<bool> _executeDatabaseOperation(
    String operation, 
    Future<void> Function() operationFn
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await operationFn();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(operation, e);
      return false;
    }
  }

  // ✅ AGREGAR ESTUDIANTE - EN MEMORIA
  Future<bool> agregarEstudiante({
    required String nombres,
    required String paterno,
    required String materno,
    required String ci,
    String? carreraId,
    String? turnoId,
    String? nivelId,
    String? paraleloId,
  }) async {
    return _executeDatabaseOperation('agregar estudiante', () async {
      // Verificar si ya existe un estudiante con el mismo CI
      final ciExists = _estudiantes.any((est) => est.ci == ci.trim());
      
      if (ciExists) {
        throw Exception('Ya existe un estudiante con este CI: $ci');
      }

      // Crear el estudiante
      final estudianteId = 'est_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();
      final fechaRegistro = DateTime.now().toString().split(' ')[0];

      final nuevoEstudiante = Estudiante(
        id: estudianteId,
        nombres: nombres.trim(),
        apellidoPaterno: paterno.trim(),
        apellidoMaterno: materno.trim(),
        ci: ci.trim(),
        fechaRegistro: fechaRegistro,
        huellasRegistradas: 0,
        carreraId: carreraId ?? 'sistemas',
        turnoId: turnoId ?? 'noche',
        nivelId: nivelId ?? 'tercero',
        paraleloId: paraleloId ?? 'b',
        fechaCreacion: now,
        fechaActualizacion: now,
      );

      _estudiantes.add(nuevoEstudiante);
      _ordenarEstudiantes();

      print('✅ Estudiante agregado en memoria: $nombres $paterno');
    });
  }

  // ✅ EDITAR ESTUDIANTE - EN MEMORIA
  Future<bool> editarEstudiante({
    required String id,
    required String nombres,
    required String paterno,
    required String materno,
    required String ci,
    String? carreraId,
    String? turnoId,
    String? nivelId,
    String? paraleloId,
  }) async {
    return _executeDatabaseOperation('editar estudiante', () async {
      // Verificar si el CI ya existe en otro estudiante
      final ciExists = _estudiantes.any((est) => est.ci == ci.trim() && est.id != id);
      
      if (ciExists) {
        throw Exception('Ya existe otro estudiante con este CI: $ci');
      }

      final index = _estudiantes.indexWhere((est) => est.id == id);
      if (index == -1) {
        throw Exception('Estudiante no encontrado');
      }

      _estudiantes[index] = _estudiantes[index].copyWith(
        nombres: nombres.trim(),
        apellidoPaterno: paterno.trim(),
        apellidoMaterno: materno.trim(),
        ci: ci.trim(),
        carreraId: carreraId ?? 'sistemas',
        turnoId: turnoId ?? 'noche',
        nivelId: nivelId ?? 'tercero',
        paraleloId: paraleloId ?? 'b',
        fechaActualizacion: DateTime.now().toIso8601String(),
      );

      _ordenarEstudiantes();
      print('✅ Estudiante editado en memoria: $id');
    });
  }

  // ✅ ELIMINAR ESTUDIANTE - EN MEMORIA
  Future<bool> eliminarEstudiante(String id) async {
    return _executeDatabaseOperation('eliminar estudiante', () async {
      _estudiantes.removeWhere((est) => est.id == id);
      _filtrarEstudiantes();
      print('✅ Estudiante eliminado de memoria: $id');
    });
  }

  // ✅ ACTUALIZAR HUELLAS - EN MEMORIA
  Future<bool> actualizarHuellasEstudiante(
    String id,
    int huellasRegistradas,
  ) async {
    try {
      final index = _estudiantes.indexWhere((est) => est.id == id);
      if (index == -1) {
        throw Exception('Estudiante no encontrado');
      }

      _estudiantes[index] = _estudiantes[index].copyWith(
        huellasRegistradas: huellasRegistradas,
        fechaActualizacion: DateTime.now().toIso8601String(),
      );

      notifyListeners();
      print('✅ Huellas actualizadas en memoria: $id a $huellasRegistradas');
      return true;
    } catch (e) {
      print('❌ Error actualizando huellas: $e');
      _error = 'Error al actualizar huellas: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ REINTENTAR CARGA
  Future<void> reintentarCarga() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    await _cargarDatosIniciales();
  }

  // ✅ MÉTODO HELPER PARA ERRORES
  void _handleError(String operation, dynamic error) {
    print('❌ Error $operation: $error');
    _error = 'Error al $operation: ${error.toString()}';
    _isLoading = false;
    notifyListeners();
  }

  // Los métodos de exportación permanecen igual...
  Future<void> exportarExcel({
    bool simple = true,
    String asignatura = 'BASE DE DATOS II',
  }) async {
    try {
      final csvContent = buildCsvString(simple, asignatura);
      
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/lista_estudiantes_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      await file.writeAsString(csvContent, flush: true);
      await Share.shareXFiles([XFile(file.path)], text: 'Lista de estudiantes');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> exportarPDF({
    bool simple = true,
    String asignatura = 'BASE DE DATOS II',
  }) async {
    try {
      final doc = buildPdfDocument(_estudiantesFiltrados, simple, asignatura);
      final bytes = await doc.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'lista_estudiantes_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      rethrow;
    }
  }

  pw.Document buildPdfDocument(
    List<Estudiante> estudiantes,
    bool simple,
    String asignatura,
  ) {
    final doc = pw.Document();

    estudiantes.sort((a, b) {
      int c = a.apellidoPaterno.compareTo(b.apellidoPaterno);
      if (c != 0) return c;
      c = a.apellidoMaterno.compareTo(b.apellidoMaterno);
      if (c != 0) return c;
      return a.nombres.compareTo(b.nombres);
    });

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'INSTITUTO TÉCNICO COMERCIAL "INCOS - EL ALTO"',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(asignatura, style: pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'CARRERA: ${carrera['nombre']}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'TURNO: ${turno['nombre']}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'CURSO: ${nivel['nombre']} - Paralelo ${paralelo['nombre']}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 8),
                ],
              ),
            ),
            pw.SizedBox(height: 6),
            if (simple)
              pw.Column(
                children: [
                  pw.Table.fromTextArray(
                    headers: ['NRO', 'ESTUDIANTES'],
                    data: List<List<String>>.generate(estudiantes.length, (i) {
                      final e = estudiantes[i];
                      return [
                        '${i + 1}',
                        '${e.apellidoPaterno} ${e.apellidoMaterno} ${e.nombres}',
                      ];
                    }),
                  ),
                ],
              )
            else
              pw.Column(
                children: [
                  pw.Table.fromTextArray(
                    headers: ['NRO', 'ESTUDIANTE', 'CI', 'Registro', 'Huellas'],
                    data: List<List<String>>.generate(estudiantes.length, (i) {
                      final e = estudiantes[i];
                      return [
                        '${i + 1}',
                        '${e.apellidoPaterno} ${e.apellidoMaterno} ${e.nombres}',
                        e.ci,
                        e.fechaRegistro,
                        '${e.huellasRegistradas}/3',
                      ];
                    }),
                  ),
                ],
              ),
          ];
        },
      ),
    );

    return doc;
  }

  String buildCsvString(bool simple, String asignatura) {
    final sb = StringBuffer();
    sb.writeln('INSTITUCIÓN,$asignatura,,');
    sb.writeln(
      'CARRERA: ${carrera['nombre']},TURNO: ${turno['nombre']},NIVEL: ${nivel['nombre']},PARAL: ${paralelo['nombre']}',
    );
    sb.writeln();

    final estudiantesExportar = _estudiantesFiltrados;
    estudiantesExportar.sort((a, b) {
      int c = a.apellidoPaterno.compareTo(b.apellidoPaterno);
      if (c != 0) return c;
      c = a.apellidoMaterno.compareTo(b.apellidoMaterno);
      if (c != 0) return c;
      return a.nombres.compareTo(b.nombres);
    });

    if (simple) {
      sb.writeln('NRO,ESTUDIANTE');
      int nro = 1;
      for (var e in estudiantesExportar) {
        final name = '${e.apellidoPaterno} ${e.apellidoMaterno} ${e.nombres}'
            .replaceAll(',', '');
        sb.writeln('$nro,"$name"');
        nro++;
      }
    } else {
      sb.writeln('NRO,ESTUDIANTE,CI,FECHA REGISTRO,HUELLAS');
      int nro = 1;
      for (var e in estudiantesExportar) {
        final name = '${e.apellidoPaterno} ${e.apellidoMaterno} ${e.nombres}'
            .replaceAll(',', '');
        sb.writeln(
          '$nro,"$name",${e.ci},${e.fechaRegistro},${e.huellasRegistradas}/3',
        );
        nro++;
      }
    }

    return sb.toString();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}