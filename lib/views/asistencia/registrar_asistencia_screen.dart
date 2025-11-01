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
            ),
            backgroundColor: AppColors.warning,
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
            ),
            backgroundColor: AppColors.error,
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
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Huella no coincide con ${estudiantes[index]['nombre']}",
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error de autenticación: ${e.toString()}"),
          backgroundColor: AppColors.error,
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
        content: Text("✅ Asistencia manual - ${estudiantes[index]['nombre']}"),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _escanearQR() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Función de escaneo QR próximamente..."),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _mostrarInfoHuella() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Información de Huellas"),
        content: const Text(
          "El sistema autentica con cualquier huella registrada en el dispositivo. "
          "En una implementación real, se conectaría con una base de datos que asocie "
          "cada huella a un estudiante específico.\n\n"
          "Estudiantes con ⚠️ no tienen huella asignada en el sistema.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: AppColors.background,
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
            icon: const Icon(Icons.info_outline),
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
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _escanearQR,
                      icon: const Icon(Icons.camera_alt),
                      label: Text('Escanear QR', style: AppTextStyles.button),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
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
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.warning, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Sensor biométrico no disponible",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.warning,
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
                Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Registro por huella',
                    style: AppTextStyles.body.copyWith(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.border, thickness: 1)),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // Contador de asistencias
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(color: AppColors.accent),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Asistencias registradas:',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
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
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: asistencia[index]
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          asistencia[index] ? Icons.check_circle : Icons.person,
                          color: asistencia[index]
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              estudiante['nombre']!,
                              style: AppTextStyles.heading3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!tieneHuella)
                            Icon(
                              Icons.warning,
                              color: AppColors.warning,
                              size: 16,
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(estudiante['curso']!, style: AppTextStyles.body),
                          if (!tieneHuella)
                            Text(
                              'Sin huella asignada',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.warning,
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
                                      : AppColors.warning,
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
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.success),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color: AppColors.success,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Registrado',
                                      style: TextStyle(
                                        color: AppColors.success,
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
