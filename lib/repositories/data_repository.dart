import 'package:cloud_firestore/cloud_firestore.dart';

// Este repositorio es la única clase que debe conocer los nombres de las colecciones
// y el API de Cloud Firestore.
class DataRepository {
  // Inicializa la instancia de Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -----------------------------------------------------------------
  // MÉTODOS PARA CarrerasViewModel
  // -----------------------------------------------------------------

  /// Obtiene un Stream de QuerySnapshot de la colección 'carreras'.
  /// Se usa para escuchar cambios en tiempo real.
  Stream<QuerySnapshot> getCarrerasStream() {
    // Usamos orderBy para asegurar un orden consistente
    // NOTA: Para consultas con orderBy, asegúrate de tener índices en Firestore si usas where()
    return _db
        .collection('carreras')
        .orderBy('nombre', descending: false)
        .snapshots();
  }

  /// Agrega un nuevo documento a la colección 'carreras'.
  // CORRECCIÓN: Usamos await para que la operación se complete,
  // pero no retornamos el DocumentReference.
  Future<void> addCarrera(Map<String, dynamic> data) async {
    await _db.collection('carreras').add(data);
    // Como no retorna nada, el método cumple con Future<void>
    return;
  }

  // -----------------------------------------------------------------
  // MÉTODOS PARA DocenteViewModel
  // -----------------------------------------------------------------

  /// Obtiene un Stream de QuerySnapshot de la colección 'docentes'.
  Stream<QuerySnapshot> getDocentesStream() {
    return _db
        .collection('docentes')
        .orderBy('apellido', descending: false)
        .snapshots();
  }

  /// Obtiene los datos de un docente específico una sola vez (Future).
  Future<DocumentSnapshot> getDocenteById(String docenteId) {
    return _db.collection('docentes').doc(docenteId).get();
  }
}
