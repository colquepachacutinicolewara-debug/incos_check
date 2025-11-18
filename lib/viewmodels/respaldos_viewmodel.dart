// viewmodels/respaldos_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/respaldo_model.dart';

class RespaldosViewModel with ChangeNotifier {
  List<Respaldo> _respaldos = [];
  List<Respaldo> _respaldosFiltrados = [];
  bool _isLoading = false;
  String? _error;
  String _filtroTipo = 'Todos';
  bool _creandoRespaldo = false;

  List<Respaldo> get respaldos => _respaldos;
  List<Respaldo> get respaldosFiltrados => _respaldosFiltrados;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filtroTipo => _filtroTipo;
  bool get creandoRespaldo => _creandoRespaldo;

  RespaldosViewModel() {
    _cargarRespaldosIniciales();
  }

  void _cargarRespaldosIniciales() {
    _respaldos = [
      Respaldo(
        id: '1',
        tipoRespaldo: 'COMPLETO',
        descripcion: 'Respaldo completo del sistema',
        rutaArchivo: '/backups/completo.zip',
        fechaRespaldo: DateTime.now().subtract(const Duration(days: 2)),
        tamanoBytes: 15728640,
        usuarioRespaldo: 'admin',
        estado: 'COMPLETADO',
        observaciones: 'Respaldo automático',
        checksum: 'abc123',
      ),
      Respaldo(
        id: '2',
        tipoRespaldo: 'INCREMENTAL',
        descripcion: 'Respaldo incremental de asistencias',
        rutaArchivo: '/backups/incremental.zip',
        fechaRespaldo: DateTime.now().subtract(const Duration(days: 1)),
        tamanoBytes: 5242880,
        usuarioRespaldo: 'admin',
        estado: 'COMPLETADO',
        observaciones: 'Solo cambios recientes',
        checksum: 'def456',
      ),
    ];
    _aplicarFiltros();
  }

  Future<void> cargarRespaldos() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> crearRespaldoCompleto(String usuario) async {
    _creandoRespaldo = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final nuevoRespaldo = Respaldo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tipoRespaldo: 'COMPLETO',
      descripcion: 'Respaldo completo del sistema',
      rutaArchivo: '/backups/completo_${DateTime.now().millisecondsSinceEpoch}.zip',
      fechaRespaldo: DateTime.now(),
      tamanoBytes: 10485760,
      usuarioRespaldo: usuario,
      estado: 'COMPLETADO',
      observaciones: 'Generado manualmente',
      checksum: 'xyz789',
    );

    _respaldos.insert(0, nuevoRespaldo);
    _aplicarFiltros();

    _creandoRespaldo = false;
    notifyListeners();

    return {'success': true, 'respaldo': nuevoRespaldo};
  }

  Future<Map<String, dynamic>> crearRespaldoIncremental(String usuario) async {
    _creandoRespaldo = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final nuevoRespaldo = Respaldo(
      id: 'inc_${DateTime.now().millisecondsSinceEpoch}',
      tipoRespaldo: 'INCREMENTAL',
      descripcion: 'Respaldo incremental de cambios',
      rutaArchivo: '/backups/incremental_${DateTime.now().millisecondsSinceEpoch}.zip',
      fechaRespaldo: DateTime.now(),
      tamanoBytes: 2097152,
      usuarioRespaldo: usuario,
      estado: 'COMPLETADO',
      observaciones: 'Cambios recientes',
      checksum: 'incremental123',
    );

    _respaldos.insert(0, nuevoRespaldo);
    _aplicarFiltros();

    _creandoRespaldo = false;
    notifyListeners();

    return {'success': true, 'respaldo': nuevoRespaldo};
  }

  Future<Map<String, dynamic>> restaurarRespaldo(String respaldoId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 3));

    _isLoading = false;
    notifyListeners();

    return {'success': true, 'mensaje': 'Respaldo restaurado exitosamente'};
  }

  Future<bool> eliminarRespaldo(String respaldoId) async {
    _respaldos.removeWhere((respaldo) => respaldo.id == respaldoId);
    _aplicarFiltros();
    notifyListeners();
    
    return true;
  }

  void cambiarFiltroTipo(String tipo) {
    _filtroTipo = tipo;
    _aplicarFiltros();
    notifyListeners();
  }

  void _aplicarFiltros() {
    _respaldosFiltrados = _respaldos.where((respaldo) {
      return _filtroTipo == 'Todos' || respaldo.tipoRespaldo == _filtroTipo;
    }).toList();
  }

  Map<String, dynamic> obtenerEstadisticasRespaldos() {
    final total = _respaldos.length;
    final completos = _respaldos.where((r) => r.esCompleto).length;
    final incrementales = _respaldos.where((r) => r.esIncremental).length;
    final tamanoTotal = _respaldos.fold(0, (sum, r) => sum + (r.tamanoBytes ?? 0));

    return {
      'total': total,
      'completos': completos,
      'incrementales': incrementales,
      'tamano_total': tamanoTotal,
      'tamano_total_display': _formatearTamano(tamanoTotal),
    };
  }

  String _formatearTamano(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}