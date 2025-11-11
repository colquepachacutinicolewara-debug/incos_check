// ui/biometric_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/esp32_service.dart';
import '../../services/attendance_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BiometricRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const BiometricRegistrationScreen({Key? key, required this.student}) : super(key: key);

  @override
  _BiometricRegistrationScreenState createState() => _BiometricRegistrationScreenState();
}

class _BiometricRegistrationScreenState extends State<BiometricRegistrationScreen> {
  bool _isConnected = false;
  bool _isRegistering = false;
  String _statusMessage = 'Verificando conexión...';

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      final connected = await ESP32Service.checkConnection();
      setState(() {
        _isConnected = connected;
        _statusMessage = connected 
            ? 'Conexión establecida. Toque "Registrar Huella"'
            : 'Error de conexión. Verifique el ESP32';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _registerFingerprint() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay conexión con el sensor')),
      );
      return;
    }

    setState(() {
      _isRegistering = true;
      _statusMessage = 'Esperando huella digital...';
    });

    try {
      final result = await ESP32Service.registerFingerprint(
        widget.student['id'],
        widget.student['name'],
      );

      if (result['success'] == true) {
        setState(() {
          _statusMessage = 'Huella registrada exitosamente!';
        });
        
        // Actualizar estudiante en Firestore con fingerprintId
        await FirebaseFirestore.instance
            .collection('students')
            .doc(widget.student['id'])
            .update({
          'fingerprintId': result['fingerprint_id'],
          'biometricRegistered': true,
          'lastBiometricUpdate': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Huella registrada exitosamente!')),
        );
        
        Navigator.pop(context, true);
      } else {
        setState(() {
          _statusMessage = 'Error: ${result['error']}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro Biométrico'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isConnected ? Icons.fingerprint : Icons.error_outline,
              size: 80,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              'Estudiante: ${widget.student['name']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('ID: ${widget.student['id']}'),
            SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Estado del Sensor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            if (!_isConnected)
              ElevatedButton.icon(
                onPressed: _checkConnection,
                icon: Icon(Icons.refresh),
                label: Text('Reintentar Conexión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            if (_isConnected && !_isRegistering)
              ElevatedButton.icon(
                onPressed: _registerFingerprint,
                icon: Icon(Icons.fingerprint),
                label: Text('Registrar Huella'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            if (_isRegistering)
              CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}