// viewmodels/registrar_asistencia_viewmodel.dart - VERSIÓN CON AMBAS OPCIONES
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../models/estudiante_model.dart';
import '../models/database_helper.dart';
import '../utils/constants.dart';

class RegistrarAsistenciaViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final LocalAuthentication auth = LocalAuthentication();
  
  List<Estudiante> _estudiantes = [];
  List<bool> _asistencia = [];
  bool _isLoading = false;
  bool _biometricAvailable = false;
  String _fechaActual = '';
  String _materiaId = 'materia_actual';
  String _periodoId = 'periodo_actual';

  List<Estudiante> get estudiantes => _estudiantes;
  List<bool> get asistencia => _asistencia;
  bool get isLoading => _isLoading;
  bool get biometricAvailable => _biometricAvailable;
  String get fechaActual => _fechaActual;

  RegistrarAsistenciaViewModel() {
    _fechaActual = _obtenerFechaActual();
    _cargarEstudiantesDesdeSQLite();
    _checkBiometricSupport();
  }

  String _obtenerFechaActual() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _cargarEstudiantesDesdeSQLite() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 Cargando TODOS los estudiantes desde SQLite...');

      // ✅ Cargar TODOS los estudiantes
      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM estudiantes 
        ORDER BY apellido_paterno, apellido_materno, nombres
      ''');

      _estudiantes = result.map((row) => 
        Estudiante.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      print('📥 TODOS los estudiantes cargados: ${_estudiantes.length}');

      // Verificar si ya hay asistencias registradas para hoy
      await _cargarAsistenciasDelDia();

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      print('❌ Error cargando estudiantes: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _cargarAsistenciasDelDia() async {
    try {
      // Verificar si ya existen asistencias para hoy
      final asistenciasHoy = await _databaseHelper.rawQuery('''
        SELECT da.asistencia_id, a.estudiante_id 
        FROM detalle_asistencias da
        JOIN asistencias a ON da.asistencia_id = a.id
        WHERE da.fecha = ? AND a.materia_id = ?
      ''', [_fechaActual, _materiaId]);

      // Inicializar lista de asistencia
      _asistencia = List.filled(_estudiantes.length, false);

      // Marcar como presentes los que ya tienen asistencia
      for (final asistenciaReg in asistenciasHoy) {
        final estudianteId = asistenciaReg['estudiante_id']?.toString();
        final index = _estudiantes.indexWhere((est) => est.id == estudianteId);
        if (index != -1) {
          _asistencia[index] = true;
        }
      }

      print('✅ Asistencias del día cargadas: ${asistenciasHoy.length}');
    } catch (e) {
      print('⚠️ Error cargando asistencias del día: $e');
      _asistencia = List.filled(_estudiantes.length, false);
    }
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

      _biometricAvailable = canCheckBiometrics && availableBiometrics.isNotEmpty;
      print('🔐 Soporte biométrico: $_biometricAvailable');
      notifyListeners();
    } catch (e) {
      _biometricAvailable = false;
      print('❌ Error verificando soporte biométrico: $e');
      notifyListeners();
    }
  }

  // ✅ MÉTODO PARA REGISTRAR CON HUELLA
  Future<void> registrarConHuella(int index, BuildContext context) async {
    if (_isLoading || _asistencia[index]) return;

    final estudiante = _estudiantes[index];
    
    // Verificar si el estudiante tiene huellas registradas
    if (!estudiante.tieneHuellasRegistradas) {
      _mostrarSnackbar(
        context,
        "❌ ${estudiante.nombreCompleto} no tiene huellas registradas",
        getErrorColor(context),
      );
      return;
    }

    // Verificar disponibilidad biométrica
    if (!_biometricAvailable) {
      _mostrarSnackbar(
        context,
        "📱 El dispositivo no soporta autenticación biométrica",
        getWarningColor(context),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🔐 Autenticando huella para: ${estudiante.nombreCompleto}');

      // Realizar autenticación biométrica
      final bool autenticado = await auth.authenticate(
        localizedReason: "Autentica tu huella para registrar asistencia de ${estudiante.nombreCompleto}",
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (autenticado) {
        // Guardar asistencia en SQLite
        await _guardarAsistenciaEnSQLite(estudiante.id, 'biometrico');
        
        _asistencia[index] = true;
        _mostrarSnackbar(
          context,
          "✅ Asistencia biométrica confirmada - ${estudiante.nombreCompleto}",
          getSuccessColor(context),
        );
        
        print('✅ Asistencia biométrica registrada para: ${estudiante.nombreCompleto}');
      } else {
        _mostrarSnackbar(
          context,
          "❌ Huella no reconocida - ${estudiante.nombreCompleto}",
          getErrorColor(context),
        );
      }
    } catch (e) {
      print('❌ Error en autenticación biométrica: $e');
      _mostrarSnackbar(
        context,
        "⚠️ Error de autenticación biométrica",
        getErrorColor(context),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ MÉTODO PARA REGISTRAR MANUALMENTE
  Future<void> registrarManual(int index, BuildContext context) async {
    if (_isLoading || _asistencia[index]) return;

    final estudiante = _estudiantes[index];

    // Mostrar diálogo de confirmación
    final bool confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Asistencia Manual'),
        content: Text('¿Registrar asistencia manual para ${estudiante.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmado) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Guardar asistencia manual en SQLite
      await _guardarAsistenciaEnSQLite(estudiante.id, 'manual');
      
      _asistencia[index] = true;
      _mostrarSnackbar(
        context,
        "✅ Asistencia manual registrada - ${estudiante.nombreCompleto}",
        getSuccessColor(context),
      );
      
      print('📋 Asistencia manual registrada para: ${estudiante.nombreCompleto}');

    } catch (e) {
      print('❌ Error registrando asistencia manual: $e');
      _mostrarSnackbar(
        context,
        "⚠️ Error registrando asistencia: ${e.toString()}",
        getErrorColor(context),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _guardarAsistenciaEnSQLite(String estudianteId, String tipo) async {
    try {
      final now = DateTime.now();
      final nowString = now.toIso8601String();

      // Primero, verificar si ya existe una asistencia para este estudiante en el período actual
      final asistenciaExistente = await _databaseHelper.rawQuery('''
        SELECT id FROM asistencias 
        WHERE estudiante_id = ? AND periodo_id = ? AND materia_id = ?
      ''', [estudianteId, _periodoId, _materiaId]);

      String asistenciaId;

      if (asistenciaExistente.isNotEmpty) {
        // Usar la asistencia existente
        asistenciaId = asistenciaExistente.first['id']?.toString() ?? '';
        
        // Actualizar asistencia existente
        await _databaseHelper.rawUpdate('''
          UPDATE asistencias 
          SET asistencia_registrada_hoy = ?, datos_asistencia = ?, ultima_actualizacion = ?
          WHERE id = ?
        ''', [
          1,
          '{"fecha": "$nowString", "tipo": "$tipo", "fecha_registro": "$_fechaActual"}',
          nowString,
          asistenciaId
        ]);
      } else {
        // Crear nueva asistencia
        asistenciaId = 'asist_${estudianteId}_${now.millisecondsSinceEpoch}';
        
        await _databaseHelper.rawInsert('''
          INSERT INTO asistencias (
            id, estudiante_id, periodo_id, materia_id, 
            asistencia_registrada_hoy, datos_asistencia, ultima_actualizacion
          ) VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', [
          asistenciaId,
          estudianteId,
          _periodoId,
          _materiaId,
          1,
          '{"fecha": "$nowString", "tipo": "$tipo", "fecha_registro": "$_fechaActual"}',
          nowString,
        ]);
      }

      // Ahora insertar/actualizar en detalle_asistencias
      await _guardarDetalleAsistencia(asistenciaId, estudianteId);

      print('💾 Asistencia guardada en SQLite: $estudianteId - $tipo');

    } catch (e) {
      print('❌ Error guardando asistencia en SQLite: $e');
      rethrow;
    }
  }

  Future<void> _guardarDetalleAsistencia(String asistenciaId, String estudianteId) async {
    try {
      final now = DateTime.now();
      
      // Verificar si ya existe un registro para hoy
      final detalleExistente = await _databaseHelper.rawQuery('''
        SELECT id FROM detalle_asistencias 
        WHERE asistencia_id = ? AND fecha = ?
      ''', [asistenciaId, _fechaActual]);

      if (detalleExistente.isNotEmpty) {
        // Actualizar registro existente
        await _databaseHelper.rawUpdate('''
          UPDATE detalle_asistencias 
          SET estado = 'P', porcentaje = 100, dia = ?
          WHERE asistencia_id = ? AND fecha = ?
        ''', [
          DateTime.now().day.toString(),
          asistenciaId,
          _fechaActual
        ]);
      } else {
        // Crear nuevo registro
        await _databaseHelper.rawInsert('''
          INSERT INTO detalle_asistencias (
            id, asistencia_id, dia, porcentaje, estado, fecha
          ) VALUES (?, ?, ?, ?, ?, ?)
        ''', [
          'det_${asistenciaId}_${now.millisecondsSinceEpoch}',
          asistenciaId,
          DateTime.now().day.toString(),
          100,
          'P', // P = Presente
          _fechaActual
        ]);
      }

      print('📝 Detalle de asistencia guardado: $estudianteId');

    } catch (e) {
      print('❌ Error guardando detalle de asistencia: $e');
      rethrow;
    }
  }

  // ✅ MÉTODO PARA REGISTRAR POR ID (útil para QR)
  void registrarAsistenciaPorId(String estudianteId, BuildContext context, {bool esManual = false}) {
    final index = _estudiantes.indexWhere((est) => est.id == estudianteId);
    if (index != -1 && !_asistencia[index]) {
      if (esManual) {
        registrarManual(index, context);
      } else {
        registrarConHuella(index, context);
      }
    } else if (index != -1) {
      _mostrarSnackbar(
        context,
        "ℹ️ ${_estudiantes[index].nombreCompleto} ya tiene asistencia registrada",
        getWarningColor(context),
      );
    }
  }

  Future<void> limpiarAsistencias() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Limpiar asistencias del día en la base de datos
      await _databaseHelper.rawDelete('''
        DELETE FROM detalle_asistencias 
        WHERE fecha = ?
      ''', [_fechaActual]);

      // Resetear asistencias en memoria
      _asistencia = List.filled(_estudiantes.length, false);

      _isLoading = false;
      notifyListeners();

      print('🗑️ Asistencias del día limpiadas');

    } catch (e) {
      print('❌ Error limpiando asistencias: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Map<String, dynamic> getEstadisticas() {
    final total = _estudiantes.length;
    final presentes = _asistencia.where((a) => a).length;
    final ausentes = total - presentes;
    final porcentaje = total > 0 ? (presentes / total * 100) : 0;

    return {
      'total': total,
      'presentes': presentes,
      'ausentes': ausentes,
      'porcentaje': porcentaje.roundToDouble(),
      'fecha': _fechaActual,
    };
  }

  void _mostrarSnackbar(BuildContext context, String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje, 
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Getters para la UI
  int get totalAsistencias => _asistencia.where((element) => element).length;
  int get totalEstudiantes => _estudiantes.length;
  int get estudiantesConHuellas => _estudiantes.where((est) => est.tieneHuellasRegistradas).length;

  Estudiante? obtenerEstudiantePorId(String id) {
    try {
      return _estudiantes.firstWhere((est) => est.id == id);
    } catch (e) {
      return null;
    }
  }

  bool tieneAsistenciaRegistrada(String estudianteId) {
    final index = _estudiantes.indexWhere((est) => est.id == estudianteId);
    return index != -1 ? _asistencia[index] : false;
  }

  Future<void> recargarEstudiantes() async {
    await _cargarEstudiantesDesdeSQLite();
  }

  // Funciones para obtener colores según el tema
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : AppColors.background;
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

  Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : AppColors.border;
  }

  Color getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.green.shade700
        : AppColors.success;
  }

  Color getWarningColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.orange.shade700
        : AppColors.warning;
  }

  Color getErrorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade700
        : AppColors.error;
  }

  Color getAccentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blue.shade700
        : AppColors.accent;
  }
}