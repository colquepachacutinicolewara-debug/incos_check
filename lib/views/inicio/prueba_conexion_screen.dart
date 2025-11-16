// screens/prueba_conexion_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class PruebaConexionScreen extends StatefulWidget {
  const PruebaConexionScreen({super.key});

  @override
  State<PruebaConexionScreen> createState() => _PruebaConexionScreenState();
}

class _PruebaConexionScreenState extends State<PruebaConexionScreen> {
  bool _probando = false;
  String _resultado = 'Presiona "Probar Conexión"';

  Future<void> _probarConexion() async {
    setState(() {
      _probando = true;
      _resultado = '🔍 Probando conexión...\n';
    });

    try {
      // Probar endpoint /status
      _resultado += '🌐 Conectando a: http://192.168.0.58/status\n\n';
      
      final response = await http.get(
        Uri.parse('http://192.168.0.58/status')
      ).timeout(const Duration(seconds: 5));

      _resultado += '📡 Código HTTP: ${response.statusCode}\n';
      _resultado += '📝 Respuesta: ${response.body}\n\n';
      
      if (response.statusCode == 200) {
        _resultado += '✅ ✅ ✅ CONEXIÓN EXITOSA ✅ ✅ ✅\n';
        _resultado += 'El ESP32 está funcionando correctamente';
      } else {
        _resultado += '❌ Error en la respuesta del ESP32';
      }
      
    } catch (e) {
      _resultado += '❌ ERROR DE CONEXIÓN:\n$e\n\n';
      _resultado += '🔧 Solución:\n';
      _resultado += '• Verifica que el celular esté en Tenda_FD7CA0\n';
      _resultado += '• Revisa que la IP 192.168.0.58 sea correcta\n';
      _resultado += '• Reinicia el ESP32 si es necesario';
    }

    setState(() {
      _probando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Conexión ESP32'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.router, size: 50, color: Colors.blue),
                    const SizedBox(height: 10),
                    Text(
                      'ESP32 Conectado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'IP: 192.168.0.58',
                      style: AppTextStyles.body,
                    ),
                    Text(
                      'WiFi: Tenda_FD7CA0',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: _probando ? null : _probarConexion,
              icon: const Icon(Icons.wifi_find),
              label: Text(_probando ? 'Probando...' : 'Probar Conexión ESP32'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _resultado,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}