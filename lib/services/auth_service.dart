// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // OBJETIVO 1: Sistema de autenticación
  Future<Usuario?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return await _getUserData(result.user!.uid);
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  Future<Usuario?> _getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore
        .collection('usuarios')
        .doc(uid)
        .get();
    if (doc.exists) {
      return Usuario(
        id: uid,
        username: doc['username'],
        email: doc['email'],
        nombre: doc['nombre'],
        role: doc['role'],
        carnet: doc['carnet'],
        departamento: doc['departamento'],
        estaActivo: doc['estaActivo'],
        fechaRegistro: doc['fechaRegistro'].toDate(),
      );
    }
    return null;
  }

  Stream<Usuario?> get userStream => _auth.authStateChanges().asyncMap((user) {
    if (user != null) return _getUserData(user.uid);
    return null;
  });

  Future<void> signOut() async => await _auth.signOut();
}
