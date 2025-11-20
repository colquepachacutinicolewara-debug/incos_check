// models/usuario_model.dart - VERSIÓN COMPLETA Y CORREGIDA
import 'package:flutter/material.dart';
import '../utils/permissions.dart';

class Usuario {
  final String id;
  final String username;
  final String email;
  final String nombre;
  final String password;
  final String role;
  final String carnet;
  final String departamento;
  final bool estaActivo;
  final DateTime fechaRegistro;
  final DateTime updatedAt;
  final String? telefono;
  final String? fotoUrl;

  Usuario({
    required this.id,
    required this.username,
    required this.email,
    required this.nombre,
    required this.password,
    required this.role,
    required this.carnet,
    required this.departamento,
    required this.estaActivo,
    required this.fechaRegistro,
    required this.updatedAt,
    this.telefono,
    this.fotoUrl,
  });

  // Constructor para datos de prueba
  Usuario.demo({
    required this.username,
    required this.email,
    required this.nombre,
    required this.role,
    required this.carnet,
    required this.departamento,
    this.telefono,
    this.fotoUrl,
  })  : id = username,
        password = 'default123',
        estaActivo = true,
        fechaRegistro = DateTime.now(),
        updatedAt = DateTime.now();

  // Método para obtener color según rol
  Color get colorRol {
    switch (role.toLowerCase()) {
      case 'administrador':
        return const Color(0xFF1565C0);
      case 'docente':
        return const Color(0xFF42A5F5);
      case 'jefe de carrera':
        return const Color(0xFF64B5F6);
      case 'director académico':
        return const Color(0xFF1976D2);
      case 'estudiante':
        return const Color(0xFF29B6F6);
      default:
        return const Color(0xFF1565C0);
    }
  }

