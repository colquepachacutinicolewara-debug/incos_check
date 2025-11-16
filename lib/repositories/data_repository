import 'package:cloud_firestore/cloud_firestore.dart';

class DataRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFirestore get db => _db;

  // -----------------------------------------------------------------
  // MÉTODOS PARA CarrerasViewModel
  // -----------------------------------------------------------------

  Stream<QuerySnapshot> getCarrerasStream() {
    return _db
        .collection('carreras')
        .orderBy('nombre', descending: false)
        .snapshots()
        .handleError((error) {
          throw _handleFirestoreError('carreras', error);
        });
  }

  Stream<DocumentSnapshot> getCarreraStream(String carreraId) {
    return _db.collection('carreras').doc(carreraId).snapshots();
  }

  Future<DocumentSnapshot> getCarrera(String carreraId) async {
    try {
      return await _db.collection('carreras').doc(carreraId).get();
    } catch (e) {
      throw _handleFirestoreError('carreras', e);
    }
  }

  Future<String> addCarrera(Map<String, dynamic> data) async {
    try {
      final docRef = await _db.collection('carreras').add(data);
      return docRef.id;
    } catch (e) {
      throw _handleFirestoreError('carreras', e);
    }
  }

  Future<void> crearCarrera(String carreraId, Map<String, dynamic> data) async {
    try {
      await _db.collection('carreras').doc(carreraId).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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

  Future<void> actualizarCarrera(
    String carreraId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection('carreras').doc(carreraId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
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
  // MÉTODOS PARA Turnos
  // -----------------------------------------------------------------

  Stream<QuerySnapshot> getTurnosStream(String carreraId) {
    return _db
        .collection('carreras')
        .doc(carreraId)
        .collection('turnos')
        .orderBy('nombre')
        .snapshots()
        .handleError((error) {
          throw _handleFirestoreError('turnos', error);
        });
  }

  Future<String> addTurno(String carreraId, Map<String, dynamic> data) async {
    try {
      final docRef = await _db
          .collection('carreras')
          .doc(carreraId)
          .collection('turnos')
          .add(data);
      return docRef.id;
    } catch (e) {
      throw _handleFirestoreError('turnos', e);
    }
  }

  Future<void> agregarTurno(
    String carreraId,
    String turnoId,
    Map<String, dynamic> turnoData,
  ) async {
    try {
      await _db.collection('carreras').doc(carreraId).update({
        'turnos.$turnoId': {
          ...turnoData,
          'createdAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError('carreras', e);
    }
  }

  Future<void> actualizarTurno(
    String carreraId,
    String turnoId,
    Map<String, dynamic> turnoData,
  ) async {
    try {
      await _db.collection('carreras').doc(carreraId).update({
        'turnos.$turnoId': {
          ...turnoData,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError('carreras', e);
    }
  }

  Future<void> eliminarTurno(String carreraId, String turnoId) async {
    try {
      await _db.collection('carreras').doc(carreraId).update({
        'turnos.$turnoId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError('carreras', e);
    }
  }

  // -----------------------------------------------------------------
  // MÉTODOS PARA Niveles
  // -----------------------------------------------------------------

  Stream<QuerySnapshot> getNivelesStream(String carreraId, String turnoId) {
    return _db
        .collection('carreras')
        .doc(carreraId)
        .collection('turnos')
        .doc(turnoId)
        .collection('niveles')
        .orderBy('nombre')
        .snapshots()
        .handleError((error) {
          throw _handleFirestoreError('niveles', error);
        });
  }

  Future<String> addNivel(
    String carreraId,
    String turnoId,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await _db
          .collection('carreras')
          .doc(carreraId)
          .collection('turnos')
          .doc(turnoId)
          .collection('niveles')
          .add(data);
      return docRef.id;
    } catch (e) {
      throw _handleFirestoreError('niveles', e);
    }
  }

  // Agrega estos métodos al DataRepository existente

// -----------------------------------------------------------------
// MÉTODOS PARA MateriaViewModel
// -----------------------------------------------------------------

Stream<QuerySnapshot> getMateriasStream() {
  return _db
      .collection('materias')
      .orderBy('carrera', descending: false)
      .orderBy('anio', descending: false)
      .orderBy('paralelo', descending: false)
      .orderBy('turno', descending: false)
      .snapshots()
      .handleError((error) {
        throw _handleFirestoreError('materias', error);
      });
}

Future<String> addMateria(Map<String, dynamic> data) async {
  try {
    final docRef = await _db.collection('materias').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  } catch (e) {
    throw _handleFirestoreError('materias', e);
  }
}

Future<void> updateMateria(String materiaId, Map<String, dynamic> data) async {
  try {
    await _db.collection('materias').doc(materiaId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    throw _handleFirestoreError('materias', e);
  }
}

Future<void> deleteMateria(String materiaId) async {
  try {
    await _db.collection('materias').doc(materiaId).delete();
  } catch (e) {
    throw _handleFirestoreError('materias', e);
  }
}

Future<bool> materiaExists(Map<String, dynamic> filters) async {
  try {
    Query query = _db.collection('materias');
    
    if (filters['codigo'] != null) {
      query = query.where('codigo', isEqualTo: filters['codigo']);
    }
    if (filters['paralelo'] != null) {
      query = query.where('paralelo', isEqualTo: filters['paralelo']);
    }
    if (filters['turno'] != null) {
      query = query.where('turno', isEqualTo: filters['turno']);
    }
    if (filters['anio'] != null) {
      query = query.where('anio', isEqualTo: filters['anio']);
    }
    if (filters['carrera'] != null) {
      query = query.where('carrera', isEqualTo: filters['carrera']);
    }
    if (filters['excludeId'] != null) {
      query = query.where(FieldPath.documentId, isNotEqualTo: filters['excludeId']);
    }

    final snapshot = await query.get();
    return snapshot.docs.isNotEmpty;
  } catch (e) {
    throw _handleFirestoreError('materias', e);
  }
}

Future<List<Map<String, dynamic>>> getCarrerasActivas() async {
  try {
    final snapshot = await _db
        .collection('carreras')
        .where('activa', isEqualTo: true)
        .orderBy('nombre')
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'nombre': data['nombre'] ?? '',
        'color': data['color'] ?? '#1565C0',
        'activa': data['activa'] ?? true,
      };
    }).toList();
  } catch (e) {
    throw _handleFirestoreError('carreras', e);
  }
}

  // -----------------------------------------------------------------
  // MÉTODOS PARA ParalelosViewModel
  // -----------------------------------------------------------------

  Stream<QuerySnapshot> getParalelosStream(
    String carreraId,
    String turnoId,
    String nivelId,
  ) {
    return _db
        .collection('carreras')
        .doc(carreraId)
        .collection('turnos')
        .doc(turnoId)
        .collection('niveles')
        .doc(nivelId)
        .collection('paralelos')
        .orderBy('nombre')
        .snapshots()
        .handleError((error) {
          throw _handleFirestoreError('paralelos', error);
        });
  }

  Future<String> addParalelo(
    String carreraId,
    String turnoId,
    String nivelId,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await _db
          .collection('carreras')
          .doc(carreraId)
          .collection('turnos')
          .doc(turnoId)
          .collection('niveles')
          .doc(nivelId)
          .collection('paralelos')
          .add(data);
      return docRef.id;
    } catch (e) {
      throw _handleFirestoreError('paralelos', e);
    }
  }

  Future<void> updateParalelo(
    String carreraId,
    String turnoId,
    String nivelId,
    String paraleloId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db
          .collection('carreras')
          .doc(carreraId)
          .collection('turnos')
          .doc(turnoId)
          .collection('niveles')
          .doc(nivelId)
          .collection('paralelos')
          .doc(paraleloId)
          .update(data);
    } catch (e) {
      throw _handleFirestoreError('paralelos', e);
    }
  }

  Future<void> deleteParalelo(
    String carreraId,
    String turnoId,
    String nivelId,
    String paraleloId,
  ) async {
    try {
      await _db
          .collection('carreras')
          .doc(carreraId)
          .collection('turnos')
          .doc(turnoId)
          .collection('niveles')
          .doc(nivelId)
          .collection('paralelos')
          .doc(paraleloId)
          .delete();
    } catch (e) {
      throw _handleFirestoreError('paralelos', e);
    }
  }

  Future<bool> paraleloExists(
    String carreraId,
    String turnoId,
    String nivelId,
    String nombre,
  ) async {
    try {
      final snapshot = await _db
          .collection('carreras')
          .doc(carreraId)
          .collection('turnos')
          .doc(turnoId)
          .collection('niveles')
          .doc(nivelId)
          .collection('paralelos')
          .where('nombre', isEqualTo: nombre)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw _handleFirestoreError('paralelos', e);
    }
  }

  Future<QuerySnapshot> getParalelos(
    String carreraId,
    String turnoId,
    String nivelId,
  ) async {
    try {
      return await _db
          .collection('carreras')
          .doc(carreraId)
          .collection('turnos')
          .doc(turnoId)
          .collection('niveles')
          .doc(nivelId)
          .collection('paralelos')
          .get();
    } catch (e) {
      throw _handleFirestoreError('paralelos', e);
    }
  }

  // -----------------------------------------------------------------
  // MÉTODOS PARA EstudiantesViewModel
  // -----------------------------------------------------------------

  Stream<QuerySnapshot> getEstudiantesStream() {
    return _db
        .collection('estudiantes')
        .orderBy('apellidoPaterno', descending: false)
        .orderBy('apellidoMaterno', descending: false)
        .orderBy('nombres', descending: false)
        .snapshots()
        .handleError((error) {
          throw _handleFirestoreError('estudiantes', error);
        });
  }

  Stream<QuerySnapshot> getEstudiantesByGrupoStream({
    required String carreraId,
    required String turnoId,
    required String nivelId,
    required String paraleloId,
  }) {
    return _db
        .collection('estudiantes')
        .where('carreraId', isEqualTo: carreraId)
        .where('turnoId', isEqualTo: turnoId)
        .where('nivelId', isEqualTo: nivelId)
        .where('paraleloId', isEqualTo: paraleloId)
        .orderBy('apellidoPaterno')
        .orderBy('apellidoMaterno')
        .orderBy('nombres')
        .snapshots()
        .handleError((error) {
          throw _handleFirestoreError('estudiantes', error);
        });
  }

  Future<String> addEstudiante(Map<String, dynamic> data) async {
    try {
      final docRef = await _db.collection('estudiantes').add(data);
      return docRef.id;
    } catch (e) {
      throw _handleFirestoreError('estudiantes', e);
    }
  }

  Future<void> updateEstudiante(
    String estudianteId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection('estudiantes').doc(estudianteId).update(data);
    } catch (e) {
      throw _handleFirestoreError('estudiantes', e);
    }
  }

  Future<void> deleteEstudiante(String estudianteId) async {
    try {
      await _db.collection('estudiantes').doc(estudianteId).delete();
    } catch (e) {
      throw _handleFirestoreError('estudiantes', e);
    }
  }

  // -----------------------------------------------------------------
  // MÉTODOS PARA DocentesViewModel
  // -----------------------------------------------------------------

  Stream<QuerySnapshot> getDocentesStream() {
    return _db
        .collection('docentes')
        .orderBy('apellidoPaterno', descending: false)
        .orderBy('apellidoMaterno', descending: false)
        .orderBy('nombres', descending: false)
        .snapshots()
        .handleError((error) {
          throw _handleFirestoreError('docentes', error);
        });
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

  Future<DocumentSnapshot> getDocenteById(String docenteId) {
    return _db.collection('docentes').doc(docenteId).get();
  }

  // -----------------------------------------------------------------
  // MÉTODOS PARA ConfiguracionViewModel
  // -----------------------------------------------------------------

  Future<DocumentSnapshot> getConfiguracion(String usuarioId) async {
    try {
      return await _db.collection('configuraciones').doc(usuarioId).get();
    } catch (e) {
      throw _handleFirestoreError('configuraciones', e);
    }
  }

  Stream<DocumentSnapshot> getConfiguracionStream(String usuarioId) {
    return _db.collection('configuraciones').doc(usuarioId).snapshots();
  }

  Future<void> saveConfiguracion(
    String usuarioId,
    Map<String, dynamic> configuracion,
  ) async {
    try {
      await _db.collection('configuraciones').doc(usuarioId).set({
        ...configuracion,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw _handleFirestoreError('configuraciones', e);
    }
  }

  Future<void> updateConfiguracion(
    String usuarioId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _db.collection('configuraciones').doc(usuarioId).update({
        ...updates,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError('configuraciones', e);
    }
  }

  // -----------------------------------------------------------------
  // MÉTODOS PARA DashboardViewModel
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

  Future<void> setDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    try {
      await _db
          .collection(collection)
          .doc(documentId)
          .set(data, SetOptions(merge: merge));
    } catch (e) {
      throw _handleFirestoreError(collection, e);
    }
  }

  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _db.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw _handleFirestoreError(collection, e);
    }
  }

  Future<bool> documentExists(String collection, String documentId) async {
    try {
      final doc = await _db.collection(collection).doc(documentId).get();
      return doc.exists;
    } catch (e) {
      throw _handleFirestoreError(collection, e);
    }
  }

  Future<QuerySnapshot> getDocuments(String collection) async {
    try {
      return await _db.collection(collection).get();
    } catch (e) {
      throw _handleFirestoreError(collection, e);
    }
  }

  // -----------------------------------------------------------------
  // MÉTODOS AUXILIARES
  // -----------------------------------------------------------------

  Exception _handleFirestoreError(String collection, dynamic error) {
    if (error is FirebaseException) {
      return Exception(
        'Error en $collection: ${error.code} - ${error.message}',
      );
    }
    return Exception('Error en $collection: $error');
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
