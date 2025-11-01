// views/biometrico/registro_huella_screen.dart
import 'package:flutter/material.dart';
import '../../services/biometrico_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class RegistroHuellaScreen extends StatefulWidget {
  final Map<String, dynamic> estudiante;
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;
  final Map<String, dynamic> nivel;
  final Map<String, dynamic> paralelo;
  final Function(int) onHuellasRegistradas; // CALLBACK AGREGADO

  const RegistroHuellaScreen({
    Key? key,
    required this.estudiante,
    required this.carrera,
    required this.turno,
    required this.nivel,
    required this.paralelo,
    required this.onHuellasRegistradas, // CALLBACK AGREGADO
  }) : super(key: key);

  @override
  _RegistroHuellaScreenState createState() => _RegistroHuellaScreenState();
}

class _RegistroHuellaScreenState extends State<RegistroHuellaScreen> {
  final BiometricoService _biometricoService = BiometricoService();
  bool _isLoading = false;
  bool _sensorConectado = false;
  String _estado = 'Verificando conexión con sensor...';
  int _huellasRegistradas = 0;
  List<String> _huellasIds = [];

  @override
  void initState() {
    super.initState();
    _verificarSensor();
  }

  Future<void> _verificarSensor() async {
    setState(() {
      _isLoading = true;
    });

    // Verificar si el sensor está disponible
    bool sensorDisponible = await _biometricoService.isBiometricSupported();

    // Para el proyecto, simulamos que el sensor está disponible
    // En producción, esto se conectaría al hardware real

    setState(() {
      _sensorConectado = sensorDisponible;
      _isLoading = false;
      _estado = sensorDisponible
          ? 'Sensor biométrico conectado y listo'
          : 'MODO SIMULACIÓN: Para demostración del proyecto';
    });
  }

  Future<void> _registrarHuellaIndividual() async {
    setState(() {
      _isLoading = true;
    });

    final resultado = await _biometricoService.registrarHuella(
      widget.estudiante['id'].toString(),
      '${widget.estudiante['nombres']} ${widget.estudiante['apellidoPaterno']}',
    );

    setState(() {
      _isLoading = false;
    });

    if (resultado['success'] == true) {
      Helpers.showSnackBar(
        context,
        '✅ Huella registrada exitosamente',
        type: 'success',
      );
      setState(() {
        _huellasRegistradas = 1;
        _huellasIds.add(resultado['huellaId']);
      });
      // ACTUALIZAR CALLBACK
      widget.onHuellasRegistradas(_huellasRegistradas);
    } else {
      // Si falla el método real, usar simulación para el proyecto
      await _registrarSimulacionIndividual();
    }
  }

