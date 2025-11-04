import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/primer_bimestre_model.dart';
import '../../../models/bimestre_model.dart'; // Importar el modelo PeriodoAcademico

class PrimerBimestreViewModel with ChangeNotifier {
  final PrimerBimestreModel _model = PrimerBimestreModel();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();

  List<AsistenciaEstudiante> _filteredEstudiantes = [];
  int? _estudianteSeleccionado;

  // Getters
  PeriodoAcademico get bimestre => _model.bimestre;
  List<String> get fechas => _model.fechas;
  List<AsistenciaEstudiante> get estudiantes => _model.estudiantes;
  List<AsistenciaEstudiante> get filteredEstudiantes => _filteredEstudiantes;
  int? get estudianteSeleccionado => _estudianteSeleccionado;
  TextEditingController get searchController => _searchController;
  TextEditingController get fechaInicioController => _fechaInicioController;
  TextEditingController get fechaFinController => _fechaFinController;

  PrimerBimestreViewModel() {
    _cargarDatosEjemplo();
    _filteredEstudiantes = _model.estudiantes;
    _searchController.addListener(_filtrarEstudiantes);
    _fechaInicioController.text = _formatDate(_model.bimestre.fechaInicio);
    _fechaFinController.text = _formatDate(_model.bimestre.fechaFin);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _cargarDatosEjemplo() {
    for (int i = 1; i <= 60; i++) {
      _model.estudiantes.add(
        AsistenciaEstudiante(
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
        return itemMatch ||
            nombreMatch ||
            (query.length > 1 && itemPartialMatch);
      }).toList();
    }
    _estudianteSeleccionado = null;
    notifyListeners();
  }

  void seleccionarEstudiante(int item) {
    _estudianteSeleccionado = _estudianteSeleccionado == item ? null : item;
    notifyListeners();
  }

  void actualizarAsistencia(
    AsistenciaEstudiante estudiante,
    String fecha,
    String valor,
  ) {
    estudiante.actualizarAsistencia(fecha, valor);
    notifyListeners();
  }

  Future<void> exportarACSV() async {
    try {
      List<List<dynamic>> csvData = [];

      // Encabezados
      csvData.add(['ÍTEM', 'ESTUDIANTE', ...fechas, 'TOTAL']);

      // Datos
      for (var estudiante in _filteredEstudiantes) {
        csvData.add([
          estudiante.item.toString().padLeft(2, '0'),
          estudiante.nombre,
          estudiante.febL,
          estudiante.febM,
          estudiante.febMi,
          estudiante.febJ,
          estudiante.febV,
          estudiante.marL,
          estudiante.marM,
          estudiante.marMi,
          estudiante.marJ,
          estudiante.marV,
          estudiante.abrL,
          estudiante.abrM,
          estudiante.abrMi,
          estudiante.abrJ,
          estudiante.abrV,
          estudiante.totalDisplay,
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/asistencia_primer_bimestre.csv';
      final File file = File(path);
      await file.writeAsString(csv, flush: true);
      await OpenFile.open(path);
    } catch (e) {
      rethrow;
    }
  }

  void editarFechasBimestre() {
    // Lógica para editar fechas (puedes implementar según necesidades)
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
