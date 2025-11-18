// services/user_service.dart - VERSIÓN CORREGIDA
import 'package:sqflite/sqflite.dart';
import '../models/database_helper.dart';
import '../models/usuario_model.dart';
import '../utils/permissions.dart';
import '../services/auth_service.dart';

// Importaciones con alias
import '../models/estudiante_model.dart' as estudiante_model;
import '../models/docente_model.dart' as docente_model;

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final AuthService _authService = AuthService();

  // ========== CREACIÓN AUTOMÁTICA DE USUARIOS ==========
  Future<Map<String, dynamic>> crearUsuarioAutomatico({
    required dynamic entidad, // Puede ser Estudiante o Docente
    required String role,
  }) async {
    try {
      Usuario usuario;
      
      if (entidad is estudiante_model.Estudiante) {
        usuario = Usuario.fromEstudiante(entidad);
        return await _authService.registrarUsuarioDesdeEstudiante(entidad);
      } else if (entidad is docente_model.Docente) {
        usuario = Usuario.fromDocente(entidad);
        return await _authService.registrarUsuarioDesdeDocente(entidad);
      } else {
        return {'success': false, 'error': 'Tipo de entidad no válido'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error creando usuario: $e'};
    }
  }

  // ========== GESTIÓN DE USUARIOS POR ROL ==========
  Future<List<Usuario>> obtenerUsuariosPorRol(String role) async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        'usuarios',
        where: 'role = ?',
        whereArgs: [role],
        orderBy: 'nombre ASC',
      );

      return results.map((data) => Usuario.fromLoginData(data)).toList();
    } catch (e) {
      print('❌ Error obteniendo usuarios por rol: $e');
      return [];
    }
  }

  Future<List<Usuario>> obtenerUsuariosActivos() async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        'usuarios',
        where: 'esta_activo = 1',
        orderBy: 'role, nombre ASC',
      );

      return results.map((data) => Usuario.fromLoginData(data)).toList();
    } catch (e) {
      print('❌ Error obteniendo usuarios activos: $e');
      return [];
    }
  }

  // ========== BÚSQUEDA Y FILTRADO ==========
  Future<List<Usuario>> buscarUsuarios(String query) async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        'usuarios',
        where: 'nombre LIKE ? OR username LIKE ? OR email LIKE ? OR carnet LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
        orderBy: 'nombre ASC',
      );

      return results.map((data) => Usuario.fromLoginData(data)).toList();
    } catch (e) {
      print('❌ Error buscando usuarios: $e');
      return [];
    }
  }

  Future<List<Usuario>> filtrarUsuarios({
    String? role,
    bool? activo,
    String? departamento,
  }) async {
    try {
      final db = await _databaseHelper.database;
      
      var where = '1=1';
      final whereArgs = <String>[];

      if (role != null) {
        where += ' AND role = ?';
        whereArgs.add(role);
      }

      if (activo != null) {
        where += ' AND esta_activo = ?';
        whereArgs.add(activo ? '1' : '0');
      }

      if (departamento != null) {
        where += ' AND departamento = ?';
        whereArgs.add(departamento);
      }

      final results = await db.query(
        'usuarios',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'role, nombre ASC',
      );

      return results.map((data) => Usuario.fromLoginData(data)).toList();
    } catch (e) {
      print('❌ Error filtrando usuarios: $e');
      return [];
    }
  }

  // ========== ESTADÍSTICAS DE USUARIOS ==========
  Future<Map<String, dynamic>> obtenerEstadisticasUsuarios() async {
    try {
      final db = await _databaseHelper.database;
      
      final totalUsuarios = await db.rawQuery(
        'SELECT COUNT(*) as total FROM usuarios'
      );
      
      final usuariosPorRol = await db.rawQuery(
        'SELECT role, COUNT(*) as count FROM usuarios GROUP BY role'
      );
      
      final usuariosActivos = await db.rawQuery(
        'SELECT COUNT(*) as activos FROM usuarios WHERE esta_activo = 1'
      );

      return {
        'total': totalUsuarios.first['total'] as int? ?? 0,
        'activos': usuariosActivos.first['activos'] as int? ?? 0,
        'por_rol': {
          for (var row in usuariosPorRol)
            row['role'] as String: row['count'] as int
        },
      };
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return {'total': 0, 'activos': 0, 'por_rol': {}};
    }
  }

  // ========== VERIFICACIÓN DE PERMISOS ==========
  Future<bool> usuarioPuedeAcceder(String userId, String permission) async {
    try {
      final usuario = await _authService.obtenerUsuarioPorId(userId);
      return usuario?.tienePermiso(permission) ?? false;
    } catch (e) {
      print('❌ Error verificando permisos: $e');
      return false;
    }
  }

  Future<List<String>> obtenerPermisosUsuario(String userId) async {
    try {
      final usuario = await _authService.obtenerUsuarioPorId(userId);
      return usuario?.permisos ?? [];
    } catch (e) {
      print('❌ Error obteniendo permisos: $e');
      return [];
    }
  }

  // ========== GENERACIÓN DE REPORTES ==========
  Future<List<Map<String, dynamic>>> generarReporteUsuarios() async {
    try {
      final usuarios = await obtenerTodosLosUsuarios();
      
      return usuarios.map((usuario) {
        return {
          'id': usuario.id,
          'nombre': usuario.nombre,
          'username': usuario.username,
          'email': usuario.email,
          'role': usuario.role,
          'carnet': usuario.carnet,
          'departamento': usuario.departamento,
          'activo': usuario.estaActivo,
          'fecha_registro': usuario.fechaRegistro.toIso8601String(),
          'telefono': usuario.telefono,
        };
      }).toList();
    } catch (e) {
      print('❌ Error generando reporte: $e');
      return [];
    }
  }

  // ========== MÉTODOS AUXILIARES ==========
  Future<List<Usuario>> obtenerTodosLosUsuarios() async {
    return await _authService.obtenerTodosLosUsuarios();
  }

  Future<Usuario?> obtenerUsuarioPorId(String userId) async {
    return await _authService.obtenerUsuarioPorId(userId);
  }

  Future<bool> actualizarUsuario(Usuario usuario) async {
    try {
      final db = await _databaseHelper.database;
      final resultado = await db.update(
        'usuarios',
        usuario.toMap(),
        where: 'id = ?',
        whereArgs: [usuario.id],
      );
      return resultado > 0;
    } catch (e) {
      print('❌ Error actualizando usuario: $e');
      return false;
    }
  }

  Future<bool> eliminarUsuario(String userId) async {
    try {
      final db = await _databaseHelper.database;
      final resultado = await db.delete(
        'usuarios',
        where: 'id = ?',
        whereArgs: [userId],
      );
      return resultado > 0;
    } catch (e) {
      print('❌ Error eliminando usuario: $e');
      return false;
    }
  }
}