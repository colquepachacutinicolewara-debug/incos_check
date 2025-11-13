// viewmodels/reporte_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/reporte_model.dart';
import '../models/database_helper.dart';

class ReporteViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance; // ✅ Cambio aquí
  ReporteModel _model = const ReporteModel();
  bool _isLoading = false;

  ReporteModel get model => _model;
  bool get isLoading => _isLoading;

  ReporteViewModel() { // ✅ Constructor sin parámetros
    _cargarReporteDesdeSQLite();
  }

  Future<void> _cargarReporteDesdeSQLite() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM reportes LIMIT 1
      ''');

      if (result.isNotEmpty) {
        _model = ReporteModel.fromMap(Map<String, dynamic>.from(result.first));
      } else {
        // Insertar reporte por defecto si no existe
        await _insertarReportePorDefecto();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error cargando reporte: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _insertarReportePorDefecto() async {
    try {
      final reportePorDefecto = ReporteModel(
        progress: 0.70,
        status: 'Reportes en Desarrollo',
        features: [
          'Reportes de asistencia por estudiante',
          'Estadísticas de asistencia por materia',
          'Reportes de faltas y justificaciones',
          'Gráficos de tendencias de asistencia',
          'Exportación a PDF y Excel',
          'Filtros por fecha, carrera y turno',
        ],
      );

      await _databaseHelper.rawInsert('''
        INSERT INTO reportes (id, progress, status, features, fecha_creacion)
        VALUES (?, ?, ?, ?, ?)
      ''', [
        'reporte_principal',
        reportePorDefecto.progress,
        reportePorDefecto.status,
        reportePorDefecto.features.join('|'), // Guardar como string separado por |
        DateTime.now().toIso8601String(),
      ]);

      _model = reportePorDefecto;
    } catch (e) {
      print('Error insertando reporte por defecto: $e');
    }
  }

  void showNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Te notificaremos cuando los reportes estén disponibles",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void updateProgress(double newProgress) async {
    _model = _model.copyWith(progress: newProgress);
    
    // Actualizar en SQLite
    try {
      await _databaseHelper.rawUpdate('''
        UPDATE reportes SET progress = ?, fecha_creacion = ?
        WHERE id = ?
      ''', [
        newProgress,
        DateTime.now().toIso8601String(),
        'reporte_principal',
      ]);
    } catch (e) {
      print('Error actualizando progreso: $e');
    }
    
    notifyListeners();
  }

  Future<void> recargarReporte() async {
    await _cargarReporteDesdeSQLite();
  }

  // Método para obtener el texto del progreso
  String get progressText => '${(model.progress * 100).toInt()}% completado';

  // Método para verificar si hay datos
  bool get tieneDatos => model.progress > 0;
}