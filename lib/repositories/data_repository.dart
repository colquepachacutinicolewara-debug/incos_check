import 'package:cloud_firestore/cloud_firestore.dart';

class DataRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -----------------------------------------------------------------
  // MÉTODOS PARA CarrerasViewModel
  // -----------------------------------------------------------------

  Stream<QuerySnapshot> getCarrerasStream() {
    // ← CORREGIDO: Remover tipo genérico
    return _db
        .collection('carreras')
        .orderBy('nombre', descending: false)
        .snapshots()
        .handleError((error) {
          throw _handleFirestoreError('carreras', error);
        });
  }

  Future<String> addCarrera(Map<String, dynamic> data) async {
    try {
      final docRef = await _db.collection('carreras').add(data);
      return docRef.id;
    } catch (e) {
      throw _handleFirestoreError('carreras', e);
    }
  }

  Future<void> updateCarrera(
    String carreraId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection('carreras').doc(carreraId).update(data);
    } catch (e) {
      throw _handleFirestoreError('carreras', e);
    }
  }

  Future<void> deleteCarrera(String carreraId) async {
    try {
      await _db.collection('carreras').doc(carreraId).delete();
    } catch (e) {
      throw _handleFirestoreError('carreras', e);
    }
  }

  // -----------------------------------------------------------------
  // MÉTODOS PARA DocenteViewModel
  // -----------------------------------------------------------------

  Stream<QuerySnapshot> getDocentesStream() {
    // ← CORREGIDO: Remover tipo genérico
    return _db
        .collection('docentes')
        .orderBy('apellido', descending: false)
        .snapshots()
        .handleError((error) {
          throw _handleFirestoreError('docentes', error);
        });
  }

  Future<DocumentSnapshot> getDocenteById(
    // ← CORREGIDO: Remover tipo genérico
    String docenteId,
  ) {
    return _db.collection('docentes').doc(docenteId).get();
  }

  Future<String> addDocente(Map<String, dynamic> data) async {
    try {
      final docRef = await _db.collection('docentes').add(data);
      return docRef.id;
    } catch (e) {
      throw _handleFirestoreError('docentes', e);
    }
  }

  Future<void> updateDocente(
    String docenteId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection('docentes').doc(docenteId).update(data);
    } catch (e) {
      throw _handleFirestoreError('docentes', e);
    }
  }

  Future<void> deleteDocente(String docenteId) async {
    try {
      await _db.collection('docentes').doc(docenteId).delete();
    } catch (e) {
      throw _handleFirestoreError('docentes', e);
    }
  }

  // -----------------------------------------------------------------
  // MÉTODOS PARA DashboardViewModel (estadísticas)
  // -----------------------------------------------------------------

  Future<int> getTotalEstudiantes() async {
    try {
      final snapshot = await _db.collection('estudiantes').get();
      return snapshot.size;
    } catch (e) {
      throw _handleFirestoreError('estudiantes', e);
    }
  }

  Future<Map<String, dynamic>> getEstadisticasHoy() async {
    try {
      final today = _getTodayString();

      // Obtener asistencias de hoy
      final asistenciasSnapshot = await _db
          .collection('asistencias')
          .where('fecha', isEqualTo: today)
          .get();

      final totalAsistencias = asistenciasSnapshot.size;
      int asistencias = 0;
      int faltas = 0;
      int tardanzas = 0;

      for (final doc in asistenciasSnapshot.docs) {
        final data = doc.data();
        final estado = data['estado']?.toString().toLowerCase() ?? '';

        if (estado == 'asistio') asistencias++;
        if (estado == 'falta') faltas++;
        if (estado == 'tardanza') tardanzas++;
      }

      final totalEstudiantes = await getTotalEstudiantes();
      final porcentajeAsistencia = totalEstudiantes > 0
          ? (asistencias / totalEstudiantes * 100)
          : 0.0;

      return {
        'totalEstudiantes': totalEstudiantes,
        'asistenciasHoy': asistencias,
        'faltasHoy': faltas,
        'tardanzasHoy': tardanzas,
        'porcentajeAsistencia': porcentajeAsistencia,
      };
    } catch (e) {
      throw _handleFirestoreError('estadísticas', e);
    }
  }

  Stream<QuerySnapshot> getCursosHoyStream() {
    // ← CORREGIDO: Remover tipo genérico
    final today = _getTodayString();
    return _db
        .collection('cursos')
        .where('fecha', isEqualTo: today)
        .orderBy('horaInicio')
        .snapshots()
        .handleError((error) {
          throw _handleFirestoreError('cursos', error);
        });
  }

  Stream<QuerySnapshot> getActividadesRecientesStream() {
    // ← CORREGIDO: Remover tipo genérico
    return _db
        .collection('asistencias')
        .orderBy('fecha', descending: true)
        .orderBy('hora', descending: true)
        .limit(10)
        .snapshots()
        .handleError((error) {
          throw _handleFirestoreError('asistencias', error);
        });
  }

  // -----------------------------------------------------------------
  // MÉTODOS GENERALES/UTILITARIOS
  // -----------------------------------------------------------------

  Future<DocumentSnapshot> getDocumentById(
    // ← CORREGIDO: Remover tipo genérico
    String collection,
    String documentId,
  ) {
    return _db.collection(collection).doc(documentId).get();
  }

  Future<String> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await _db.collection(collection).add(data);
      return docRef.id;
    } catch (e) {
      throw _handleFirestoreError(collection, e);
    }
  }

  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw _handleFirestoreError(collection, e);
    }
  }

  // Método auxiliar para manejo de errores
  Exception _handleFirestoreError(String collection, dynamic error) {
    if (error is FirebaseException) {
      return Exception(
        'Error en $collection: ${error.code} - ${error.message}',
      );
    }
    return Exception('Error en $collection: $error');
  }

  // Método auxiliar para obtener la fecha de hoy como string
  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
