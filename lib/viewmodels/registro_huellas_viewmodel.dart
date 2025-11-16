// viewmodels/registro_huellas_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/huella_model.dart';
import '../models/database_helper.dart';
import '../services/esp32_service.dart';

class RegistroHuellasViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  List<HuellaModel> _huellas = [];
  int _huellaActual = 0;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _sensorConectado = false;
  Map<String, dynamic>? _estudiante;
  bool _initialized = false;

  List<HuellaModel> get huellas => _huellas;
  int get huellaActual => _huellaActual;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get sensorConectado => _sensorConectado;
  Map<String, dynamic>? get estudiante => _estudiante;
  
  int get huellasRegistradas {
    return _huellas.where((huella) => huella.registrada).length;
  }

  RegistroHuellasViewModel() {
    _inicializarHuellas();
  }

  void _inicializarHuellas() {
    _huellas = [
      HuellaModel(
        id: 'huella_0',
        estudianteId: '',
        numeroDedo: 1,
        nombreDedo: 'Pulgar derecho',
        icono: '👍',
        registrada: false,
        fechaRegistro: '',
      ),
      HuellaModel(
        id: 'huella_1',
        estudianteId: '',
        numeroDedo: 2,
        nombreDedo: 'Índice derecho',
        icono: '👆',
        registrada: false,
        fechaRegistro: '',
      ),
      HuellaModel(
        id: 'huella_2',
        estudianteId: '',
        numeroDedo: 3,
        nombreDedo: 'Medio derecho',
        icono: '✌️',
        registrada: false,
        fechaRegistro: '',
      ),
    ];
  }

  void configurarEstudiante(Map<String, dynamic> estudiante) {
    _estudiante = estudiante;
    
    if (!_initialized) {
      _initialized = true;
      _inicializarProceso();
    } else {
      _cargarHuellasEstudiante();
    }
  }

  Future<void> _inicializarProceso() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _verificarConexionSensor(),
        _cargarHuellasEstudiante(),
      ]);
    } catch (e) {
      _errorMessage = 'Error inicializando proceso: $e';
      print('❌ Error en inicialización: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _verificarConexionSensor() async {
    try {
      print('🔌 Verificando conexión con ESP32...');
      
      _sensorConectado = await ESP32Service.verificarConexion();
      
      if (_sensorConectado) {
        _errorMessage = '';
        print('✅ ESP32 conectado correctamente');
        
        // Verificar cuántas huellas hay registradas
        final estadisticas = await ESP32Service.contarHuellas();
        if (estadisticas['exito'] == true) {
          print('📊 Huellas en sensor: ${estadisticas['count']}');
        }
      } else {
        _errorMessage = '❌ No se pudo conectar al sensor ESP32';
        print('❌ ESP32 no disponible');
        
        // Sugerencias para el usuario
        _errorMessage += '\n\n🔧 Verifica:';
        _errorMessage += '\n• Que el ESP32 esté encendido';
        _errorMessage += '\n• Que esté en la misma red WiFi';
        _errorMessage += '\n• La IP configurada (${ESP32Service.baseUrl})';
      }
    } catch (e) {
      _sensorConectado = false;
      _errorMessage = '❌ Error verificando sensor: $e';
      print('❌ Error en verificación: $e');
    }
  }

  Future<void> reintentarConexionSensor() async {
    _isLoading = true;
    _errorMessage = '🔄 Intentando reconectar...';
    notifyListeners();

    await _verificarConexionSensor();

    _isLoading = false;
    notifyListeners();
  }

  // viewmodels/registro_huellas_viewmodel.dart
// ACTUALIZA EL MÉTODO registrarHuellaActual:

Future<void> registrarHuellaActual() async {
  if (_isLoading || _estudiante == null) {
    return;
  }

  // Verificar conexión antes de registrar
  if (!_sensorConectado) {
    _errorMessage = '❌ Sensor no conectado. Reintenta la conexión.';
    notifyListeners();
    return;
  }

  final huella = _huellas[_huellaActual];
  if (huella.registrada) {
    _errorMessage = '✅ Esta huella ya está registrada';
    notifyListeners();
    return;
  }

  _isLoading = true;
  _errorMessage = '🔄 Iniciando registro de huella...';
  notifyListeners();

  try {
    print('🔐 Iniciando registro de huella ${huella.nombreDedo}');
    
    // Generar ID único para esta huella
    final fingerprintId = _generarFingerprintId();
    print('📋 Fingerprint ID generado: $fingerprintId');

    // Registrar en el ESP32
    print('🔄 Enviando comando de registro al ESP32...');
    _errorMessage = '🔄 Comunicando con ESP32...';
    notifyListeners();

    final resultado = await ESP32Service.registrarHuella(fingerprintId);

    if (resultado['exito'] == true) {
      print('✅ Huella registrada exitosamente en ESP32 - ID: $fingerprintId');
      
      // Guardar en base de datos local
      await _guardarHuellaEnSQLite(huella, fingerprintId.toString());
      
      // Actualizar estado local
      _marcarHuellaComoRegistrada(_huellaActual, fingerprintId.toString());
      
      _errorMessage = '✅ ${huella.nombreDedo} registrado exitosamente!';
      
      print('💾 Huella guardada en base de datos local');
      
      // Avanzar automáticamente después de 2 segundos
      if (_huellaActual < _huellas.length - 1) {
        await Future.delayed(const Duration(seconds: 2));
        siguienteHuella();
      } else {
        // Si es la última huella, mostrar mensaje de completado
        _errorMessage = '🎉 ¡Todas las huellas han sido registradas!';
      }
    } else {
      final errorMsg = resultado['error'] ?? resultado['mensaje'] ?? 'Error desconocido';
      _errorMessage = '❌ Error del sensor: $errorMsg';
      print('❌ Error del ESP32: $errorMsg');
      
      // Dar instrucciones específicas basadas en el error
      if (errorMsg.contains('timeout') || errorMsg.contains('conexión')) {
        _errorMessage += '\n\n🔧 Verifica la conexión con el ESP32';
      } else if (errorMsg.contains('lleno') || errorMsg.contains('full')) {
        _errorMessage += '\n\n🔧 El sensor está lleno. Elimina huellas antiguas.';
      } else if (errorMsg.contains('Error HTTP')) {
        _errorMessage += '\n\n🔧 El ESP32 no respondió correctamente';
      } else if (errorMsg.contains('Tiempo de espera')) {
        _errorMessage += '\n\n🔧 El registro tomó demasiado tiempo. Reintenta.';
      }
    }
  } catch (e) {
    _errorMessage = '❌ Error en registro: $e';
    print('❌ Error durante registro: $e');
    
    // Manejo específico de errores de red
    if (e.toString().contains('SocketException') || e.toString().contains('Network is unreachable')) {
      _errorMessage += '\n\n🔧 Error de red. Verifica:';
      _errorMessage += '\n• Conexión WiFi del celular';
      _errorMessage += '\n• IP del ESP32 (${ESP32Service.baseUrl})';
      _errorMessage += '\n• Que ambos estén en la misma red';
    }
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  int _generarFingerprintId() {
    if (_estudiante == null) return 0;
    
    try {
      final estudianteId = int.tryParse(_estudiante!['id'].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final dedoId = _huellas[_huellaActual].numeroDedo;
      
      // Ejemplo: estudiante ID 123, dedo 1 -> 1231
      // Limitamos el ID máximo a 127 (límite del sensor)
      final fingerprintId = (estudianteId % 1000) * 10 + dedoId;
      
      // Aseguramos que esté en el rango válido (1-127)
      return fingerprintId.clamp(1, 127);
    } catch (e) {
      print('❌ Error generando fingerprint ID: $e');
      return _huellaActual + 1; // Fallback simple
    }
  }

  Future<void> _guardarHuellaEnSQLite(HuellaModel huella, String templateData) async {
    try {
      final now = DateTime.now().toIso8601String();
      final huellaId = 'huella_${_estudiante!['id']}_${huella.numeroDedo}';

      await _databaseHelper.rawInsert('''
        INSERT OR REPLACE INTO huellas_biometricas (
          id, estudiante_id, numero_dedo, nombre_dedo, icono, 
          registrada, template_data, fecha_registro
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        huellaId,
        _estudiante!['id'],
        huella.numeroDedo,
        huella.nombreDedo,
        huella.icono,
        1,
        templateData,
        now,
      ]);

      await _actualizarContadorHuellasEstudiante();
      print('💾 Huella guardada en SQLite: $huellaId');
    } catch (e) {
      print('❌ Error guardando en SQLite: $e');
      rethrow;
    }
  }

  Future<void> _actualizarContadorHuellasEstudiante() async {
    try {
      final countResult = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM huellas_biometricas 
        WHERE estudiante_id = ? AND registrada = 1
      ''', [_estudiante!['id']]);

      final huellasRegistradas = countResult.first['count'] as int? ?? 0;

      await _databaseHelper.rawUpdate('''
        UPDATE estudiantes 
        SET huellas_registradas = ?, fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        huellasRegistradas,
        DateTime.now().toIso8601String(),
        _estudiante!['id'],
      ]);

      print('📊 Contador actualizado: $huellasRegistradas huellas');
    } catch (e) {
      print('❌ Error actualizando contador: $e');
    }
  }

  Future<void> _cargarHuellasEstudiante() async {
    if (_estudiante == null) return;

    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM huellas_biometricas 
        WHERE estudiante_id = ?
        ORDER BY numero_dedo
      ''', [_estudiante!['id']]);

      for (final row in result) {
        final huellaDb = HuellaModel.fromMap(Map<String, dynamic>.from(row));
        final index = _huellas.indexWhere((h) => h.numeroDedo == huellaDb.numeroDedo);
        if (index != -1) {
          _huellas[index] = huellaDb;
        }
      }
      
      print('📁 Huellas cargadas: ${huellasRegistradas}/${_huellas.length}');
    } catch (e) {
      print('❌ Error cargando huellas: $e');
    }
  }

  void _marcarHuellaComoRegistrada(int index, String templateData) {
    final nuevasHuellas = List<HuellaModel>.from(_huellas);
    nuevasHuellas[index] = nuevasHuellas[index].copyWith(
      registrada: true,
      templateData: templateData,
      fechaRegistro: DateTime.now().toIso8601String(),
      estudianteId: _estudiante!['id'],
    );
    _huellas = nuevasHuellas;
    notifyListeners();
  }

  void siguienteHuella() {
    if (_huellaActual < _huellas.length - 1) {
      _huellaActual++;
      _errorMessage = '';
      notifyListeners();
    }
  }

  void anteriorHuella() {
    if (_huellaActual > 0) {
      _huellaActual--;
      _errorMessage = '';
      notifyListeners();
    }
  }

  void seleccionarHuella(int index) {
    if (index >= 0 && index < _huellas.length) {
      _huellaActual = index;
      _errorMessage = '';
      notifyListeners();
    }
  }

  // Nuevo método para verificar estado detallado
  Future<Map<String, dynamic>> obtenerEstadoDetallado() async {
    return {
      'sensorConectado': _sensorConectado,
      'huellasRegistradas': huellasRegistradas,
      'totalHuellas': _huellas.length,
      'estudiante': _estudiante?['nombres'],
      'ipESP32': ESP32Service.baseUrl,
    };
  }

  // Método para limpiar errores
  void limpiarError() {
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}