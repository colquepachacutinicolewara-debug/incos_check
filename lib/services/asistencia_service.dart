// services/asistencia_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'biometrico_service.dart';

class AsistenciaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BiometricoService _biometricService = BiometricoService();

  // ✅ OBJETIVO 4: Registrar asistencia automáticamente con huella
  Future<Map<String, dynamic>> registrarAsistenciaBiometrica({
    required int estudianteId,
    required String estudianteNombre,
    required String materia,
    required String bimestre,
  }) async {
    try {
      // 1. Verificar huella biométrica
      final resultadoBiometrico = await _biometricService
          .verificarHuellaParaAsistencia();

      if (!resultadoBiometrico['success']) {
        return {
          'success': false,
          'message': resultadoBiometrico['message'],
          'tipo': 'error_biometrico',
        };
      }

      // 2. Verificar que la huella coincida con el estudiante
      final String estudianteIdBiometrico =
          resultadoBiometrico['estudianteId'] ?? '';
      if (estudianteIdBiometrico != estudianteId.toString()) {
        return {
          'success': false,
          'message': 'La huella no coincide con el estudiante seleccionado',
          'tipo': 'huella_no_coincide',
        };
      }

      // 3. Registrar asistencia en Firestore
      final resultadoFirestore = await _registrarAsistenciaFirestore(
        estudianteId: estudianteId,
        estudianteNombre: estudianteNombre,
        materia: materia,
        bimestre: bimestre,
        tipoRegistro: 'biometrico',
      );

      return resultadoFirestore;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error en registro biométrico: $e',
        'tipo': 'error_sistema',
      };
    }
  }

  // ✅ OBJETIVO 4: Registrar asistencia manual (para estudiantes sin huella)
  Future<Map<String, dynamic>> registrarAsistenciaManual({
    required int estudianteId,
    required String estudianteNombre,
    required String materia,
    required String bimestre,
  }) async {
    try {
      final resultado = await _registrarAsistenciaFirestore(
        estudianteId: estudianteId,
        estudianteNombre: estudianteNombre,
        materia: materia,
        bimestre: bimestre,
        tipoRegistro: 'manual',
      );

      return resultado;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error en registro manual: $e',
        'tipo': 'error_sistema',
      };
    }
  }

  // ✅ MÉTODO PRIVADO: Registrar en Firestore
  Future<Map<String, dynamic>> _registrarAsistenciaFirestore({
    required int estudianteId,
    required String estudianteNombre,
    required String materia,
    required String bimestre,
    required String tipoRegistro,
  }) async {
    try {
      final timestamp = DateTime.now();
      final recordId = '${estudianteId}_${timestamp.millisecondsSinceEpoch}';

      // Datos de la asistencia
      final asistenciaData = {
        'id': recordId,
        'estudianteId': estudianteId,
        'estudianteNombre': estudianteNombre,
        'materia': materia,
        'bimestre': bimestre,
        'fecha': timestamp,
        'timestamp': FieldValue.serverTimestamp(),
        'tipoRegistro': tipoRegistro,
        'valido': true,
        'curso': 'Tercer Año B - Sistemas Informáticos',
        'carrera': 'Sistemas Informáticos',
        'proyecto': 'INCOS - Control Asistencia Biométrico',
        'estado': 'asistio', // asistio, falta, tardanza
      };

      // Registrar en colección asistencias
      await _firestore
          .collection('asistencias')
          .doc(recordId)
          .set(asistenciaData);

      // Actualizar estadísticas del estudiante
      await _actualizarEstadisticasEstudiante(estudianteId);

      // Registrar en historial de actividades
      await _registrarEnHistorial(estudianteId, estudianteNombre, tipoRegistro);

      return {
        'success': true,
        'message': 'Asistencia registrada exitosamente',
        'tipo': tipoRegistro,
        'timestamp': timestamp,
        'recordId': recordId,
      };
    } catch (e) {
      throw Exception('Error Firestore: $e');
    }
  }

  // ✅ Actualizar estadísticas del estudiante
  Future<void> _actualizarEstadisticasEstudiante(int estudianteId) async {
    try {
      final estudianteRef = _firestore
          .collection('estudiantes')
          .doc(estudianteId.toString());

      await estudianteRef.update({
        'ultimaAsistencia': FieldValue.serverTimestamp(),
        'totalAsistencias': FieldValue.increment(1),
        'asistenciasBimestreActual': FieldValue.increment(1),
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error actualizando estadísticas: $e');
      // No lanzar error para no interrumpir el registro principal
    }
  }

  // ✅ Registrar en historial de actividades
  Future<void> _registrarEnHistorial(
    int estudianteId,
    String estudianteNombre,
    String tipoRegistro,
  ) async {
    try {
      await _firestore.collection('historial_actividades').add({
        'estudianteId': estudianteId,
        'estudianteNombre': estudianteNombre,
        'tipo': 'asistencia_registrada',
        'subtipo': tipoRegistro,
        'timestamp': FieldValue.serverTimestamp(),
        'descripcion': 'Asistencia registrada via $tipoRegistro',
      });
    } catch (e) {
      print('Error registrando en historial: $e');
    }
  }

  // ✅ Obtener asistencias de un estudiante
  Future<List<Map<String, dynamic>>> obtenerAsistenciasEstudiante(
    int estudianteId,
    String bimestre,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('asistencias')
          .where('estudianteId', isEqualTo: estudianteId)
          .where('bimestre', isEqualTo: bimestre)
          .where('valido', isEqualTo: true)
          .orderBy('fecha', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Error obteniendo asistencias: $e');
    }
  }

  // ✅ Verificar si ya se registró asistencia hoy
  Future<bool> verificarAsistenciaHoy(int estudianteId) async {
    try {
      final hoy = DateTime.now();
      final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
      final finDia = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('asistencias')
          .where('estudianteId', isEqualTo: estudianteId)
          .where('fecha', isGreaterThanOrEqualTo: inicioDia)
          .where('fecha', isLessThanOrEqualTo: finDia)
          .where('valido', isEqualTo: true)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error verificando asistencia hoy: $e');
      return false;
    }
  }
}
