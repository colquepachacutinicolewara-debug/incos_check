// viewmodels/bimestre_viewmodel.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/periodo_academico_model.dart';
import '../models/database_helper.dart';

class BimestreViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  List<PeriodoAcademico> _bimestres = [];
  List<PeriodoAcademico> get bimestres => _bimestres;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  // Controladores para edición (MISMO QUE ANTES)
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  // Variables para edición (MISMO QUE ANTES)
  String _bimestreEditandoId = '';
  String _estadoSeleccionado = 'Planificado';

  TextEditingController get nombreController => _nombreController;
  TextEditingController get fechaInicioController => _fechaInicioController;
  TextEditingController get fechaFinController => _fechaFinController;
  TextEditingController get descripcionController => _descripcionController;
  String get estadoSeleccionado => _estadoSeleccionado;

  BimestreViewModel() {
    cargarBimestres();
  }

  Future<void> cargarBimestres() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // ✅ SIEMPRE CARGAR 4 BIMESTRES
      await _cargarOCrearBimestres();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar bimestres: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cargarOCrearBimestres() async {
    try {
      // Intentar cargar bimestres existentes
      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM periodos_academicos 
        WHERE tipo = 'Bimestral'
        ORDER BY numero
      ''');

      if (result.isNotEmpty) {
        _bimestres = result.map((row) => 
          PeriodoAcademico.fromMap(Map<String, dynamic>.from(row))
        ).toList();
        print('✅ ${_bimestres.length} bimestres cargados desde SQLite');
      }

      // ✅ GARANTIZAR QUE SIEMPRE HAY 4 BIMESTRES
      if (_bimestres.length < 4) {
        await _completarBimestresFaltantes();
      }

      // Ordenar por número
      _bimestres.sort((a, b) => a.numero.compareTo(b.numero));

    } catch (e) {
      print('❌ Error cargando bimestres: $e');
      _cargarBimestresEnMemoria();
    }
  }

  Future<void> _completarBimestresFaltantes() async {
    try {
      final numerosExistentes = _bimestres.map((b) => b.numero).toSet();
      final todosBimestres = _crearBimestresCompletos();
      
      for (final bimestre in todosBimestres) {
        if (!numerosExistentes.contains(bimestre.numero)) {
          // Insertar bimestre faltante
          await _databaseHelper.rawInsert('''
            INSERT INTO periodos_academicos (
              id, nombre, tipo, numero, fecha_inicio, fecha_fin, 
              estado, fechas_clases, descripcion, fecha_creacion,
              total_clases, duracion_dias
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''', [
            bimestre.id,
            bimestre.nombre,
            bimestre.tipo,
            bimestre.numero,
            bimestre.fechaInicio.toIso8601String(),
            bimestre.fechaFin.toIso8601String(),
            bimestre.estado,
            json.encode(bimestre.fechasClases),
            bimestre.descripcion,
            bimestre.fechaCreacion.toIso8601String(),
            bimestre.totalClasesComputed,
            bimestre.duracionDiasComputed,
          ]);
          
          _bimestres.add(bimestre);
          print('✅ Bimestre ${bimestre.numero} insertado');
        }
      }
      
      notifyListeners();
      
    } catch (e) {
      print('❌ Error completando bimestres: $e');
      _cargarBimestresEnMemoria();
    }
  }

  List<PeriodoAcademico> _crearBimestresCompletos() {
    final now = DateTime.now();
    return [
      PeriodoAcademico(
        id: 'bim1_${now.millisecondsSinceEpoch}',
        nombre: 'Primer Bimestre',
        tipo: 'Bimestral',
        numero: 1,
        fechaInicio: DateTime(2024, 2, 1),
        fechaFin: DateTime(2024, 3, 31),
        estado: 'Finalizado',
        fechasClases: _generarFechasClases(DateTime(2024, 2, 1), DateTime(2024, 3, 31)),
        descripcion: 'Primer bimestre académico 2024',
        fechaCreacion: DateTime(2024, 1, 15),
      ),
      PeriodoAcademico(
        id: 'bim2_${now.millisecondsSinceEpoch + 1}',
        nombre: 'Segundo Bimestre',
        tipo: 'Bimestral',
        numero: 2,
        fechaInicio: DateTime(2024, 4, 1),
        fechaFin: DateTime(2024, 5, 31),
        estado: 'En Curso',
        fechasClases: _generarFechasClases(DateTime(2024, 4, 1), DateTime(2024, 5, 31)),
        descripcion: 'Segundo bimestre académico 2024',
        fechaCreacion: DateTime(2024, 3, 15),
      ),
      PeriodoAcademico(
        id: 'bim3_${now.millisecondsSinceEpoch + 2}',
        nombre: 'Tercer Bimestre',
        tipo: 'Bimestral',
        numero: 3,
        fechaInicio: DateTime(2024, 6, 1),
        fechaFin: DateTime(2024, 7, 31),
        estado: 'Planificado',
        fechasClases: _generarFechasClases(DateTime(2024, 6, 1), DateTime(2024, 7, 31)),
        descripcion: 'Tercer bimestre académico 2024',
        fechaCreacion: DateTime(2024, 5, 15),
      ),
      PeriodoAcademico(
        id: 'bim4_${now.millisecondsSinceEpoch + 3}',
        nombre: 'Cuarto Bimestre',
        tipo: 'Bimestral',
        numero: 4,
        fechaInicio: DateTime(2024, 8, 1),
        fechaFin: DateTime(2024, 9, 30),
        estado: 'Planificado',
        fechasClases: _generarFechasClases(DateTime(2024, 8, 1), DateTime(2024, 9, 30)),
        descripcion: 'Cuarto bimestre académico 2024',
        fechaCreacion: DateTime(2024, 7, 15),
      ),
    ];
  }

  void _cargarBimestresEnMemoria() {
    _bimestres = _crearBimestresCompletos();
    print('✅ ${_bimestres.length} bimestres cargados en memoria');
  }

  List<String> _generarFechasClases(DateTime inicio, DateTime fin) {
    List<String> fechas = [];
    DateTime fechaActual = inicio;
    
    while (fechaActual.isBefore(fin) || fechaActual.isAtSameMomentAs(fin)) {
      if (fechaActual.weekday >= DateTime.monday && fechaActual.weekday <= DateTime.friday) {
        fechas.add('${fechaActual.day.toString().padLeft(2, '0')}/${fechaActual.month.toString().padLeft(2, '0')}');
      }
      fechaActual = fechaActual.add(const Duration(days: 1));
    }
    
    return fechas;
  }

  // ✅ MÉTODOS CRUD COMPLETOS (IGUAL QUE TU PERIODOACADEMICOVIEWMODEL)

  Future<bool> editarBimestreCompleto(
    String bimestreId,
    String nuevoNombre,
    String nuevoTipo,
    int nuevoNumero,
    DateTime nuevaFechaInicio,
    DateTime nuevaFechaFin,
    String nuevoEstado,
    String nuevaDescripcion,
  ) async {
    try {
      final bimestreIndex = _bimestres.indexWhere((b) => b.id == bimestreId);
      if (bimestreIndex == -1) {
        _error = 'Bimestre no encontrado';
        notifyListeners();
        return false;
      }

      // Verificar si ya existe otro bimestre con el mismo número
      if (nuevoNumero != _bimestres[bimestreIndex].numero) {
        final existe = await _databaseHelper.rawQuery('''
          SELECT COUNT(*) as count FROM periodos_academicos 
          WHERE numero = ? AND tipo = ? AND id != ?
        ''', [nuevoNumero, nuevoTipo, bimestreId]);

        final count = (existe.first['count'] as int?) ?? 0;
        if (count > 0) {
          _error = 'Ya existe otro bimestre con el mismo número y tipo';
          notifyListeners();
          return false;
        }
      }

      final nuevasFechasClases = _generarFechasClases(nuevaFechaInicio, nuevaFechaFin);

      final bimestreActualizado = PeriodoAcademico(
        id: bimestreId,
        nombre: nuevoNombre,
        tipo: nuevoTipo,
        numero: nuevoNumero,
        fechaInicio: nuevaFechaInicio,
        fechaFin: nuevaFechaFin,
        estado: nuevoEstado,
        fechasClases: nuevasFechasClases,
        descripcion: nuevaDescripcion,
        fechaCreacion: _bimestres[bimestreIndex].fechaCreacion,
      );

      // Actualizar en SQLite
      await _databaseHelper.rawUpdate('''
        UPDATE periodos_academicos SET 
        nombre = ?, tipo = ?, numero = ?, fecha_inicio = ?, fecha_fin = ?,
        estado = ?, fechas_clases = ?, descripcion = ?,
        total_clases = ?, duracion_dias = ?
        WHERE id = ?
      ''', [
        nuevoNombre,
        nuevoTipo,
        nuevoNumero,
        nuevaFechaInicio.toIso8601String(),
        nuevaFechaFin.toIso8601String(),
        nuevoEstado,
        json.encode(nuevasFechasClases),
        nuevaDescripcion,
        nuevasFechasClases.length,
        nuevaFechaFin.difference(nuevaFechaInicio).inDays,
        bimestreId,
      ]);

      _bimestres[bimestreIndex] = bimestreActualizado;
      _limpiarFormulario();
      notifyListeners();
      
      print('✅ Bimestre actualizado correctamente');
      return true;
    } catch (e) {
      _error = 'Error al editar bimestre: $e';
      notifyListeners();
      return false;
    }
  }

  void cargarBimestreParaEditar(PeriodoAcademico bimestre) {
    _bimestreEditandoId = bimestre.id;
    _nombreController.text = bimestre.nombre;
    _fechaInicioController.text = _formatDateForInput(bimestre.fechaInicio);
    _fechaFinController.text = _formatDateForInput(bimestre.fechaFin);
    _descripcionController.text = bimestre.descripcion;
    _estadoSeleccionado = bimestre.estado;
    notifyListeners();
  }

  void setEstadoSeleccionado(String estado) {
    _estadoSeleccionado = estado;
    notifyListeners();
  }

  String _formatDateForInput(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDateFromInput(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  Future<bool> guardarEdicionBimestre() async {
    if (_nombreController.text.isEmpty ||
        _fechaInicioController.text.isEmpty ||
        _fechaFinController.text.isEmpty) {
      _error = 'Nombre y fechas son requeridos';
      notifyListeners();
      return false;
    }

    final fechaInicio = _parseDateFromInput(_fechaInicioController.text);
    final fechaFin = _parseDateFromInput(_fechaFinController.text);

    if (fechaInicio == null || fechaFin == null) {
      _error = 'Formato de fecha inválido';
      notifyListeners();
      return false;
    }

    if (fechaFin.isBefore(fechaInicio)) {
      _error = 'La fecha fin no puede ser anterior a la fecha inicio';
      notifyListeners();
      return false;
    }

    final bimestreOriginal = _bimestres.firstWhere((b) => b.id == _bimestreEditandoId);

    return await editarBimestreCompleto(
      _bimestreEditandoId,
      _nombreController.text,
      bimestreOriginal.tipo,
      bimestreOriginal.numero,
      fechaInicio,
      fechaFin,
      _estadoSeleccionado,
      _descripcionController.text,
    );
  }

  Future<bool> cambiarEstadoBimestre(String id, String nuevoEstado) async {
    try {
      final bimestreIndex = _bimestres.indexWhere((b) => b.id == id);
      if (bimestreIndex == -1) return false;

      final bimestreActualizado = _bimestres[bimestreIndex].copyWith(estado: nuevoEstado);

      await _databaseHelper.rawUpdate('''
        UPDATE periodos_academicos SET estado = ? WHERE id = ?
      ''', [nuevoEstado, id]);

      _bimestres[bimestreIndex] = bimestreActualizado;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al cambiar estado: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarBimestre(String id) async {
    try {
      await _databaseHelper.rawDelete('''
        DELETE FROM periodos_academicos WHERE id = ?
      ''', [id]);

      _bimestres.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar bimestre: $e';
      notifyListeners();
      return false;
    }
  }

  void _limpiarFormulario() {
    _bimestreEditandoId = '';
    _nombreController.clear();
    _fechaInicioController.clear();
    _fechaFinController.clear();
    _descripcionController.clear();
    _estadoSeleccionado = 'Planificado';
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ✅ MÉTODOS DE UTILIDAD PARA UI (IGUAL QUE ANTES)
  Color getColorPorNumero(int numero) {
    switch (numero) {
      case 1: return Colors.orange;
      case 2: return Colors.green;
      case 3: return Colors.blue;
      case 4: return Colors.purple;
      default: return Colors.grey;
    }
  }

  Color getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'finalizado': return Colors.green;
      case 'en curso': return Colors.blue;
      case 'planificado': return Colors.orange;
      case 'cancelado': return Colors.red;
      default: return Colors.grey;
    }
  }

  String getEstadoDisplay(String estado) {
    switch (estado.toLowerCase()) {
      case 'en curso': return '🟢 En Curso';
      case 'planificado': return '🟡 Planificado';
      case 'finalizado': return '🔵 Finalizado';
      case 'cancelado': return '🔴 Cancelado';
      default: return estado;
    }
  }

  List<String> get opcionesEstado => ['Planificado', 'En Curso', 'Finalizado', 'Cancelado'];

  @override
  void dispose() {
    _nombreController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}