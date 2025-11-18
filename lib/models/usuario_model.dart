// models/usuario_model.dart - VERSIÓN CORREGIDA
import 'package:flutter/material.dart';
import '../utils/permissions.dart';

// Importaciones con alias para evitar conflictos
import 'estudiante_model.dart' as estudiante_model;
import 'docente_model.dart' as docente_model;

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
  final String? carreraId;
  final String? turnoId;

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
    this.carreraId,
    this.turnoId,
  });

  // ========== CONSTRUCTORES MEJORADOS ==========
  factory Usuario.fromEstudiante(estudiante_model.Estudiante estudiante) {
    final userData = AppPermissions.getDefaultUserForRole(
      'estudiante', 
      estudiante.ci, 
      estudiante.nombreCompleto
    );
    
    return Usuario(
      id: 'est_${estudiante.id}',
      username: userData['username']!,
      email: userData['email']!,
      nombre: estudiante.nombreCompleto,
      password: userData['password']!,
      role: 'estudiante',
      carnet: estudiante.ci,
      departamento: userData['departamento']!,
      estaActivo: estudiante.activo,
      fechaRegistro: DateTime.now(),
      updatedAt: DateTime.now(),
      telefono: estudiante.telefono,
      carreraId: estudiante.carreraId,
      turnoId: estudiante.turnoId,
    );
  }

  factory Usuario.fromDocente(docente_model.Docente docente) {
    final userData = AppPermissions.getDefaultUserForRole(
      'docente', 
      docente.ci, 
      docente.nombreCompleto
    );
    
    return Usuario(
      id: 'doc_${docente.id}',
      username: userData['username']!,
      email: docente.email,
      nombre: docente.nombreCompleto,
      password: userData['password']!,
      role: 'docente',
      carnet: docente.ci,
      departamento: userData['departamento']!,
      estaActivo: docente.estaActivo,
      fechaRegistro: DateTime.now(),
      updatedAt: DateTime.now(),
      telefono: docente.telefono,
      carreraId: docente.carrera,
      turnoId: docente.turno,
    );
  }

  // ========== CONSTRUCTOR fromLoginData ==========
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
      carreraId: data['carrera_id']?.toString(),
      turnoId: data['turno_id']?.toString(),
    );
  }

  // ========== CONVERSIÓN SQLITE MEJORADA ==========
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
      'carrera_id': carreraId,
      'turno_id': turnoId,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      role: map['role']?.toString() ?? 'estudiante',
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
      carreraId: map['carrera_id']?.toString(),
      turnoId: map['turno_id']?.toString(),
    );
  }

  // ========== PROPIEDADES DE UI MEJORADAS ==========
  Color get colorRol => AppPermissions.getRoleColor(role);
  IconData get iconoRol => AppPermissions.getRoleIcon(role);
  String get rolDisplay => role[0].toUpperCase() + role.substring(1);
  String get descripcionRol => AppPermissions.getRoleDescription(role);
  int get nivelAcceso => AppPermissions.availableRoles.indexOf(role) + 1;

  // ========== MÉTODOS DE PERMISOS MEJORADOS ==========
  bool tienePermiso(String permission) => AppPermissions.hasPermission(role, permission);
  bool tieneAlgunPermiso(List<String> permissions) => AppPermissions.hasAnyPermission(role, permissions);
  bool tieneTodosPermisos(List<String> permissions) => AppPermissions.hasAllPermissions(role, permissions);
  List<String> get permisos => AppPermissions.getPermissionsForRole(role);

  // ========== PERMISOS POR MÓDULO ==========
  bool get puedeAccederDashboard => tienePermiso(AppPermissions.ACCESS_DASHBOARD);
  bool get puedeAccederGestion => AppPermissions.canAccessGestion(role);
  bool get puedeAccederAsistencia => AppPermissions.canAccessAsistencia(role);
  bool get puedeAccederReportes => AppPermissions.canAccessReportes(role);
  bool get puedeAccederConfiguracion => AppPermissions.canAccessConfiguracion(role);

  // ========== PERMISOS ESPECÍFICOS ==========
  bool get puedeGestionarEstudiantes => tienePermiso(AppPermissions.MANAGE_ESTUDIANTES);
  bool get puedeGestionarDocentes => tienePermiso(AppPermissions.MANAGE_DOCENTES);
  bool get puedeGestionarMaterias => tienePermiso(AppPermissions.MANAGE_MATERIAS);
  bool get puedeRegistrarAsistencia => tienePermiso(AppPermissions.REGISTER_ASISTENCIA);
  bool get puedeTomarAsistencia => tienePermiso(AppPermissions.TAKE_ATTENDANCE);
  bool get puedeVerHistorial => tienePermiso(AppPermissions.VIEW_HISTORIAL_ASISTENCIA);
  bool get puedeVerPropiaAsistencia => tienePermiso(AppPermissions.VIEW_OWN_ATTENDANCE);
  bool get puedeGenerarReportes => tienePermiso(AppPermissions.GENERATE_REPORTES);
  bool get puedeGestionarUsuarios => tienePermiso(AppPermissions.MANAGE_USUARIOS);

  // ========== MÓDULOS DISPONIBLES ==========
  Map<String, Map<String, dynamic>> get modulosDisponibles {
    return {
      'Gestión': {
        'acceso': puedeAccederGestion,
        'icon': Icons.manage_accounts,
        'color': Colors.blue,
        'submodulos': {
          'Estudiantes': puedeGestionarEstudiantes,
          'Docentes': puedeGestionarDocentes,
          'Materias': puedeGestionarMaterias,
        }
      },
      'Asistencia': {
        'acceso': puedeAccederAsistencia,
        'icon': Icons.fingerprint,
        'color': Colors.green,
        'submodulos': {
          'Registrar': puedeRegistrarAsistencia,
          'Tomar Lista': puedeTomarAsistencia,
          'Historial': puedeVerHistorial,
        }
      },
      'Reportes': {
        'acceso': puedeAccederReportes,
        'icon': Icons.analytics,
        'color': Colors.orange,
        'submodulos': {
          'Generar': puedeGenerarReportes,
          'Estadísticas': puedeVerHistorial,
        }
      },
      'Configuración': {
        'acceso': puedeAccederConfiguracion,
        'icon': Icons.settings,
        'color': Colors.purple,
        'submodulos': {
          'Usuarios': puedeGestionarUsuarios,
        }
      },
    };
  }

  // ========== MÉTODOS DE UTILIDAD ==========
  Usuario copyWith({
    String? username,
    String? nombre,
    String? email,
    String? telefono,
    String? fotoUrl,
    String? password,
    bool? estaActivo,
    String? carreraId,
    String? turnoId,
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
      estaActivo: estaActivo ?? this.estaActivo,
      fechaRegistro: fechaRegistro,
      updatedAt: DateTime.now(),
      telefono: telefono ?? this.telefono,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      carreraId: carreraId ?? this.carreraId,
      turnoId: turnoId ?? this.turnoId,
    );
  }

  bool puedeAccederA(String seccion) {
    switch (seccion.toLowerCase()) {
      case 'estudiantes': return puedeGestionarEstudiantes;
      case 'docentes': return puedeGestionarDocentes;
      case 'materias': return puedeGestionarMaterias;
      case 'asistencia': return puedeRegistrarAsistencia;
      case 'historial': return puedeVerHistorial;
      case 'reportes': return puedeGenerarReportes;
      case 'configuracion': return puedeAccederConfiguracion;
      case 'usuarios': return puedeGestionarUsuarios;
      default: return false;
    }
  }

  @override
  String toString() => 'Usuario($id: $nombre - $role)';

  @override
  bool operator ==(Object other) => identical(this, other) || other is Usuario && other.id == id;

  @override
  int get hashCode => id.hashCode;
}