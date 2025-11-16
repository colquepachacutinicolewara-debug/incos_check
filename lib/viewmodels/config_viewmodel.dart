//lib/viewmodels/config_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/config_notas_model.dart';
import '../models/database_helper.dart';

class ConfigViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  ConfigNotasAsistencia _configuracion = ConfigNotasAsistencia(
    id: 'config_default',
    nombre: 'Configuración Por Defecto',
    puntajeTotal: 10.0,
    reglasCalculo: ConfigNotasAsistencia.reglasPorDefecto,
    fechaCreacion: DateTime.now(),
    fechaActualizacion: DateTime.now(),
  );
  
  bool _isLoading = false;
  String? _error;
  bool _configuracionModificada = false;

  ConfigNotasAsistencia get configuracion => _configuracion;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get configuracionModificada => _configuracionModificada;

  ConfigViewModel() {
    cargarConfiguracion();
  }

  Future<void> cargarConfiguracion() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _databaseHelper.obtenerConfiguracionActiva();

      if (result.isNotEmpty) {
        _configuracion = ConfigNotasAsistencia.fromMap(
          Map<String, dynamic>.from(result.first)
        );
        print('✅ Configuración cargada: ${_configuracion.nombre}');
      } else {
        // Crear configuración por defecto si no existe
        await _crearConfiguracionPorDefecto();
      }

      _configuracionModificada = false;

    } catch (e) {
      _error = 'Error al cargar configuración: $e';
      print('❌ Error cargando configuración: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _crearConfiguracionPorDefecto() async {
    try {
      final now = DateTime.now();
      final config = ConfigNotasAsistencia(
        id: 'config_tercero_b',
        nombre: 'Sistema de Notas Tercer Año B - Sistemas',
        puntajeTotal: 10.0,
        reglasCalculo: ConfigNotasAsistencia.reglasPorDefecto,
        fechaCreacion: now,
        fechaActualizacion: now,
      );

      await _databaseHelper.insertarConfiguracion({
        'id': config.id,
        'nombre': config.nombre,
        'puntaje_total': config.puntajeTotal,
        'reglas_calculo': config.reglasCalculo,
        'activo': true,
        'fecha_creacion': config.fechaCreacion,
        'fecha_actualizacion': config.fechaActualizacion,
      });

      _configuracion = config;
      print('✅ Configuración por defecto creada');

    } catch (e) {
      print('❌ Error creando configuración por defecto: $e');
      rethrow;
    }
  }

  Future<bool> guardarConfiguracion(ConfigNotasAsistencia nuevaConfig) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Verificar si ya existe una configuración con el mismo nombre
      if (nuevaConfig.id != _configuracion.id) {
        final existe = await _databaseHelper.existeConfiguracionConNombre(
          nuevaConfig.nombre, 
          _configuracion.id
        );

        if (existe) {
          _error = 'Ya existe una configuración con ese nombre';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Desactivar todas las configuraciones anteriores
      await _databaseHelper.desactivarTodasLasConfiguraciones();

      // Guardar nueva configuración
      final now = DateTime.now();
      final configParaGuardar = nuevaConfig.copyWith(
        fechaActualizacion: now,
        activo: true,
      );

      await _databaseHelper.insertarConfiguracion({
        'id': configParaGuardar.id,
        'nombre': configParaGuardar.nombre,
        'puntaje_total': configParaGuardar.puntajeTotal,
        'reglas_calculo': configParaGuardar.reglasCalculo,
        'activo': configParaGuardar.activo,
        'fecha_creacion': configParaGuardar.fechaCreacion,
        'fecha_actualizacion': configParaGuardar.fechaActualizacion,
      });

      _configuracion = configParaGuardar;
      _configuracionModificada = false;

      print('✅ Configuración guardada: ${_configuracion.nombre}');
      return true;

    } catch (e) {
      _error = 'Error al guardar configuración: $e';
      print('❌ Error guardando configuración: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void actualizarConfiguracionLocal(ConfigNotasAsistencia nuevaConfig) {
    _configuracion = nuevaConfig;
    _configuracionModificada = true;
    notifyListeners();
  }

  void actualizarRegla(String clave, dynamic valor) {
    final nuevasReglas = Map<String, dynamic>.from(_configuracion.reglasCalculo);
    nuevasReglas[clave] = valor;
    
    _configuracion = _configuracion.copyWith(reglasCalculo: nuevasReglas);
    _configuracionModificada = true;
    notifyListeners();
  }

  void actualizarPuntajeTotal(double nuevoPuntaje) {
    _configuracion = _configuracion.copyWith(puntajeTotal: nuevoPuntaje);
    _configuracionModificada = true;
    notifyListeners();
  }

  void actualizarNombre(String nuevoNombre) {
    _configuracion = _configuracion.copyWith(nombre: nuevoNombre);
    _configuracionModificada = true;
    notifyListeners();
  }

  void resetearConfiguracion() {
    _configuracion = ConfigNotasAsistencia(
      id: 'config_reset',
      nombre: 'Configuración Reset',
      puntajeTotal: 10.0,
      reglasCalculo: ConfigNotasAsistencia.reglasPorDefecto,
      fechaCreacion: DateTime.now(),
      fechaActualizacion: DateTime.now(),
    );
    _configuracionModificada = true;
    notifyListeners();
  }

  // Métodos de utilidad para la UI
  List<String> get opcionesPuntajeTotal => ['5.0', '10.0', '20.0', '100.0'];
  List<String> get opcionesMinimoAprobatorio => ['5.0', '6.0', '7.0', '8.0'];

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void marcarComoNoModificada() {
    _configuracionModificada = false;
    notifyListeners();
  }

  // Métodos para colores
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

  Color getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.green.shade700
        : Colors.green;
  }
}