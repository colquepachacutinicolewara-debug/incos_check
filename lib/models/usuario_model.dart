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
    switch (role) {
      case 'Administrador':
        return const Color(0xFF1565C0);
      case 'Docente':
        return const Color(0xFF42A5F5);
      case 'Jefe de Carrera':
        return const Color(0xFF64B5F6);
      case 'Director Académico':
        return const Color(0xFF1976D2);
      case 'Estudiante':
        return const Color(0xFF29B6F6);
      default:
        return const Color(0xFF1565C0);
    }
  }

  // Método para obtener ícono según rol
  IconData get iconoRol {
    switch (role) {
      case 'Administrador':
        return Icons.admin_panel_settings;
      case 'Docente':
        return Icons.school;
      case 'Jefe de Carrera':
        return Icons.manage_accounts;
      case 'Director Académico':
        return Icons.supervisor_account;
      case 'Estudiante':
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
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? '',
      carnet: map['carnet'] ?? '',
      departamento: map['departamento'] ?? '',
      estaActivo: (map['esta_activo'] ?? 1) == 1,
      fechaRegistro: map['fecha_registro'] != null
          ? DateTime.parse(map['fecha_registro'])
          : DateTime.now(),
    );
  }

  // Métodos de utilidad
  bool get puedeGestionarUsuarios => role == 'Administrador';
  bool get puedeGestionarAsistencias => role == 'Administrador' || role == 'Docente';
  bool get puedeVerReportes => role == 'Administrador' || role == 'Director Académico';

  String get rolDisplay {
    switch (role) {
      case 'Administrador':
        return 'Administrador';
      case 'Docente':
        return 'Docente';
      case 'Jefe de Carrera':
        return 'Jefe de Carrera';
      case 'Director Académico':
        return 'Director Académico';
      case 'Estudiante':
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