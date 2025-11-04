import 'package:cloud_firestore/cloud_firestore.dart';

class DataRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -----------------------------------------------------------------
  // MÉTODOS PARA CarrerasViewModel
  // -----------------------------------------------------------------

  Stream<QuerySnapshot<Map<String, dynamic>>> getCarrerasStream() {
    return _db
        .collection('carreras')
        .orderBy('nombre', descending: false)
        .snapshots();
  }

  Future<void> addCarrera(Map<String, dynamic> data) async {
    try {
      await _db.collection('carreras').add(data);
    } catch (e) {
      throw Exception('Error al agregar carrera: $e');
    }
  }

  Future<void> updateCarrera(
    String carreraId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection('carreras').doc(carreraId).update(data);
    } catch (e) {
      throw Exception('Error al actualizar carrera: $e');
    }
  }

  Future<void> deleteCarrera(String carreraId) async {
    try {
      await _db.collection('carreras').doc(carreraId).delete();
    } catch (e) {
      throw Exception('Error al eliminar carrera: $e');
    }
  }

  // -----------------------------------------------------------------
  // MÉTODOS PARA DocenteViewModel
  // -----------------------------------------------------------------

  Stream<QuerySnapshot<Map<String, dynamic>>> getDocentesStream() {
    return _db
        .collection('docentes')
        .orderBy('apellido', descending: false)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocenteById(
    String docenteId,
  ) {
    return _db.collection('docentes').doc(docenteId).get();
  }

  Future<void> addDocente(Map<String, dynamic> data) async {
    try {
      await _db.collection('docentes').add(data);
    } catch (e) {
      throw Exception('Error al agregar docente: $e');
    }
  }

  Future<void> updateDocente(
    String docenteId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection('docentes').doc(docenteId).update(data);
    } catch (e) {
      throw Exception('Error al actualizar docente: $e');
    }
  }

  Future<void> deleteDocente(String docenteId) async {
    try {
      await _db.collection('docentes').doc(docenteId).delete();
    } catch (e) {
      throw Exception('Error al eliminar docente: $e');
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
      throw Exception('Error al obtener total de estudiantes: $e');
    }
  }

  Future<Map<String, dynamic>> getEstadisticasHoy() async {
    try {
      // Aquí puedes implementar la lógica para obtener estadísticas del día
      // Por ahora retornamos datos de ejemplo
      return {
        'totalEstudiantes': 45,
        'asistenciasHoy': 38,
        'faltasHoy': 7,
        'tardanzasHoy': 3,
        'porcentajeAsistencia': 84.4,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCursosHoyStream() {
    // Ejemplo: obtener cursos para hoy
    return _db
        .collection('cursos')
        .where('fecha', isEqualTo: _getTodayString())
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getActividadesRecientesStream() {
    return _db
        .collection('asistencias')
        .orderBy('fecha', descending: true)
        .limit(10)
        .snapshots();
  }

  // -----------------------------------------------------------------
  // MÉTODOS GENERALES/UTILITARIOS
  // -----------------------------------------------------------------

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocumentById(
    String collection,
    String documentId,
  ) {
    return _db.collection(collection).doc(documentId).get();
  }

  Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).add(data);
    } catch (e) {
      throw Exception('Error al agregar documento a $collection: $e');
    }
  }

  // Método auxiliar para obtener la fecha de hoy como string
  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
