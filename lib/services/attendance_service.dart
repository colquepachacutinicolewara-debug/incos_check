// services/attendance_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // OBJETIVO 4: Automatizar registro de asistencia biométrica
  Future<void> registrarAsistenciaBiometrica({
    required String estudianteId,
    required String materiaId,
    required String bimestre,
  }) async {
    try {
      String recordId =
          '${estudianteId}_${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('asistencias').doc(recordId).set({
        'id': recordId,
        'estudianteId': estudianteId,
        'materiaId': materiaId,
        'bimestre': bimestre,
        'fecha': DateTime.now(),
        'presente': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print(
        'Asistencia registrada exitosamente para el estudiante: $estudianteId',
      );
    } catch (e) {
      print('Error al registrar asistencia: $e');
      throw e;
    }
  }

  // OBJETIVO 5: Cálculo automático DPS (nota sobre 10)
  Future<double> calcularNotaDPS({
    required String estudianteId,
    required String materiaId,
    required String bimestre,
  }) async {
    try {
      // Obtener asistencias del estudiante
      QuerySnapshot snapshot = await _firestore
          .collection('asistencias')
          .where('estudianteId', isEqualTo: estudianteId)
          .where('materiaId', isEqualTo: materiaId)
          .where('bimestre', isEqualTo: bimestre)
          .get();

      int totalClases = await _obtenerTotalClases(materiaId, bimestre);
      int asistencias = snapshot.docs.length;

      // Evitar división por cero
      if (totalClases == 0) return 0.0;

      double porcentaje = (asistencias / totalClases) * 100;
      return (porcentaje / 100) * 10; // Convertir a nota sobre 10
    } catch (e) {
      print('Error al calcular nota DPS: $e');
      return 0.0;
    }
  }

  // Método auxiliar para obtener el total de clases
  Future<int> _obtenerTotalClases(String materiaId, String bimestre) async {
    try {
      // Aquí deberías implementar la lógica para obtener el total de clases
      // Por ejemplo, desde una colección de configuraciones o horarios

      // Por ahora, retornamos un valor por defecto
      return 20; // Suponiendo 20 clases en el bimestre
    } catch (e) {
      print('Error al obtener total de clases: $e');
      return 0;
    }
  }

  // OBJETIVO 6: Generar reportes de asistencia
  Future<Map<String, dynamic>> generarReporteAsistencia(
    String materiaId,
    String bimestre,
  ) async {
    try {
      // Obtener todas las asistencias de la materia y bimestre
      QuerySnapshot snapshot = await _firestore
          .collection('asistencias')
          .where('materiaId', isEqualTo: materiaId)
          .where('bimestre', isEqualTo: bimestre)
          .get();

      // Procesar datos para el reporte
      Map<String, List<DateTime>> asistenciasPorEstudiante = {};

      for (var doc in snapshot.docs) {
        String estudianteId = doc['estudianteId'];
        DateTime fecha = (doc['fecha'] as Timestamp).toDate();

        if (!asistenciasPorEstudiante.containsKey(estudianteId)) {
          asistenciasPorEstudiante[estudianteId] = [];
        }
        asistenciasPorEstudiante[estudianteId]!.add(fecha);
      }

      // Calcular estadísticas
      int totalEstudiantes = asistenciasPorEstudiante.length;
      int totalAsistencias = snapshot.docs.length;

      return {
        'materiaId': materiaId,
        'bimestre': bimestre,
        'totalEstudiantes': totalEstudiantes,
        'totalAsistencias': totalAsistencias,
        'asistenciasPorEstudiante': asistenciasPorEstudiante,
        'fechaGeneracion': DateTime.now(),
      };
    } catch (e) {
      print('Error al generar reporte: $e');
      throw e;
    }
  }

  // Método adicional: Obtener historial de asistencias de un estudiante
  Future<List<Map<String, dynamic>>> obtenerHistorialAsistencia(
    String estudianteId,
    String materiaId,
    String bimestre,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('asistencias')
          .where('estudianteId', isEqualTo: estudianteId)
          .where('materiaId', isEqualTo: materiaId)
          .where('bimestre', isEqualTo: bimestre)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc['id'],
          'fecha': (doc['fecha'] as Timestamp).toDate(),
          'presente': doc['presente'],
          'timestamp': (doc['timestamp'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      print('Error al obtener historial: $e');
      return [];
    }
  }

  // Método adicional: Verificar si ya existe asistencia registrada hoy
  Future<bool> verificarAsistenciaHoy(
    String estudianteId,
    String materiaId,
  ) async {
    try {
      DateTime hoy = DateTime.now();
      DateTime inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
      DateTime finDia = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection('asistencias')
          .where('estudianteId', isEqualTo: estudianteId)
          .where('materiaId', isEqualTo: materiaId)
          .where('fecha', isGreaterThanOrEqualTo: inicioDia)
          .where('fecha', isLessThanOrEqualTo: finDia)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar asistencia de hoy: $e');
      return false;
    }
  }
}
