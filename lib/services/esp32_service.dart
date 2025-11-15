// services/esp32_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ESP32Service {
  static const String baseUrl = 'http://10.61.163.202/'; // Tu IP del ESP32
  
  // Verificar estado del sensor
  static Future<bool> verificarConexion() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/status')).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200 && response.body.contains('Conectado');
    } catch (e) {
      print('❌ Error conectando al ESP32: $e');
      return false;
    }
  }

  // Buscar huella en el sensor
  static Future<Map<String, dynamic>> buscarHuella() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/check')).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final body = response.body;
        
        if (body.contains('Huella encontrada')) {
          // Extraer ID y confianza del mensaje
          final regex = RegExp(r'ID: (\d+) Confianza: (\d+)');
          final match = regex.firstMatch(body);
          
          if (match != null) {
            final fingerprintId = int.parse(match.group(1)!);
            final confidence = int.parse(match.group(2)!);
            
            return {
              'encontrada': true,
              'fingerprintId': fingerprintId,
              'confidence': confidence,
              'mensaje': body,
            };
          }
        }
        
        return {
          'encontrada': false,
          'mensaje': body,
        };
      } else {
        return {
          'encontrada': false,
          'error': 'Error HTTP: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'encontrada': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Registrar nueva huella en el sensor
  static Future<Map<String, dynamic>> registrarHuella(int fingerprintId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/enroll?id=$fingerprintId'),
      ).timeout(const Duration(seconds: 60)); // Tiempo largo para registro completo
      
      if (response.statusCode == 200) {
        return {
          'exito': response.body.contains('éxito') || response.body.contains('almacenada'),
          'mensaje': response.body,
          'fingerprintId': fingerprintId,
        };
      } else {
        return {
          'exito': false,
          'error': 'Error HTTP: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Eliminar todas las huellas del sensor
  static Future<Map<String, dynamic>> eliminarBaseDatos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/delete')).timeout(
        const Duration(seconds: 10),
      );
      
      return {
        'exito': response.statusCode == 200,
        'mensaje': response.body,
      };
    } catch (e) {
      return {
        'exito': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Contar huellas registradas en el sensor
  static Future<Map<String, dynamic>> contarHuellas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/count')).timeout(
        const Duration(seconds: 5),
      );
      
      return {
        'exito': response.statusCode == 200,
        'mensaje': response.body,
        'count': response.body.contains('Huellas registradas:') 
            ? int.tryParse(RegExp(r'(\d+)').firstMatch(response.body)?.group(0) ?? '0') ?? 0
            : 0,
      };
    } catch (e) {
      return {
        'exito': false,
        'error': 'Error de conexión: $e',
      };
    }
  }
}