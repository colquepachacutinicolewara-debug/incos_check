// models/usuario_model.dart
import 'package:flutter/material.dart';

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
  });

  // Constructor para datos de prueba
  Usuario.demo({
    required this.username,
    required this.email,
    required this.nombre,
    required this.role,
    required this.carnet,
    required this.departamento,
  })  : id = username,
        password = 'default123',
        estaActivo = true,
        fechaRegistro = DateTime.now();

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
    );
  }

  // ✅ NUEVO: Constructor desde datos de login
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
    );
  }

  // Métodos de utilidad - MEJORADOS
  bool get puedeGestionarUsuarios => role.toLowerCase() == 'administrador';
  bool get puedeGestionarAsistencias => 
      role.toLowerCase() == 'administrador' || role.toLowerCase() == 'docente';
  bool get puedeVerReportes => 
      role.toLowerCase() == 'administrador' || 
      role.toLowerCase() == 'director académico' ||
      role.toLowerCase() == 'jefe de carrera';
  
  bool get puedeGestionarCursos => role.toLowerCase() == 'administrador';
  bool get puedeRegistrarAsistencia => 
      role.toLowerCase() == 'administrador' || role.toLowerCase() == 'docente';
  bool get puedeGestionarEstudiantes => 
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