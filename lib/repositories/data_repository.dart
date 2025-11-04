import 'package:cloud_firestore/cloud_firestore.dart';

class DataRepository {
  // Inicialización de FirebaseFirestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -----------------------------------------------------------------
  // MÉTODOS PARA CarrerasViewModel (CRUD)
  // -----------------------------------------------------------------

  /// Obtiene un stream de documentos de la colección 'carreras'.
  Stream<QuerySnapshot<Map<String, dynamic>>> getCarrerasStream() {
    return _db
        .collection('carreras')
        .orderBy('nombre', descending: false)
        .snapshots()
        .handleError((error) {
          // Lanza la excepción manejada para que el ViewModel la capture
          throw _handleFirestoreError('carreras', error);
        });
  }

  /// Agrega una nueva carrera y retorna su ID.
  Future<String> addCarrera(Map<String, dynamic> data) async {
    try {
      final docRef = await _db.collection('carreras').add(data);
      return docRef.id;
    } catch (e) {
      throw _handleFirestoreError('carreras', e);
    }
  }

  /// Actualiza una carrera por su ID.
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

  /// Elimina una carrera por su ID.
  Future<void> deleteCarrera(String carreraId) async {
    try {
      await _db.collection('carreras').doc(carreraId).delete();
    } catch (e) {
      throw _handleFirestoreError('carreras', e);
    }
  }

  // -----------------------------------------------------------------
  // MÉTODOS PARA DocenteViewModel (CRUD de Docentes)
  // -----------------------------------------------------------------

  /// Obtiene un stream de documentos de la colección 'docentes'.
  Stream<QuerySnapshot<Map<String, dynamic>>> getDocentesStream() {
    return _db
        .collection('docentes')
        .orderBy('apellido', descending: false)
        .snapshots()
        .handleError((error) {
          throw _handleFirestoreError('docentes', error);
        });
  }

  /// Obtiene un documento de docente por su ID.
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocenteById(
    String docenteId,
  ) {
    return _db.collection('docentes').doc(docenteId).get();
  }

  /// Agrega un nuevo docente y retorna su ID.
  Future<String> addDocente(Map<String, dynamic> data) async {
    try {
      final docRef = await _db.collection('docentes').add(data);
      return docRef.id;
    } catch (e) {
      throw _handleFirestoreError('docentes', e);
    }
  }

  /// Actualiza un docente por su ID.
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

  /// Elimina un docente por su ID.
  Future<void> deleteDocente(String docenteId) async {
    try {
      await _db.collection('docentes').doc(docenteId).delete();
    } catch (e) {
      throw _handleFirestoreError('docentes', e);
    }
  }

  // -----------------------------------------------------------------
  // MÉTODOS PARA DashboardViewModel (Estadísticas y Cursos)
  // -----------------------------------------------------------------

  /// Obtiene el número total de estudiantes.
  Future<int> getTotalEstudiantes() async {
    try {
      final snapshot = await _db.collection('estudiantes').get();
      return snapshot.size;
    } catch (e) {
      throw _handleFirestoreError('estudiantes', e);
    }
  }

  /// Obtiene estadísticas de asistencia para el día de hoy.
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

  /// Obtiene un stream de cursos programados para hoy.
  Stream<QuerySnapshot<Map<String, dynamic>>> getCursosHoyStream() {
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

  /// Obtiene un stream de las últimas 10 actividades (asistencias) recientes.
  Stream<QuerySnapshot<Map<String, dynamic>>> getActividadesRecientesStream() {
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

  /// Obtiene un documento genérico por colección e ID.
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocumentById(
    String collection,
    String documentId,
  ) {
    return _db.collection(collection).doc(documentId).get();
  }

  /// Agrega un documento genérico a una colección y retorna su ID.
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

  /// Actualiza un documento genérico en una colección por su ID.
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

  // Método auxiliar privado para manejo consistente de errores de Firestore
  Exception _handleFirestoreError(String collection, dynamic error) {
    if (error is FirebaseException) {
      return Exception(
        'Error de Firestore en $collection: ${error.code} - ${error.message}',
      );
    }
    return Exception('Error desconocido en $collection: $error');
  }

  // Método auxiliar privado para obtener la fecha de hoy en formato 'YYYY-MM-DD'
  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
