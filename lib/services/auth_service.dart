// services/auth_service.dart - VERSIÓN CORREGIDA Y LIMPIADA

import 'package:sqflite/sqflite.dart';
import '../models/database_helper.dart'; // Asegúrate de que esta ruta sea correcta
import '../models/usuario_model.dart';

// Importaciones con alias
import '../models/estudiante_model.dart' as estudiante_model;
import '../models/docente_model.dart' as docente_model;

class AuthService {
  // Patrón Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Propiedad de la Base de Datos (FALTABA en tu código)
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  // Estado de sesión
  Usuario? _currentUser;

  // ========== GETTERS PÚBLICOS ==========
  // Getter añadido para que otros servicios puedan acceder a la DB a través de AuthService.
  Future<Database> get database => _databaseHelper.database; 
  
  Usuario? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get userRole => _currentUser?.role;

  // ========== LOGIN MEJORADO ==========
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      print('🔐 AuthService: Iniciando login para $username');
      
      // Validaciones mejoradas
      if (username.isEmpty || password.isEmpty) {
        return _errorResponse('Por favor, completa todos los campos');
      }

      if (username.length < 3) {
        return _errorResponse('El usuario debe tener al menos 3 caracteres');
      }

      // Verificar en base de datos
      final userData = await _databaseHelper.verificarCredenciales(username, password);
      
