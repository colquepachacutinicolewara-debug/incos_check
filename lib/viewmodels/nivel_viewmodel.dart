import 'package:flutter/material.dart';
import '../models/nivel_model.dart';
import '../models/database_helper.dart';

class NivelViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  // Parámetros opcionales con valores por defecto
  Map<String, dynamic> carrera;
  Map<String, dynamic> turno;
  String tipo;

  List<NivelModel> _niveles = [];
  List<NivelModel> get niveles => _niveles;

  final TextEditingController _nombreController = TextEditingController();
  TextEditingController get nombreController => _nombreController;

  final TextEditingController _editarNombreController = TextEditingController();
  TextEditingController get editarNombreController => _editarNombreController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  // CONSTRUCTOR CORREGIDO - Sin parámetro DatabaseHelper requerido
  NivelViewModel({
    Map<String, dynamic>? carrera,
    Map<String, dynamic>? turno,
    this.tipo = 'Niveles',
  }) : carrera = carrera ?? {'id': '', 'nombre': 'General', 'color': '#1565C0'},
       turno = turno ?? {'id': '', 'nombre': 'General'} {
    _cargarNiveles();
  }

  Future<void> _cargarNiveles() async {
    try {
      _isLoading = true;
      notifyListeners();

      String query = 'SELECT * FROM niveles WHERE 1=1';
      List<Object?> params = [];

      // Agregar filtros solo si los IDs no están vacíos
      if (carrera['id']?.toString().isNotEmpty == true) {
        query += ' AND carrera_id = ?';
        params.add(carrera['id']?.toString());
      }
      if (turno['id']?.toString().isNotEmpty == true) {
        query += ' AND turno_id = ?';
        params.add(turno['id']?.toString());
      }

      query += ' ORDER BY orden';

      final nivelesData = await _databaseHelper.rawQuery(query, params);

      _niveles = nivelesData.map((nivelMap) => 
        NivelModel.fromMap(Map<String, dynamic>.from(nivelMap))
      ).toList();

      // SOLO para "Sistemas Informáticos" agregar nivel por defecto si no hay
      if (_niveles.isEmpty && _esSistemasInformaticos()) {
        await _agregarNivelPorDefectoSistemas();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error cargando niveles: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _esSistemasInformaticos() {
    return carrera['nombre'] == 'Sistemas Informáticos';
  }

  Future<void> _agregarNivelPorDefectoSistemas() async {
    try {
      final nivelPorDefecto = NivelModel(
        id: '${turno['id']}_tercero_${DateTime.now().millisecondsSinceEpoch}',
        nombre: 'Tercero',
        activo: true,
        orden: 3,
        paralelos: [],
      );

      await _databaseHelper.rawInsert('''
        INSERT INTO niveles (id, nombre, activo, orden, paralelos, carrera_id, turno_id, fecha_creacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        nivelPorDefecto.id,
        nivelPorDefecto.nombre,
        nivelPorDefecto.activo ? 1 : 0,
        nivelPorDefecto.orden,
        '[]', // paralelos vacíos como JSON
        carrera['id']?.toString() ?? '',
        turno['id']?.toString() ?? '',
        DateTime.now().toIso8601String(),
      ]);

      await _cargarNiveles();
    } catch (e) {
      print('Error agregando nivel por defecto: $e');
    }
  }

  // Mapeo de nombres de nivel a año numérico
  int obtenerAnioDesdeNivel(String nombreNivel) {
    switch (nombreNivel.toLowerCase()) {
      case 'primero': return 1;
      case 'segundo': return 2;
      case 'tercero': return 3;
      case 'cuarto': return 4;
      case 'quinto': return 5;
      default: return 1;
    }
  }

  int obtenerCantidadMaterias(String nombreNivel) {
    int anio = obtenerAnioDesdeNivel(nombreNivel);
    // Retorna cantidad fija basada en el año
    switch (anio) {
      case 1: return 7;
      case 2: return 8;
      case 3: return 8;
      default: return 0;
    }
  }

  Future<bool> agregarNivel(String nombre) async {
    try {
      String nombreLower = nombre.toLowerCase().trim();
      int orden = _ordenNiveles[nombreLower] ?? 99;

      // Verificar si ya existe
      String query = 'SELECT COUNT(*) as count FROM niveles WHERE 1=1';
      List<Object?> params = [];

      if (carrera['id']?.toString().isNotEmpty == true) {
        query += ' AND carrera_id = ?';
        params.add(carrera['id']?.toString());
      }
      if (turno['id']?.toString().isNotEmpty == true) {
        query += ' AND turno_id = ?';
        params.add(turno['id']?.toString());
      }
      query += ' AND LOWER(nombre) = ?';
      params.add(nombreLower);

      final existe = await _databaseHelper.rawQuery(query, params);

      final count = (existe.first['count'] as int?) ?? 0;
      if (count > 0) {
        return false; // Ya existe
      }

      final nuevoNivel = NivelModel(
        id: '${turno['id']}_${DateTime.now().millisecondsSinceEpoch}',
        nombre: _capitalizarPrimeraLetra(nombre),
        activo: true,
        orden: orden,
        paralelos: [],
      );

      await _databaseHelper.rawInsert('''
        INSERT INTO niveles (id, nombre, activo, orden, paralelos, carrera_id, turno_id, fecha_creacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        nuevoNivel.id,
        nuevoNivel.nombre,
        nuevoNivel.activo ? 1 : 0,
        nuevoNivel.orden,
        '[]',
        carrera['id']?.toString() ?? '',
        turno['id']?.toString() ?? '',
        DateTime.now().toIso8601String(),
      ]);

      await _cargarNiveles();
      return true;
    } catch (e) {
      print('Error agregando nivel: $e');
      return false;
    }
  }

  Future<bool> editarNivel(NivelModel nivel, String nuevoNombre) async {
    try {
      String nombreLower = nuevoNombre.toLowerCase().trim();
      int nuevoOrden = _ordenNiveles[nombreLower] ?? nivel.orden;

      // Verificar si ya existe (excluyendo el actual)
      String query = 'SELECT COUNT(*) as count FROM niveles WHERE 1=1';
      List<Object?> params = [];

      if (carrera['id']?.toString().isNotEmpty == true) {
        query += ' AND carrera_id = ?';
        params.add(carrera['id']?.toString());
      }
      if (turno['id']?.toString().isNotEmpty == true) {
        query += ' AND turno_id = ?';
        params.add(turno['id']?.toString());
      }
      query += ' AND LOWER(nombre) = ? AND id != ?';
      params.addAll([nombreLower, nivel.id]);

      final existe = await _databaseHelper.rawQuery(query, params);

      final count = (existe.first['count'] as int?) ?? 0;
      if (count > 0) {
        return false; // Ya existe
      }

      await _databaseHelper.rawUpdate('''
        UPDATE niveles SET nombre = ?, orden = ? 
        WHERE id = ?
      ''', [
        _capitalizarPrimeraLetra(nuevoNombre),
        nuevoOrden,
        nivel.id,
      ]);

      await _cargarNiveles();
      return true;
    } catch (e) {
      print('Error editando nivel: $e');
      return false;
    }
  }

  Future<bool> eliminarNivel(NivelModel nivel) async {
    try {
      await _databaseHelper.rawDelete('''
        DELETE FROM niveles WHERE id = ?
      ''', [nivel.id]);

      await _cargarNiveles();
      return true;
    } catch (e) {
      print('Error eliminando nivel: $e');
      return false;
    }
  }

  Future<bool> toggleActivarNivel(NivelModel nivel, bool value) async {
    try {
      await _databaseHelper.rawUpdate('''
        UPDATE niveles SET activo = ? WHERE id = ?
      ''', [
        value ? 1 : 0,
        nivel.id,
      ]);

      await _cargarNiveles();
      return true;
    } catch (e) {
      print('Error cambiando estado nivel: $e');
      return false;
    }
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