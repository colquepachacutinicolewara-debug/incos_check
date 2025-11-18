import 'package:flutter/material.dart';
// utils/permissions.dart - VERSIÓN MEJORADA Y COMPLETA
class AppPermissions {
  // ========== MÓDULOS PRINCIPALES ==========
  static const String ACCESS_DASHBOARD = 'access_dashboard';
  static const String ACCESS_GESTION = 'access_gestion';
  static const String ACCESS_ASISTENCIA = 'access_asistencia';
  static const String ACCESS_REPORTES = 'access_reportes';
  static const String ACCESS_CONFIGURACION = 'access_configuracion';

  // ========== GESTIÓN ACADÉMICA ==========
  static const String MANAGE_ESTUDIANTES = 'manage_estudiantes';
  static const String MANAGE_DOCENTES = 'manage_docentes';
  static const String MANAGE_CARRERAS = 'manage_carreras';
  static const String MANAGE_MATERIAS = 'manage_materias';
  static const String MANAGE_PARALELOS = 'manage_paralelos';
  static const String MANAGE_TURNOS = 'manage_turnos';
  static const String MANAGE_NIVELES = 'manage_niveles';
  static const String MANAGE_PERIODOS = 'manage_periodos';
  static const String MANAGE_HORARIOS = 'manage_horarios';

  // ========== ASISTENCIA ==========
  static const String REGISTER_ASISTENCIA = 'register_asistencia';
  static const String VIEW_HISTORIAL_ASISTENCIA = 'view_historial_asistencia';
  static const String MANAGE_BIOMETRICO = 'manage_biometrico';
  static const String TAKE_ATTENDANCE = 'take_attendance';
  static const String VIEW_OWN_ATTENDANCE = 'view_own_attendance';

  // ========== REPORTES ==========
  static const String GENERATE_REPORTES = 'generate_reportes';
  static const String EXPORT_DATA = 'export_data';
  static const String VIEW_STATISTICS = 'view_statistics';
  static const String VIEW_GLOBAL_REPORTS = 'view_global_reports';

  // ========== CONFIGURACIÓN ==========
  static const String MANAGE_USUARIOS = 'manage_usuarios';
  static const String MANAGE_CONFIGURACION = 'manage_configuracion';
  static const String MANAGE_BACKUPS = 'manage_backups';
  static const String VIEW_LOGS = 'view_logs';
  static const String SYSTEM_ADMIN = 'system_admin';

  // ========== PERMISOS ESPECÍFICOS POR ROL ==========
  static Map<String, List<String>> rolePermissions = {
    'administrador': [
      // Módulos
      ACCESS_DASHBOARD, ACCESS_GESTION, ACCESS_ASISTENCIA, ACCESS_REPORTES, ACCESS_CONFIGURACION,
      // Gestión académica
      MANAGE_ESTUDIANTES, MANAGE_DOCENTES, MANAGE_CARRERAS, MANAGE_MATERIAS, 
      MANAGE_PARALELOS, MANAGE_TURNOS, MANAGE_NIVELES, MANAGE_PERIODOS, MANAGE_HORARIOS,
      // Asistencia
      REGISTER_ASISTENCIA, VIEW_HISTORIAL_ASISTENCIA, MANAGE_BIOMETRICO, TAKE_ATTENDANCE,
      // Reportes
      GENERATE_REPORTES, EXPORT_DATA, VIEW_STATISTICS, VIEW_GLOBAL_REPORTS,
      // Configuración
      MANAGE_USUARIOS, MANAGE_CONFIGURACION, MANAGE_BACKUPS, VIEW_LOGS, SYSTEM_ADMIN,
    ],

    'director académico': [
      ACCESS_DASHBOARD, ACCESS_GESTION, ACCESS_ASISTENCIA, ACCESS_REPORTES,
      MANAGE_ESTUDIANTES, MANAGE_DOCENTES, MANAGE_CARRERAS, MANAGE_MATERIAS,
      VIEW_HISTORIAL_ASISTENCIA, GENERATE_REPORTES, EXPORT_DATA, 
      VIEW_STATISTICS, VIEW_GLOBAL_REPORTS, VIEW_LOGS,
    ],

    'jefe de carrera': [
      ACCESS_DASHBOARD, ACCESS_GESTION, ACCESS_ASISTENCIA, ACCESS_REPORTES,
      MANAGE_ESTUDIANTES, MANAGE_DOCENTES, MANAGE_MATERIAS, MANAGE_HORARIOS,
      VIEW_HISTORIAL_ASISTENCIA, GENERATE_REPORTES, VIEW_STATISTICS,
    ],

    'docente': [
      ACCESS_DASHBOARD, ACCESS_ASISTENCIA, ACCESS_REPORTES,
      REGISTER_ASISTENCIA, VIEW_HISTORIAL_ASISTENCIA, TAKE_ATTENDANCE,
      GENERATE_REPORTES, VIEW_STATISTICS, VIEW_OWN_ATTENDANCE,
    ],

    'estudiante': [
      ACCESS_DASHBOARD, VIEW_OWN_ATTENDANCE,
    ],
  };

