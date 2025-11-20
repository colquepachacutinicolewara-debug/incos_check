// services/esp32_service.dart - VERSIÓN MEJORADA
import 'package:http/http.dart' as http;

class ESP32Service {
  static const String baseUrl = 'http://10.64.241.202';
  
  // ✅ VERIFICAR CONEXIÓN MEJORADA
  static Future<Map<String, dynamic>> verificarConexion() async {
    try {
      print('🌐 Conectando a: $baseUrl/status');
      final response = await http.get(Uri.parse('$baseUrl/status')).timeout(
        const Duration(seconds: 5),
      );
      
      print('📡 Respuesta del ESP32: ${response.statusCode} - ${response.body}');
      
      return {
        'conectado': response.statusCode == 200,
        'mensaje': response.body,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      print('❌ Error de conexión ESP32: $e');
      return {
        'conectado': false,
        'error': e.toString(),
        'mensaje': 'No se pudo conectar al ESP32',
      };
    }
  }

  // ✅ REGISTRAR HUELLA CON CONTROL DE ID
  static Future<Map<String, dynamic>> registrarHuella({
    required String studentId,
    required int fingerprintId,
  }) async {
    try {
      print('🔄 Registrando huella para estudiante: $studentId con ID: $fingerprintId');
      
      final url = Uri.parse('$baseUrl/enroll?studentId=$studentId&fingerId=$fingerprintId');
      print('📤 URL: $url');
      
      final response = await http.get(url).timeout(const Duration(seconds: 60));
      
      print('📡 Respuesta del registro: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final body = response.body;
        
        // El ESP32 responde inmediatamente
        if (body.contains('Procesando registro')) {
          // Esperar un poco para que complete el proceso
          await Future.delayed(const Duration(seconds: 20));
          
          // Verificar si la huella se registró contando
          final countResult = await contarHuellas();
          
          return {
            'exito': true,
            'mensaje': '✅ Huella registrada exitosamente para $studentId con ID $fingerprintId',
            'studentId': studentId,
            'fingerprintId': fingerprintId,
            'huellasTotales': countResult['count'] ?? 0,
          };
        }
        
        // Si hay otro tipo de respuesta
        return {
          'exito': body.contains('éxito') || body.contains('almacenada'),
          'mensaje': body,
          'studentId': studentId,
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
        'studentId': studentId,
        'fingerprintId': fingerprintId,
      };
    }
  }

  // ✅ BUSCAR HUELLA MEJORADA
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

  // ✅ ELIMINAR TODAS LAS HUELLAS
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

  // ✅ CONTAR HUELLAS REGISTRADAS
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

  // ✅ VERIFICAR SI UN ID DE HUELLA ESTÁ DISPONIBLE
  static Future<bool> verificarIdDisponible(int fingerprintId) async {
    try {
      // Primero buscar huella
      final resultado = await buscarHuella();
      if (resultado['encontrada'] == true) {
        final idExistente = resultado['fingerprintId'] as int;
        return idExistente != fingerprintId;
      }
      return true;
    } catch (e) {
      print('❌ Error verificando ID disponible: $e');
      return true;
    }
  }

  // ✅ OBTENER INFORMACIÓN DEL SISTEMA
  static Future<Map<String, dynamic>> obtenerInfoSistema() async {
    try {
      final conexion = await verificarConexion();
      final conteo = await contarHuellas();
      
      return {
        'conexion': conexion,
        'huellasRegistradas': conteo['count'] ?? 0,
        'urlBase': baseUrl,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'Error obteniendo información: $e',
        'conexion': {'conectado': false},
        'huellasRegistradas': 0,
      };
    }
  }
}