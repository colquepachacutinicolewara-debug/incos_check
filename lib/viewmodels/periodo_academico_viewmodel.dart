import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/periodo_academico_model.dart';
import '../models/database_helper.dart';

class PeriodoAcademicoViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

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

  // Variables para edición
  String _periodoEditandoId = '';
  String _estadoSeleccionado = 'Planificado';

  TextEditingController get nombreController => _nombreController;
  TextEditingController get fechaInicioController => _fechaInicioController;
  TextEditingController get fechaFinController => _fechaFinController;
  TextEditingController get descripcionController => _descripcionController;
  String get estadoSeleccionado => _estadoSeleccionado;

  PeriodoAcademicoViewModel() {
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
          fechasClases: _generarFechasClases(DateTime(2024, 6, 1), DateTime(2024, 7, 31)),
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
          fechasClases: _generarFechasClases(DateTime(2024, 8, 1), DateTime(2024, 9, 30)),
          descripcion: 'Cuarto período académico 2024',
          fechaCreacion: DateTime(2024, 7, 15),
        ),
      ];

      for (final periodo in periodosPredefinidos) {
        await _databaseHelper.rawInsert('''
          INSERT INTO periodos_academicos (
            id, nombre, tipo, numero, fecha_inicio, fecha_fin, 
            estado, fechas_clases, descripcion, fecha_creacion,
            total_clases, duracion_dias
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          periodo.id,
          periodo.nombre,
          periodo.tipo,
          periodo.numero,
          periodo.fechaInicio.toIso8601String(),
          periodo.fechaFin.toIso8601String(),
          periodo.estado,
          json.encode(periodo.fechasClases),
          periodo.descripcion,
          periodo.fechaCreacion.toIso8601String(),
          periodo.totalClasesComputed,
          periodo.duracionDiasComputed,
        ]);
      }

      _periodos = periodosPredefinidos;
      print('✅ ${_periodos.length} periodos académicos insertados en SQLite');
    } catch (e) {
      print('❌ Error insertando periodos predefinidos: $e');
      // Si hay error, cargar datos en memoria
      _cargarPeriodosEnMemoria();
    }
  }

  void _cargarPeriodosEnMemoria() {
    _periodos = [
      PeriodoAcademico(
        id: 'bim1_memoria',
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
        id: 'bim2_memoria',
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
        id: 'bim3_memoria',
        nombre: 'Tercer Bimestre',
        tipo: 'Bimestral',
        numero: 3,
        fechaInicio: DateTime(2024, 6, 1),
        fechaFin: DateTime(2024, 7, 31),
        estado: 'Planificado',
        fechasClases: _generarFechasClases(DateTime(2024, 6, 1), DateTime(2024, 7, 31)),
        descripcion: 'Tercer período académico 2024',
        fechaCreacion: DateTime(2024, 5, 15),
      ),
      PeriodoAcademico(
        id: 'bim4_memoria',
        nombre: 'Cuarto Bimestre',
        tipo: 'Bimestral',
        numero: 4,
        fechaInicio: DateTime(2024, 8, 1),
        fechaFin: DateTime(2024, 9, 30),
        estado: 'Planificado',
        fechasClases: _generarFechasClases(DateTime(2024, 8, 1), DateTime(2024, 9, 30)),
        descripcion: 'Cuarto período académico 2024',
        fechaCreacion: DateTime(2024, 7, 15),
      ),
    ];
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
      _cargarPeriodosEnMemoria();
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

  // ✅ MÉTODO PARA EDITAR FECHAS - RESPONDIENDO A TU PREGUNTA
  Future<bool> editarFechasPeriodo(
    String periodoId,
    DateTime nuevaFechaInicio,
    DateTime nuevaFechaFin,
  ) async {
    try {
      final periodoIndex = _periodos.indexWhere((p) => p.id == periodoId);
      if (periodoIndex == -1) {
        _error = 'Período no encontrado';
        notifyListeners();
        return false;
      }

      final periodoActual = _periodos[periodoIndex];
      final nuevasFechasClases = _generarFechasClases(nuevaFechaInicio, nuevaFechaFin);

      final periodoActualizado = periodoActual.copyWith(
        fechaInicio: nuevaFechaInicio,
        fechaFin: nuevaFechaFin,
        fechasClases: nuevasFechasClases,
      );

      // Actualizar en SQLite
      await _databaseHelper.rawUpdate('''
        UPDATE periodos_academicos SET 
        fecha_inicio = ?, fecha_fin = ?, fechas_clases = ?,
        total_clases = ?, duracion_dias = ?
        WHERE id = ?
      ''', [
        nuevaFechaInicio.toIso8601String(),
        nuevaFechaFin.toIso8601String(),
        json.encode(nuevasFechasClases),
        nuevasFechasClases.length,
        nuevaFechaFin.difference(nuevaFechaInicio).inDays,
        periodoId,
      ]);

      _periodos[periodoIndex] = periodoActualizado;
      notifyListeners();
      
      print('✅ Fechas del período actualizadas correctamente');
      return true;
    } catch (e) {
      _error = 'Error al editar fechas: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ MÉTODO COMPLETO PARA EDITAR PERIODO
  Future<bool> editarPeriodoCompleto(
    String periodoId,
    String nuevoNombre,
    String nuevoTipo,
    int nuevoNumero,
    DateTime nuevaFechaInicio,
    DateTime nuevaFechaFin,
    String nuevoEstado,
    String nuevaDescripcion,
  ) async {
    try {
      final periodoIndex = _periodos.indexWhere((p) => p.id == periodoId);
      if (periodoIndex == -1) {
        _error = 'Período no encontrado';
        notifyListeners();
        return false;
      }

      // Verificar si ya existe otro periodo con el mismo número
      if (nuevoNumero != _periodos[periodoIndex].numero) {
        final existe = await _databaseHelper.rawQuery('''
          SELECT COUNT(*) as count FROM periodos_academicos 
          WHERE numero = ? AND tipo = ? AND id != ?
        ''', [nuevoNumero, nuevoTipo, periodoId]);

        final count = (existe.first['count'] as int?) ?? 0;
        if (count > 0) {
          _error = 'Ya existe otro período con el mismo número y tipo';
          notifyListeners();
          return false;
        }
      }

      final nuevasFechasClases = _generarFechasClases(nuevaFechaInicio, nuevaFechaFin);

      final periodoActualizado = PeriodoAcademico(
        id: periodoId,
        nombre: nuevoNombre,
        tipo: nuevoTipo,
        numero: nuevoNumero,
        fechaInicio: nuevaFechaInicio,
        fechaFin: nuevaFechaFin,
        estado: nuevoEstado,
        fechasClases: nuevasFechasClases,
        descripcion: nuevaDescripcion,
        fechaCreacion: _periodos[periodoIndex].fechaCreacion,
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
        periodoId,
      ]);

      _periodos[periodoIndex] = periodoActualizado;
      _limpiarFormulario();
      notifyListeners();
      
      print('✅ Período actualizado correctamente');
      return true;
    } catch (e) {
      _error = 'Error al editar período: $e';
      notifyListeners();
      return false;
    }
  }

  void cargarPeriodoParaEditar(PeriodoAcademico periodo) {
    _periodoEditandoId = periodo.id;
    _nombreController.text = periodo.nombre;
    _fechaInicioController.text = _formatDateForInput(periodo.fechaInicio);
    _fechaFinController.text = _formatDateForInput(periodo.fechaFin);
    _descripcionController.text = periodo.descripcion;
    _estadoSeleccionado = periodo.estado;
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

  // ✅ MÉTODO SIMPLIFICADO PARA GUARDAR EDICIÓN DESDE FORMULARIO
  Future<bool> guardarEdicionPeriodo() async {
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

    final periodoOriginal = _periodos.firstWhere((p) => p.id == _periodoEditandoId);

    return await editarPeriodoCompleto(
      _periodoEditandoId,
      _nombreController.text,
      periodoOriginal.tipo, // Mantener el tipo original o permitir cambiar
      periodoOriginal.numero, // Mantener el número original
      fechaInicio,
      fechaFin,
      _estadoSeleccionado,
      _descripcionController.text,
    );
  }

  Future<bool> cambiarEstadoPeriodo(String id, String nuevoEstado) async {
    try {
      final periodoIndex = _periodos.indexWhere((p) => p.id == id);
      if (periodoIndex == -1) return false;

      final periodoActualizado = _periodos[periodoIndex].copyWith(estado: nuevoEstado);

      await _databaseHelper.rawUpdate('''
        UPDATE periodos_academicos SET estado = ? WHERE id = ?
      ''', [nuevoEstado, id]);

      _periodos[periodoIndex] = periodoActualizado;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al cambiar estado: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarPeriodo(String id) async {
    try {
      await _databaseHelper.rawDelete('''
        DELETE FROM periodos_academicos WHERE id = ?
      ''', [id]);

      _periodos.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar período: $e';
      notifyListeners();
      return false;
    }
  }

  void _limpiarFormulario() {
    _periodoEditandoId = '';
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

  // Métodos de utilidad para UI
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