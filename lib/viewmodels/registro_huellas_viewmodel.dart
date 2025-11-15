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

  List<HuellaModel> get huellas => _huellas;
  int get huellaActual => _huellaActual;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get sensorConectado => _sensorConectado;
  Map<String, dynamic>? get estudiante => _estudiante;
  
  // AÑADIR ESTA PROPIEDAD GETTER
  int get huellasRegistradas {
    return _huellas.where((huella) => huella.registrada).length;
  }

  // Inicializar con datos de huellas por defecto
  RegistroHuellasViewModel() {
    _inicializarHuellas();
    _verificarConexionSensor();
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

  // Configurar estudiante para el registro
  void configurarEstudiante(Map<String, dynamic> estudiante) {
    _estudiante = estudiante;
    
    // Cargar huellas existentes del estudiante
    _cargarHuellasEstudiante();
    notifyListeners();
  }

  // Verificar conexión con el sensor ESP32
  Future<void> _verificarConexionSensor() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sensorConectado = await ESP32Service.verificarConexion();
      _errorMessage = _sensorConectado ? '' : 'Sensor no conectado';
    } catch (e) {
      _sensorConectado = false;
      _errorMessage = 'Error verificando sensor: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Cargar huellas existentes del estudiante desde SQLite
  Future<void> _cargarHuellasEstudiante() async {
    if (_estudiante == null) return;

    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM huellas_biometricas 
        WHERE estudiante_id = ?
        ORDER BY numero_dedo
      ''', [_estudiante!['id']]);

      // Actualizar estado de las huellas
      for (final row in result) {
        final huellaDb = HuellaModel.fromMap(Map<String, dynamic>.from(row));
        final index = _huellas.indexWhere((h) => h.numeroDedo == huellaDb.numeroDedo);
        if (index != -1) {
          _huellas[index] = huellaDb;
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error cargando huellas: $e');
    }
  }

  // Registrar la huella actual en el sensor ESP32
  Future<void> registrarHuellaActual() async {
    if (_isLoading || _estudiante == null) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Verificar conexión con el sensor
      if (!_sensorConectado) {
        _errorMessage = 'Sensor de huellas no conectado';
        return;
      }

      final huella = _huellas[_huellaActual];
      
      print('🔐 Registrando huella ${huella.nombreDedo} para estudiante ${_estudiante!['nombres']}');

      // Usar el ID del estudiante como fingerprintId en el ESP32
      final fingerprintId = _generarFingerprintId();

      // Registrar huella en el sensor ESP32
      final resultado = await ESP32Service.registrarHuella(fingerprintId);

      if (resultado['exito'] == true) {
        // Guardar huella en SQLite
        await _guardarHuellaEnSQLite(huella, fingerprintId.toString());
        
        // Marcar como registrada
        _marcarHuellaComoRegistrada(_huellaActual, fingerprintId.toString());
        
        _errorMessage = '✅ ${huella.nombreDedo} registrado exitosamente';
        
        print('✅ Huella registrada - ID: $fingerprintId');

        // Avanzar automáticamente si no es la última
        if (_huellaActual < _huellas.length - 1) {
          await Future.delayed(const Duration(seconds: 2));
          siguienteHuella();
        }
      } else {
        _errorMessage = '❌ Error registrando huella: ${resultado['error'] ?? resultado['mensaje']}';
      }
    } catch (e) {
      _errorMessage = '❌ Error: $e';
      print('❌ Error en registro de huella: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generar ID único para la huella basado en estudiante + dedo
  int _generarFingerprintId() {
    final estudianteId = int.tryParse(_estudiante!['id'].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final dedoId = _huellas[_huellaActual].numeroDedo;
    
    // Combinar ID estudiante y número de dedo para crear ID único
    return (estudianteId % 1000) * 10 + dedoId;
  }

  // Guardar huella en SQLite
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
        1, // registrada
        templateData, // Guardamos el fingerprintId del ESP32
        now,
      ]);

      // Actualizar contador de huellas en el estudiante
      await _actualizarContadorHuellasEstudiante();

      print('💾 Huella guardada en SQLite: $huellaId');
    } catch (e) {
      print('❌ Error guardando huella en SQLite: $e');
      rethrow;
    }
  }

  // Actualizar contador de huellas del estudiante
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

      print('📊 Huellas actualizadas: $huellasRegistradas');
    } catch (e) {
      print('❌ Error actualizando contador de huellas: $e');
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
    notifyListeners(); // Asegurar que se notifique el cambio
  }

  // Navegación entre huellas
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

  // Verificar huella para asistencia
  Future<bool> verificarHuellaParaAsistencia() async {
    if (!_sensorConectado) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final resultado = await ESP32Service.buscarHuella();
      
      _isLoading = false;
      notifyListeners();

      if (resultado['encontrada'] == true) {
        final fingerprintId = resultado['fingerprintId'] as int;
        final confidence = resultado['confidence'] as int;
        
        print('✅ Huella encontrada - ID: $fingerprintId, Confianza: $confidence');
        
        // Aquí podrías buscar en SQLite qué estudiante tiene esta huella
        return await _verificarHuellaEnSQLite(fingerprintId);
      }
      
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verificar si la huella encontrada corresponde a un estudiante
  Future<bool> _verificarHuellaEnSQLite(int fingerprintId) async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT estudiante_id FROM huellas_biometricas 
        WHERE template_data = ? AND registrada = 1
      ''', [fingerprintId.toString()]);

      return result.isNotEmpty;
    } catch (e) {
      print('❌ Error verificando huella en SQLite: $e');
      return false;
    }
  }

  // Reiniciar el proceso
  void reiniciarProceso() {
    _huellaActual = 0;
    _errorMessage = '';
    _inicializarHuellas();
    notifyListeners();
  }

  // Método para obtener el número total de huellas registradas
  int getTotalHuellasRegistradas() {
    return huellasRegistradas;
  }
}