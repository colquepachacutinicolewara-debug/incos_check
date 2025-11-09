// lib/services/biometric_registry_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';

class BiometricRegistryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Registrar huella para un estudiante
  Future<bool> registerStudentBiometric({
    required String studentId,
    required String studentName,
  }) async {
    try {
      // Autenticar con huella
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Registra tu huella para $studentName',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        // Generar ID único para la huella (en una app real, esto vendría del sensor)
        final String biometricId = 'bio_${DateTime.now().millisecondsSinceEpoch}';
        
        // Guardar en Firestore
        await _firestore.collection('student_biometrics').doc(studentId).set({
          'studentId': studentId,
          'biometricId': biometricId,
          'studentName': studentName,
          'registeredAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });

        // Actualizar contador de huellas del estudiante
        await _firestore.collection('students').doc(studentId).update({
          'huellasRegistradas': 3, // Máximo de huellas
          'fechaActualizacion': FieldValue.serverTimestamp(),
        });

        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Error registrando huella: $e');
    }
  }

  // Verificar huella y obtener estudiante
  Future<String?> verifyBiometricAndGetStudent() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Autentica tu identidad para registrar asistencia',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        // En una implementación real, aquí obtendrías el ID de huella del sensor
        // Por ahora, simulamos la búsqueda
        return await _findStudentByBiometric();
      }
      return null;
    } catch (e) {
      throw Exception('Error en autenticación biométrica: $e');
    }
  }

  Future<String?> _findStudentByBiometric() async {
    // Simulación - en realidad buscarías por ID de huella del sensor
    final snapshot = await _firestore
        .collection('student_biometrics')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data()['studentId'] as String;
    }
    return null;
  }

  // Obtener estudiantes sin huellas registradas
  Stream<QuerySnapshot> getStudentsWithoutBiometrics() {
    return _firestore
        .collection('students')
        .where('huellasRegistradas', isLessThan: 3)
        .snapshots();
  }
}