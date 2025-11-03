// lib/services/biometria_service.dart
import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';

/// Servicio centralizado para manejar la autenticación biométrica.
/// Este servicio funciona con huellas, rostro o iris (según el dispositivo).
class BiometriaService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Verifica si el dispositivo soporta biometría.
  static Future<bool> dispositivoSoportaBiometria() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      debugPrint('Error verificando soporte biométrico: $e');
      return false;
    }
  }

  /// Devuelve la lista de biometrías disponibles (huella, rostro, iris, etc.)
  static Future<List<BiometricType>> obtenerBiometriasDisponibles() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error obteniendo biometrias: $e');
      return [];
    }
  }

  /// Autenticación biométrica general.
  /// Retorna true si la autenticación fue exitosa.
  static Future<bool> autenticarHuella({
    String razon = 'Verifica tu identidad para continuar',
  }) async {
    try {
      final bool soportado = await dispositivoSoportaBiometria();
      if (!soportado) {
        debugPrint('⚠ El dispositivo no soporta biometría.');
        return false;
      }

      final bool autenticado = await _auth.authenticate(
        localizedReason: razon,
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      return autenticado;
    } catch (e) {
      debugPrint('Error durante autenticación biométrica: $e');
      return false;
    }
  }

  /// Simula el registro de una huella.
  /// Aquí podrías guardar los datos en Firebase más adelante.
  static Future<bool> registrarHuella({
    required String idEstudiante,
    required int numeroHuella,
  }) async {
    try {
      final autenticado = await autenticarHuella(
        razon: 'Registra tu huella #$numeroHuella',
      );

      if (!autenticado) return false;

      // 🔹 Aquí podrías guardar la huella en Firebase (encriptada o con metadatos)
      // await FirebaseFirestore.instance.collection('huellas').add({
      //   'idEstudiante': idEstudiante,
      //   'numeroHuella': numeroHuella,
      //   'timestamp': FieldValue.serverTimestamp(),
      // });

      debugPrint('✅ Huella $numeroHuella registrada para $idEstudiante');
      return true;
    } catch (e) {
      debugPrint('Error registrando huella: $e');
      return false;
    }
  }

  /// Simula la verificación de una huella.
  /// Cuando se conecte a Firebase, aquí se comparará con los datos almacenados.
  static Future<bool> verificarHuella({
    String razon = 'Verifica tu huella para identificarte',
  }) async {
    try {
      final autenticado = await autenticarHuella(razon: razon);
      if (autenticado) {
        debugPrint('✅ Huella verificada correctamente');
      } else {
        debugPrint('❌ Huella no reconocida o autenticación cancelada');
      }
      return autenticado;
    } catch (e) {
      debugPrint('Error verificando huella: $e');
      return false;
    }
  }
}
