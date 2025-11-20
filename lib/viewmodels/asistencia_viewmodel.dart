// viewmodels/asistencia_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/database_helper.dart';
import '../models/asistencia_model.dart';

class AsistenciaViewModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  bool _isLoading = false;
  String? _error;
  bool _asistenciaRegistradaHoy = false;
  List<AsistenciaData> _datosAsistencia = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get asistenciaRegistradaHoy => _asistenciaRegistradaHoy;
  List<AsistenciaData> get datosAsistencia => _datosAsistencia;

  AsistenciaViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadAsistenciaData();
  }

  Future<void> refreshData() async {
    await _loadAsistenciaData();
  }

  Future<void> _loadAsistenciaData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simular carga de datos
      await Future.delayed(const Duration(seconds: 1));

      // Datos de ejemplo
      _datosAsistencia = [
        AsistenciaData('Lun', 85),
        AsistenciaData('Mar', 92),
        AsistenciaData('Mié', 78),
        AsistenciaData('Jue', 88),
        AsistenciaData('Vie', 95),
      ];

      _asistenciaRegistradaHoy = false;

    } catch (e) {
      _error = 'Error al cargar datos de asistencia: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para registrar asistencia
  Future<bool> registrarAsistencia(Map<String, dynamic> datosAsistencia) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 1));

      _asistenciaRegistradaHoy = true;
      _error = null;
      
      return true;
    } catch (e) {
      _error = 'Error al registrar asistencia: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Métodos para colores según el tema
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color getAppBarColor(BuildContext context) {
    return Theme.of(context).appBarTheme.backgroundColor ?? Colors.blue;
  }

  Color getCardColor(BuildContext context) {
    return Theme.of(context).cardTheme.color ?? Colors.white;
  }

  Color getChartTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;
  }
}