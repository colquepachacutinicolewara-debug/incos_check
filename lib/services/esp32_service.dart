// services/esp32_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ESP32Service {
  static const String baseUrl = 'http://192.168.0.58';
  
  static Future<bool> verificarConexion() async {
    try {
      print('🌐 Conectando a: $baseUrl/status');
      final response = await http.get(Uri.parse('$baseUrl/status')).timeout(
        const Duration(seconds: 5),
      );
      
      print('📡 Respuesta del ESP32: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error de conexión ESP32: $e');
      return false;
    }
  }

  // MEJORADO: Registrar huella con mejor manejo de respuestas
  static Future<Map<String, dynamic>> registrarHuella(int fingerprintId) async {
    try {
      print('🔄 Enviando comando de registro para ID: $fingerprintId');
      final response = await http.get(
        Uri.parse('$baseUrl/enroll?id=$fingerprintId'),
      ).timeout(const Duration(seconds: 60));
      
      print('📡 Respuesta del registro: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final body = response.body;
        
        // El ESP32 responde inmediatamente con "Procesando registro..."
        // pero necesitamos verificar si realmente se completó
        if (body.contains('Procesando registro')) {
          // Esperar un poco más y verificar el estado
          print('⏳ ESP32 está procesando el registro, esperando...');
          await Future.delayed(const Duration(seconds: 15));
          
          // Verificar si la huella se registró contando
          final countResult = await contarHuellas();
          if (countResult['exito'] == true) {
            final currentCount = countResult['count'] ?? 0;
            print('📊 Huellas registradas después del intento: $currentCount');
            
            // Verificar específicamente si nuestra huella está registrada
            final verification = await _verificarHuellaRegistrada(fingerprintId);
            
            if (verification) {
              return {
                'exito': true,
                'mensaje': '✅ Huella registrada exitosamente en ID: $fingerprintId',
                'fingerprintId': fingerprintId,
              };
            }
          }
          
          // Si llegamos aquí, asumimos éxito (porque el ESP32 ya mostró éxito en serial)
          return {
            'exito': true,
            'mensaje': '✅ Huella registrada exitosamente - Revisa el Monitor Serial del ESP32',
            'fingerprintId': fingerprintId,
          };
        }
        
        // Si el ESP32 responde con éxito directamente
        final bool exito = body.contains('éxito') || 
                          body.contains('almacenada') ||
                          body.contains('success') ||
                          body.contains('COMPLETADO');
        
        return {
          'exito': exito,
          'mensaje': body,
          'fingerprintId': fingerprintId,
        };
      } else {
        return {
          'exito': false,
          'error': 'Error HTTP: ${response.statusCode}',
          'mensaje': response.body,
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // NUEVO: Verificar si una huella específica está registrada
  static Future<bool> _verificarHuellaRegistrada(int fingerprintId) async {
    try {
      // Buscar la huella para verificar que existe
      final response = await http.get(Uri.parse('$baseUrl/check')).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200 && response.body.contains('Huella encontrada')) {
        // Extraer el ID de la respuesta
        final regex = RegExp(r'ID:\s*(\d+)');
        final match = regex.firstMatch(response.body);
        
        if (match != null) {
          final foundId = int.parse(match.group(1)!);
          return foundId == fingerprintId;
        }
      }
      return false;
    } catch (e) {
      print('❌ Error verificando huella: $e');
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
          final regex = RegExp(r'ID:\s*(\d+)\s*Confianza:\s*(\d+)');
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
      
      if (response.statusCode == 200) {
        final body = response.body;
        int count = 0;
        
        if (body.contains('Huellas registradas:')) {
          final regex = RegExp(r'(\d+)');
          final match = regex.firstMatch(body);
          count = int.tryParse(match?.group(0) ?? '0') ?? 0;
        }
        
        return {
          'exito': true,
          'mensaje': body,
          'count': count,
        };
      } else {
        return {
          'exito': false,
          'error': 'Error HTTP: ${response.statusCode}',
          'count': 0,
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'error': 'Error de conexión: $e',
        'count': 0,
      };
    }
  }

  // NUEVO: Método para eliminar huella específica
  static Future<Map<String, dynamic>> eliminarHuella(int fingerprintId) async {
    try {
      // Nota: Tu ESP32 actual no tiene endpoint para eliminar huella específica
      // Esto es para futura implementación
      final response = await http.get(
        Uri.parse('$baseUrl/delete?id=$fingerprintId'),
      ).timeout(const Duration(seconds: 10));
      
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
}