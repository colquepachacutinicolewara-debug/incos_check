// views/biometrico/registro_huellas_screen.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class RegistroHuellasScreen extends StatefulWidget {
  final Map<String, dynamic> estudiante;
  final Function(int) onHuellasRegistradas;

  const RegistroHuellasScreen({
    super.key,
    required this.estudiante,
    required this.onHuellasRegistradas,
  });

  @override
  State<RegistroHuellasScreen> createState() => _RegistroHuellasScreenState();
}

class _RegistroHuellasScreenState extends State<RegistroHuellasScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  final List<bool> _huellasRegistradas = [false, false, false];
  int _huellaActual = 0;
  bool _isLoading = false;
  bool _biometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  final List<String> _nombresDedos = [
    'Pulgar - Mano Derecha',
    'Índice - Mano Derecha',
    'Medio - Mano Derecha',
  ];

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      _availableBiometrics = await _auth.getAvailableBiometrics();

      setState(() {
        _biometricAvailable =
            canCheckBiometrics && _availableBiometrics.isNotEmpty;
      });

      if (_biometricAvailable) {
        print('Biométricos disponibles: $_availableBiometrics');
      } else {
        print('No hay sensores biométricos disponibles');
      }
    } catch (e) {
      print('Error verificando biométricos: $e');
      setState(() {
        _biometricAvailable = false;
      });
    }
  }

  Future<void> _registrarHuellaActual() async {
    if (_isLoading || _huellasRegistradas[_huellaActual]) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar disponibilidad biométrica
      if (!_biometricAvailable) {
        Helpers.showSnackBar(
          context,
          'El dispositivo no soporta autenticación biométrica',
          type: 'error',
        );
        return;
      }

      // Realizar autenticación biométrica
      final bool authenticated = await _auth.authenticate(
        localizedReason:
            'Registra tu huella para ${_nombresDedos[_huellaActual]}',
        options: const AuthenticationOptions(
          biometricOnly: true, // Solo permite huella/face ID
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        // Simular procesamiento del registro
        await Future.delayed(const Duration(milliseconds: 500));

        setState(() {
          _huellasRegistradas[_huellaActual] = true;
        });

        Helpers.showSnackBar(
          context,
          '✅ ${_nombresDedos[_huellaActual]} registrada exitosamente',
          type: 'success',
        );

        // Avanzar automáticamente a la siguiente huella
        if (_huellaActual < 2) {
          await Future.delayed(const Duration(milliseconds: 800));
          _siguienteHuella();
        }
      } else {
        Helpers.showSnackBar(
          context,
          '❌ Autenticación fallida para ${_nombresDedos[_huellaActual]}',
          type: 'error',
        );
      }
    } catch (e) {
      print('Error en autenticación: $e');
      Helpers.showSnackBar(context, 'Error: ${e.toString()}', type: 'error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _siguienteHuella() {
    if (_huellaActual < 2) {
      setState(() {
        _huellaActual++;
      });
    }
  }

  void _anteriorHuella() {
    if (_huellaActual > 0) {
      setState(() {
        _huellaActual--;
      });
    }
  }

  void _finalizarRegistro() {
    int totalRegistradas = _huellasRegistradas.where((h) => h).length;
    widget.onHuellasRegistradas(totalRegistradas);
    Navigator.pop(context);
    Helpers.showSnackBar(
      context,
      'Registro de huellas completado: $totalRegistradas/3',
      type: 'success',
    );
  }

  void _reenrolarHuella(int index) {
    setState(() {
      _huellasRegistradas[index] = false;
      _huellaActual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registro de Huellas',
          style: AppTextStyles.heading2Dark(
            context,
          ).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          if (_huellasRegistradas.any((h) => h))
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.white),
              onPressed: _finalizarRegistro,
              tooltip: 'Finalizar registro',
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del estudiante
            Card(
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    widget.estudiante['nombres'][0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  '${widget.estudiante['apellidoPaterno']} ${widget.estudiante['apellidoMaterno']} ${widget.estudiante['nombres']}',
                  style: AppTextStyles.heading3Dark(context),
                ),
                subtitle: Text(
                  'CI: ${widget.estudiante['ci']}',
                  style: AppTextStyles.bodyDark(context),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.large),

            // Estado del sensor biométrico
            if (!_biometricAvailable)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sensor biométrico no disponible",
                            style: AppTextStyles.bodyDark(context).copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                            ),
                          ),
                          if (_availableBiometrics.isEmpty)
                            Text(
                              "No se detectaron sensores de huella",
                              style: AppTextStyles.bodyDark(
                                context,
                              ).copyWith(fontSize: 12, color: Colors.orange),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sensor biométrico disponible",
                            style: AppTextStyles.bodyDark(context).copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            "Sensores: ${_availableBiometrics.map((b) => _getBiometricName(b)).join(', ')}",
                            style: AppTextStyles.bodyDark(
                              context,
                            ).copyWith(fontSize: 12, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Progreso
            Text(
              'Progreso: ${_huellasRegistradas.where((h) => h).length}/3 huellas registradas',
              style: AppTextStyles.heading2Dark(context),
            ),
            SizedBox(height: AppSpacing.small),
            LinearProgressIndicator(
              value: _huellasRegistradas.where((h) => h).length / 3,
              backgroundColor: Colors.grey.shade300,
              color: AppColors.primary,
            ),
            SizedBox(height: AppSpacing.large),

            // Huella actual
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _isLoading ? null : _registrarHuellaActual,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _huellasRegistradas[_huellaActual]
                              ? Colors.green.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _huellasRegistradas[_huellaActual]
                                ? Colors.green
                                : AppColors.primary,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.fingerprint,
                          size: 120,
                          color: _huellasRegistradas[_huellaActual]
                              ? Colors.green
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.medium),
                    Text(
                      _nombresDedos[_huellaActual],
                      style: AppTextStyles.heading2Dark(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.small),
                    Text(
                      _huellasRegistradas[_huellaActual]
                          ? '✅ Huella registrada - Toca para reenrolar'
                          : 'Toca el icono para registrar esta huella',
                      style: AppTextStyles.bodyDark(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.medium),

                    if (_isLoading)
                      Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.small),
                          Text(
                            'Esperando huella...',
                            style: AppTextStyles.bodyDark(context),
                          ),
                        ],
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _registrarHuellaActual,
                        icon: const Icon(Icons.fingerprint),
                        label: Text(
                          _huellasRegistradas[_huellaActual]
                              ? 'Reenrolar Huella'
                              : 'Registrar Huella',
                          style: AppTextStyles.bodyDark(context),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Controles de navegación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _huellaActual > 0 ? _anteriorHuella : null,
                  child: Text(
                    'Anterior',
                    style: AppTextStyles.bodyDark(context),
                  ),
                ),
                ElevatedButton(
                  onPressed: _huellaActual < 2 ? _siguienteHuella : null,
                  child: Text(
                    'Siguiente',
                    style: AppTextStyles.bodyDark(context),
                  ),
                ),
              ],
            ),

            // Lista de huellas
            SizedBox(height: AppSpacing.large),
            Text(
              'Huellas registradas:',
              style: AppTextStyles.heading3Dark(context),
            ),
            SizedBox(height: AppSpacing.small),
            ..._nombresDedos.asMap().entries.map((entry) {
              int index = entry.key;
              String nombre = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    _huellasRegistradas[index]
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: _huellasRegistradas[index]
                        ? Colors.green
                        : Colors.grey,
                  ),
                  title: Text(nombre, style: AppTextStyles.bodyDark(context)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_huellasRegistradas[index])
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20),
                          onPressed: () => _reenrolarHuella(index),
                          tooltip: 'Reenrolar huella',
                          color: AppColors.primary,
                        ),
                      Icon(
                        Icons.fingerprint,
                        color: _huellasRegistradas[index]
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _huellaActual = index;
                    });
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getBiometricName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Reconocimiento Facial';
      case BiometricType.fingerprint:
        return 'Sensor de Huella';
      case BiometricType.iris:
        return 'Reconocimiento de Iris';
      default:
        return 'Biométrico';
    }
  }
}
