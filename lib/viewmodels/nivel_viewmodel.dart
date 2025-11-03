import 'package:flutter/material.dart';
import '../models/nivel_model.dart';
import 'package:incos_check/utils/data_manager.dart';

class NivelesViewModel with ChangeNotifier {
  final DataManager _dataManager = DataManager();
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;
  final String tipo;

  List<NivelModel> _niveles = [];
  List<NivelModel> get niveles => _niveles;

  final TextEditingController _nombreController = TextEditingController();
  TextEditingController get nombreController => _nombreController;

  final TextEditingController _editarNombreController = TextEditingController();
  TextEditingController get editarNombreController => _editarNombreController;

  // Mapeo de nombres a valores de orden
  final Map<String, int> _ordenNiveles = {
    'primero': 1,
    'segundo': 2,
    'tercero': 3,
    'cuarto': 4,
    'quinto': 5,
    'sexto': 6,
    'séptimo': 7,
    'octavo': 8,
    'noveno': 9,
    'décimo': 10,
  };

  // Mapeo de años a materias para Sistemas Informáticos
  final Map<int, List<Map<String, dynamic>>> _materiasPorAnio = {
    1: [
      {
        'id': 'hardware',
        'codigo': 'HARD101',
        'nombre': 'Hardware de Computadoras',
        'color': '#FF6B6B',
      },
      {
        'id': 'matematica',
        'codigo': 'MAT101',
        'nombre': 'Matemática para la Informática',
        'color': '#4ECDC4',
      },
      {
        'id': 'ingles',
        'codigo': 'ING101',
        'nombre': 'Inglés Técnico',
        'color': '#45B7D1',
      },
      {
        'id': 'web1',
        'codigo': 'WEB101',
        'nombre': 'Diseño y Programación Web I',
        'color': '#96CEB4',
      },
      {
        'id': 'ofimatica',
        'codigo': 'OFI101',
        'nombre': 'Ofimática y Tecnología Multimedia',
        'color': '#FECA57',
      },
      {
        'id': 'sistemas-op',
        'codigo': 'SO101',
        'nombre': 'Taller de Sistemas Operativos',
        'color': '#FF9FF3',
      },
      {
        'id': 'programacion1',
        'codigo': 'PROG101',
        'nombre': 'Programación I',
        'color': '#54A0FF',
      },
    ],
    2: [
      {
        'id': 'programacion2',
        'codigo': 'PROG201',
        'nombre': 'Programación II',
        'color': '#54A0FF',
      },
      {
        'id': 'estructura',
        'codigo': 'ED201',
        'nombre': 'Estructura de Datos',
        'color': '#4ECDC4',
      },
      {
        'id': 'estadistica',
        'codigo': 'EST201',
        'nombre': 'Estadística',
        'color': '#4ECDC4',
      },
      {
        'id': 'basedatos1',
        'codigo': 'BD201',
        'nombre': 'Base de Datos I',
        'color': '#A55EEA',
      },
      {
        'id': 'redes1',
        'codigo': 'RED201',
        'nombre': 'Redes de Computadoras I',
        'color': '#FF6B6B',
      },
      {
        'id': 'analisis1',
        'codigo': 'ADS201',
        'nombre': 'Análisis y Diseño de Sistemas I',
        'color': '#F78FB3',
      },
      {
        'id': 'moviles1',
        'codigo': 'PM201',
        'nombre': 'Programación para Dispositivos Móviles I',
        'color': '#54A0FF',
      },
      {
        'id': 'web2',
        'codigo': 'WEB201',
        'nombre': 'Diseño y Programación Web II',
        'color': '#96CEB4',
      },
    ],
    3: [
      {
        'id': 'redes2',
        'codigo': 'RED301',
        'nombre': 'Redes de Computadoras II',
        'color': '#FF6B6B',
      },
      {
        'id': 'web3',
        'codigo': 'WEB301',
        'nombre': 'Diseño y Programación Web III',
        'color': '#96CEB4',
      },
      {
        'id': 'moviles2',
        'codigo': 'PM301',
        'nombre': 'Programación para Dispositivos Móviles II',
        'color': '#54A0FF',
      },
      {
        'id': 'analisis2',
        'codigo': 'ADS301',
        'nombre': 'Análisis y Diseño de Sistemas II',
        'color': '#F78FB3',
      },
      {
        'id': 'taller-grado',
        'codigo': 'TMG301',
        'nombre': 'Taller de Modalidad de Graduación',
        'color': '#45B7D1',
      },
      {
        'id': 'gestion-calidad',
        'codigo': 'GMC301',
        'nombre': 'Gestión y Mejoramiento de la Calidad de Software',
        'color': '#F78FB3',
      },
      {
        'id': 'basedatos2',
        'codigo': 'BD301',
        'nombre': 'Base de Datos II',
        'color': '#A55EEA',
      },
      {
        'id': 'emprendimiento',
        'codigo': 'EMP301',
        'nombre': 'Emprendimiento Productivo',
        'color': '#45B7D1',
      },
    ],
  };

