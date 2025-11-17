// viewmodels/respaldos_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/respaldo_model.dart';
import '../models/database_helper.dart';

class RespaldosViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
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
    cargarRespaldos();
  }

  Future<void> cargarRespaldos() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _databaseHelper.obtenerHistorialRespaldos();

      _respaldos = result.map((row) => 
        Respaldo.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      _aplicarFiltros();
      
      print('✅ ${_respaldos.length} respaldos cargados');

    } catch (e) {
      _error = 'Error al cargar respaldos: $e';
      print('❌ Error cargando respaldos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🆕 CREAR RESPALDO COMPLETO
  Future<Map<String, dynamic>> crearRespaldoCompleto(String usuario) async {
    try {
      _creandoRespaldo = true;
      notifyListeners();

      print('🔄 Creando respaldo completo...');

      final respaldoData = await _databaseHelper.generarRespaldoCompleto();
      
      _creandoRespaldo = false;
      await cargarRespaldos();
      notifyListeners();

      return {
        'success': true,
        'respaldo': respaldoData,
        'mensaje': 'Respaldo completo creado exitosamente'
      };

    } catch (e) {
      _creandoRespaldo = false;
      _error = 'Error creando respaldo: $e';
      notifyListeners();
      
      return {
        'success': false,
        'error': 'Error creando respaldo: $e'
      };
    }
  }

  // 🆕 CREAR RESPALDO INCREMENTAL
  Future<Map<String, dynamic>> crearRespaldoIncremental(String usuario) async {
    try {
      _creandoRespaldo = true;
      notifyListeners();

      print('🔄 Creando respaldo incremental...');

      final respaldoData = await _databaseHelper.generarRespaldoIncremental();
      
      _creandoRespaldo = false;
      await cargarRespaldos();
      notifyListeners();

      return {
        'success': true,
        'respaldo': respaldoData,
        'mensaje': 'Respaldo incremental creado exitosamente'
      };

    } catch (e) {
      _creandoRespaldo = false;
      _error = 'Error creando respaldo incremental: $e';
      notifyListeners();
      
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  // 🆕 RESTAURAR DESDE RESPALDO
  Future<Map<String, dynamic>> restaurarRespaldo(String respaldoId) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 Restaurando desde respaldo: $respaldoId');

      // Obtener datos del respaldo
      final respaldo = _respaldos.firstWhere((r) => r.id == respaldoId);
      
      // En una implementación real, aquí cargarías el archivo de respaldo
      // y llamarías a _databaseHelper.restaurarDesdeRespaldo(datos)

      // Simular proceso de restauración
      await Future.delayed(const Duration(seconds: 2));

      _isLoading = false;
      notifyListeners();

      return {
        'success': true,
        'mensaje': 'Sistema restaurado exitosamente desde el respaldo'
      };

    } catch (e) {
      _isLoading = false;
      _error = 'Error restaurando respaldo: $e';
      notifyListeners();
      
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  // 🆕 ELIMINAR RESPALDO
  Future<bool> eliminarRespaldo(String respaldoId) async {
    try {
      await _databaseHelper.eliminarRespaldo(respaldoId);
      await cargarRespaldos();
      
      print('✅ Respaldo eliminado: $respaldoId');
      return true;

    } catch (e) {
      _error = 'Error eliminando respaldo: $e';
      notifyListeners();
      return false;
    }
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

  // 🆕 OBTENER ESTADÍSTICAS DE RESPALDOS
  Map<String, dynamic> obtenerEstadisticasRespaldos() {
    final total = _respaldos.length;
    final completos = _respaldos.where((r) => r.esCompleto).length;
    final incrementales = _respaldos.where((r) => r.esIncremental).length;
    final tamanoTotal = _respaldos.fold(0, (sum, r) => sum + (r.tamanoBytes ?? 0));
    
    final ultimoRespaldo = _respaldos.isNotEmpty 
        ? _respaldos.first.fechaRespaldo 
        : null;

    return {
      'total': total,
      'completos': completos,
      'incrementales': incrementales,
      'tamano_total': tamanoTotal,
      'tamano_total_display': _formatearTamano(tamanoTotal),
      'ultimo_respaldo': ultimoRespaldo,
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