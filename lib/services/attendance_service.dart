// services/attendance_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BiometricAttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registrar asistencia con huella digital
  Future<void> registerBiometricAttendance({
    required String studentId,
    required String courseId,
    required String fingerprintId,
    required DateTime timestamp,
  }) async {
    try {
      // Verificar si ya existe registro para hoy
      final today = DateTime(timestamp.year, timestamp.month, timestamp.day);
      final attendanceRef = _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .where('courseId', isEqualTo: courseId)
          .where('date', isEqualTo: Timestamp.fromDate(today));

      final existingAttendance = await attendanceRef.get();

      if (existingAttendance.docs.isEmpty) {
        // Registrar nueva asistencia
        await _firestore.collection('attendance').add({
          'studentId': studentId,
          'courseId': courseId,
          'fingerprintId': fingerprintId,
          'timestamp': Timestamp.fromDate(timestamp),
          'date': Timestamp.fromDate(today),
          'status': 'present', // presente
          'biometricVerified': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('Asistencia registrada exitosamente para: $studentId');
      } else {
        print('Asistencia ya registrada para hoy: $studentId');
        throw Exception('Asistencia ya registrada para hoy');
      }
    } catch (e) {
      print('Error registrando asistencia: $e');
      throw Exception('Error al registrar asistencia: $e');
    }
  }

  // Obtener estadísticas de asistencia
  Future<Map<String, dynamic>> getAttendanceStats(
      String courseId, String studentId) async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    final attendanceQuery = await _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .where('courseId', isEqualTo: courseId)
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
        .get();

    final totalDays = now.day; // Días del mes hasta hoy
    final presentDays = attendanceQuery.docs.length;
    final absentDays = totalDays - presentDays;
    final attendanceRate = (presentDays / totalDays) * 100;

    return {
      'totalDays': totalDays,
      'presentDays': presentDays,
      'absentDays': absentDays,
      'attendanceRate': attendanceRate,
      'attendanceScore': calculateAttendanceScore(presentDays, totalDays),
    };
  }

  // Calcular nota de asistencia (sobre 10 puntos)
  double calculateAttendanceScore(int presentDays, int totalDays) {
    if (totalDays == 0) return 0.0;
    
    final attendanceRate = presentDays / totalDays;
    
    // Escala: 100% asistencia = 10 puntos
    // 80% asistencia = 8 puntos, etc.
    double score = attendanceRate * 10;
    
    // Redondear a 2 decimales
    return double.parse(score.toStringAsFixed(2));
  }

  // Obtener historial de asistencia de un estudiante
  Future<List<Map<String, dynamic>>> getStudentAttendanceHistory(
      String studentId, String courseId) async {
    final attendanceQuery = await _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .where('courseId', isEqualTo: courseId)
        .orderBy('timestamp', descending: true)
        .get();

    return attendanceQuery.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'date': (data['timestamp'] as Timestamp).toDate(),
        'status': data['status'],
        'biometricVerified': data['biometricVerified'] ?? false,
      };
    }).toList();
  }

  // Obtener reporte de asistencia del curso
  Future<Map<String, dynamic>> getCourseAttendanceReport(String courseId) async {
    final attendanceQuery = await _firestore
        .collection('attendance')
        .where('courseId', isEqualTo: courseId)
        .get();

    // Agrupar por estudiante
    Map<String, List<DateTime>> studentAttendance = {};
    
    for (final doc in attendanceQuery.docs) {
      final data = doc.data();
      final studentId = data['studentId'];
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      
      if (!studentAttendance.containsKey(studentId)) {
        studentAttendance[studentId] = [];
      }
      studentAttendance[studentId]!.add(timestamp);
    }

    // Calcular estadísticas por estudiante
    final now = DateTime.now();
    final totalDays = now.day;
    
    final studentReports = <Map<String, dynamic>>[];
    
    for (final studentId in studentAttendance.keys) {
      final presentDays = studentAttendance[studentId]!.length;
      final score = calculateAttendanceScore(presentDays, totalDays);
      
      studentReports.add({
        'studentId': studentId,
        'presentDays': presentDays,
        'totalDays': totalDays,
        'score': score,
        'attendanceRate': (presentDays / totalDays) * 100,
      });
    }

    return {
      'courseId': courseId,
      'reportDate': DateTime.now(),
      'totalStudents': studentAttendance.length,
      'studentReports': studentReports,
    };
  }
}