  NivelesViewModel({
    required this.carrera,
    required this.turno,
    required this.tipo,
  }) {
    _cargarNiveles();
  }

  void _cargarNiveles() {
    final nivelesData = _dataManager.getNiveles(
      carrera['id'].toString(),
      turno['id'].toString(),
    );

    _niveles = nivelesData
        .map((nivelMap) => NivelModel.fromMap(nivelMap))
        .toList();

    // SOLO para "Sistemas Informáticos" agregar nivel por defecto
    if (_niveles.isEmpty && _esSistemasInformaticos()) {
      _agregarNivelPorDefectoSistemas();
    } else {
      _ordenarNiveles();
      notifyListeners();
    }
  }

  bool _esSistemasInformaticos() {
    return carrera['nombre'] == 'Sistemas Informáticos';
  }

  void _agregarNivelPorDefectoSistemas() {
    final nivelPorDefecto = NivelModel(
      id: '${turno['id']}_tercero',
      nombre: 'Tercero',
      activo: true,
      orden: 3,
      paralelos: [],
    );

    _dataManager.agregarNivel(
      carrera['id'].toString(),
      turno['id'].toString(),
      nivelPorDefecto.toMap(),
    );

    _cargarNiveles();
  }

  void _ordenarNiveles() {
    _niveles.sort((a, b) => a.orden.compareTo(b.orden));
  }

  // Mapeo de nombres de nivel a año numérico
  int obtenerAnioDesdeNivel(String nombreNivel) {
    switch (nombreNivel.toLowerCase()) {
      case 'primero':
        return 1;
      case 'segundo':
        return 2;
      case 'tercero':
        return 3;
      case 'cuarto':
        return 4;
      case 'quinto':
        return 5;
      default:
        return 1;
    }
  }

  int obtenerCantidadMaterias(String nombreNivel) {
    int anio = obtenerAnioDesdeNivel(nombreNivel);
    return _materiasPorAnio[anio]?.length ?? 0;
  }

  void agregarNivel(String nombre) {
    String nombreLower = nombre.toLowerCase().trim();
    int orden = _ordenNiveles[nombreLower] ?? 99;

    final nuevoNivel = NivelModel(
      id: '${turno['id']}_${DateTime.now().millisecondsSinceEpoch}',
      nombre: _capitalizarPrimeraLetra(nombre),
      activo: true,
      orden: orden,
      paralelos: [],
    );

    _dataManager.agregarNivel(
      carrera['id'].toString(),
      turno['id'].toString(),
      nuevoNivel.toMap(),
    );

    _cargarNiveles();
  }

  void editarNivel(NivelModel nivel, String nuevoNombre) {
    String nombreLower = nuevoNombre.toLowerCase().trim();
    int nuevoOrden = _ordenNiveles[nombreLower] ?? nivel.orden;

    final nivelActualizado = nivel.copyWith(
      nombre: _capitalizarPrimeraLetra(nuevoNombre),
      orden: nuevoOrden,
    );

    _dataManager.actualizarNivel(
      carrera['id'].toString(),
      turno['id'].toString(),
      nivel.id,
      nivelActualizado.toMap(),
    );

    _cargarNiveles();
  }

  void eliminarNivel(NivelModel nivel) {
    _dataManager.eliminarNivel(
      carrera['id'].toString(),
      turno['id'].toString(),
      nivel.id,
    );

    _cargarNiveles();
  }

  void toggleActivarNivel(NivelModel nivel, bool value) {
    final nivelActualizado = nivel.copyWith(activo: value);

    _dataManager.actualizarNivel(
      carrera['id'].toString(),
      turno['id'].toString(),
      nivel.id,
      nivelActualizado.toMap(),
    );

    _cargarNiveles();
  }

  String _capitalizarPrimeraLetra(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  void limpiarControladores() {
    _nombreController.clear();
    _editarNombreController.clear();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _editarNombreController.dispose();
    super.dispose();
  }
}
