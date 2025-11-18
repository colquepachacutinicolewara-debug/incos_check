// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = "http://192.168.1.100/incos_check/api"; // Cambia por tu IP
  static String? _token;
  
  // Método para login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/index.php?action=login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _token = data['token'];
          await _saveToken(_token!);
          return {'success': true, 'user': data['user']};
        }
      }
      
      final errorData = jsonDecode(response.body);
      return {'success': false, 'error': errorData['error'] ?? 'Credenciales incorrectas'};
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
  
  // Método para sincronizar datos individuales
  static Future<Map<String, dynamic>> syncData(
    String table, 
    Map<String, dynamic> data, 
    String operation
  ) async {
    await _loadToken();
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/index.php?action=sync&table=$table'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'operation': operation,
          'data': data,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'error': errorData['error'] ?? 'Error del servidor'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
  
  // Método para sincronización masiva
  static Future<Map<String, dynamic>> syncBatch(List<Map<String, dynamic>> batch) async {
    await _loadToken();
    
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/index.php?action=sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'batch': batch}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'error': errorData['error'] ?? 'Error del servidor'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
  
  // Método para obtener cambios desde última sincronización
  static Future<Map<String, dynamic>> getChangesSince(
    String table, 
    String lastSync
  ) async {
    await _loadToken();
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/index.php?action=sync&table=$table&lastSync=$lastSync'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'error': errorData['error'] ?? 'Error del servidor'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
  
  // Método para crear respaldo
  static Future<Map<String, dynamic>> createBackup() async {
    await _loadToken();
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/index.php?action=backup'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'error': errorData['error'] ?? 'Error del servidor'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
  
  // Método para restaurar respaldo
  static Future<Map<String, dynamic>> restoreBackup(String backupId) async {
    await _loadToken();
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/index.php?action=restore'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'backup_id': backupId}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'error': errorData['error'] ?? 'Error del servidor'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
  
  // Métodos auxiliares para manejo del token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  static Future<void> _loadToken() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
    }
  }
  
  static Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  static Future<bool> get isLoggedIn async {
    await _loadToken();
    return _token != null;
  }
  
  // Obtener token actual
  static String? get token => _token;
}