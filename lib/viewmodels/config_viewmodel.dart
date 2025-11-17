// viewmodels/config_viewmodel.dart - VERSIÓN CORREGIDA
import 'package:flutter/material.dart';
import '../models/config_notas_model.dart';
import '../models/database_helper.dart';

class ConfigViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  ConfigNotasAsistencia _configuracion = ConfigNotasAsistencia(
    id: 'config_default',
    nombre: 'Configuración Por Defecto',
    descripcion: 'Configuración inicial del sistema',
    puntajeMaximo: 10.0,
    formulaTipo: 'BIMESTRAL',
    parametros: '{"asistencia_minima": 80, "tolerancia_minutos": 15, "considera_puntualidad": true}',
    activo: true,
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

      final result = await _databaseHelper.obtenerConfiguracionNotasAsistenciaActiva();

      if (result != null) {
        _configuracion = ConfigNotasAsistencia.fromMap(result);
        print('✅ Configuración cargada: ${_configuracion.nombre}');
      } else {
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
      final config = ConfigNotasAsistencia(
        id: 'config_asistencia_default',
        nombre: 'Configuración Notas Asistencia Tercer Año B',
        descripcion: 'Cálculo de nota de asistencia bimestral sobre 10 puntos',
        puntajeMaximo: 10.0,
        formulaTipo: 'BIMESTRAL',
        parametros: '{"asistencia_minima": 80, "tolerancia_minutos": 15, "considera_puntualidad": true}',
        activo: true,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      await _databaseHelper.rawInsert('''
        INSERT INTO config_notas_asistencia 
        (id, nombre, descripcion, puntaje_maximo, formula_tipo, parametros, activo, fecha_creacion, fecha_actualizacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        config.id,
        config.nombre,
        config.descripcion,
        config.puntajeMaximo,
        config.formulaTipo,
        config.parametros,
        config.activo ? 1 : 0,
        config.fechaCreacion.toIso8601String(),
        config.fechaActualizacion.toIso8601String(),
      ]);

      _configuracion = config;
      print('✅ Configuración por defecto creada');

    } catch (e) {
      print('❌ Error creando configuración por defecto: $e');
      rethrow;
    }
  }

  Future<bool> guardarConfiguracion() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Actualizar configuración
      await _databaseHelper.rawUpdate('''
        UPDATE config_notas_asistencia 
        SET nombre = ?, descripcion = ?, puntaje_maximo = ?, formula_tipo = ?, 
            parametros = ?, fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        _configuracion.nombre,
        _configuracion.descripcion,
        _configuracion.puntajeMaximo,
        _configuracion.formulaTipo,
        _configuracion.parametros,
        DateTime.now().toIso8601String(),
        _configuracion.id,
      ]);

      _configuracionModificada = false;
      _error = null;
      
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

  void actualizarNombre(String nombre) {
    _configuracion = _configuracion.copyWith(nombre: nombre);
    _configuracionModificada = true;
    notifyListeners();
  }

  void actualizarDescripcion(String descripcion) {
    _configuracion = _configuracion.copyWith(descripcion: descripcion);
    _configuracionModificada = true;
    notifyListeners();
  }

  void actualizarPuntajeMaximo(double puntajeMaximo) {
    _configuracion = _configuracion.copyWith(puntajeMaximo: puntajeMaximo);
    _configuracionModificada = true;
    notifyListeners();
  }

  void actualizarParametro(String clave, dynamic valor) {
    final nuevosParametros = _configuracion.withParametros({clave: valor});
    _configuracion = nuevosParametros;
    _configuracionModificada = true;
    notifyListeners();
  }

  void resetearConfiguracion() {
    _configuracion = ConfigNotasAsistencia(
      id: 'config_reset',
      nombre: 'Configuración Reset',
      descripcion: 'Configuración restablecida',
      puntajeMaximo: 10.0,
      formulaTipo: 'BIMESTRAL',
      parametros: '{"asistencia_minima": 80, "tolerancia_minutos": 15, "considera_puntualidad": true}',
      activo: true,
      fechaCreacion: DateTime.now(),
      fechaActualizacion: DateTime.now(),
    );
    _configuracionModificada = true;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void marcarComoNoModificada() {
    _configuracionModificada = false;
    notifyListeners();
  }
}