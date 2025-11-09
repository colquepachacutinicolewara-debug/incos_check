// services/auth_service.dart - CORREGIDO
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // OBJETIVO 1: Sistema de autenticación seguro con roles
  Future<Usuario?> signInWithEmailPassword(String email, String password) async {
    try {
      // 1. Autenticar con Firebase Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Obtener datos del usuario desde Firestore
      Usuario? usuario = await _getUserData(result.user!.uid);

      if (usuario != null) {
        // 3. Verificar que el usuario esté activo
        if (!usuario.estaActivo) {
          await _auth.signOut();
          throw Exception('Usuario desactivado. Contacte al administrador.');
        }

        // 4. Actualizar último acceso
        await _updateLastAccess(usuario.id);

        return usuario;
      } else {
        await _auth.signOut();
        throw Exception('Usuario no encontrado en el sistema.');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<Usuario?> _getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('usuarios')
          .doc(uid)
          .get();
          
      if (doc.exists) {
        return Usuario.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener datos del usuario: $e');
    }
  }

  Future<void> _updateLastAccess(String uid) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        'ultimoAcceso': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error actualizando último acceso: $e');
    }
  }

  // Manejo de errores de autenticación
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-email':
        return 'El formato del correo electrónico es inválido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido desactivada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intente más tarde.';
      case 'network-request-failed':
        return 'Error de conexión. Verifique su internet.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }

  // Registrar nuevo usuario (solo para administradores)
  Future<Usuario> registerUser({
    required String email,
    required String password,
    required String nombre,
    required String role,
    required String carnet,
    String? departamento,
    String? carrera,
    String? telefono,
  }) async {
    try {
      // 1. Crear usuario en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Crear documento en Firestore
      final usuario = Usuario(
        id: userCredential.user!.uid,
        username: email.split('@').first,
        email: email,
        nombre: nombre,
        role: role,
        carnet: carnet,
        departamento: departamento,
        carrera: carrera,
        telefono: telefono,
        estaActivo: true,
        fechaRegistro: DateTime.now(),
        // ✅ CORREGIDO: Usar el método público
        permisos: Usuario.getDefaultPermissions(role),
      );

      await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set(usuario.toFirestore());

      return usuario;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  // Cambiar contraseña
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Reautenticar antes de cambiar contraseña
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream de cambios de estado de autenticación
  Stream<Usuario?> get userStream => _auth.authStateChanges().asyncMap((user) {
    if (user != null) {
      return _getUserData(user.uid);
    }
    return null;
  });

  // Verificar si el usuario actual tiene un permiso específico
  Future<bool> currentUserHasPermission(String permission) async {
    final user = _auth.currentUser;
    if (user != null) {
      final usuario = await _getUserData(user.uid);
      return usuario?.tienePermiso(permission) ?? false;
    }
    return false;
  }

  // Obtener usuario actual
  Future<Usuario?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _getUserData(user.uid);
    }
    return null;
  }

  // ✅ NUEVO: Método para crear el usuario SuperAdmin inicial
  Future<void> createInitialSuperAdmin() async {
    try {
      // Verificar si ya existe un SuperAdmin
      final superAdminSnapshot = await _firestore
          .collection('usuarios')
          .where('role', isEqualTo: 'SuperAdmin')
          .limit(1)
          .get();

      if (superAdminSnapshot.docs.isEmpty) {
        // Crear el SuperAdmin inicial (Tú)
        await registerUser(
          email: 'colquepachacuti@gmail.com', // Cambia por tu email
          password: 'Admin123!', // Cambia por una contraseña segura
          nombre: 'Nicole Wara Colque Pachacuti',
          role: 'SuperAdmin',
          carnet: '75205630',
          departamento: 'Sistemas Informáticos',
          telefono: '+59175205630',
        );
        print('✅ SuperAdmin creado exitosamente');
      } else {
        print('ℹ️ SuperAdmin ya existe en el sistema');
      }
    } catch (e) {
      print('❌ Error creando SuperAdmin: $e');
    }
  }
}