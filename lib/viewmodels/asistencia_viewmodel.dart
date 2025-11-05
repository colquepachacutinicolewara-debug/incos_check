import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/asistencia_model.dart';
import '../repositories/data_repository.dart';

class AsistenciaViewModel with ChangeNotifier {
  final DataRepository _repository;
  EstadoAsistencia _estado = EstadoAsistencia(
    asistenciaRegistradaHoy: false,
    datosAsistencia: [
      AsistenciaData('Lun', 85),
      AsistenciaData('Mar', 92),
      AsistenciaData('Mié', 78),
      AsistenciaData('Jue', 95),
      AsistenciaData('Vie', 88),
      AsistenciaData('Sáb', 70),
      AsistenciaData('Dom', 65),
    ],
  );

  bool _isLoading = false;
  String? _error;

  // Constructor que recibe el DataRepository
  AsistenciaViewModel(this._repository) {
    _loadAsistenciaData();
  }

  // Getters
  bool get asistenciaRegistradaHoy => _estado.asistenciaRegistradaHoy;
  List<AsistenciaData> get datosAsistencia => _estado.datosAsistencia;
  EstadoAsistencia get estado => _estado;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar datos desde Firestore
  Future<void> _loadAsistenciaData() async {
    try {
      _setLoading(true);

      // Intentar cargar desde Firestore
      final today = _getTodayString();
      final asistenciaHoy = await _checkAsistenciaRegistradaHoy(today);

      // Cargar datos históricos
      final datosHistoricos = await _loadDatosAsistenciaHistoricos();

      _estado = _estado.copyWith(
        asistenciaRegistradaHoy: asistenciaHoy,
        datosAsistencia: datosHistoricos.isNotEmpty
            ? datosHistoricos
            : _estado.datosAsistencia,
      );

      _clearError();
    } catch (e) {
      _setError('Error al cargar datos de asistencia: $e');
      // Mantener datos mock como fallback
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Verificar si ya se registró asistencia hoy
  Future<bool> _checkAsistenciaRegistradaHoy(String today) async {
    try {
      final snapshot = await _repository.getDocumentById('asistencias', today);
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  // Cargar datos históricos de asistencia
  Future<List<AsistenciaData>> _loadDatosAsistenciaHistoricos() async {
    try {
      // Aquí puedes implementar la lógica para cargar datos históricos
      // Por ahora retornamos lista vacía para usar los datos mock como fallback
      return [];
    } catch (e) {
      return [];
    }
  }

  // Métodos para actualizar el estado
  Future<void> registrarAsistencia() async {
    try {
      _setLoading(true);

      final today = _getTodayString();
      final asistenciaData = {
        'fecha': today,
        'estado': 'asistio',
        'hora': DateTime.now().toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Guardar en Firestore
      await _repository.addDocument('asistencias', asistenciaData);

      // Actualizar estado local
      _estado = _estado.copyWith(asistenciaRegistradaHoy: true);
      _clearError();

      notifyListeners();
    } catch (e) {
      _setError('Error al registrar asistencia: $e');
      // Fallback: actualizar solo el estado local
      _estado = _estado.copyWith(asistenciaRegistradaHoy: true);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reiniciarAsistencia() async {
    try {
      _setLoading(true);

      final today = _getTodayString();

      // Eliminar de Firestore si existe
      await _repository.updateDocument('asistencias', today, {
        'estado': 'eliminado',
        'timestamp_eliminacion': FieldValue.serverTimestamp(),
      });

      // Actualizar estado local
      _estado = _estado.copyWith(asistenciaRegistradaHoy: false);
      _clearError();

      notifyListeners();
    } catch (e) {
      _setError('Error al reiniciar asistencia: $e');
      // Fallback: actualizar solo el estado local
      _estado = _estado.copyWith(asistenciaRegistradaHoy: false);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void actualizarDatosAsistencia(List<AsistenciaData> nuevosDatos) {
    _estado = _estado.copyWith(datosAsistencia: nuevosDatos);
    notifyListeners();
  }

  // Métodos de utilidad para colores (MANTENIDOS SIN CAMBIOS)
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

  Color getAppBarColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }

  Color getChartTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  // Métodos auxiliares
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
  }

  void _clearError() {
    _error = null;
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Método para forzar recarga de datos
  Future<void> refreshData() async {
    await _loadAsistenciaData();
  }
}
