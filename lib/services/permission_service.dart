// services/permission_service.dart - VERSIÓN CORREGIDA
import '../models/database_helper.dart';
import '../utils/permissions.dart';

class PermissionService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // 🌟 OBTENER PERMISOS DE USUARIO
  Future<List<String>> obtenerPermisosUsuario(String userId) async {
    try {
      final db = await _databaseHelper.database;
      
      // Obtener el rol del usuario
      final userResult = await db.query(
        'usuarios',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (userResult.isEmpty) {
        return [];
      }

      final userRole = userResult.first['role']?.toString() ?? 'estudiante';
      
      // Obtener permisos del rol
      return AppPermissions.getPermissionsForRole(userRole);
    } catch (e) {
      print('❌ Error obteniendo permisos: $e');
      return [];
    }
  }

  // 🌟 OBTENER MÓDULOS DISPONIBLES
  Future<Map<String, bool>> obtenerModulosDisponibles(String userId) async {
    try {
      final permisos = await obtenerPermisosUsuario(userId);
      
      return {
        'Gestión': permisos.any((p) => [
          AppPermissions.MANAGE_ESTUDIANTES,
          AppPermissions.MANAGE_DOCENTES,
          AppPermissions.MANAGE_CARRERAS,
          AppPermissions.MANAGE_MATERIAS,
        ].contains(p)),
        'Asistencia': permisos.any((p) => [
          AppPermissions.REGISTER_ASISTENCIA,
          AppPermissions.VIEW_HISTORIAL_ASISTENCIA,
          AppPermissions.TAKE_ATTENDANCE,
        ].contains(p)),
        'Reportes': permisos.any((p) => [
          AppPermissions.GENERATE_REPORTES,
          AppPermissions.VIEW_STATISTICS,
        ].contains(p)),
        'Configuración': permisos.any((p) => [
          AppPermissions.MANAGE_USUARIOS,
          AppPermissions.MANAGE_CONFIGURACION,
        ].contains(p)),
      };
    } catch (e) {
      print('❌ Error obteniendo módulos: $e');
      return {};
    }
  }

  // 🌟 VERIFICAR PERMISO ESPECÍFICO
  Future<bool> verificarPermiso(String userId, String permission) async {
    try {
      final permisos = await obtenerPermisosUsuario(userId);
      return permisos.contains(permission);
    } catch (e) {
      print('❌ Error verificando permiso: $e');
      return false;
    }
  }

  // 🌟 REGISTRAR INTENTO DE ACCESO NO AUTORIZADO
  Future<void> registrarIntentoAccesoNoAutorizado({
    required String userId,
    required String modulo,
    required String accion,
  }) async {
    try {
      final db = await _databaseHelper.database;
      
      // Verificar si la tabla logs_acceso existe
      try {
        await db.insert('logs_acceso', {
          'user_id': userId,
          'modulo': modulo,
          'accion': accion,
          'fecha': DateTime.now().toIso8601String(),
          'autorizado': 0,
          'ip': 'local',
        });
        
        print('🚫 Intento de acceso no autorizado registrado: $userId - $modulo - $accion');
      } catch (e) {
        // Si la tabla no existe, solo loguear
        print('⚠️ Tabla logs_acceso no disponible: $e');
      }
    } catch (e) {
      print('❌ Error registrando intento de acceso: $e');
    }
  }
}