  Future<void> _registrarSimulacionIndividual() async {
    setState(() {
      _isLoading = true;
    });

    // Simulación para el proyecto
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _huellasRegistradas = 1;
      _huellasIds.add(
        'SIM_${widget.estudiante['id']}_${DateTime.now().millisecondsSinceEpoch}',
      );
    });

    Helpers.showSnackBar(
      context,
      '✅ SIMULACIÓN: Huella registrada para proyecto',
      type: 'success',
    );
    // ACTUALIZAR CALLBACK
    widget.onHuellasRegistradas(_huellasRegistradas);
  }

  Future<void> _registrarTresHuellas() async {
    setState(() {
      _isLoading = true;
    });

    final resultado = await _biometricoService.registrarMultiplesHuellasSimuladas(
      estudianteId: widget.estudiante['id'].toString(),
      estudianteNombre:
          '${widget.estudiante['nombres']} ${widget.estudiante['apellidoPaterno']}',
      cantidadHuellas: 3,
    );

    setState(() {
      _isLoading = false;
    });

    if (resultado['success'] == true) {
      Helpers.showSnackBar(
        context,
        '✅ ${resultado['totalRegistradas']}/3 huellas registradas',
        type: 'success',
      );
      setState(() {
        _huellasRegistradas = resultado['totalRegistradas'];
        _huellasIds = List<String>.from(resultado['huellasIds']);
      });
      // ACTUALIZAR CALLBACK
      widget.onHuellasRegistradas(_huellasRegistradas);
    }
  }

  Future<void> _verificarHuella() async {
    setState(() {
      _isLoading = true;
    });

    final resultado = await _biometricoService.verificarHuellaSimulada();

    setState(() {
      _isLoading = false;
    });

    if (resultado['success'] == true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('✅ Huella Verificada - PROYECTO INCOS'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Estudiante: ${resultado['estudianteNombre']}'),
                Text('ID: ${resultado['estudianteId']}'),
                Text(
                  'Hora: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                ),
                SizedBox(height: 10),
                Text(
                  'Carrera: ${widget.carrera['nombre']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Turno: ${widget.turno['nombre']}'),
                Text('Nivel: ${widget.nivel['nombre']}'),
                Text('Paralelo: ${widget.paralelo['nombre']}'),
                SizedBox(height: 10),
                Text(
                  resultado['mensaje'],
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Registrar Asistencia'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _mostrarInformacionProyecto() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🔬 Proyecto INCOS - Sistema Biométrico'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'APLICACIÓN MÓVIL PARA EL CONTROL DE ASISTENCIA DE ESTUDIANTES MEDIANTE EL USO DE UN LECTOR BIOMÉTRICO DE HUELLA DIGITAL',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Caso: Tercer Año "B"'),
              Text('Carrera: Sistemas Informáticos'),
              Text('Institución: INCOS - El Alto'),
              SizedBox(height: 10),
              Text(
                'Funcionalidades:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Registro biométrico de estudiantes'),
              Text('• Control de asistencia con huella digital'),
              Text('• Gestión de paralelos y niveles'),
              Text('• Reportes y estadísticas'),
              SizedBox(height: 10),
              Text(
                'Nota: Esta es una simulación para fines del proyecto. En producción se integrará con hardware biométrico real.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema Biométrico - Proyecto INCOS'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _mostrarInformacionProyecto,
            tooltip: 'Información del Proyecto',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Procesando huella digital...',
                    style: AppTextStyles.body,
                  ),
                  Text(
                    'Proyecto INCOS - Sistema Biométrico',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del estudiante
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          widget.estudiante['nombres'][0],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        '${widget.estudiante['nombres']} ${widget.estudiante['apellidoPaterno']} ${widget.estudiante['apellidoMaterno']}',
                        style: AppTextStyles.heading3,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CI: ${widget.estudiante['ci']}'),
                          Text('Carrera: ${widget.carrera['nombre']}'),
                          Text('Paralelo: ${widget.paralelo['nombre']}'),
                          Text('Huellas registradas: $_huellasRegistradas/3'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.large),

                  // Estado del sensor
                  Card(
                    color: _sensorConectado
                        ? Colors.green[50]
                        : Colors.blue[50],
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.medium),
                      child: Row(
                        children: [
                          Icon(
                            _sensorConectado ? Icons.sensors : Icons.computer,
                            color: _sensorConectado
                                ? Colors.green
                                : Colors.blue,
                          ),
                          SizedBox(width: AppSpacing.small),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _sensorConectado
                                      ? 'Sensor Biométrico Conectado'
                                      : 'Modo Simulación',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _sensorConectado
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                                ),
                                Text(
                                  _estado,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _sensorConectado
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.large),

                  // Logo y información del proyecto
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.fingerprint,
                          size: 80,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: AppSpacing.medium),
                        Text(
                          'SISTEMA BIOMÉTRICO INCOS',
                          style: AppTextStyles.heading2,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.small),
                        Text(
                          'Control de Asistencia con Huella Digital\nTercer Año "B" - Sistemas Informáticos',
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xlarge),

                  // Botones de acción
                  if (_huellasRegistradas == 0) ...[
                    ElevatedButton.icon(
                      onPressed: _registrarHuellaIndividual,
                      icon: Icon(Icons.fingerprint),
                      label: Text('Registrar 1 Huella'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: AppSpacing.small),
                    ElevatedButton.icon(
                      onPressed: _registrarTresHuellas,
                      icon: Icon(Icons.fingerprint),
                      label: Text('Registrar 3 Huellas (Recomendado)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],

                  if (_huellasRegistradas > 0) ...[
                    ElevatedButton.icon(
                      onPressed: _verificarHuella,
                      icon: Icon(Icons.verified_user),
                      label: Text('Verificar Huella y Registrar Asistencia'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: AppSpacing.small),
                    Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.medium),
                        child: Column(
                          children: [
                            Text(
                              '✅ $_huellasRegistradas Huella(s) Registrada(s)',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_huellasIds.isNotEmpty)
                              Text(
                                'IDs: ${_huellasIds.join(', ')}',
                                style: TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: AppSpacing.large),
                  Divider(),
                  SizedBox(height: AppSpacing.small),

                  // Información adicional del proyecto
                  Text(
                    '🔬 Proyecto de Grado - INCOS El Alto',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.small),
                  Text(
                    'Sistema de control de asistencia biométrico para el Tercer Año "B" de la carrera de Sistemas Informáticos.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
    );
  }
}