  // Método para obtener ícono según rol
  IconData get iconoRol {
    switch (role.toLowerCase()) {
      case 'administrador':
        return Icons.admin_panel_settings;
      case 'docente':
        return Icons.school;
      case 'jefe de carrera':
        return Icons.manage_accounts;
      case 'director académico':
        return Icons.supervisor_account;
      case 'estudiante':
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  // Para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nombre': nombre,
      'password': password,
      'role': role,
      'carnet': carnet,
      'departamento': departamento,
      'esta_activo': estaActivo ? 1 : 0,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'telefono': telefono,
      'foto_url': fotoUrl,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      role: map['role']?.toString() ?? 'Docente',
      carnet: map['carnet']?.toString() ?? '',
      departamento: map['departamento']?.toString() ?? '',
      estaActivo: (map['esta_activo'] ?? 1) == 1,
      fechaRegistro: map['fecha_registro'] != null
          ? DateTime.parse(map['fecha_registro'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
      telefono: map['telefono']?.toString(),
      fotoUrl: map['foto_url']?.toString(),
    );
  }

  // Constructor desde datos de login
  factory Usuario.fromLoginData(Map<String, Object?> data) {
    return Usuario(
      id: data['id']?.toString() ?? '',
      username: data['username']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      nombre: data['nombre']?.toString() ?? '',
      password: data['password']?.toString() ?? '',
      role: data['role']?.toString() ?? 'Usuario',
      carnet: data['carnet']?.toString() ?? '',
      departamento: data['departamento']?.toString() ?? '',
      estaActivo: (data['esta_activo'] is int) 
          ? (data['esta_activo'] as int) == 1
          : true,
      fechaRegistro: data['fecha_registro'] != null
          ? DateTime.parse(data['fecha_registro'].toString())
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'].toString())
          : DateTime.now(),
      telefono: data['telefono']?.toString(),
      fotoUrl: data['foto_url']?.toString(),
    );
  }

  // Método para copiar con nuevos valores (para edición)
  Usuario copyWith({
    String? username,
    String? nombre,
    String? email,
    String? telefono,
    String? fotoUrl,
    String? password,
  }) {
    return Usuario(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      password: password ?? this.password,
      role: role,
      carnet: carnet,
      departamento: departamento,
      estaActivo: estaActivo,
      fechaRegistro: fechaRegistro,
      updatedAt: DateTime.now(),
      telefono: telefono ?? this.telefono,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }

  // 🌟 MÉTODOS DE PERMISOS MEJORADOS
  bool tienePermiso(String permission) {
    return AppPermissions.hasPermission(role, permission);
  }

  bool tieneAlgunPermiso(List<String> permissions) {
    return AppPermissions.hasAnyPermission(role, permissions);
  }

  bool tieneTodosPermisos(List<String> permissions) {
    return AppPermissions.hasAllPermissions(role, permissions);
  }

  List<String> get permisos => AppPermissions.getPermissionsForRole(role);

  // 🌟 PERMISOS ESPECÍFICOS POR MÓDULO
  bool get puedeAccederDashboard => tienePermiso(AppPermissions.ACCESS_DASHBOARD);
  bool get puedeAccederGestion => tienePermiso(AppPermissions.ACCESS_GESTION);
  bool get puedeAccederAsistencia => tienePermiso(AppPermissions.ACCESS_ASISTENCIA);
  bool get puedeAccederReportes => tienePermiso(AppPermissions.ACCESS_REPORTES);
  bool get puedeAccederConfiguracion => tienePermiso(AppPermissions.ACCESS_CONFIGURACION);

  // Gestión académica
  bool get puedeGestionarEstudiantes => tienePermiso(AppPermissions.MANAGE_ESTUDIANTES);
  bool get puedeGestionarDocentes => tienePermiso(AppPermissions.MANAGE_DOCENTES);
  bool get puedeGestionarCarreras => tienePermiso(AppPermissions.MANAGE_CARRERAS);
  bool get puedeGestionarMaterias => tienePermiso(AppPermissions.MANAGE_MATERIAS);
  bool get puedeGestionarParalelos => tienePermiso(AppPermissions.MANAGE_PARALELOS);
  bool get puedeGestionarTurnos => tienePermiso(AppPermissions.MANAGE_TURNOS);
  bool get puedeGestionarNiveles => tienePermiso(AppPermissions.MANAGE_NIVELES);
  bool get puedeGestionarPeriodos => tienePermiso(AppPermissions.MANAGE_PERIODOS);

  // Asistencia
  bool get puedeRegistrarAsistencia => tienePermiso(AppPermissions.REGISTER_ASISTENCIA);
  bool get puedeVerHistorialAsistencia => tienePermiso(AppPermissions.VIEW_HISTORIAL_ASISTENCIA);
  bool get puedeGestionarBiometrico => tienePermiso(AppPermissions.MANAGE_BIOMETRICO);

  // Reportes
  bool get puedeGenerarReportes => tienePermiso(AppPermissions.GENERATE_REPORTES);
  bool get puedeExportarDatos => tienePermiso(AppPermissions.EXPORT_DATA);
  bool get puedeVerEstadisticas => tienePermiso(AppPermissions.VIEW_STATISTICS);

  // Configuración
  bool get puedeGestionarUsuarios => tienePermiso(AppPermissions.MANAGE_USUARIOS);
  bool get puedeGestionarConfiguracion => tienePermiso(AppPermissions.MANAGE_CONFIGURACION);
  bool get puedeGestionarRespaldos => tienePermiso(AppPermissions.MANAGE_BACKUPS);
  bool get puedeVerLogs => tienePermiso(AppPermissions.VIEW_LOGS);

  // 🌟 MÉTODO PARA OBTENER MÓDULOS DISPONIBLES
  Map<String, bool> get modulosDisponibles {
    return {
      'Gestión Académica': puedeAccederGestion,
      'Registro de Asistencia': puedeAccederAsistencia,
      'Reportes e Informes': puedeAccederReportes,
      'Configuración': puedeAccederConfiguracion,
    };
  }

  // 🌟 MÉTODO PARA VERIFICAR ACCESO A SECCIÓN ESPECÍFICA
  bool puedeAccederA(String seccion) {
    switch (seccion.toLowerCase()) {
      case 'estudiantes':
        return puedeGestionarEstudiantes;
      case 'docentes':
        return puedeGestionarDocentes;
      case 'carreras':
        return puedeGestionarCarreras;
      case 'materias':
        return puedeGestionarMaterias;
      case 'asistencia':
        return puedeRegistrarAsistencia;
      case 'historial':
        return puedeVerHistorialAsistencia;
      case 'reportes':
        return puedeGenerarReportes;
      case 'configuracion':
        return puedeGestionarConfiguracion;
      case 'usuarios':
        return puedeGestionarUsuarios;
      default:
        return false;
    }
  }

  // 🌟 MÉTODOS DE UTILIDAD (COMPATIBILIDAD CON CÓDIGO EXISTENTE)
  bool get puedeGestionarAsistencias => 
      role.toLowerCase() == 'administrador' || role.toLowerCase() == 'docente';
  
  bool get puedeVerReportes => 
      role.toLowerCase() == 'administrador' || 
      role.toLowerCase() == 'director académico' ||
      role.toLowerCase() == 'jefe de carrera';
  
  bool get puedeGestionarCursos => role.toLowerCase() == 'administrador';
  
  bool get puedeGestionarEstudiantesLegacy => 
      role.toLowerCase() == 'administrador' || role.toLowerCase() == 'docente';

  String get rolDisplay {
    switch (role.toLowerCase()) {
      case 'administrador':
        return 'Administrador';
      case 'docente':
        return 'Docente';
      case 'jefe de carrera':
        return 'Jefe de Carrera';
      case 'director académico':
        return 'Director Académico';
      case 'estudiante':
        return 'Estudiante';
      default:
        return role;
    }
  }

  // 🌟 MÉTODO PARA OBTENER DESCRIPCIÓN DEL ROL
  String get descripcionRol {
    switch (role.toLowerCase()) {
      case 'administrador':
        return 'Acceso completo a todos los módulos y funciones del sistema';
      case 'director académico':
        return 'Puede gestionar datos académicos y ver reportes completos';
      case 'jefe de carrera':
        return 'Puede gestionar estudiantes, docentes y materias de su carrera';
      case 'docente':
        return 'Puede registrar asistencia y ver reportes de sus materias';
      case 'estudiante':
        return 'Puede ver su propio historial de asistencia';
      default:
        return 'Usuario con permisos básicos';
    }
  }

  // 🌟 MÉTODO PARA OBTENER NIVEL DE ACCESO (1-5)
  int get nivelAcceso {
    switch (role.toLowerCase()) {
      case 'administrador':
        return 5;
      case 'director académico':
        return 4;
      case 'jefe de carrera':
        return 3;
      case 'docente':
        return 2;
      case 'estudiante':
        return 1;
      default:
        return 0;
    }
  }

  @override
  String toString() {
    return 'Usuario($id: $nombre - $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Usuario && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}