  // ========== MÉTODOS DE VERIFICACIÓN MEJORADOS ==========
  static bool hasPermission(String role, String permission) {
    final permissions = rolePermissions[role.toLowerCase()] ?? [];
    return permissions.contains(permission);
  }

  static List<String> getPermissionsForRole(String role) {
    return rolePermissions[role.toLowerCase()] ?? [];
  }

  static bool hasAnyPermission(String role, List<String> permissions) {
    return permissions.any((permission) => hasPermission(role, permission));
  }

  static bool hasAllPermissions(String role, List<String> permissions) {
    return permissions.every((permission) => hasPermission(role, permission));
  }

  // 🌟 GRUPOS DE PERMISOS PARA VERIFICACIÓN DE MÓDULOS
  static List<String> get gestionPermisos => [
    MANAGE_ESTUDIANTES, MANAGE_DOCENTES, MANAGE_CARRERAS, MANAGE_MATERIAS,
    MANAGE_PARALELOS, MANAGE_TURNOS, MANAGE_NIVELES, MANAGE_PERIODOS, MANAGE_HORARIOS,
  ];

  static List<String> get asistenciaPermisos => [
    REGISTER_ASISTENCIA, VIEW_HISTORIAL_ASISTENCIA, MANAGE_BIOMETRICO, TAKE_ATTENDANCE,
  ];

  static List<String> get reportesPermisos => [
    GENERATE_REPORTES, EXPORT_DATA, VIEW_STATISTICS, VIEW_GLOBAL_REPORTS,
  ];

  static List<String> get configuracionPermisos => [
    MANAGE_USUARIOS, MANAGE_CONFIGURACION, MANAGE_BACKUPS, VIEW_LOGS, SYSTEM_ADMIN,
  ];
  
  // ========== VERIFICACIÓN POR MÓDULO ==========
  static bool canAccessGestion(String role) => hasAnyPermission(role, gestionPermisos);
  static bool canAccessAsistencia(String role) => hasAnyPermission(role, asistenciaPermisos);
  static bool canAccessReportes(String role) => hasAnyPermission(role, reportesPermisos);
  static bool canAccessConfiguracion(String role) => hasAnyPermission(role, configuracionPermisos);

  // ========== INFORMACIÓN DE ROLES ==========
  static List<String> get availableRoles => rolePermissions.keys.toList();

  static String getRoleDescription(String role) {
    switch (role.toLowerCase()) {
      case 'administrador':
        return 'Acceso completo a todos los módulos y funciones del sistema';
      case 'director académico':
        return 'Puede gestionar datos académicos y ver reportes completos';
      case 'jefe de carrera':
        return 'Puede gestionar estudiantes, docentes y materias de su carrera';
      case 'docente':
        return 'Puede registrar asistencia y generar reportes de sus materias';
      case 'estudiante':
        return 'Puede consultar su historial de asistencia y horarios';
      default:
        return 'Rol no definido';
    }
  }

  static IconData getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'administrador':
        return Icons.admin_panel_settings;
      case 'director académico':
        return Icons.supervisor_account;
      case 'jefe de carrera':
        return Icons.manage_accounts;
      case 'docente':
        return Icons.school;
      case 'estudiante':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'administrador':
        return const Color(0xFFD32F2F); // Rojo
      case 'director académico':
        return const Color(0xFF1976D2); // Azul
      case 'jefe de carrera':
        return const Color(0xFF388E3C); // Verde
      case 'docente':
        return const Color(0xFFF57C00); // Naranja
      case 'estudiante':
        return const Color(0xFF7B1FA2); // Púrpura
      default:
        return const Color(0xFF757575); // Gris
    }
  }

  // ========== GENERACIÓN DE USUARIOS POR ROL ==========
  static Map<String, dynamic> getDefaultUserForRole(String role, String ci, String nombreCompleto) {
    final username = _generateUsername(ci, nombreCompleto);
    final email = _generateEmail(username);
    
    return {
      'username': username,
      'email': email,
      'password': ci, // Por defecto la contraseña es el CI
      'role': role,
      'carnet': ci,
      'departamento': _getDepartamentoForRole(role),
    };
  }

  static String _generateUsername(String ci, String nombreCompleto) {
    final nombres = nombreCompleto.split(' ');
    final primerNombre = nombres[0].toLowerCase();
    return '$primerNombre.$ci';
  }

  static String _generateEmail(String username) {
    return '$username@incos.edu.bo';
  }

  static String _getDepartamentoForRole(String role) {
    switch (role.toLowerCase()) {
      case 'estudiante':
        return 'Sistemas Informáticos';
      case 'docente':
        return 'Docente - Sistemas';
      case 'jefe de carrera':
        return 'Jefatura - Sistemas';
      case 'director académico':
        return 'Dirección Académica';
      case 'administrador':
        return 'Administración';
      default:
        return 'Sistema';
    }
  }
}
