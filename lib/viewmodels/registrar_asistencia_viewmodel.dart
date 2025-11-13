// viewmodels/registrar_asistencia_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../models/estudiante_model.dart';
import '../models/database_helper.dart';
import '../utils/constants.dart';

class RegistrarAsistenciaViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final LocalAuthentication auth = LocalAuthentication();
  
  List<Estudiante> estudiantes = [];
  List<bool> asistencia = [];
  bool _isLoading = false;
  bool _biometricAvailable = false;

  bool get isLoading => _isLoading;
  bool get biometricAvailable => _biometricAvailable;

  RegistrarAsistenciaViewModel() {
    _cargarEstudiantesDesdeSQLite();
    _checkBiometricSupport();
  }

  Future<void> _cargarEstudiantesDesdeSQLite() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM estudiantes 
        WHERE activo = 1 
        ORDER BY apellido_paterno, apellido_materno, nombres
      ''');

      estudiantes = result.map((row) => 
        Estudiante.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      // Si no hay estudiantes, cargar los de ejemplo
      if (estudiantes.isEmpty) {
        await _cargarEstudiantesEjemplo();
      }

      asistencia = List.filled(estudiantes.length, false);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error cargando estudiantes: $e');
      await _cargarEstudiantesEjemplo();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cargarEstudiantesEjemplo() async {
    final estudiantesEjemplo = [
      Estudiante(
        id: '1',
        nombres: 'Ana',
        apellidoPaterno: 'García',
        apellidoMaterno: 'López',
        ci: '1234567',
        fechaRegistro: DateTime.now().toIso8601String(),
        huellasRegistradas: 3,
      ),
      Estudiante(
        id: '2',
        nombres: 'Carlos',
        apellidoPaterno: 'Rodríguez',
        apellidoMaterno: 'Mendoza',
        ci: '1234568',
        fechaRegistro: DateTime.now().toIso8601String(),
        huellasRegistradas: 3,
      ),
      Estudiante(
        id: '3',
        nombres: 'María',
        apellidoPaterno: 'Fernández',
        apellidoMaterno: 'Castro',
        ci: '1234569',
        fechaRegistro: DateTime.now().toIso8601String(),
        huellasRegistradas: 3,
      ),
      Estudiante(
        id: '4',
        nombres: 'José',
        apellidoPaterno: 'Martínez',
        apellidoMaterno: 'Rojas',
        ci: '1234570',
        fechaRegistro: DateTime.now().toIso8601String(),
        huellasRegistradas: 3,
      ),
      Estudiante(
        id: '5',
        nombres: 'Laura',
        apellidoPaterno: 'Hernández',
        apellidoMaterno: 'Silva',
        ci: '1234571',
        fechaRegistro: DateTime.now().toIso8601String(),
        huellasRegistradas: 3,
      ),
    ];

    // Insertar estudiantes de ejemplo en SQLite
    for (final estudiante in estudiantesEjemplo) {
      await _databaseHelper.rawInsert('''
        INSERT OR IGNORE INTO estudiantes (id, nombres, apellido_paterno, apellido_materno, ci, fecha_registro, huellas_registradas, fecha_creacion, fecha_actualizacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        estudiante.id,
        estudiante.nombres,
        estudiante.apellidoPaterno,
        estudiante.apellidoMaterno,
        estudiante.ci,
        estudiante.fechaRegistro,
        estudiante.huellasRegistradas,
        DateTime.now().toIso8601String(),
        DateTime.now().toIso8601String(),
      ]);
    }

    estudiantes = estudiantesEjemplo;
    asistencia = List.filled(estudiantes.length, false);
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

      _biometricAvailable = canCheckBiometrics && availableBiometrics.isNotEmpty;
      notifyListeners();
    } catch (e) {
      _biometricAvailable = false;
      notifyListeners();
    }
  }

  Future<void> autenticarHuella(int index, BuildContext context) async {
    if (_isLoading || asistencia[index]) return;

    _isLoading = true;
    notifyListeners();

    try {
      final estudiante = estudiantes[index];

      // Verificar si el estudiante tiene huellas registradas
      if (!estudiante.tieneTodasLasHuellas) {
        _mostrarSnackbar(
          context,
          "${estudiante.nombreCompleto} no tiene huellas registradas en el sistema",
          getWarningColor(context),
        );
        return;
      }

      // Verificar disponibilidad de biométricos
      if (!_biometricAvailable) {
        _mostrarSnackbar(
          context,
          "El dispositivo no soporta autenticación biométrica",
          getErrorColor(context),
        );
        return;
      }

      // Realizar autenticación biométrica
      final bool autenticado = await auth.authenticate(
        localizedReason: "Autentica tu identidad para ${estudiante.nombreCompleto}",
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (autenticado) {
        // Guardar asistencia en SQLite
        await _guardarAsistenciaEnSQLite(estudiante.id);
        
        asistencia[index] = true;
        _mostrarSnackbar(
          context,
          "✅ Asistencia confirmada - ${estudiante.nombreCompleto}",
          getSuccessColor(context),
        );
      } else {
        _mostrarSnackbar(
          context,
          "❌ Huella no coincide con ${estudiante.nombreCompleto}",
          getErrorColor(context),
        );
      }
    } catch (e) {
      _mostrarSnackbar(
        context,
        "Error de autenticación: ${e.toString()}",
        getErrorColor(context),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _guardarAsistenciaEnSQLite(String estudianteId) async {
    try {
      final now = DateTime.now();
      await _databaseHelper.rawInsert('''
        INSERT INTO asistencias (id, estudiante_id, periodo_id, materia_id, asistencia_registrada_hoy, datos_asistencia, ultima_actualizacion)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', [
        'asist_${estudianteId}_${now.millisecondsSinceEpoch}',
        estudianteId,
        'periodo_actual',
        'materia_actual',
        1,
        '{"fecha": "${now.toIso8601String()}", "tipo": "biometrico"}',
        now.toIso8601String(),
      ]);
    } catch (e) {
      print('Error guardando asistencia: $e');
    }
  }

  void registrarSinHuella(int index, BuildContext context) {
    if (_isLoading || asistencia[index]) return;

    asistencia[index] = true;
    _guardarAsistenciaManualEnSQLite(estudiantes[index].id);
    
    _mostrarSnackbar(
      context,
      "✅ Asistencia manual - ${estudiantes[index].nombreCompleto}",
      getSuccessColor(context),
    );
    notifyListeners();
  }

  Future<void> _guardarAsistenciaManualEnSQLite(String estudianteId) async {
    try {
      final now = DateTime.now();
      await _databaseHelper.rawInsert('''
        INSERT INTO asistencias (id, estudiante_id, periodo_id, materia_id, asistencia_registrada_hoy, datos_asistencia, ultima_actualizacion)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', [
        'asist_manual_${estudianteId}_${now.millisecondsSinceEpoch}',
        estudianteId,
        'periodo_actual',
        'materia_actual',
        1,
        '{"fecha": "${now.toIso8601String()}", "tipo": "manual"}',
        now.toIso8601String(),
      ]);
    } catch (e) {
      print('Error guardando asistencia manual: $e');
    }
  }

  void registrarAsistenciaManual(String estudianteId, BuildContext context) {
    final index = estudiantes.indexWhere((est) => est.id == estudianteId);
    if (index != -1 && !asistencia[index]) {
      registrarSinHuella(index, context);
    }
  }

  void limpiarAsistencias() {
    asistencia = List.filled(estudiantes.length, false);
    notifyListeners();
  }

  Map<String, dynamic> getEstadisticas() {
    final total = estudiantes.length;
    final presentes = asistencia.where((a) => a).length;
    final ausentes = total - presentes;
    final porcentaje = total > 0 ? (presentes / total * 100) : 0;

    return {
      'total': total,
      'presentes': presentes,
      'ausentes': ausentes,
      'porcentaje': porcentaje,
    };
  }

  void _mostrarSnackbar(BuildContext context, String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
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

  // Getters para la UI
  int get totalAsistencias => asistencia.where((element) => element).length;
  int get totalEstudiantes => estudiantes.length;

  Estudiante? obtenerEstudiantePorId(String id) {
    try {
      return estudiantes.firstWhere((est) => est.id == id);
    } catch (e) {
      return null;
    }
  }

  bool tieneAsistenciaRegistrada(String estudianteId) {
    final index = estudiantes.indexWhere((est) => est.id == estudianteId);
    return index != -1 ? asistencia[index] : false;
  }

  Future<void> recargarEstudiantes() async {
    await _cargarEstudiantesDesdeSQLite();
  }
}