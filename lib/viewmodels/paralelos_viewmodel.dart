import 'package:flutter/material.dart';
import 'package:incos_check/utils/data_manager.dart';
import '../models/paralelo_model.dart';

class ParalelosViewModel extends ChangeNotifier {
  final DataManager _dataManager = DataManager();
  List<Paralelo> _paralelos = [];
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _editarNombreController = TextEditingController();

  List<Paralelo> get paralelos => _paralelos;
  TextEditingController get nombreController => _nombreController;
  TextEditingController get editarNombreController => _editarNombreController;

  String _tipo = '';
  Map<String, dynamic> _carrera = {};
  Map<String, dynamic> _turno = {};
  Map<String, dynamic> _nivel = {};

  void inicializarDatos({
    required String tipo,
    required Map<String, dynamic> carrera,
    required Map<String, dynamic> turno,
    required Map<String, dynamic> nivel,
  }) {
    _tipo = tipo;
    _carrera = carrera;
    _turno = turno;
    _nivel = nivel;

    _inicializarYcargarParalelos();
  }

  void _inicializarYcargarParalelos() {
    _dataManager.inicializarCarrera(
      _carrera['id'].toString(),
      _carrera['nombre'],
      _carrera['color'],
    );

    final bool esSistemasTerceroNoche =
        _carrera['nombre'].toUpperCase().contains('SISTEMAS') &&
        _nivel['nombre'] == 'Tercero' &&
        _turno['nombre'] == 'Noche';

    if (esSistemasTerceroNoche) {
      _cargarParaleloEjemploSistemas();
    } else {
      _cargarParalelosDataManager();
    }
  }

  void _cargarParaleloEjemploSistemas() {
    _paralelos = [
      Paralelo(
        id: 'sistemas_noche_tercero_B',
        nombre: 'B',
        activo: true,
        estudiantes: [
          {
            'id': 1,
            'nombres': 'Juan Carlos',
            'apellidoPaterno': 'Pérez',
            'apellidoMaterno': 'Gómez',
            'ci': '1234567',
            'fechaRegistro': '2024-01-15',
            'huellasRegistradas': 3,
          },
          {
            'id': 2,
            'nombres': 'María Elena',
            'apellidoPaterno': 'López',
            'apellidoMaterno': 'Martínez',
            'ci': '7654321',
            'fechaRegistro': '2024-01-16',
            'huellasRegistradas': 2,
          },
        ],
      ),
    ];
    notifyListeners();
  }

  void _cargarParalelosDataManager() {
    final paralelosData = _dataManager.getParalelos(
      _carrera['id'].toString(),
      _turno['id'].toString(),
      _nivel['id'].toString(),
    );

    _paralelos = paralelosData.map((map) => Paralelo.fromMap(map)).toList();
    notifyListeners();
  }

  bool get esCarreraDeEjemplo {
    return _carrera['nombre'].toUpperCase().contains('SISTEMAS') &&
        _nivel['nombre'] == 'Tercero' &&
        _turno['nombre'] == 'Noche';
  }

  bool esParaleloEjemplo(Paralelo paralelo) {
    return esCarreraDeEjemplo && paralelo.id == 'sistemas_noche_tercero_B';
  }

  void agregarParalelo(String nombre) {
    bool existe = _paralelos.any((p) => p.nombre == nombre);

    if (existe) {
      throw Exception('Ya existe un paralelo con la letra $nombre');
    }

    final nuevoParalelo = Paralelo(
      id: '${_carrera['id']}_${_turno['id']}_${_nivel['id']}_$nombre',
      nombre: nombre,
      activo: true,
      estudiantes: [],
    );

    _dataManager.agregarParalelo(
      _carrera['id'].toString(),
      _turno['id'].toString(),
      _nivel['id'].toString(),
      nuevoParalelo.toMap(),
    );

    _paralelos.add(nuevoParalelo);
    _paralelos.sort((a, b) => a.nombre.compareTo(b.nombre));
    notifyListeners();
  }

  void cambiarEstadoParalelo(Paralelo paralelo, bool nuevoEstado) {
    final index = _paralelos.indexWhere((p) => p.id == paralelo.id);
    if (index != -1) {
      _paralelos[index] = paralelo.copyWith(activo: nuevoEstado);

      _dataManager.actualizarParalelo(
        _carrera['id'].toString(),
        _turno['id'].toString(),
        _nivel['id'].toString(),
        paralelo.id,
        _paralelos[index].toMap(),
      );
      notifyListeners();
    }
  }

  void editarParalelo(Paralelo paralelo, String nuevoNombre) {
    bool existe = _paralelos.any(
      (p) => p.nombre == nuevoNombre && p.id != paralelo.id,
    );

    if (existe) {
      throw Exception('Ya existe un paralelo con la letra $nuevoNombre');
    }

    final index = _paralelos.indexWhere((p) => p.id == paralelo.id);
    if (index != -1) {
      _paralelos[index] = paralelo.copyWith(nombre: nuevoNombre);
      _paralelos.sort((a, b) => a.nombre.compareTo(b.nombre));

      _dataManager.actualizarParalelo(
        _carrera['id'].toString(),
        _turno['id'].toString(),
        _nivel['id'].toString(),
        paralelo.id,
        _paralelos[index].toMap(),
      );
      notifyListeners();
    }
  }

  void eliminarParalelo(Paralelo paralelo) {
    _paralelos.removeWhere((p) => p.id == paralelo.id);

    _dataManager.eliminarParalelo(
      _carrera['id'].toString(),
      _turno['id'].toString(),
      _nivel['id'].toString(),
      paralelo.id,
    );
    notifyListeners();
  }

  Map<String, dynamic> get carrera => _carrera;
  Map<String, dynamic> get turno => _turno;
  Map<String, dynamic> get nivel => _nivel;
  String get tipo => _tipo;

  @override
  void dispose() {
    _nombreController.dispose();
    _editarNombreController.dispose();
    super.dispose();
  }
}
