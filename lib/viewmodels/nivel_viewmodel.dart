import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/data_manager.dart';
import 'package:incos_check/models/nivel_model.dart';

class NivelViewModel extends ChangeNotifier {
  final DataManager _dataManager = DataManager();
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;
  final String tipo;

  List<NivelModel> _niveles = [];
  List<NivelModel> get niveles => _niveles;

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController editarNombreController = TextEditingController();

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

  NivelViewModel({
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

  // CRUD Operations

  void agregarNivel(String nombre) {
    if (nombre.trim().isEmpty) return;

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

    _cargarNiveles(); // Esto ya llama a notifyListeners()
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

  // Helper methods
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

  int obtenerCantidadMaterias(NivelModel nivel) {
    int anio = obtenerAnioDesdeNivel(nivel.nombre);
    // Retornar 0 por ahora, puedes implementar la lógica de materias después
    return 0;
  }

  String obtenerNumeroRomano(int numero) {
    switch (numero) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      case 4:
        return 'IV';
      case 5:
        return 'V';
      case 6:
        return 'VI';
      case 7:
        return 'VII';
      case 8:
        return 'VIII';
      case 9:
        return 'IX';
      case 10:
        return 'X';
      default:
        return numero.toString();
    }
  }

  String _capitalizarPrimeraLetra(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  Color parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    editarNombreController.dispose();
    super.dispose();
  }
}
