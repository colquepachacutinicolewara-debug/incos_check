// services/auth_service.dart
import 'package:sqflite/sqflite.dart';
import '../models/database_helper.dart';
import '../models/usuario_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // 🌟 LOGIN MEJORADO CON MÁS VALIDACIONES
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      print('🔐 AuthService: Iniciando login para $username');
      
      // Validaciones
      if (username.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'error': 'Por favor, completa todos los campos',
          'user': null,
        };
      }

      if (username.length < 3) {
        return {
          'success': false,
          'error': 'El usuario debe tener al menos 3 caracteres',
          'user': null,
        };
      }

      // Verificar en base de datos
      final userData = await _databaseHelper.verificarCredenciales(username, password);
      
      if (userData != null && userData.isNotEmpty) {
        final usuario = Usuario.fromLoginData(userData);
        
        // Verificar si el usuario está activo
        if (!usuario.estaActivo) {
          return {
            'success': false,
            'error': 'Tu cuenta está desactivada. Contacta al administrador.',
            'user': null,
          };
        }

        // Guardar sesión
        await _guardarSesion(usuario.id);
        
        print('✅ AuthService: Login exitoso para ${usuario.nombre}');
        
        return {
          'success': true,
          'error': null,
          'user': usuario,
        };
      } else {
        return {
          'success': false,
          'error': 'Usuario o contraseña incorrectos',
          'user': null,
        };
      }
    } catch (e) {
      print('❌ AuthService Error: $e');
      return {
        'success': false,
        'error': 'Error del sistema: $e',
        'user': null,
      };
    }
  }

  // 🌟 REGISTRO DE NUEVOS USUARIOS (PARA ADMIN)
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
        where: 'username = ? OR email = ?',
        whereArgs: [username, email],
      );

      if (usuarioExistente.isNotEmpty) {
        return {
          'success': false,
          'error': 'El usuario o email ya están registrados',
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

  // 🌟 ACTUALIZAR PERFIL MEJORADO
  Future<Map<String, dynamic>> actualizarPerfil({
    required String userId,
    String? username,
    String? nombre,
    String? email,
    String? telefono,
    String? fotoUrl,
  }) async {
    try {
      final db = await _databaseHelper.database;

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) updateData['username'] = username;
      if (nombre != null) updateData['nombre'] = nombre;
      if (email != null) updateData['email'] = email;
      if (telefono != null) updateData['telefono'] = telefono;
      if (fotoUrl != null) updateData['foto_url'] = fotoUrl;

      final resultado = await db.update(
        'usuarios',
        updateData,
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (resultado > 0) {
        // Obtener usuario actualizado
        final usuarioActualizado = await db.query(
          'usuarios',
          where: 'id = ?',
          whereArgs: [userId],
        );

        return {
          'success': true,
          'error': null,
          'user': usuarioActualizado.isNotEmpty 
              ? Usuario.fromLoginData(usuarioActualizado.first) 
              : null,
        };
      } else {
        return {
          'success': false,
          'error': 'No se pudo actualizar el perfil',
          'user': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error del sistema: $e',
        'user': null,
      };
    }
  }

  // 🌟 CAMBIO DE CONTRASEÑA MEJORADO
  Future<Map<String, dynamic>> cambiarPassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final db = await _databaseHelper.database;

      // Verificar contraseña actual
      final usuario = await db.query(
        'usuarios',
        where: 'id = ? AND password = ?',
        whereArgs: [userId, currentPassword],
      );

      if (usuario.isEmpty) {
        return {
          'success': false,
          'error': 'La contraseña actual es incorrecta',
        };
      }

      // Validar nueva contraseña
      if (newPassword.length < 6) {
        return {
          'success': false,
          'error': 'La nueva contraseña debe tener al menos 6 caracteres',
        };
      }

      // Actualizar contraseña
      final resultado = await db.update(
        'usuarios',
        {
          'password': newPassword,
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

  // 🌟 GESTIÓN DE SESIÓN MEJORADA
  Future<void> _guardarSesion(String userId) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert(
        'configuraciones',
        {
          'id': 'session_user',
          'value': userId,
          'last_updated': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('❌ Error guardando sesión: $e');
    }
  }

  Future<String?> obtenerSesionGuardada() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'configuraciones',
        where: 'id = ?',
        whereArgs: ['session_user'],
      );

      if (result.isNotEmpty) {
        return result.first['value']?.toString();
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo sesión: $e');
      return null;
    }
  }

  Future<void> cerrarSesion() async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'configuraciones',
        where: 'id = ?',
        whereArgs: ['session_user'],
      );
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
    }
  }

  // 🌟 OBTENER USUARIO POR ID
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

  // 🌟 LISTAR TODOS LOS USUARIOS (PARA ADMIN)
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

  // 🌟 ACTIVAR/DESACTIVAR USUARIO
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
}