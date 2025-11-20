import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "http://localhost/incos_api";
  // Para dispositivo físico: "http://192.168.1.X/incos_api"
  
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HEADERS comunes
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // MANEJAR errores HTTP
  dynamic _handleResponse(http.Response response) {
    print('🔗 API Response: ${response.statusCode} - ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // TEST de conexión
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/test'),
        headers: _headers,
      ).timeout(Duration(seconds: 10));
      
      final data = _handleResponse(response);
      return data['success'] == true;
    } catch (e) {
      print('❌ Error testing connection: $e');
      return false;
    }
  }

  // ========== ESTUDIANTES ==========

  // OBTENER todos los estudiantes
  Future<List<dynamic>> obtenerEstudiantes() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/estudiantes'),
      headers: _headers,
    );
    
    final data = _handleResponse(response);
    return data['data'] ?? [];
  }

  // CREAR estudiante
  Future<dynamic> crearEstudiante(Map<String, dynamic> estudiante) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/estudiantes'),
      headers: _headers,
      body: json.encode(estudiante),
    );
    
    return _handleResponse(response);
  }

  // SINCRONIZAR lote de estudiantes
  Future<dynamic> sincronizarEstudiantes(List<Map<String, dynamic>> estudiantes) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/estudiantes'),
      headers: _headers,
      body: json.encode({'estudiantes': estudiantes}),
    );
    
    return _handleResponse(response);
  }

  // ========== ASISTENCIAS ==========

  // REGISTRAR asistencia
  Future<dynamic> registrarAsistencia(Map<String, dynamic> asistencia) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/asistencias'),
      headers: _headers,
      body: json.encode(asistencia),
    );
    
    return _handleResponse(response);
  }

  // SINCRONIZAR lote de asistencias
  Future<dynamic> sincronizarAsistencias(List<Map<String, dynamic>> asistencias) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/asistencias'),
      headers: _headers,
      body: json.encode({'asistencias': asistencias}),
    );
    
    return _handleResponse(response);
  }

  // OBTENER asistencias por fecha
  Future<List<dynamic>> obtenerAsistenciasPorFecha(String fecha, {String? materiaId}) async {
    String url = '$_baseUrl/asistencias?fecha=$fecha';
    if (materiaId != null) {
      url += '&materia_id=$materiaId';
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );
    
    final data = _handleResponse(response);
    return data['data'] ?? [];
  }

  // ========== SINCRONIZACIÓN COMPLETA ==========

  Future<dynamic> sincronizarCompleta({
    required List<Map<String, dynamic>> estudiantes,
    required List<Map<String, dynamic>> asistencias,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/sync'),
      headers: _headers,
      body: json.encode({
        'estudiantes': estudiantes,
        'asistencias': asistencias,
      }),
    );
    
    return _handleResponse(response);
  }
}