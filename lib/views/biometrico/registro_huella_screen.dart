// 📂 views/biometrico/registro_huellas_screen.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

// Utilidades y estilos
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

  // ✅ Verifica si hay sensores disponibles en el dispositivo
  Future<void> _checkBiometricSupport() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      _availableBiometrics = await _auth.getAvailableBiometrics();

      setState(() {
        _biometricAvailable =
            canCheckBiometrics && _availableBiometrics.isNotEmpty;
      });
    } catch (e) {
      setState(() => _biometricAvailable = false);
      debugPrint('Error verificando biométricos: $e');
    }
  }

  // ✅ Registra huella simulando autenticación del dedo actual
  Future<void> _registrarHuellaActual() async {
    if (_isLoading || _huellasRegistradas[_huellaActual]) return;

    setState(() => _isLoading = true);

    try {
      if (!_biometricAvailable) {
        Helpers.showSnackBar(
          context,
          'El dispositivo no soporta autenticación biométrica',
          type: 'error',
        );
        return;
      }

      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Coloca tu dedo para ${_nombresDedos[_huellaActual]}',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        await Future.delayed(const Duration(milliseconds: 600));

        setState(() {
          _huellasRegistradas[_huellaActual] = true;
        });

        Helpers.showSnackBar(
          context,
          '✅ ${_nombresDedos[_huellaActual]} registrada correctamente',
          type: 'success',
        );

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
      Helpers.showSnackBar(context, 'Error: ${e.toString()}', type: 'error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _siguienteHuella() {
    if (_huellaActual < 2) setState(() => _huellaActual++);
  }

  void _anteriorHuella() {
    if (_huellaActual > 0) setState(() => _huellaActual--);
  }

  void _finalizarRegistro() {
    int total = _huellasRegistradas.where((h) => h).length;
    widget.onHuellasRegistradas(total);
    Navigator.pop(context);
    Helpers.showSnackBar(
      context,
      'Registro de huellas completado: $total/3',
      type: 'success',
    );
  }

  void _reenrolarHuella(int index) {
    setState(() {
      _huellasRegistradas[index] = false;
      _huellaActual = index;
    });
  }

  // ✅ Nombre legible del tipo biométrico
  String _getBiometricName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Reconocimiento Facial';
      case BiometricType.fingerprint:
        return 'Sensor de Huella';
      case BiometricType.iris:
        return 'Reconocimiento de Iris';
      default:
        return 'Desconocido';
    }
  }

  // ✅ Interfaz principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Huellas'),
        backgroundColor: AppColors.primary,
        actions: [
          if (_huellasRegistradas.any((h) => h))
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.white),
              tooltip: 'Finalizar registro',
              onPressed: _finalizarRegistro,
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧑 Datos del estudiante
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
                ),
                subtitle: Text('CI: ${widget.estudiante['ci']}'),
              ),
            ),
            const SizedBox(height: 20),

            // 🔍 Estado del sensor
            _biometricAvailable
                ? _infoBox(
                    color: Colors.green,
                    icon: Icons.check_circle,
                    title: "Sensor biométrico disponible",
                    subtitle:
                        "Detectado: ${_availableBiometrics.map(_getBiometricName).join(', ')}",
                  )
                : _infoBox(
                    color: Colors.orange,
                    icon: Icons.warning,
                    title: "Sensor biométrico no disponible",
                    subtitle: "No se detectaron sensores de huella",
                  ),

            const SizedBox(height: 10),

            // 📈 Progreso
            Text(
              'Progreso: ${_huellasRegistradas.where((h) => h).length}/3 huellas registradas',
              style: AppTextStyles.heading2Dark(context),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _huellasRegistradas.where((h) => h).length / 3,
              backgroundColor: Colors.grey.shade300,
              color: AppColors.primary,
            ),

            const SizedBox(height: 25),

            // 🔵 Huella actual (icono central animado)
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
                    const SizedBox(height: 16),
                    Text(
                      _nombresDedos[_huellaActual],
                      style: AppTextStyles.heading2Dark(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _huellasRegistradas[_huellaActual]
                          ? '✅ Huella registrada. Toca para reenrolar.'
                          : 'Toca el icono para registrar esta huella.',
                      style: AppTextStyles.bodyDark(context),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text('Esperando huella...'),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // 🔙 Controles de navegación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _huellaActual > 0 ? _anteriorHuella : null,
                  child: const Text('Anterior'),
                ),
                ElevatedButton(
                  onPressed: _huellaActual < 2 ? _siguienteHuella : null,
                  child: const Text('Siguiente'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🧾 Lista de huellas registradas
            Text(
              'Huellas registradas:',
              style: AppTextStyles.heading3Dark(context),
            ),
            const SizedBox(height: 10),
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
                  title: Text(nombre),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_huellasRegistradas[index])
                        IconButton(
                          icon: const Icon(Icons.refresh),
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
                  onTap: () => setState(() => _huellaActual = index),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _infoBox({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, color: color),
                ),
                Text(subtitle, style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
