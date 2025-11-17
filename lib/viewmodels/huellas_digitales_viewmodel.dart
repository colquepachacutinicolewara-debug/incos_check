// viewmodels/huellas_digitales_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/huella_model.dart';
import '../models/estudiante_model.dart';
import '../models/database_helper.dart';

class HuellasDigitalesViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  List<Estudiante> _estudiantes = [];
  List<Estudiante> _estudiantesFiltrados = [];
  Map<String, List<HuellaModel>> _huellasPorEstudiante = {};
  
  bool _isLoading = false;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  List<Estudiante> get estudiantes => _estudiantes;
  List<Estudiante> get estudiantesFiltrados => _estudiantesFiltrados;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TextEditingController get searchController => _searchController;

  HuellasDigitalesViewModel() {
    _cargarEstudiantesYHuellas();
    _searchController.addListener(_filtrarEstudiantes);
  }

  Future<void> _cargarEstudiantesYHuellas() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Cargar estudiantes
      final estudiantesResult = await _databaseHelper.rawQuery('''
        SELECT * FROM estudiantes WHERE activo = 1 
        ORDER BY apellido_paterno, apellido_materno, nombres
      ''');

      _estudiantes = estudiantesResult.map((row) => 
        Estudiante.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      // Cargar huellas para cada estudiante
      for (final estudiante in _estudiantes) {
        final huellasResult = await _databaseHelper.obtenerHuellasPorEstudiante(estudiante.id);
        _huellasPorEstudiante[estudiante.id] = huellasResult.map((row) => 
          HuellaModel.fromMap(Map<String, dynamic>.from(row))
        ).toList();
      }

      _filtrarEstudiantes();
      print('✅ ${_estudiantes.length} estudiantes y huellas cargados');

    } catch (e) {
      _error = 'Error al cargar datos: $e';
      print('❌ Error cargando estudiantes y huellas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _filtrarEstudiantes() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _estudiantesFiltrados = List.from(_estudiantes);
    } else {
      _estudiantesFiltrados = _estudiantes.where((estudiante) {
        return estudiante.nombreCompleto.toLowerCase().contains(query) ||
               estudiante.ci.contains(query);
      }).toList();
    }
    notifyListeners();
  }

  // 🆕 OBTENER HUELLAS DE UN ESTUDIANTE
  List<HuellaModel> obtenerHuellasDeEstudiante(String estudianteId) {
    return _huellasPorEstudiante[estudianteId] ?? [];
  }

  // 🆕 REGISTRAR NUEVA HUELLA
  Future<bool> registrarHuella({
    required String estudianteId,
    required int numeroDedo,
    required String templateData,
  }) async {
    try {
      final huellaId = 'huella_${estudianteId}_$numeroDedo';
      final nombresDedos = {
        1: 'Pulgar', 2: 'Índice', 3: 'Medio', 4: 'Anular', 5: 'Meñique'
      };

      final nuevaHuella = HuellaModel(
        id: huellaId,
        estudianteId: estudianteId,
        numeroDedo: numeroDedo,
        nombreDedo: nombresDedos[numeroDedo] ?? 'Dedo $numeroDedo',
        icono: 'fingerprint',
        registrada: true,
        templateData: templateData,
        fechaRegistro: DateTime.now().toIso8601String(),
      );

      await _databaseHelper.insertarHuellaBiometrica(nuevaHuella.toMap());

      // Actualizar estado de huellas del estudiante
      await _actualizarEstadoHuellasEstudiante(estudianteId);

      // Recargar datos
      await _cargarEstudiantesYHuellas();
      
      print('✅ Huella registrada para estudiante: $estudianteId');
      return true;

    } catch (e) {
      _error = 'Error registrando huella: $e';
      print('❌ Error registrando huella: $e');
      notifyListeners();
      return false;
    }
  }

  // 🆕 ELIMINAR HUELLA
  Future<bool> eliminarHuella(String huellaId, String estudianteId) async {
    try {
      await _databaseHelper.eliminarHuellaBiometrica(huellaId);

      // Actualizar estado de huellas del estudiante
      await _actualizarEstadoHuellasEstudiante(estudianteId);

      // Recargar datos
      await _cargarEstudiantesYHuellas();
      
      print('✅ Huella eliminada: $huellaId');
      return true;

    } catch (e) {
      _error = 'Error eliminando huella: $e';
      print('❌ Error eliminando huella: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> _actualizarEstadoHuellasEstudiante(String estudianteId) async {
    try {
      final huellas = await _databaseHelper.obtenerHuellasPorEstudiante(estudianteId);
      final huellasRegistradas = huellas.where((h) => h['registrada'] == 1).length;

      await _databaseHelper.rawUpdate('''
        UPDATE estudiantes 
        SET huellas_registradas = ?, fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        huellasRegistradas,
        DateTime.now().toIso8601String(),
        estudianteId
      ]);

    } catch (e) {
      print('❌ Error actualizando estado de huellas: $e');
    }
  }

  // 🆕 VERIFICAR SI UN DEDO YA ESTÁ REGISTRADO
  Future<bool> verificarDedoRegistrado(String estudianteId, int numeroDedo) async {
    try {
      final huella = await _databaseHelper.obtenerHuellaPorDedo(estudianteId, numeroDedo);
      return huella != null && huella['registrada'] == 1;
    } catch (e) {
      return false;
    }
  }

  // 🆕 ESTADÍSTICAS DE HUELLAS
  Map<String, dynamic> obtenerEstadisticasHuellas() {
    final totalEstudiantes = _estudiantes.length;
    final estudiantesConHuellas = _estudiantes.where((e) => e.tieneHuellasRegistradas).length;
    final estudiantesSinHuellas = totalEstudiantes - estudiantesConHuellas;
    final estudiantesCompletos = _estudiantes.where((e) => e.tieneTodasLasHuellas).length;

    // Contar huellas registradas en total
    final totalHuellasRegistradas = _huellasPorEstudiante.values
        .fold(0, (sum, huellas) => sum + huellas.where((h) => h.registrada).length);

    return {
      'total_estudiantes': totalEstudiantes,
      'con_huellas': estudiantesConHuellas,
      'sin_huellas': estudiantesSinHuellas,
      'completos': estudiantesCompletos,
      'total_huellas_registradas': totalHuellasRegistradas,
      'porcentaje_con_huellas': totalEstudiantes > 0 ? 
          (estudiantesConHuellas / totalEstudiantes * 100).roundToDouble() : 0.0,
    };
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