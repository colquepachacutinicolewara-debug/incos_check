// services/permission_service.dart
import '../models/database_helper.dart';
import '../utils/permissions.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // 🌟 VERIFICAR PERMISO EN TIEMPO REAL
  Future<bool> verificarPermiso(String userId, String permission) async {
    try {
      final db = await _databaseHelper.database;
      
      // Obtener rol del usuario
      final userResult = await db.query(
        'usuarios',
        where: 'id = ? AND esta_activo = 1',
        whereArgs: [userId],
      );

      if (userResult.isEmpty) return false;

      final userRole = userResult.first['role']?.toString().toLowerCase() ?? '';
      return AppPermissions.hasPermission(userRole, permission);
    } catch (e) {
      print('❌ Error verificando permiso: $e');
      return false;
    }
  }

  // 🌟 OBTENER TODOS LOS PERMISOS DE UN USUARIO
  Future<List<String>> obtenerPermisosUsuario(String userId) async {
    try {
      final db = await _databaseHelper.database;
      
      final userResult = await db.query(
        'usuarios',
        where: 'id = ? AND esta_activo = 1',
        whereArgs: [userId],
      );

      if (userResult.isEmpty) return [];

      final userRole = userResult.first['role']?.toString().toLowerCase() ?? '';
      return AppPermissions.getPermissionsForRole(userRole);
    } catch (e) {
      print('❌ Error obteniendo permisos: $e');
      return [];
    }
  }

  // 🌟 VERIFICAR ACCESO A MÓDULO
  Future<bool> puedeAccederModulo(String userId, String modulo) async {
    final permissionMap = {
      'gestion': AppPermissions.ACCESS_GESTION,
      'asistencia': AppPermissions.ACCESS_ASISTENCIA,
      'reportes': AppPermissions.ACCESS_REPORTES,
      'configuracion': AppPermissions.ACCESS_CONFIGURACION,
    };

    final permission = permissionMap[modulo.toLowerCase()];
    if (permission == null) return false;

    return await verificarPermiso(userId, permission);
  }

  // 🌟 OBTENER MÓDULOS DISPONIBLES PARA USUARIO
  Future<Map<String, bool>> obtenerModulosDisponibles(String userId) async {
    try {
      final permisos = await obtenerPermisosUsuario(userId);
      
      return {
        'Gestión Académica': permisos.contains(AppPermissions.ACCESS_GESTION),
        'Registro de Asistencia': permisos.contains(AppPermissions.ACCESS_ASISTENCIA),
        'Reportes e Informes': permisos.contains(AppPermissions.ACCESS_REPORTES),
        'Configuración': permisos.contains(AppPermissions.ACCESS_CONFIGURACION),
      };
    } catch (e) {
      print('❌ Error obteniendo módulos: $e');
      return {};
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
      await db.insert('logs_seguridad', {
        'id': 'log_${DateTime.now().millisecondsSinceEpoch}',
        'usuario_id': userId,
        'modulo': modulo,
        'accion': accion,
        'fecha': DateTime.now().toIso8601String(),
        'tipo': 'ACCESO_NO_AUTORIZADO',
        'ip': 'local', // En una app real obtendrías la IP
        'dispositivo': 'mobile',
      });
    } catch (e) {
      print('❌ Error registrando log de seguridad: $e');
    }
  }
}