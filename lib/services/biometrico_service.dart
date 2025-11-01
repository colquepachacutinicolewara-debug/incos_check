// services/biometrico_service.dart
import 'package:flutter/services.dart';

class BiometricoService {
  static const platform = MethodChannel('com.incos/biometrico');

  /// Verifica si el dispositivo soporta huella digital
  Future<bool> isBiometricSupported() async {
    try {
      final bool isSupported = await platform.invokeMethod(
        'isBiometricSupported',
      );
      return isSupported;
    } on PlatformException catch (e) {
      print("Error verificando soporte biométrico: ${e.message}");
      return false;
    }
  }

  /// Registra nueva huella digital para un estudiante
  Future<Map<String, dynamic>> registrarHuella(
    String estudianteId,
    String estudianteNombre,
  ) async {
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod(
        'registrarHuella',
        {'estudianteId': estudianteId, 'estudianteNombre': estudianteNombre},
      );

      return {
        'success': true,
        'huellaId': result['huellaId'],
        'message': 'Huella registrada exitosamente',
      };
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.message ?? 'Error desconocido',
        'message': 'Error registrando huella: ${e.message}',
      };
    }
  }

  /// Verifica huella y retorna ID del estudiante
  Future<Map<String, dynamic>> verificarHuella() async {
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod(
        'verificarHuella',
      );

      return {
        'success': true,
        'estudianteId': result['estudianteId'],
        'estudianteNombre': result['estudianteNombre'],
        'timestamp': DateTime.now().toIso8601String(),
      };
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.message ?? 'Error en verificación',
        'message': 'Error verificando huella: ${e.message}',
      };
    }
  }

  /// Elimina huella registrada
  Future<bool> eliminarHuella(String huellaId) async {
    try {
      final bool success = await platform.invokeMethod('eliminarHuella', {
        'huellaId': huellaId,
      });
      return success;
    } on PlatformException catch (e) {
      print("Error eliminando huella: ${e.message}");
      return false;
    }
  }

  /// Obtiene estadísticas del sensor biométrico
  Future<Map<String, dynamic>> getEstadisticasBiometrico() async {
    try {
      final Map<dynamic, dynamic> stats = await platform.invokeMethod(
        'getEstadisticas',
      );
      return {
        'huellasRegistradas': stats['huellasRegistradas'] ?? 0,
        'ultimaVerificacion': stats['ultimaVerificacion'],
        'estadoSensor': stats['estadoSensor'] ?? 'Desconocido',
      };
    } on PlatformException catch (e) {
      return {'huellasRegistradas': 0, 'estadoSensor': 'Error: ${e.message}'};
    }
  }

  /// SIMULACIÓN: Registrar múltiples huellas para el proyecto
  Future<Map<String, dynamic>> registrarMultiplesHuellasSimuladas({
    required String estudianteId,
    required String estudianteNombre,
    required int cantidadHuellas,
  }) async {
    // Simulamos el registro de huellas para el proyecto
    await Future.delayed(Duration(seconds: 2));

    List<String> huellasIds = [];
    for (int i = 1; i <= cantidadHuellas; i++) {
      huellasIds.add(
        'HUELLA_${estudianteId}_DEDO_${i}_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    return {
      'success': true,
      'huellasIds': huellasIds,
      'totalRegistradas': huellasIds.length,
      'message':
          'SIMULACIÓN: Se registraron ${huellasIds.length} huellas para el proyecto',
      'estudianteId': estudianteId,
      'estudianteNombre': estudianteNombre,
      'tipo': 'SIMULACIÓN PARA PROYECTO INCOS',
    };
  }

  /// SIMULACIÓN: Verificar huella para demostración
  Future<Map<String, dynamic>> verificarHuellaSimulada() async {
    // Simulamos la verificación para el proyecto
    await Future.delayed(Duration(seconds: 1));

    return {
      'success': true,
      'estudianteId': 'demo_incos_001',
      'estudianteNombre': 'ESTUDIANTE DEMO - INCOS',
      'timestamp': DateTime.now().toIso8601String(),
      'mensaje':
          'SIMULACIÓN: Huella verificada exitosamente para demostración del proyecto',
      'proyecto': 'Control de Asistencia Biométrico - INCOS EL ALTO',
    };
  }
}
