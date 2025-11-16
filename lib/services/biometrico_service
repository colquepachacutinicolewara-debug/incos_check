// services/biometrico_service.dart
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BiometricoService {
  static const platform = MethodChannel('com.incos/biometrico');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // OBJETIVO 2: Integración biométrica segura e individual
  Future<Map<String, dynamic>> registrarHuellaConFirebase(
    String estudianteId,
    String estudianteNombre,
  ) async {
    try {
      // 1. Verificar si el estudiante existe
      final estudianteDoc = await _firestore
          .collection('estudiantes')
          .doc(estudianteId)
          .get();

      if (!estudianteDoc.exists) {
        return {
          'success': false,
          'message': 'Estudiante no encontrado en la base de datos',
        };
      }

      // 2. Registrar huella en dispositivo
      final Map<dynamic, dynamic> result = await platform.invokeMethod(
        'registrarHuella',
        {'estudianteId': estudianteId, 'estudianteNombre': estudianteNombre},
      );

      // 3. Actualizar Firestore con registro biométrico
      await _firestore.collection('estudiantes').doc(estudianteId).update({
        'huellaRegistrada': true,
        'huellaId': result['huellaId'],
        'fechaRegistroHuella': FieldValue.serverTimestamp(),
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      });

      // 4. Registrar en historial biométrico
      await _firestore.collection('registro_huellas').add({
        'estudianteId': estudianteId,
        'estudianteNombre': estudianteNombre,
        'huellaId': result['huellaId'],
        'fechaRegistro': FieldValue.serverTimestamp(),
        'tipo': 'REGISTRO',
        'dispositivo': 'Lector Biométrico INCOS',
      });

      return {
        'success': true,
        'huellaId': result['huellaId'],
        'message': 'Huella registrada y almacenada exitosamente',
        'estudianteId': estudianteId,
      };
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.message ?? 'Error desconocido',
        'message': 'Error en registro biométrico: ${e.message}',
      };
    }
  }

  // OBJETIVO 4: Autenticación individual para registro de asistencia
  Future<Map<String, dynamic>> verificarHuellaParaAsistencia() async {
    try {
      // 1. Verificar huella en dispositivo
      final Map<dynamic, dynamic> result = await platform.invokeMethod(
        'verificarHuella',
      );

      final String estudianteId = result['estudianteId'];
      final String estudianteNombre = result['estudianteNombre'];

      // 2. Verificar en Firestore que la huella esté activa
      final estudianteDoc = await _firestore
          .collection('estudiantes')
          .doc(estudianteId)
          .get();

      if (!estudianteDoc.exists ||
          !(estudianteDoc.data()?['huellaRegistrada'] ?? false)) {
        return {
          'success': false,
          'message': 'Huella no registrada en el sistema',
        };
      }

      // 3. Registrar verificación en historial
      await _firestore.collection('verificaciones_huellas').add({
        'estudianteId': estudianteId,
        'estudianteNombre': estudianteNombre,
        'timestamp': FieldValue.serverTimestamp(),
        'tipo': 'ASISTENCIA',
        'valido': true,
      });

      return {
        'success': true,
        'estudianteId': estudianteId,
        'estudianteNombre': estudianteNombre,
        'timestamp': DateTime.now(),
        'message': 'Autenticación biométrica exitosa',
      };
    } on PlatformException catch (e) {
      // Registrar intento fallido
      await _firestore.collection('verificaciones_huellas').add({
        'timestamp': FieldValue.serverTimestamp(),
        'tipo': 'ERROR',
        'valido': false,
        'error': e.message,
      });

      return {
        'success': false,
        'error': e.message ?? 'Error en verificación',
        'message': 'Autenticación biométrica fallida',
      };
    }
  }

  // OBJETIVO 8: Gestión administrativa de huellas
  Future<Map<String, dynamic>> obtenerEstadisticasBiometricas() async {
    try {
      // Estadísticas del dispositivo
      final Map<dynamic, dynamic> deviceStats = await platform.invokeMethod(
        'getEstadisticas',
      );

      // Estadísticas de Firestore
      final huellasRegistradas = await _firestore
          .collection('estudiantes')
          .where('huellaRegistrada', isEqualTo: true)
          .get()
          .then((snapshot) => snapshot.size);

      final totalVerificaciones = await _firestore
          .collection('verificaciones_huellas')
          .where('valido', isEqualTo: true)
          .get()
          .then((snapshot) => snapshot.size);

      return {
        'huellasRegistradas': huellasRegistradas,
        'totalVerificaciones': totalVerificaciones,
        'estadoSensor': deviceStats['estadoSensor'] ?? 'Desconocido',
        'ultimaVerificacion': deviceStats['ultimaVerificacion'],
        'fechaConsulta': DateTime.now(),
      };
    } on PlatformException catch (e) {
      return {
        'error': 'Error obteniendo estadísticas: ${e.message}',
        'huellasRegistradas': 0,
        'totalVerificaciones': 0,
      };
    }
  }

  // OBJETIVO 9: Respaldo de datos biométricos
  Future<Map<String, dynamic>> exportarDatosBiometricos() async {
    try {
      final huellasSnapshot = await _firestore
          .collection('estudiantes')
          .where('huellaRegistrada', isEqualTo: true)
          .get();

      final verificacionesSnapshot = await _firestore
          .collection('verificaciones_huellas')
          .orderBy('timestamp', descending: true)
          .limit(1000)
          .get();

      final datosExportacion = {
        'fechaExportacion': DateTime.now().toIso8601String(),
        'totalEstudiantesConHuella': huellasSnapshot.size,
        'estudiantes': huellasSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'nombre': data['nombreCompleto'] ?? '',
            'huellaId': data['huellaId'] ?? '',
            'fechaRegistro': data['fechaRegistroHuella']
                ?.toDate()
                .toIso8601String(),
          };
        }).toList(),
        'totalVerificaciones': verificacionesSnapshot.size,
        'proyecto': 'INCOS - Control Asistencia Biométrico',
      };

      return {
        'success': true,
        'datos': datosExportacion,
        'message': 'Datos biométricos exportados exitosamente',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error en exportación: $e'};
    }
  }
}
