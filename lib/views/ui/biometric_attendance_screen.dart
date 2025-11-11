// ui/biometric_attendance_screen.dart
import 'package:flutter/material.dart';
import '../../services/esp32_service.dart';
import '../../services/attendance_service.dart';

class BiometricAttendanceScreen extends StatefulWidget {
  final String courseId;

  const BiometricAttendanceScreen({Key? key, required this.courseId}) : super(key: key);

  @override
  _BiometricAttendanceScreenState createState() => _BiometricAttendanceScreenState();
}

class _BiometricAttendanceScreenState extends State<BiometricAttendanceScreen> {
  bool _isConnected = false;
  bool _isProcessing = false;
  String _statusMessage = 'Iniciando...';
  final BiometricAttendanceService _attendanceService = BiometricAttendanceService();

  @override
  void initState() {
    super.initState();
    _initializeSystem();
  }

  Future<void> _initializeSystem() async {
    setState(() {
      _statusMessage = 'Conectando con sensor...';
    });

    try {
      final connected = await ESP32Service.checkConnection();
      setState(() {
        _isConnected = connected;
        _statusMessage = connected 
            ? 'Sistema listo. Espere huella...'
            : 'Error de conexión';
      });

      if (connected) {
        _startAttendanceMonitoring();
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    }
  }

  void _startAttendanceMonitoring() {
    // En una implementación real, esto sería un WebSocket o polling constante
    _checkForFingerprint();
  }

  Future<void> _checkForFingerprint() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Leyendo huella...';
    });

    try {
      final result = await ESP32Service.verifyFingerprint();
      
      if (result['success'] == true) {
        final fingerprintId = result['fingerprint_id'];
        final studentId = result['student_id'];
        
        await _processAttendance(fingerprintId, studentId);
      } else {
        setState(() {
          _statusMessage = 'Huella no reconocida. Intente nuevamente.';
        });
        
        // Reintentar después de 2 segundos
        await Future.delayed(Duration(seconds: 2));
        _resetForNextScan();
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
      _resetForNextScan();
    }
  }

  Future<void> _processAttendance(String fingerprintId, String studentId) async {
    try {
      setState(() {
        _statusMessage = 'Registrando asistencia...';
      });

      await _attendanceService.registerBiometricAttendance(
        studentId: studentId,
        courseId: widget.courseId,
        fingerprintId: fingerprintId,
        timestamp: DateTime.now(),
      );

      setState(() {
        _statusMessage = 'Asistencia registrada!';
      });

      // Mostrar confirmación
      _showSuccessDialog(studentId);
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Error registrando: $e';
      });
    } finally {
      _resetForNextScan();
    }
  }

  void _resetForNextScan() {
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Listo para siguiente huella...';
        });
        _checkForFingerprint();
      }
    });
  }

  void _showSuccessDialog(String studentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Asistencia Registrada'),
        content: Text('Asistencia confirmada para el estudiante: $studentId'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro Biométrico'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _initializeSystem,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: _isProcessing ? Colors.blue[100] : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fingerprint,
                size: 80,
                color: _isProcessing ? Colors.blue : Colors.grey,
              ),
            ),
            SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Estado del Sistema',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_isProcessing)
              CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _initializeSystem,
              icon: Icon(Icons.restart_alt),
              label: Text('Reiniciar Sistema'),
            ),
          ],
        ),
      ),
    );
  }
}