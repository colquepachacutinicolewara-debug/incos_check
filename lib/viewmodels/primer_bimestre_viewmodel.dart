import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/primer_bimestre_model.dart';
import '../models/periodo_academico_model.dart';
import '../models/database_helper.dart';
import '../models/estudiante_model.dart';
import '../viewmodels/estudiantes_viewmodel.dart';

class PrimerBimestreViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final PrimerBimestreModel _model = PrimerBimestreModel.defaultModel();
  
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();

  List<AsistenciaEstudiante> _filteredEstudiantes = [];
  int? _estudianteSeleccionado;
  bool _isLoading = false;

  // Referencia al ViewModel de estudiantes
  late EstudiantesViewModel _estudiantesViewModel;

  // Getters
  PeriodoAcademico get bimestre => _model.bimestre;
  List<String> get fechas => _model.fechas;
  List<AsistenciaEstudiante> get estudiantes => _model.estudiantes;
  List<AsistenciaEstudiante> get filteredEstudiantes => _filteredEstudiantes;
  int? get estudianteSeleccionado => _estudianteSeleccionado;
  bool get isLoading => _isLoading;
  TextEditingController get searchController => _searchController;
  TextEditingController get fechaInicioController => _fechaInicioController;
  TextEditingController get fechaFinController => _fechaFinController;

  // Método para inicializar con el ViewModel de estudiantes
  void initializeWithEstudiantes(EstudiantesViewModel estudiantesViewModel) {
    _estudiantesViewModel = estudiantesViewModel;
    _cargarDatosDesdeEstudiantes();
    _searchController.addListener(_filtrarEstudiantes);
    _fechaInicioController.text = _formatDate(_model.bimestre.fechaInicio);
    _fechaFinController.text = _formatDate(_model.bimestre.fechaFin);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _cargarDatosDesdeEstudiantes() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Esperar a que los estudiantes estén cargados
      if (_estudiantesViewModel.estudiantes.isEmpty) {
        await _estudiantesViewModel.recargarEstudiantes();
      }

      // Convertir estudiantes a AsistenciaEstudiante
      _model.estudiantes.clear();
      
      int item = 1;
      for (var estudiante in _estudiantesViewModel.estudiantes) {
        final nombreCompleto = '${estudiante.apellidoPaterno} ${estudiante.apellidoMaterno} ${estudiante.nombres}';
        
        final asistenciaEstudiante = AsistenciaEstudiante(
          item: item,
          nombre: nombreCompleto,
        );
        _model.estudiantes.add(asistenciaEstudiante);
        item++;
      }

      // Verificar si ya existen datos en SQLite para este bimestre
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM asistencias 
        WHERE periodo_id = ? AND materia_id LIKE '%primer_bimestre%'
      ''', [_model.bimestre.id]);

      final count = (result.first['count'] as int?) ?? 0;

      if (count == 0) {
        // Insertar datos iniciales en SQLite
        await _insertarDatosInicialesEnSQLite();
      } else {
        // Cargar datos existentes desde SQLite
        await _cargarDatosExistentesDesdeSQLite();
      }

      _filteredEstudiantes = _model.estudiantes;
      _isLoading = false;
      notifyListeners();
      
      print('✅ ${_model.estudiantes.length} estudiantes cargados desde EstudiantesViewModel');
    } catch (e) {
      print('❌ Error cargando datos desde estudiantes: $e');
      _cargarDatosEjemplo();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _insertarDatosInicialesEnSQLite() async {
    try {
      for (final estudiante in _model.estudiantes) {
        // Guardar en SQLite
        await _databaseHelper.rawInsert('''
          INSERT INTO asistencias (
            id, estudiante_id, periodo_id, materia_id, 
            asistencia_registrada_hoy, datos_asistencia, ultima_actualizacion
          ) VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', [
          'asist_primer_${estudiante.item}',
          'est_${estudiante.item}',
          _model.bimestre.id,
          'materia_primer_bimestre',
          0,
          json.encode(estudiante.toMap()),
          DateTime.now().toIso8601String(),
        ]);
      }

      print('✅ ${_model.estudiantes.length} estudiantes insertados en SQLite para primer bimestre');
    } catch (e) {
      print('❌ Error insertando datos iniciales en SQLite: $e');
    }
  }

  Future<void> _cargarDatosExistentesDesdeSQLite() async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM asistencias 
        WHERE periodo_id = ? AND materia_id LIKE '%primer_bimestre%'
        ORDER BY estudiante_id
      ''', [_model.bimestre.id]);

      // Mapear datos existentes a los estudiantes actuales
      for (var row in result) {
        try {
          final datos = json.decode(row['datos_asistencia'] as String);
          final estudianteExistente = AsistenciaEstudiante.fromMap(Map<String, dynamic>.from(datos));
          
          // Actualizar el estudiante correspondiente en la lista
          final index = _model.estudiantes.indexWhere((e) => e.item == estudianteExistente.item);
          if (index != -1) {
            // ✅ CORREGIDO: Crear un nuevo objeto con los datos actualizados
            final estudianteActual = _model.estudiantes[index];
            final estudianteActualizado = AsistenciaEstudiante(
              item: estudianteActual.item,
              nombre: estudianteActual.nombre, // Mantener el nombre original
              febL: estudianteExistente.febL,
              febM: estudianteExistente.febM,
              febMi: estudianteExistente.febMi,
              febJ: estudianteExistente.febJ,
              febV: estudianteExistente.febV,
              marL: estudianteExistente.marL,
              marM: estudianteExistente.marM,
              marMi: estudianteExistente.marMi,
              marJ: estudianteExistente.marJ,
              marV: estudianteExistente.marV,
              abrL: estudianteExistente.abrL,
              abrM: estudianteExistente.abrM,
              abrMi: estudianteExistente.abrMi,
              abrJ: estudianteExistente.abrJ,
              abrV: estudianteExistente.abrV,
            );
            
            _model.estudiantes[index] = estudianteActualizado;
          }
        } catch (e) {
          print('❌ Error parseando estudiante existente: $e');
        }
      }

      print('✅ Datos de asistencia cargados desde SQLite para primer bimestre');
    } catch (e) {
      print('❌ Error cargando datos desde SQLite: $e');
    }
  }

  void _cargarDatosEjemplo() {
    // Solo como fallback si todo falla
    int item = 1;
    for (var estudiante in _estudiantesViewModel.estudiantes) {
      final nombreCompleto = '${estudiante.apellidoPaterno} ${estudiante.apellidoMaterno} ${estudiante.nombres}';
      
      _model.estudiantes.add(
        AsistenciaEstudiante(
          item: item,
          nombre: nombreCompleto,
        ),
      );
      item++;
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
    AsistenciaEstudiante estudiante,
    String fecha,
    String valor,
  ) async {
    try {
      // Encontrar el índice del estudiante
      final index = _model.estudiantes.indexWhere((e) => e.item == estudiante.item);
      if (index != -1) {
        // Crear una nueva instancia con la asistencia actualizada
        final estudianteActualizado = AsistenciaEstudiante(
          item: estudiante.item,
          nombre: estudiante.nombre,
          febL: estudiante.febL,
          febM: estudiante.febM,
          febMi: estudiante.febMi,
          febJ: estudiante.febJ,
          febV: estudiante.febV,
          marL: estudiante.marL,
          marM: estudiante.marM,
          marMi: estudiante.marMi,
          marJ: estudiante.marJ,
          marV: estudiante.marV,
          abrL: estudiante.abrL,
          abrM: estudiante.abrM,
          abrMi: estudiante.abrMi,
          abrJ: estudiante.abrJ,
          abrV: estudiante.abrV,
        );
        
        // Actualizar la asistencia
        estudianteActualizado.actualizarAsistencia(fecha, valor);
        
        // Reemplazar en la lista
        _model.estudiantes[index] = estudianteActualizado;
        
        // Actualizar en SQLite
        await _databaseHelper.rawUpdate('''
          UPDATE asistencias SET 
          datos_asistencia = ?, ultima_actualizacion = ?
          WHERE id = ?
        ''', [
          json.encode(estudianteActualizado.toMap()),
          DateTime.now().toIso8601String(),
          'asist_primer_${estudiante.item}',
        ]);

        // Actualizar la lista filtrada
        _filtrarEstudiantes();
        notifyListeners();
      }
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
          estudiante.nombre, // Nombre completo
        ];

        // Agregar todas las asistencias
        row.addAll([
          estudiante.febL, estudiante.febM, estudiante.febMi, estudiante.febJ, estudiante.febV,
          estudiante.marL, estudiante.marM, estudiante.marMi, estudiante.marJ, estudiante.marV,
          estudiante.abrL, estudiante.abrM, estudiante.abrMi, estudiante.abrJ, estudiante.abrV,
        ]);

        row.add(estudiante.totalDisplay);
        csvData.add(row);
      }

      String csv = const ListToCsvConverter().convert(csvData);
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/asistencia_primer_bimestre.csv';
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
        : Colors.orange.shade50;
  }

  Color getSearchBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color getOrangeAccentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.orange.shade700
        : Colors.orange;
  }

  Color getOrangeLightColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.orange.shade900.withOpacity(0.3)
        : Colors.orange.shade50;
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