      if (userData != null && userData.isNotEmpty) {
        final usuario = Usuario.fromLoginData(userData);
        
        // Verificar si el usuario está activo
        if (!usuario.estaActivo) {
          return _errorResponse('Tu cuenta está desactivada. Contacta al administrador.');
        }

        // Guardar sesión y usuario actual
        await _guardarSesion(usuario.id);
        _currentUser = usuario;
        
        print('✅ AuthService: Login exitoso para ${usuario.nombre} (${usuario.role})');
        
        return _successResponse(user: usuario);
      } else {
        return _errorResponse('Usuario o contraseña incorrectos');
      }
    } catch (e) {
      print('❌ AuthService Error: $e');
      return _errorResponse('Error del sistema: $e');
    }
  }

  // ========== REGISTRO AUTOMÁTICO DE USUARIOS ==========
  Future<Map<String, dynamic>> registrarUsuarioDesdeEstudiante(estudiante_model.Estudiante estudiante) async {
    try {
      final usuario = Usuario.fromEstudiante(estudiante);
      return await _registrarUsuarioEnBD(usuario);
    } catch (e) {
      return _errorResponse('Error registrando usuario estudiante: $e');
    }
  }

  Future<Map<String, dynamic>> registrarUsuarioDesdeDocente(docente_model.Docente docente) async {
    try {
      final usuario = Usuario.fromDocente(docente);
      return await _registrarUsuarioEnBD(usuario);
    } catch (e) {
      return _errorResponse('Error registrando usuario docente: $e');
    }
  }

  Future<Map<String, dynamic>> _registrarUsuarioEnBD(Usuario usuario) async {
    try {
      final db = await _databaseHelper.database; // ✅ Correcto, usando _databaseHelper

      // Verificar si el usuario ya existe
      final usuarioExistente = await db.query(
        'usuarios',
        where: 'username = ? OR email = ? OR carnet = ?',
        whereArgs: [usuario.username, usuario.email, usuario.carnet],
      );

      if (usuarioExistente.isNotEmpty) {
        return _errorResponse('El usuario, email o carnet ya están registrados');
      }

      // Insertar nuevo usuario
      final resultado = await db.insert('usuarios', usuario.toMap());
      
      if (resultado > 0) {
        // Actualizar estudiante/docente con el ID de usuario
        await _actualizarRelacionUsuario(usuario);
        
        return _successResponse(userId: usuario.id, user: usuario);
      } else {
        return _errorResponse('Error al crear el usuario en la base de datos');
      }
    } catch (e) {
      return _errorResponse('Error del sistema: $e');
    }
  }

  Future<void> _actualizarRelacionUsuario(Usuario usuario) async {
    final db = await _databaseHelper.database;
    
    if (usuario.role == 'estudiante') {
      // Extraer ID de estudiante del ID de usuario (est_123 -> 123)
      final estudianteId = usuario.id.replaceFirst('est_', '');
      await db.update(
        'estudiantes',
        {'usuario_id': usuario.id},
        where: 'id = ?',
        whereArgs: [estudianteId],
      );
    } else if (usuario.role == 'docente') {
      // Extraer ID de docente del ID de usuario (doc_123 -> 123)
      final docenteId = usuario.id.replaceFirst('doc_', '');
      await db.update(
        'docentes',
        {'usuario_id': usuario.id},
        where: 'id = ?',
        whereArgs: [docenteId],
      );
    }
  }

  // ========== GESTIÓN DE SESIÓN MEJORADA ==========
  Future<void> _guardarSesion(String userId) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert(
        'session_data',
        {
          'user_id': userId,
          'login_time': DateTime.now().toIso8601String(),
          'is_active': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('❌ Error guardando sesión: $e');
    }
  }

  Future<void> cargarSesionGuardada() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'session_data',
        where: 'is_active = 1',
        orderBy: 'login_time DESC',
        limit: 1,
      );

      if (result.isNotEmpty) {
        final userId = result.first['user_id']?.toString();
        if (userId != null) {
          final usuario = await obtenerUsuarioPorId(userId);
          if (usuario != null && usuario.estaActivo) {
            _currentUser = usuario;
            print('🔄 Sesión cargada: ${usuario.nombre}');
          }
        }
      }
    } catch (e) {
      print('❌ Error cargando sesión: $e');
    }
  }

  Future<void> cerrarSesion() async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'session_data',
        {'is_active': 0},
        where: 'is_active = 1',
      );
      _currentUser = null;
      print('🚪 Sesión cerrada');
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
    }
  }

  // ========== ACTUALIZACIÓN DE PERFIL MEJORADA ==========
  Future<Map<String, dynamic>> actualizarPerfil({
    required String userId,
    String? username,
    String? nombre,
    String? email,
    String? telefono,
    String? fotoUrl,
    String? password,
  }) async {
    try {
      final db = await _databaseHelper.database;

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) {
        // Verificar que el username no esté en uso
        final existing = await db.query(
          'usuarios',
          where: 'username = ? AND id != ?',
          whereArgs: [username, userId],
        );
        if (existing.isNotEmpty) {
          return _errorResponse('El nombre de usuario ya está en uso');
        }
        updateData['username'] = username;
      }
      
      if (nombre != null) updateData['nombre'] = nombre;
      if (email != null) updateData['email'] = email;
      if (telefono != null) updateData['telefono'] = telefono;
      if (fotoUrl != null) updateData['foto_url'] = fotoUrl;
      if (password != null) {
        if (password.length < 6) {
          return _errorResponse('La contraseña debe tener al menos 6 caracteres');
        }
        updateData['password'] = password;
      }

      final resultado = await db.update(
        'usuarios',
        updateData,
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (resultado > 0) {
        // Actualizar usuario actual en memoria
        if (_currentUser?.id == userId) {
          final usuarioActualizado = await obtenerUsuarioPorId(userId);
          if (usuarioActualizado != null) {
            _currentUser = usuarioActualizado;
          }
        }

        return _successResponse(user: _currentUser);
      } else {
        return _errorResponse('No se pudo actualizar el perfil');
      }
    } catch (e) {
      return _errorResponse('Error del sistema: $e');
    }
  }

  // ========== MÉTODOS AUXILIARES ==========
  Future<Usuario?> obtenerUsuarioPorId(String userId) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'usuarios',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (result.isNotEmpty) {
        return Usuario.fromLoginData(result.first);
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo usuario: $e');
      return null;
    }
  }

  Future<List<Usuario>> obtenerTodosLosUsuarios() async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        'usuarios',
        orderBy: 'fecha_registro DESC',
      );

      return results.map((data) => Usuario.fromLoginData(data)).toList();
    } catch (e) {
      print('❌ Error obteniendo usuarios: $e');
      return [];
    }
  }

  Future<bool> toggleEstadoUsuario(String userId, bool activo) async {
    try {
      final db = await _databaseHelper.database;
      final resultado = await db.update(
        'usuarios',
        {
          'esta_activo': activo ? 1 : 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      return resultado > 0;
    } catch (e) {
      print('❌ Error cambiando estado usuario: $e');
      return false;
    }
  }

// ========== MÉTODO CAMBIAR CONTRASEÑA ==========
Future<Map<String, dynamic>> cambiarContrasena({
  required String userId,
  required String contrasenaActual,
  required String nuevaContrasena,
}) async {
  try {
    final db = await _databaseHelper.database;

    // Verificar contraseña actual
    final usuario = await db.query(
      'usuarios',
      where: 'id = ? AND password = ?',
      whereArgs: [userId, contrasenaActual],
    );

    if (usuario.isEmpty) {
      return {
        'success': false,
        'error': 'La contraseña actual es incorrecta',
      };
    }

    // Validar nueva contraseña
    if (nuevaContrasena.length < 6) {
      return {
        'success': false,
        'error': 'La nueva contraseña debe tener al menos 6 caracteres',
      };
    }

    // Actualizar contraseña
    final resultado = await db.update(
      'usuarios',
      {
        'password': nuevaContrasena,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (resultado > 0) {
      return {
        'success': true,
        'error': null,
      };
    } else {
      return {
        'success': false,
        'error': 'Error al actualizar la contraseña',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Error del sistema: $e',
    };
  }
}

// ========== MÉTODO REGISTRAR USUARIO (PARA ADMIN) ==========
Future<Map<String, dynamic>> registrarUsuario({
  required String username,
  required String password,
  required String nombre,
  required String email,
  required String role,
  required String carnet,
  required String departamento,
  String? telefono,
}) async {
  try {
    final db = await _databaseHelper.database;

    // Verificar si el usuario ya existe
    final usuarioExistente = await db.query(
      'usuarios',
      where: 'username = ? OR email = ? OR carnet = ?',
      whereArgs: [username, email, carnet],
    );

    if (usuarioExistente.isNotEmpty) {
      return {
        'success': false,
        'error': 'El usuario, email o carnet ya están registrados',
        'userId': null,
      };
    }

    // Crear nuevo usuario
    final nuevoUsuario = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'username': username,
      'email': email,
      'nombre': nombre,
      'password': password,
      'role': role,
      'carnet': carnet,
      'departamento': departamento,
      'esta_activo': 1,
      'fecha_registro': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'telefono': telefono,
      'foto_url': null,
    };

    final resultado = await db.insert('usuarios', nuevoUsuario);
    
    if (resultado > 0) {
      return {
        'success': true,
        'error': null,
        'userId': nuevoUsuario['id'],
      };
    } else {
      return {
        'success': false,
        'error': 'Error al crear el usuario',
        'userId': null,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Error del sistema: $e',
      'userId': null,
    };
  }
}

// ========== MÉTODO OBTENER USUARIOS (ALIAS) ==========
Future<List<Usuario>> obtenerUsuarios() async {
  return await obtenerTodosLosUsuarios();
}

// ========== MÉTODO CAMBIAR ESTADO USUARIO (ALIAS) ==========
Future<bool> cambiarEstadoUsuario(String userId, bool activo) async {
  return await toggleEstadoUsuario(userId, activo);
}

  // ========== MÉTODOS DE RESPUESTA ==========
  Map<String, dynamic> _successResponse({String? userId, Usuario? user}) {
    return {
      'success': true,
      'error': null,
      'userId': userId,
      'user': user,
    };
  }

  Map<String, dynamic> _errorResponse(String error) {
    return {
      'success': false,
      'error': error,
      'userId': null,
      'user': null,
    };
  }
}