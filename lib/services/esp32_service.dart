// services/esp32_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ESP32Service {
  static const String baseUrl = 'http://192.168.4.1'; // IP del ESP32 en modo AP
  static const int timeoutSeconds = 10;

  // Verificar conexión con ESP32
  static Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/status'))
          .timeout(Duration(seconds: timeoutSeconds));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'online' && data['sensor_connected'] == true;
      }
      return false;
    } catch (e) {
      print('Error de conexión ESP32: $e');
      return false;
    }
  }

  // Registrar nueva huella
  static Future<Map<String, dynamic>> registerFingerprint(
      String studentId, String studentName) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/enroll'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'student_id': studentId,
              'student_name': studentName,
            }),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error del servidor ESP32: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de comunicación: $e');
    }
  }

  // Verificar huella
  static Future<Map<String, dynamic>> verifyFingerprint() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/verify'))
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error del servidor ESP32: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de comunicación: $e');
    }
  }

  // Obtener lista de huellas registradas
  static Future<List<dynamic>> getRegisteredFingerprints() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/fingerprints'))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error del servidor ESP32: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de comunicación: $e');
    }
  }

  // Eliminar huella
  static Future<Map<String, dynamic>> deleteFingerprint(int fingerprintId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/fingerprint/$fingerprintId'),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error del servidor ESP32: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de comunicación: $e');
    }
  }
}