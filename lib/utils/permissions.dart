// utils/permissions.dart
class AppPermissions {
  // Permisos de módulos
  static const String ACCESS_DASHBOARD = 'access_dashboard';
  static const String ACCESS_GESTION = 'access_gestion';
  static const String ACCESS_ASISTENCIA = 'access_asistencia';
  static const String ACCESS_REPORTES = 'access_reportes';
  static const String ACCESS_CONFIGURACION = 'access_configuracion';

  // Permisos específicos de gestión
  static const String MANAGE_ESTUDIANTES = 'manage_estudiantes';
  static const String MANAGE_DOCENTES = 'manage_docentes';
  static const String MANAGE_CARRERAS = 'manage_carreras';
  static const String MANAGE_MATERIAS = 'manage_materias';
  static const String MANAGE_PARALELOS = 'manage_paralelos';
  static const String MANAGE_TURNOS = 'manage_turnos';
  static const String MANAGE_NIVELES = 'manage_niveles';
  static const String MANAGE_PERIODOS = 'manage_periodos';

  // Permisos de asistencia
  static const String REGISTER_ASISTENCIA = 'register_asistencia';
  static const String VIEW_HISTORIAL_ASISTENCIA = 'view_historial_asistencia';
  static const String MANAGE_BIOMETRICO = 'manage_biometrico';

  // Permisos de reportes
  static const String GENERATE_REPORTES = 'generate_reportes';
  static const String EXPORT_DATA = 'export_data';
  static const String VIEW_STATISTICS = 'view_statistics';

  // Permisos de configuración
  static const String MANAGE_USUARIOS = 'manage_usuarios';
  static const String MANAGE_CONFIGURACION = 'manage_configuracion';
  static const String MANAGE_BACKUPS = 'manage_backups';
  static const String VIEW_LOGS = 'view_logs';

  // Mapeo de roles a permisos
  static Map<String, List<String>> rolePermissions = {
    'administrador': [
      ACCESS_DASHBOARD,
      ACCESS_GESTION,
      ACCESS_ASISTENCIA,
      ACCESS_REPORTES,
      ACCESS_CONFIGURACION,
      MANAGE_ESTUDIANTES,
      MANAGE_DOCENTES,
      MANAGE_CARRERAS,
      MANAGE_MATERIAS,
      MANAGE_PARALELOS,
      MANAGE_TURNOS,
      MANAGE_NIVELES,
      MANAGE_PERIODOS,
      REGISTER_ASISTENCIA,
      VIEW_HISTORIAL_ASISTENCIA,
      MANAGE_BIOMETRICO,
      GENERATE_REPORTES,
      EXPORT_DATA,
      VIEW_STATISTICS,
      MANAGE_USUARIOS,
      MANAGE_CONFIGURACION,
      MANAGE_BACKUPS,
      VIEW_LOGS,
    ],
    'director académico': [
      ACCESS_DASHBOARD,
      ACCESS_GESTION,
      ACCESS_ASISTENCIA,
      ACCESS_REPORTES,
      ACCESS_CONFIGURACION,
      MANAGE_ESTUDIANTES,
      MANAGE_DOCENTES,
      MANAGE_CARRERAS,
      MANAGE_MATERIAS,
      VIEW_HISTORIAL_ASISTENCIA,
      GENERATE_REPORTES,
      EXPORT_DATA,
      VIEW_STATISTICS,
      VIEW_LOGS,
    ],
    'jefe de carrera': [
      ACCESS_DASHBOARD,
      ACCESS_GESTION,
      ACCESS_ASISTENCIA,
      ACCESS_REPORTES,
      MANAGE_ESTUDIANTES,
      MANAGE_DOCENTES,
      MANAGE_MATERIAS,
      VIEW_HISTORIAL_ASISTENCIA,
      GENERATE_REPORTES,
      VIEW_STATISTICS,
    ],
    'docente': [
      ACCESS_DASHBOARD,
      ACCESS_ASISTENCIA,
      ACCESS_REPORTES,
      REGISTER_ASISTENCIA,
      VIEW_HISTORIAL_ASISTENCIA,
      GENERATE_REPORTES,
      VIEW_STATISTICS,
    'view_own_students',
    ],
    'estudiante': [
      ACCESS_DASHBOARD,
      VIEW_HISTORIAL_ASISTENCIA,
    ],
  };

  // Verificar si un rol tiene un permiso específico
  static bool hasPermission(String role, String permission) {
    final permissions = rolePermissions[role.toLowerCase()] ?? [];
    return permissions.contains(permission);
  }

  // Obtener todos los permisos de un rol
  static List<String> getPermissionsForRole(String role) {
    return rolePermissions[role.toLowerCase()] ?? [];
  }

  // Verificar múltiples permisos
  static bool hasAnyPermission(String role, List<String> permissions) {
    for (final permission in permissions) {
      if (hasPermission(role, permission)) {
        return true;
      }
    }
    return false;
  }

  static bool hasAllPermissions(String role, List<String> permissions) {
    for (final permission in permissions) {
      if (!hasPermission(role, permission)) {
        return false;
      }
    }
    return true;
  }

  // Obtener roles disponibles
  static List<String> get availableRoles => rolePermissions.keys.toList();

  // Obtener descripción del rol
  static String getRoleDescription(String role) {
    switch (role.toLowerCase()) {
      case 'administrador':
        return 'Acceso completo a todos los módulos del sistema';
      case 'director académico':
        return 'Puede gestionar datos académicos y ver reportes';
      case 'jefe de carrera':
        return 'Puede gestionar estudiantes y docentes de su carrera';
      case 'docente':
        return 'Puede registrar asistencia y generar reportes';
      case 'estudiante':
        return 'Puede consultar su historial de asistencia';
      default:
        return 'Rol no definido';
    }
  }
}