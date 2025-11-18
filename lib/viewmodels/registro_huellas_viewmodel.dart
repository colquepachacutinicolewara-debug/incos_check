// viewmodels/registro_huellas_viewmodel.dart - VERSIÓN COMPLETA CORREGIDA
import 'package:flutter/material.dart';
import '../models/huella_model.dart';
import '../models/database_helper.dart';
import '../services/esp32_service.dart';
import '../repositories/huella_repository.dart';

class RegistroHuellasViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final HuellaRepository _huellaRepository = HuellaRepository();
  
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
      // ✅ PRIMERO: Verificar estado de la BD
      await _verificarEstadoBD();
      
      // ✅ SEGUNDO: Verificar que el estudiante existe en la BD
      await _verificarEstudianteEnBD();
      
      // ✅ TERCERO: Verificar sensor y cargar huellas
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

  // ✅ NUEVO: VERIFICAR ESTADO DE LA BD
  Future<void> _verificarEstadoBD() async {
    try {
      print('🔍 === VERIFICACIÓN DE BASE DE DATOS ===');
      
      // Verificar estudiantes
      final estudiantes = await _databaseHelper.rawQuery('SELECT id, nombres FROM estudiantes LIMIT 5');
      print('📋 Estudiantes en BD:');
      for (var est in estudiantes) {
        print('   - ${est['id']}: ${est['nombres']}');
      }
      
      // Verificar huellas existentes
      final huellas = await _databaseHelper.rawQuery('SELECT * FROM huellas_biometricas LIMIT 5');
      print('📋 Huellas en BD: ${huellas.length}');
      
      print('🔍 === FIN VERIFICACIÓN ===');
    } catch (e) {
      print('❌ Error verificando BD: $e');
    }
  }

  // ✅ VERIFICAR QUE EL ESTUDIANTE EXISTE EN LA BD
  Future<void> _verificarEstudianteEnBD() async {
    if (_estudiante == null) return;
    
    try {
      final estudianteExiste = await _huellaRepository.verificarEstudianteExiste(_estudiante!['id']);
      
      if (!estudianteExiste) {
        throw Exception('El estudiante no existe en la base de datos. ID: ${_estudiante!['id']}');
      }
      
      print('✅ Estudiante verificado en BD: ${_estudiante!['id']}');
    } catch (e) {
      print('❌ Error verificando estudiante en BD: $e');
      rethrow;
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

  // ✅ MÉTODO PRINCIPAL CORREGIDO PARA REGISTRAR HUELLA
  Future<void> registrarHuellaActual() async {
    if (_isLoading || _estudiante == null) {
      print('⏸️  Registro bloqueado - Loading: $_isLoading, Estudiante: ${_estudiante != null}');
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
        await _guardarHuellaEnBD(huella, fingerprintId.toString());
        
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
      }
    } catch (e) {
      _errorMessage = '❌ Error en registro: $e';
      print('❌ Error durante registro: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ MÉTODO CORREGIDO PARA GUARDAR EN BD
  Future<void> _guardarHuellaEnBD(HuellaModel huella, String templateData) async {
    try {
      final now = DateTime.now().toIso8601String();
      final huellaId = 'huella_${_estudiante!['id']}_${huella.numeroDedo}';

      print('💾 Preparando huella para guardar:');
      print('   - ID: $huellaId');
      print('   - Estudiante ID: ${_estudiante!['id']}');
      print('   - Dedo: ${huella.numeroDedo}');
      print('   - Template: $templateData');

      final nuevaHuella = HuellaModel(
        id: huellaId,
        estudianteId: _estudiante!['id'],
        numeroDedo: huella.numeroDedo,
        nombreDedo: huella.nombreDedo,
        icono: huella.icono,
        registrada: true,
        templateData: templateData,
        fechaRegistro: now,
      );

      // ✅ USAR EL REPOSITORY PARA INSERTAR
      final exito = await _huellaRepository.insertarHuella(nuevaHuella);
      
      if (exito) {
        print('🎉 Huella guardada exitosamente en SQLite: $huellaId');
      } else {
        print('❌ FALLÓ el guardado en BD - Repository retornó false');
        throw Exception('No se pudo guardar la huella en la base de datos - Ver logs');
      }
    } catch (e) {
      print('❌ Error crítico guardando en SQLite: $e');
      rethrow;
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

  Future<void> _cargarHuellasEstudiante() async {
    if (_estudiante == null) return;

    try {
      // ✅ USAR EL REPOSITORY PARA CARGAR HUELLAS
      final huellasBD = await _huellaRepository.obtenerHuellasPorEstudiante(_estudiante!['id']);

      for (final huellaDb in huellasBD) {
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