import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gestion_model.dart';
import 'package:flutter/material.dart';

class GestionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Colecciones
  static const String carrerasCollection = 'carreras';
  static const String estudiantesCollection = 'estudiantes';
  static const String docentesCollection = 'docentes';
  static const String cursosCollection = 'cursos';
  static const String turnosCollection = 'turnos';
  static const String paralelosCollection = 'paralelos';
  static const String nivelesCollection = 'niveles';

  // ========== CARRERAS ==========
  Future<List<CarreraConfig>> getCarreras() async {
    try {
      final snapshot = await _firestore
          .collection(carrerasCollection)
          .where('activa', isEqualTo: true)
          .orderBy('nombre')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CarreraConfig(
          id: data['id'] ?? doc.id.hashCode,
          nombre: data['nombre'] ?? 'Sin nombre',
          color: data['color'] ?? '#1565C0',
          icon: _getIconFromCode(data['icon'] ?? Icons.school.codePoint),
          activa: data['activa'] ?? true,
        );
      }).toList();
    } catch (e) {
      print('Error getting carreras: $e');
      return _getCarrerasDefault();
    }
  }

  Future<void> addCarrera(CarreraConfig carrera) async {
    try {
      await _firestore.collection(carrerasCollection).add(carrera.toMap());
    } catch (e) {
      print('Error adding carrera: $e');
      throw Exception('No se pudo agregar la carrera');
    }
  }

  Future<void> updateCarrera(String docId, CarreraConfig carrera) async {
    try {
      await _firestore
          .collection(carrerasCollection)
          .doc(docId)
          .update(carrera.toMap());
    } catch (e) {
      print('Error updating carrera: $e');
      throw Exception('No se pudo actualizar la carrera');
    }
  }

  Future<void> deleteCarrera(String docId) async {
    try {
      await _firestore.collection(carrerasCollection).doc(docId).delete();
    } catch (e) {
      print('Error deleting carrera: $e');
      throw Exception('No se pudo eliminar la carrera');
    }
  }

  // ========== ESTUDIANTES ==========
  Future<int> getEstudiantesCount(String carrera) async {
    try {
      final snapshot = await _firestore
          .collection(estudiantesCollection)
          .where('carrera', isEqualTo: carrera)
          .where('activo', isEqualTo: true)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting estudiantes count: $e');
      return 0;
    }
  }

  // ========== DOCENTES ==========
  Future<int> getDocentesCount(String carrera) async {
    try {
      final snapshot = await _firestore
          .collection(docentesCollection)
          .where('carrera', isEqualTo: carrera)
          .where('activo', isEqualTo: true)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting docentes count: $e');
      return 0;
    }
  }

  // ========== CURSOS ==========
  Future<int> getCursosCount(String carrera) async {
    try {
      final snapshot = await _firestore
          .collection(cursosCollection)
          .where('carrera', isEqualTo: carrera)
          .where('activo', isEqualTo: true)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting cursos count: $e');
      return 0;
    }
  }

  // ========== TURNOS ==========
  Future<int> getTurnosCount(String carrera) async {
    try {
      final snapshot = await _firestore
          .collection(turnosCollection)
          .where('carrera', isEqualTo: carrera)
          .where('activo', isEqualTo: true)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting turnos count: $e');
      return 0;
    }
  }

  Future<List<String>> getTurnos(String carrera) async {
    try {
      final snapshot = await _firestore
          .collection(turnosCollection)
          .where('carrera', isEqualTo: carrera)
          .where('activo', isEqualTo: true)
          .orderBy('nombre')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['nombre'] as String)
          .toList();
    } catch (e) {
      print('Error getting turnos: $e');
      return ['Mañana', 'Tarde', 'Noche'];
    }
  }

  Future<void> addTurno(String carrera, String turno) async {
    try {
      await _firestore.collection(turnosCollection).add({
        'carrera': carrera,
        'nombre': turno,
        'activo': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding turno: $e');
      throw Exception('No se pudo agregar el turno');
    }
  }

  Future<void> deleteTurno(String docId) async {
    try {
      await _firestore.collection(turnosCollection).doc(docId).update({
        'activo': false,
      });
    } catch (e) {
      print('Error deleting turno: $e');
      throw Exception('No se pudo eliminar el turno');
    }
  }

  // ========== PARALELOS ==========
  Future<int> getParalelosCount(String carrera) async {
    try {
      final snapshot = await _firestore
          .collection(paralelosCollection)
          .where('carrera', isEqualTo: carrera)
          .where('activo', isEqualTo: true)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting paralelos count: $e');
      return 0;
    }
  }

  Future<List<String>> getParalelos(String carrera) async {
    try {
      final snapshot = await _firestore
          .collection(paralelosCollection)
          .where('carrera', isEqualTo: carrera)
          .where('activo', isEqualTo: true)
          .orderBy('nombre')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['nombre'] as String)
          .toList();
    } catch (e) {
      print('Error getting paralelos: $e');
      return ['A', 'B', 'C'];
    }
  }

  Future<void> addParalelo(String carrera, String paralelo) async {
    try {
      await _firestore.collection(paralelosCollection).add({
        'carrera': carrera,
        'nombre': paralelo,
        'activo': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding paralelo: $e');
      throw Exception('No se pudo agregar el paralelo');
    }
  }

  Future<void> deleteParalelo(String docId) async {
    try {
      await _firestore.collection(paralelosCollection).doc(docId).update({
        'activo': false,
      });
    } catch (e) {
      print('Error deleting paralelo: $e');
      throw Exception('No se pudo eliminar el paralelo');
    }
  }

  // ========== NIVELES ==========
  Future<int> getNivelesCount(String carrera) async {
    try {
      final snapshot = await _firestore
          .collection(nivelesCollection)
          .where('carrera', isEqualTo: carrera)
          .where('activo', isEqualTo: true)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting niveles count: $e');
      return 0;
    }
  }

  Future<List<String>> getNiveles(String carrera) async {
    try {
      final snapshot = await _firestore
          .collection(nivelesCollection)
          .where('carrera', isEqualTo: carrera)
          .where('activo', isEqualTo: true)
          .orderBy('orden')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['nombre'] as String)
          .toList();
    } catch (e) {
      print('Error getting niveles: $e');
      return ['Primero', 'Segundo', 'Tercero', 'Cuarto', 'Quinto', 'Sexto'];
    }
  }

  // ========== HELPERS ==========
  IconData _getIconFromCode(int codePoint) {
    try {
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.school;
    }
  }

  List<CarreraConfig> _getCarrerasDefault() {
    return [
      CarreraConfig(
        id: 1,
        nombre: 'Sistemas Informáticos',
        color: '#1565C0',
        icon: Icons.computer,
        activa: true,
      ),
      CarreraConfig(
        id: 2,
        nombre: 'Idioma Inglés',
        color: '#F44336',
        icon: Icons.language,
        activa: true,
      ),
    ];
  }
}