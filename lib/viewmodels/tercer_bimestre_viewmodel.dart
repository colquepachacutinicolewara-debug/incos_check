import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/tercer_bimestre_model.dart';
import '../models/bimestre_model.dart';
import '../models/database_helper.dart';

class TercerBimestreViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final TercerBimestreModel _model = TercerBimestreModel.defaultModel();
  
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();

  List<AsistenciaEstudianteTercer> _filteredEstudiantes = [];
  int? _estudianteSeleccionado;
  bool _isLoading = false;

  // Getters
  PeriodoAcademico get bimestre => _model.bimestre;
  List<String> get fechas => _model.fechas;
  List<AsistenciaEstudianteTercer> get estudiantes => _model.estudiantes;
  List<AsistenciaEstudianteTercer> get filteredEstudiantes => _filteredEstudiantes;
  int? get estudianteSeleccionado => _estudianteSeleccionado;
  bool get isLoading => _isLoading;
  TextEditingController get searchController => _searchController;
  TextEditingController get fechaInicioController => _fechaInicioController;
  TextEditingController get fechaFinController => _fechaFinController;

  TercerBimestreViewModel() {
    _cargarDatosDesdeSQLite();
    _searchController.addListener(_filtrarEstudiantes);
    _fechaInicioController.text = _formatDate(_model.bimestre.fechaInicio);
    _fechaFinController.text = _formatDate(_model.bimestre.fechaFin);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _cargarDatosDesdeSQLite() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Verificar si ya existen datos en SQLite para este bimestre
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM asistencias 
        WHERE periodo_id = ? AND materia_id LIKE '%tercer_bimestre%'
      ''', [_model.bimestre.id]);

      final count = (result.first['count'] as int?) ?? 0;

      if (count == 0) {
        // Insertar datos de ejemplo si no existen
        await _insertarDatosEjemploEnSQLite();
      } else {
        // Cargar datos existentes desde SQLite
        await _cargarDatosExistentesDesdeSQLite();
      }

      _filteredEstudiantes = _model.estudiantes;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error cargando datos desde SQLite: $e');
      _cargarDatosEjemplo();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _insertarDatosEjemploEnSQLite() async {
    try {
      for (int i = 1; i <= 60; i++) {
        final estudiante = AsistenciaEstudianteTercer(
          item: i,
          nombre: 'Estudiante ${i.toString().padLeft(2, '0')}',
        );

        _model.estudiantes.add(estudiante);

        // Guardar en SQLite
        await _databaseHelper.rawInsert('''
          INSERT INTO asistencias (
            id, estudiante_id, periodo_id, materia_id, 
            asistencia_registrada_hoy, datos_asistencia, ultima_actualizacion
          ) VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', [
          'asist_tercer_${estudiante.item}',
          'est_${estudiante.item}',
          _model.bimestre.id,
          'materia_tercer_bimestre',
          0,
          json.encode(estudiante.toMap()),
          DateTime.now().toIso8601String(),
        ]);
      }

      print('✅ ${_model.estudiantes.length} estudiantes insertados en SQLite para tercer bimestre');
    } catch (e) {
      print('❌ Error insertando datos ejemplo en SQLite: $e');
    }
  }

  Future<void> _cargarDatosExistentesDesdeSQLite() async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM asistencias 
        WHERE periodo_id = ? AND materia_id LIKE '%tercer_bimestre%'
        ORDER BY estudiante_id
      ''', [_model.bimestre.id]);

      _model.estudiantes.clear();
      for (var row in result) {
        try {
          final datos = json.decode(row['datos_asistencia'] as String);
          final estudiante = AsistenciaEstudianteTercer.fromMap(Map<String, dynamic>.from(datos));
          _model.estudiantes.add(estudiante);
        } catch (e) {
          print('❌ Error parseando estudiante: $e');
        }
      }

      print('✅ ${_model.estudiantes.length} estudiantes cargados desde SQLite para tercer bimestre');
    } catch (e) {
      print('❌ Error cargando datos desde SQLite: $e');
      _cargarDatosEjemplo();
    }
  }

  void _cargarDatosEjemplo() {
    for (int i = 1; i <= 60; i++) {
      _model.estudiantes.add(
        AsistenciaEstudianteTercer(
          item: i,
          nombre: 'Estudiante ${i.toString().padLeft(2, '0')}',
        ),
      );
    }
    _filteredEstudiantes = _model.estudiantes;
  }

  void _filtrarEstudiantes() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      _filteredEstudiantes = _model.estudiantes;
    } else {
      _filteredEstudiantes = _model.estudiantes.where((estudiante) {
        final nombreMatch = estudiante.nombre.toLowerCase().contains(query);
        final itemMatch = estudiante.item.toString() == query;
        final itemPartialMatch = estudiante.item.toString().contains(query);
        return itemMatch || nombreMatch || (query.length > 1 && itemPartialMatch);
      }).toList();
    }
    _estudianteSeleccionado = null;
    notifyListeners();
  }

  void seleccionarEstudiante(int item) {
    _estudianteSeleccionado = _estudianteSeleccionado == item ? null : item;
    notifyListeners();
  }

  Future<void> actualizarAsistencia(
    AsistenciaEstudianteTercer estudiante,
    String fecha,
    String valor,
  ) async {
    try {
      estudiante.actualizarAsistencia(fecha, valor);
      
      // Actualizar en SQLite
      await _databaseHelper.rawUpdate('''
        UPDATE asistencias SET 
        datos_asistencia = ?, ultima_actualizacion = ?
        WHERE id = ?
      ''', [
        json.encode(estudiante.toMap()),
        DateTime.now().toIso8601String(),
        'asist_tercer_${estudiante.item}',
      ]);

      notifyListeners();
    } catch (e) {
      print('❌ Error actualizando asistencia en SQLite: $e');
    }
  }

  Future<void> exportarACSV() async {
    try {
      _isLoading = true;
      notifyListeners();

      List<List<dynamic>> csvData = [];

      // Encabezados
      csvData.add(['ÍTEM', 'ESTUDIANTE', ...fechas, 'TOTAL']);

      // Datos
      for (var estudiante in _filteredEstudiantes) {
        List<dynamic> row = [
          estudiante.item.toString().padLeft(2, '0'),
          estudiante.nombre,
        ];

        // Agregar todas las asistencias
        row.addAll([
          estudiante.julL, estudiante.julM, estudiante.julMi, estudiante.julJ, estudiante.julV,
          estudiante.agoL, estudiante.agoM, estudiante.agoMi, estudiante.agoJ, estudiante.agoV,
          estudiante.sepL, estudiante.sepM, estudiante.sepMi, estudiante.sepJ, estudiante.sepV,
        ]);

        row.add(estudiante.totalDisplay);
        csvData.add(row);
      }

      String csv = const ListToCsvConverter().convert(csvData);
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/asistencia_tercer_bimestre.csv';
      final File file = File(path);
      await file.writeAsString(csv, flush: true);
      await OpenFile.open(path);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void editarFechasBimestre() {
    // Lógica para editar fechas
    notifyListeners();
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

  Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  Color getHeaderBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.purple.shade50;
  }

  Color getSearchBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color getPurpleAccentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.purple.shade700
        : Colors.purple;
  }

  Color getPurpleLightColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.purple.shade900.withOpacity(0.3)
        : Colors.purple.shade50;
  }

  Color getColorAsistencia(String valor, BuildContext context) {
    switch (valor.toUpperCase()) {
      case 'P':
        return Colors.green;
      case 'F':
        return Colors.red;
      case 'J':
        return Colors.orange;
      default:
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade200;
    }
  }

  String getTooltipAsistencia(String valor) {
    switch (valor.toUpperCase()) {
      case 'P':
        return 'Presente';
      case 'F':
        return 'Falta';
      case 'J':
        return 'Justificado';
      default:
        return 'Sin registrar';
    }
  }

  Color getColorTotal(int total) {
    double porcentaje = total / 15;
    if (porcentaje >= 0.9) return Colors.green;
    if (porcentaje >= 0.7) return Colors.orange;
    return Colors.red;
  }

  Color getColorFila(int item, BuildContext context) {
    if (_estudianteSeleccionado == item) {
      return Theme.of(context).brightness == Brightness.dark
          ? Colors.yellow.withOpacity(0.2)
          : Colors.yellow.withOpacity(0.3);
    }
    return Colors.transparent;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }
}