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

  // Datos de ejemplo usando tu modelo Estudiante
  final List<Estudiante> estudiantesEjemplo = [
    Estudiante(
      id: 1,
      nombres: 'Ana',
      apellidoPaterno: 'García',
      apellidoMaterno: 'López',
      ci: '1234567',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 3,
    ),
    Estudiante(
      id: 2,
      nombres: 'Carlos',
      apellidoPaterno: 'Rodríguez',
      apellidoMaterno: '',
      ci: '1234568',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 3,
    ),
    Estudiante(
      id: 3,
      nombres: 'María',
      apellidoPaterno: 'Fernández',
      apellidoMaterno: '',
      ci: '1234569',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 3,
    ),
    Estudiante(
      id: 4,
      nombres: 'José',
      apellidoPaterno: 'Martínez',
      apellidoMaterno: '',
      ci: '1234570',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 3,
    ),
    Estudiante(
      id: 5,
      nombres: 'Laura',
      apellidoPaterno: 'Hernández',
      apellidoMaterno: '',
      ci: '1234571',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 3,
    ),
    Estudiante(
      id: 6,
      nombres: 'Miguel',
      apellidoPaterno: 'Sánchez',
      apellidoMaterno: '',
      ci: '1234572',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 1,
    ),
    Estudiante(
      id: 7,
      nombres: 'Elena',
      apellidoPaterno: 'Díaz',
      apellidoMaterno: '',
      ci: '1234573',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 0,
    ),
    Estudiante(
      id: 8,
      nombres: 'David',
      apellidoPaterno: 'Romero',
      apellidoMaterno: '',
      ci: '1234574',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 3,
    ),
    Estudiante(
      id: 9,
      nombres: 'Sofía',
      apellidoPaterno: 'Torres',
      apellidoMaterno: '',
      ci: '1234575',
      fechaRegistro: '2024-01-01',
      huellasRegistradas: 2,
    ),
    Estudiante(
      id: 10,
      nombres: 'Daniel',
      apellidoPaterno: 'Vázquez',
      apellidoMaterno: '',
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
}
