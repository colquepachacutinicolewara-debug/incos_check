// viewmodels/registro_huella_simple_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/database_helper.dart';
import '../services/esp32_service.dart';

class RegistroHuellaSimpleViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  Map<String, dynamic>? _estudiante;
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  bool _sensorConectado = false;
  int _fingerprintId = 1;
  bool _huellaRegistrada = false;

  Map<String, dynamic>? get estudiante => _estudiante;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  bool get sensorConectado => _sensorConectado;
  int get fingerprintId => _fingerprintId;
  bool get huellaRegistrada => _huellaRegistrada;

  void configurarEstudiante(Map<String, dynamic> estudiante) {
    _estudiante = estudiante;
    _errorMessage = '';
    _successMessage = '';
    _huellaRegistrada = false;
    
    // Generar ID basado en el estudiante
    _generarFingerprintId();
    
    // Verificar si ya tiene huella registrada
    _verificarHuellaExistente();
    
    // Verificar conexión con sensor
    _verificarConexionSensor();
    
    notifyListeners();
  }

  void _generarFingerprintId() {
    if (_estudiante == null) return;
    
    try {
      // Usar los últimos 3 dígitos del ID del estudiante
      final estudianteId = _estudiante!['id'] as String;
      final digitos = estudianteId.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (digitos.length >= 2) {
        final baseId = int.parse(digitos.substring(digitos.length - 2));
        _fingerprintId = (baseId % 127) + 1; // Asegurar que esté entre 1-127
      } else {
        // Fallback: usar hash del nombre
        final nombres = _estudiante!['nombres'] as String;
        _fingerprintId = (nombres.hashCode.abs() % 127) + 1;
      }
    } catch (e) {
      print('❌ Error generando fingerprint ID: $e');
      _fingerprintId = 1; // Valor por defecto
    }
  }

  Future<void> _verificarHuellaExistente() async {
    if (_estudiante == null) return;
    
    try {
      final huellas = await _databaseHelper.obtenerHuellasPorEstudiante(_estudiante!['id']);
      _huellaRegistrada = huellas.isNotEmpty;
    } catch (e) {
      print('❌ Error verificando huella existente: $e');
      _huellaRegistrada = false;
    }
  }

  Future<void> _verificarConexionSensor() async {
    try {
      _isLoading = true;
      notifyListeners();

      final resultado = await ESP32Service.verificarConexion();
      _sensorConectado = resultado['conectado'] == true;
      
      if (!_sensorConectado) {
        _errorMessage = '❌ No se pudo conectar al sensor ESP32';
      } else {
        _errorMessage = '';
      }
    } catch (e) {
      _sensorConectado = false;
      _errorMessage = '❌ Error verificando sensor: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ MÉTODO PRINCIPAL PARA REGISTRAR HUELLA
  Future<void> registrarHuella() async {
    if (_isLoading || _estudiante == null || _huellaRegistrada) {
      return;
    }

    if (!_sensorConectado) {
      _errorMessage = '❌ Sensor no conectado. Verifica la conexión.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      print('🔐 Iniciando registro de huella...');
      print('   Estudiante: ${_estudiante!['id']}');
      print('   Fingerprint ID: $_fingerprintId');

      // 1. Registrar en el ESP32
      final resultado = await ESP32Service.registrarHuella(
        studentId: _estudiante!['id'],
        fingerprintId: _fingerprintId,
      );

      if (resultado['exito'] == true) {
        // 2. Guardar en base de datos local
        await _guardarHuellaEnBD();
        
        _successMessage = resultado['mensaje'] ?? '✅ Huella registrada exitosamente';
        _huellaRegistrada = true;
        
        print('🎉 Huella registrada y guardada en BD');
      } else {
        _errorMessage = resultado['error'] ?? resultado['mensaje'] ?? '❌ Error desconocido';
        print('❌ Error del ESP32: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = '❌ Error en registro: $e';
      print('❌ Error durante registro: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ GUARDAR EN BASE DE DATOS
  Future<void> _guardarHuellaEnBD() async {
    try {
      final now = DateTime.now().toIso8601String();
      final huellaId = 'huella_${_estudiante!['id']}';

      final huellaData = {
        'id': huellaId,
        'estudiante_id': _estudiante!['id'],
        'numero_dedo': 1, // Solo un dedo por estudiante
        'nombre_dedo': 'Dedo Principal',
        'icono': '👍',
        'registrada': 1,
        'template_data': 'fingerprint_$_fingerprintId',
        'fecha_registro': now,
        'dispositivo_registro': 'ESP32',
      };

      // Insertar o actualizar huella
      await _databaseHelper.insertarHuellaBiometrica(huellaData);

      // Actualizar contador del estudiante
      await _databaseHelper.rawUpdate('''
        UPDATE estudiantes 
        SET huellas_registradas = 1, fecha_actualizacion = ?
        WHERE id = ?
      ''', [now, _estudiante!['id']]);

      print('💾 Huella guardada en SQLite: $huellaId');
    } catch (e) {
      print('❌ Error guardando en BD: $e');
      rethrow;
    }
  }

  // ✅ ELIMINAR HUELLA
  Future<void> eliminarHuella() async {
    if (_estudiante == null || !_huellaRegistrada) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Eliminar de la base de datos local
      await _databaseHelper.rawDelete(
        'DELETE FROM huellas_biometricas WHERE estudiante_id = ?',
        [_estudiante!['id']]
      );

      // 2. Actualizar estudiante
      await _databaseHelper.rawUpdate(
        'UPDATE estudiantes SET huellas_registradas = 0 WHERE id = ?',
        [_estudiante!['id']]
      );

      // 3. Opcional: Eliminar del ESP32 (requeriría endpoint adicional)
      // await ESP32Service.eliminarHuella(_fingerprintId);

      _huellaRegistrada = false;
      _successMessage = '✅ Huella eliminada exitosamente';
      _errorMessage = '';

      print('🗑️ Huella eliminada para estudiante: ${_estudiante!['id']}');
    } catch (e) {
      _errorMessage = '❌ Error eliminando huella: $e';
      print('❌ Error eliminando huella: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ CAMBIAR FINGERPRINT ID
  void cambiarFingerprintId(int nuevoId) {
    if (nuevoId >= 1 && nuevoId <= 127) {
      _fingerprintId = nuevoId;
      notifyListeners();
    }
  }

  // ✅ REINTENTAR CONEXIÓN
  Future<void> reintentarConexion() async {
    await _verificarConexionSensor();
  }

  // ✅ OBTENER INFORMACIÓN DEL ESTADO
  Map<String, dynamic> obtenerEstado() {
    return {
      'estudiante': _estudiante?['nombres'],
      'estudianteId': _estudiante?['id'],
      'fingerprintId': _fingerprintId,
      'huellaRegistrada': _huellaRegistrada,
      'sensorConectado': _sensorConectado,
      'cargando': _isLoading,
    };
  }

  void limpiarMensajes() {
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }
}