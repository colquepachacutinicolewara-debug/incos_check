// viewmodels/historial_asistencia_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/historial_asistencia_model.dart';
import '../models/database_helper.dart';
import 'dart:convert';

class HistorialAsistenciaViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance; // ✅ Cambio aquí
  FiltroHistorial _filtro = FiltroHistorial(
    mostrarTodasMaterias: false,
    queryBusqueda: '',
  );

  List<RegistroHistorial> _registros = [];
  List<RegistroHistorial> _registrosFiltrados = [];
  bool _isLoading = false;
  String? _error;

  HistorialAsistenciaViewModel() { // ✅ Constructor sin parámetros
    _cargarHistorial();
  }

  // Getters
  bool get mostrarTodasMaterias => _filtro.mostrarTodasMaterias;
  String get queryBusqueda => _filtro.queryBusqueda;
  FiltroHistorial get filtro => _filtro;
  List<RegistroHistorial> get registros => _registros;
  List<RegistroHistorial> get registrosFiltrados => _registrosFiltrados;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar historial desde SQLite
  Future<void> _cargarHistorial() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM historial_asistencias 
        ORDER BY fecha_consulta DESC
        LIMIT 100
      ''');

      _registros = result.map((row) => 
        RegistroHistorial.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      _aplicarFiltros();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar historial: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Métodos para actualizar el estado
  void toggleMostrarTodasMaterias() {
    _filtro = _filtro.copyWith(
      mostrarTodasMaterias: !_filtro.mostrarTodasMaterias,
    );
    _aplicarFiltros();
    notifyListeners();
  }

  void setQueryBusqueda(String query) {
    _filtro = _filtro.copyWith(queryBusqueda: query);
    _aplicarFiltros();
    notifyListeners();
  }

  void limpiarFiltros() {
    _filtro = FiltroHistorial(mostrarTodasMaterias: false, queryBusqueda: '');
    _aplicarFiltros();
    notifyListeners();
  }

  void _aplicarFiltros() {
    _registrosFiltrados = _registros.where((registro) {
      final matchesFiltroMaterias = _filtro.mostrarTodasMaterias || 
          (!_filtro.mostrarTodasMaterias && registro.filtroMostrarTodasMaterias);
      
      final matchesBusqueda = _filtro.queryBusqueda.isEmpty ||
          (registro.queryBusqueda?.toLowerCase().contains(_filtro.queryBusqueda.toLowerCase()) ?? false) ||
          registro.estudianteId.toLowerCase().contains(_filtro.queryBusqueda.toLowerCase()) ||
          registro.materiaId.toLowerCase().contains(_filtro.queryBusqueda.toLowerCase());

      return matchesFiltroMaterias && matchesBusqueda;
    }).toList();
  }

  // Método para obtener texto de filtros aplicados
  String obtenerTextoFiltros(int anioSeleccionado) {
    List<String> filtros = [];

    if (_filtro.mostrarTodasMaterias) {
      filtros.add('Todas las materias');
    } else {
      filtros.add('$anioSeleccionado° Año');
    }

    if (_filtro.queryBusqueda.isNotEmpty) {
      filtros.add('Búsqueda: "${_filtro.queryBusqueda}"');
    }

    return 'Filtros: ${filtros.join(' • ')}';
  }

  // Método para agregar nuevo registro de historial
  Future<void> agregarRegistroHistorial(RegistroHistorial registro) async {
    try {
      await _databaseHelper.rawInsert('''
        INSERT INTO historial_asistencias 
        (id, estudiante_id, materia_id, periodo_id, fecha_consulta, 
         filtro_mostrar_todas_materias, query_busqueda, datos_consulta)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        registro.id,
        registro.estudianteId,
        registro.materiaId,
        registro.periodoId,
        registro.fechaConsulta.toIso8601String(),
        registro.filtroMostrarTodasMaterias ? 1 : 0,
        registro.queryBusqueda,
        registro.datosConsulta != null ? json.encode(registro.datosConsulta) : null
      ]);

      await _cargarHistorial(); // Recargar lista
    } catch (e) {
      _error = 'Error al agregar registro: $e';
      notifyListeners();
    }
  }

  // Método para eliminar registro de historial
  Future<void> eliminarRegistro(String id) async {
    try {
      await _databaseHelper.rawDelete('''
        DELETE FROM historial_asistencias WHERE id = ?
      ''', [id]);

      await _cargarHistorial(); // Recargar lista
    } catch (e) {
      _error = 'Error al eliminar registro: $e';
      notifyListeners();
    }
  }

  // Método para limpiar todo el historial
  Future<void> limpiarTodoElHistorial() async {
    try {
      await _databaseHelper.rawDelete('''
        DELETE FROM historial_asistencias
      ''');

      await _cargarHistorial(); // Recargar lista
    } catch (e) {
      _error = 'Error al limpiar historial: $e';
      notifyListeners();
    }
  }

  Future<void> reintentarCarga() async {
    _error = null;
    await _cargarHistorial();
  }

  // Métodos de utilidad para colores
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : const Color(0xFFF5F5F5);
  }

  Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }

  Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color getFilterBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  Color getSearchBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color getDropdownBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }
}