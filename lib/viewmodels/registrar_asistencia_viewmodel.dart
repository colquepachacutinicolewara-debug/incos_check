// viewmodels/registrar_asistencia_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../models/estudiante_model.dart';
import '../utils/constants.dart';

class AsistenciaViewModel with ChangeNotifier {
  final LocalAuthentication auth = LocalAuthentication();
  List<Estudiante> estudiantes = [];
  List<bool> asistencia = [];
  bool _isLoading = false;
  bool _biometricAvailable = false;

  bool get isLoading => _isLoading;
  bool get biometricAvailable => _biometricAvailable;

  // ✅ CORREGIDO: Datos de ejemplo usando el modelo actualizado
  final List<Estudiante> estudiantesEjemplo = [
    Estudiante(
      id: '1',
      nombres: 'Ana',
      apellidoPaterno: 'García',
      apellidoMaterno: 'López',
      ci: '1234567',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 3,
    ),
    Estudiante(
      id: '2',
      nombres: 'Carlos',
      apellidoPaterno: 'Rodríguez',
      apellidoMaterno: 'Mendoza',
      ci: '1234568',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 3,
    ),
    Estudiante(
      id: '3',
      nombres: 'María',
      apellidoPaterno: 'Fernández',
      apellidoMaterno: 'Castro',
      ci: '1234569',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 3,
    ),
    Estudiante(
      id: '4',
      nombres: 'José',
      apellidoPaterno: 'Martínez',
      apellidoMaterno: 'Rojas',
      ci: '1234570',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 3,
    ),
    Estudiante(
      id: '5',
      nombres: 'Laura',
      apellidoPaterno: 'Hernández',
      apellidoMaterno: 'Silva',
      ci: '1234571',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 3,
    ),
    Estudiante(
      id: '6',
      nombres: 'Miguel',
      apellidoPaterno: 'Sánchez',
      apellidoMaterno: 'Vega',
      ci: '1234572',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 1,
    ),
    Estudiante(
      id: '7',
      nombres: 'Elena',
      apellidoPaterno: 'Díaz',
      apellidoMaterno: 'Paredes',
      ci: '1234573',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 0,
    ),
    Estudiante(
      id: '8',
      nombres: 'David',
      apellidoPaterno: 'Romero',
      apellidoMaterno: 'Quiroga',
      ci: '1234574',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 3,
    ),
    Estudiante(
      id: '9',
      nombres: 'Sofía',
      apellidoPaterno: 'Torres',
      apellidoMaterno: 'Aguilar',
      ci: '1234575',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 2,
    ),
    Estudiante(
      id: '10',
      nombres: 'Daniel',
      apellidoPaterno: 'Vázquez',
      apellidoMaterno: 'Campos',
      ci: '1234576',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 0,
    ),
  ];

  AsistenciaViewModel() {
    _inicializarDatos();
    _checkBiometricSupport();
  }

  void _inicializarDatos() {
    estudiantes = estudiantesEjemplo;
    asistencia = List.filled(estudiantes.length, false);
  }

  // ✅ NUEVO: Método para cargar estudiantes desde Firestore
  void cargarEstudiantesDesdeFirestore(List<Estudiante> nuevosEstudiantes) {
    estudiantes = nuevosEstudiantes;
    asistencia = List.filled(estudiantes.length, false);
    notifyListeners();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = await auth
          .getAvailableBiometrics();

      _biometricAvailable =
          canCheckBiometrics && availableBiometrics.isNotEmpty;
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
        localizedReason:
            "Autentica tu identidad para ${estudiante.nombreCompleto}",
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (autenticado) {
        // Simular verificación en base de datos
        await Future.delayed(const Duration(milliseconds: 800));

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

  void registrarSinHuella(int index, BuildContext context) {
    if (_isLoading || asistencia[index]) return;

    asistencia[index] = true;
    _mostrarSnackbar(
      context,
      "✅ Asistencia manual - ${estudiantes[index].nombreCompleto}",
      getSuccessColor(context),
    );
    notifyListeners();
  }

  // ✅ NUEVO: Método para registrar asistencia manualmente
  void registrarAsistenciaManual(String estudianteId, BuildContext context) {
    final index = estudiantes.indexWhere((est) => est.id == estudianteId);
    if (index != -1 && !asistencia[index]) {
      registrarSinHuella(index, context);
    }
  }

  // ✅ NUEVO: Método para limpiar todas las asistencias
  void limpiarAsistencias() {
    asistencia = List.filled(estudiantes.length, false);
    notifyListeners();
  }

  // ✅ NUEVO: Método para obtener estadísticas
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

  // Funciones para obtener colores según el tema (públicas)
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

  // ✅ NUEVO: Buscar estudiante por ID
  Estudiante? obtenerEstudiantePorId(String id) {
    try {
      return estudiantes.firstWhere((est) => est.id == id);
    } catch (e) {
      return null;
    }
  }

  // ✅ NUEVO: Verificar si un estudiante tiene asistencia registrada
  bool tieneAsistenciaRegistrada(String estudianteId) {
    final index = estudiantes.indexWhere((est) => est.id == estudianteId);
    return index != -1 ? asistencia[index] : false;
  }
}
