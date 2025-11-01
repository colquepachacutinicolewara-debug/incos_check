import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../utils/constants.dart';

class RegistrarAsistenciaScreen extends StatefulWidget {
  const RegistrarAsistenciaScreen({super.key});

  @override
  State<RegistrarAsistenciaScreen> createState() =>
      _RegistrarAsistenciaScreenState();
}

class _RegistrarAsistenciaScreenState extends State<RegistrarAsistenciaScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  List<bool> asistencia = List.filled(10, false);
  bool _isLoading = false;
  bool _biometricAvailable = false;

  // Datos de ejemplo de estudiantes con "huellas asignadas" (simulado)
  final List<Map<String, dynamic>> estudiantes = [
    {
      'nombre': 'Ana García López',
      'curso': 'Matemáticas Avanzadas',
      'huellaAsignada': true,
    },
    {
      'nombre': 'Carlos Rodríguez',
      'curso': 'Matemáticas Avanzadas',
      'huellaAsignada': true,
    },
    {
      'nombre': 'María Fernández',
      'curso': 'Matemáticas Avanzadas',
      'huellaAsignada': true,
    },
    {
      'nombre': 'José Martínez',
      'curso': 'Matemáticas Avanzadas',
      'huellaAsignada': true,
    },
    {
      'nombre': 'Laura Hernández',
      'curso': 'Matemáticas Avanzadas',
      'huellaAsignada': true,
    },
    {
      'nombre': 'Miguel Sánchez',
      'curso': 'Matemáticas Avanzadas',
      'huellaAsignada': false,
    },
    {
      'nombre': 'Elena Díaz',
      'curso': 'Matemáticas Avanzadas',
      'huellaAsignada': false,
    },
    {
      'nombre': 'David Romero',
      'curso': 'Matemáticas Avanzadas',
      'huellaAsignada': true,
    },
    {
      'nombre': 'Sofía Torres',
      'curso': 'Matemáticas Avanzadas',
      'huellaAsignada': true,
    },
    {
      'nombre': 'Daniel Vázquez',
      'curso': 'Matemáticas Avanzadas',
      'huellaAsignada': false,
    },
  ];

  // Funciones para obtener colores según el tema
  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : AppColors.background;
  }

  Color _getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : AppColors.border;
  }

  Color _getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.green.shade700
        : AppColors.success;
  }

  Color _getWarningColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.orange.shade700
        : AppColors.warning;
  }

  Color _getErrorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade700
        : AppColors.error;
  }

  Color _getAccentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blue.shade700
        : AppColors.accent;
  }

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = await auth
          .getAvailableBiometrics();

      setState(() {
        _biometricAvailable =
            canCheckBiometrics && availableBiometrics.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _biometricAvailable = false;
      });
    }
  }

  Future<void> autenticarHuella(int index) async {
    if (_isLoading || asistencia[index]) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar si el estudiante tiene huella asignada (simulado)
      if (!estudiantes[index]['huellaAsignada']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${estudiantes[index]['nombre']} no tiene huella registrada en el sistema",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: _getWarningColor(context),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Verificar disponibilidad de biométricos
      if (!_biometricAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "El dispositivo no soporta autenticación biométrica",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: _getErrorColor(context),
          ),
        );
        return;
      }

      // Realizar autenticación biométrica
      final bool autenticado = await auth.authenticate(
        localizedReason:
            "Autentica tu identidad para ${estudiantes[index]['nombre']}",
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (autenticado) {
        // Simular verificación en base de datos
        await Future.delayed(const Duration(milliseconds: 800));

        setState(() {
          asistencia[index] = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ Asistencia confirmada - ${estudiantes[index]['nombre']}",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: _getSuccessColor(context),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Huella no coincide con ${estudiantes[index]['nombre']}",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: _getErrorColor(context),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error de autenticación: ${e.toString()}",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: _getErrorColor(context),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método alternativo para registrar sin huella (para testing)
  void _registrarSinHuella(int index) {
    if (_isLoading || asistencia[index]) return;

    setState(() {
      asistencia[index] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "✅ Asistencia manual - ${estudiantes[index]['nombre']}",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: _getSuccessColor(context),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _escanearQR() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Función de escaneo QR próximamente...",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _mostrarInfoHuella() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(context),
        title: Text(
          "Información de Huellas",
          style: TextStyle(color: _getTextColor(context)),
        ),
        content: Text(
          "El sistema autentica con cualquier huella registrada en el dispositivo. "
          "En una implementación real, se conectaría con una base de datos que asocie "
          "cada huella a un estudiante específico.\n\n"
          "Estudiantes con ⚠️ no tienen huella asignada en el sistema.",
          style: TextStyle(color: _getSecondaryTextColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Entendido",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Registrar Asistencia',
          style: AppTextStyles.heading1.copyWith(
            fontSize: isSmallScreen ? 20 : 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 2,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _mostrarInfoHuella,
            tooltip: 'Información sobre huellas',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          children: [
            // Card de escaneo QR
            Card(
              elevation: 4,
              color: _getCardColor(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: isSmallScreen ? 50 : 60,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    Text(
                      'Escanear Código QR',
                      style: AppTextStyles.heading2.copyWith(
                        fontSize: isSmallScreen ? 16 : 18,
                        color: _getTextColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _escanearQR,
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: Text(
                        'Escanear QR',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16 : 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Estado del sensor biométrico
            if (!_biometricAvailable)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _getWarningColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: Border.all(color: _getWarningColor(context)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: _getWarningColor(context),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Sensor biométrico no disponible",
                        style: AppTextStyles.body.copyWith(
                          color: _getWarningColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Separador
            Row(
              children: [
                Expanded(
                  child: Divider(color: _getBorderColor(context), thickness: 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Registro por huella',
                    style: AppTextStyles.body.copyWith(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: _getTextColor(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(color: _getBorderColor(context), thickness: 1),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // Contador de asistencias
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getAccentColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(color: _getAccentColor(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Asistencias registradas:',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(context),
                    ),
                  ),
                  Text(
                    '${asistencia.where((element) => element).length}/${asistencia.length}',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // Lista de estudiantes
            Expanded(
              child: ListView.builder(
                itemCount: estudiantes.length,
                itemBuilder: (context, index) {
                  final estudiante = estudiantes[index];
                  final tieneHuella = estudiante['huellaAsignada'] as bool;

                  return Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: isSmallScreen ? 2 : 4,
                    ),
                    elevation: 2,
                    color: _getCardColor(context),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: asistencia[index]
                            ? _getSuccessColor(context).withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          asistencia[index] ? Icons.check_circle : Icons.person,
                          color: asistencia[index]
                              ? _getSuccessColor(context)
                              : AppColors.primary,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              estudiante['nombre']!,
                              style: AppTextStyles.heading3.copyWith(
                                color: _getTextColor(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!tieneHuella)
                            Icon(
                              Icons.warning,
                              color: _getWarningColor(context),
                              size: 16,
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            estudiante['curso']!,
                            style: AppTextStyles.body.copyWith(
                              color: _getSecondaryTextColor(context),
                            ),
                          ),
                          if (!tieneHuella)
                            Text(
                              'Sin huella asignada',
                              style: AppTextStyles.body.copyWith(
                                color: _getWarningColor(context),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      trailing: SizedBox(
                        width: isSmallScreen ? 110 : 130,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!asistencia[index])
                              ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => autenticarHuella(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: tieneHuella
                                      ? AppColors.primary
                                      : _getWarningColor(context),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 8 : 12,
                                    vertical: 6,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      tieneHuella
                                          ? Icons.fingerprint
                                          : Icons.warning,
                                      size: isSmallScreen ? 14 : 16,
                                    ),
                                    SizedBox(width: isSmallScreen ? 4 : 6),
                                    Text(
                                      tieneHuella ? 'Huella' : 'Manual',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 10 : 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (asistencia[index])
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getSuccessColor(
                                    context,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getSuccessColor(context),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color: _getSuccessColor(context),
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Registrado',
                                      style: TextStyle(
                                        color: _getSuccessColor(context),
                                        fontSize: isSmallScreen ? 10 : 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
