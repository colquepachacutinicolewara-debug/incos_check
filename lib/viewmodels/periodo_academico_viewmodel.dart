// viewmodels/periodo_academico_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/bimestre_model.dart';
import '../models/database_helper.dart';

class PeriodoAcademicoViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance; // ✅ Cambio aquí

  List<PeriodoAcademico> _periodos = [];
  List<PeriodoAcademico> get periodos => _periodos;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  // Controladores para edición
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  TextEditingController get nombreController => _nombreController;
  TextEditingController get fechaInicioController => _fechaInicioController;
  TextEditingController get fechaFinController => _fechaFinController;
  TextEditingController get descripcionController => _descripcionController;

  PeriodoAcademicoViewModel() { // ✅ Constructor sin parámetros
    cargarPeriodos();
  }

  Future<void> cargarPeriodos() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Primero verificar si hay periodos en la base de datos
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM periodos_academicos
      ''');

      final count = (result.first['count'] as int?) ?? 0;

      if (count == 0) {
        // Si no hay periodos, insertar los 4 bimestres por defecto
        await _insertarPeriodosPredefinidos();
      } else {
        // Cargar periodos existentes
        await _cargarPeriodosExistentes();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar periodos académicos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _insertarPeriodosPredefinidos() async {
    try {
      final periodosPredefinidos = [
        PeriodoAcademico(
          id: 'bim1_${DateTime.now().millisecondsSinceEpoch}',
          nombre: 'Primer Bimestre',
          tipo: 'Bimestral',
          numero: 1,
          fechaInicio: DateTime(2024, 2, 1),
          fechaFin: DateTime(2024, 3, 31),
          estado: 'Finalizado',
          fechasClases: _generarFechasClases(DateTime(2024, 2, 1), DateTime(2024, 3, 31)),
          descripcion: 'Primer período académico 2024',
          fechaCreacion: DateTime(2024, 1, 15),
        ),
        PeriodoAcademico(
          id: 'bim2_${DateTime.now().millisecondsSinceEpoch + 1}',
          nombre: 'Segundo Bimestre',
          tipo: 'Bimestral',
          numero: 2,
          fechaInicio: DateTime(2024, 4, 1),
          fechaFin: DateTime(2024, 5, 31),
          estado: 'En Curso',
          fechasClases: _generarFechasClases(DateTime(2024, 4, 1), DateTime(2024, 5, 31)),
          descripcion: 'Segundo período académico 2024',
          fechaCreacion: DateTime(2024, 3, 15),
        ),
        PeriodoAcademico(
          id: 'bim3_${DateTime.now().millisecondsSinceEpoch + 2}',
          nombre: 'Tercer Bimestre',
          tipo: 'Bimestral',
          numero: 3,
          fechaInicio: DateTime(2024, 6, 1),
          fechaFin: DateTime(2024, 7, 31),
          estado: 'Planificado',
          fechasClases: [],
          descripcion: 'Tercer período académico 2024',
          fechaCreacion: DateTime(2024, 5, 15),
        ),
        PeriodoAcademico(
          id: 'bim4_${DateTime.now().millisecondsSinceEpoch + 3}',
          nombre: 'Cuarto Bimestre',
          tipo: 'Bimestral',
          numero: 4,
          fechaInicio: DateTime(2024, 8, 1),
          fechaFin: DateTime(2024, 9, 30),
          estado: 'Planificado',
          fechasClases: [],
          descripcion: 'Cuarto período académico 2024',
          fechaCreacion: DateTime(2024, 7, 15),
        ),
      ];

      for (final periodo in periodosPredefinidos) {
        await _databaseHelper.rawInsert('''
          INSERT INTO periodos_academicos (id, nombre, tipo, numero, fecha_inicio, fecha_fin, 
          estado, fechas_clases, descripcion, fecha_creacion, fecha_actualizacion)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          periodo.id,
          periodo.nombre,
          periodo.tipo,
          periodo.numero,
          periodo.fechaInicio.toIso8601String(),
          periodo.fechaFin.toIso8601String(),
          periodo.estado,
          periodo.fechasClases.join(','),
          periodo.descripcion,
          periodo.fechaCreacion.toIso8601String(),
          DateTime.now().toIso8601String(),
        ]);
      }

      _periodos = periodosPredefinidos;
      print('✅ ${_periodos.length} periodos académicos insertados en SQLite');
    } catch (e) {
      print('❌ Error insertando periodos predefinidos: $e');
    }
  }

  Future<void> _cargarPeriodosExistentes() async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM periodos_academicos 
        ORDER BY numero
      ''');

      _periodos = result.map((row) => 
        PeriodoAcademico.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      print('✅ ${_periodos.length} periodos académicos cargados desde SQLite');
    } catch (e) {
      print('❌ Error cargando periodos desde SQLite: $e');
    }
  }

  List<String> _generarFechasClases(DateTime inicio, DateTime fin) {
    List<String> fechas = [];
    DateTime fechaActual = inicio;
    
    while (fechaActual.isBefore(fin) || fechaActual.isAtSameMomentAs(fin)) {
      // Solo días de semana (lunes a viernes)
      if (fechaActual.weekday >= DateTime.monday && fechaActual.weekday <= DateTime.friday) {
        fechas.add('${fechaActual.day.toString().padLeft(2, '0')}/${fechaActual.month.toString().padLeft(2, '0')}');
      }
      fechaActual = fechaActual.add(const Duration(days: 1));
    }
    
    return fechas;
  }

  Future<bool> agregarPeriodo(PeriodoAcademico periodo) async {
    try {
      // Verificar si ya existe un periodo con el mismo número
      final existe = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM periodos_academicos 
        WHERE numero = ? AND tipo = ?
      ''', [periodo.numero, periodo.tipo]);

      final count = (existe.first['count'] as int?) ?? 0;
      if (count > 0) {
        _error = 'Ya existe un período con el mismo número y tipo';
        notifyListeners();
        return false;
      }

      await _databaseHelper.rawInsert('''
        INSERT INTO periodos_academicos (id, nombre, tipo, numero, fecha_inicio, fecha_fin, 
        estado, fechas_clases, descripcion, fecha_creacion, fecha_actualizacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        periodo.id,
        periodo.nombre,
        periodo.tipo,
        periodo.numero,
        periodo.fechaInicio.toIso8601String(),
        periodo.fechaFin.toIso8601String(),
        periodo.estado,
        periodo.fechasClases.join(','),
        periodo.descripcion,
        periodo.fechaCreacion.toIso8601String(),
        DateTime.now().toIso8601String(),
      ]);

      await cargarPeriodos();
      _limpiarFormulario();
      return true;
    } catch (e) {
      _error = 'Error al agregar período: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarPeriodo(PeriodoAcademico periodo) async {
    try {
      // Verificar si ya existe otro periodo con el mismo número (excluyendo el actual)
      final existe = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM periodos_academicos 
        WHERE numero = ? AND tipo = ? AND id != ?
      ''', [periodo.numero, periodo.tipo, periodo.id]);

      final count = (existe.first['count'] as int?) ?? 0;
      if (count > 0) {
        _error = 'Ya existe otro período con el mismo número y tipo';
        notifyListeners();
        return false;
      }

      await _databaseHelper.rawUpdate('''
        UPDATE periodos_academicos SET 
        nombre = ?, tipo = ?, numero = ?, fecha_inicio = ?, fecha_fin = ?,
        estado = ?, fechas_clases = ?, descripcion = ?, fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        periodo.nombre,
        periodo.tipo,
        periodo.numero,
        periodo.fechaInicio.toIso8601String(),
        periodo.fechaFin.toIso8601String(),
        periodo.estado,
        periodo.fechasClases.join(','),
        periodo.descripcion,
        DateTime.now().toIso8601String(),
        periodo.id,
      ]);

      await cargarPeriodos();
      _limpiarFormulario();
      return true;
    } catch (e) {
      _error = 'Error al actualizar período: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarPeriodo(String id) async {
    try {
      await _databaseHelper.rawDelete('''
        DELETE FROM periodos_academicos WHERE id = ?
      ''', [id]);

      await cargarPeriodos();
      return true;
    } catch (e) {
      _error = 'Error al eliminar período: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cambiarEstadoPeriodo(String id, String nuevoEstado) async {
    try {
      await _databaseHelper.rawUpdate('''
        UPDATE periodos_academicos SET estado = ?, fecha_actualizacion = ?
        WHERE id = ?
      ''', [nuevoEstado, DateTime.now().toIso8601String(), id]);

      await cargarPeriodos();
      return true;
    } catch (e) {
      _error = 'Error al cambiar estado: $e';
      notifyListeners();
      return false;
    }
  }

  void cargarPeriodoParaEditar(PeriodoAcademico periodo) {
    _nombreController.text = periodo.nombre;
    _fechaInicioController.text = _formatDate(periodo.fechaInicio);
    _fechaFinController.text = _formatDate(periodo.fechaFin);
    _descripcionController.text = periodo.descripcion;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _fechaInicioController.clear();
    _fechaFinController.clear();
    _descripcionController.clear();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Métodos de utilidad
  Color getColorPorNumero(int numero) {
    switch (numero) {
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.orange;
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
      case 'en curso': return 'En Curso';
      case 'planificado': return 'Planificado';
      case 'finalizado': return 'Finalizado';
      case 'cancelado': return 'Cancelado';
      default: return estado;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}