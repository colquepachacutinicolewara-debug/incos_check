// models/usuario_model.dart - COMPLETAMENTE CORREGIDO
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Usuario {
  final String id;
  final String username;
  final String email;
  final String nombre;
  final String role;
  final String carnet;
  final String? departamento;
  final String? carrera;
  final String? telefono;
  final bool estaActivo;
  final DateTime fechaRegistro;
  final DateTime? ultimoAcceso;
  final List<String> permisos;

  Usuario({
    required this.id,
    required this.username,
    required this.email,
    required this.nombre,
    required this.role,
    required this.carnet,
    this.departamento,
    this.carrera,
    this.telefono,
    required this.estaActivo,
    required this.fechaRegistro,
    this.ultimoAcceso,
    required this.permisos,
  });

  // Factory desde Firestore
  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      role: data['role'] ?? 'Estudiante',
      carnet: data['carnet'] ?? '',
      departamento: data['departamento'],
      carrera: data['carrera'],
      telefono: data['telefono'],
      estaActivo: data['estaActivo'] ?? true,
      fechaRegistro: (data['fechaRegistro'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ultimoAcceso: (data['ultimoAcceso'] as Timestamp?)?.toDate(),
      // ✅ CORREGIDO: Usar el método público
      permisos: List<String>.from(data['permisos'] ?? getDefaultPermissions(data['role'] ?? 'Estudiante')),
    );
  }

  // ✅ CORREGIDO: Método público para obtener permisos por defecto
  static List<String> getDefaultPermissions(String role) {
    switch (role) {
      case 'SuperAdmin':
        return [
          'gestion_usuarios',
          'gestion_docentes', 
          'gestion_estudiantes',
          'gestion_cursos',
          'ver_reportes',
          'exportar_datos',
          'configuracion_sistema'
        ];
      case 'Administrador':
        return [
          'gestion_docentes',
          'gestion_estudiantes', 
          'gestion_cursos',
          'ver_reportes',
          'exportar_datos'
        ];
      case 'DirectorAcademico':
        return [
          'gestion_docentes',
          'gestion_cursos',
          'ver_reportes', 
          'exportar_datos'
        ];
      case 'JefeCarrera':
        return [
          'gestion_estudiantes',
          'gestion_cursos',
          'ver_reportes'
        ];
      case 'Docente':
        return [
          'registrar_asistencia',
          'ver_estudiantes',
          'ver_reportes'
        ];
      case 'Secretaria':
        return [
          'gestion_estudiantes',
          'ver_reportes'
        ];
      case 'Estudiante':
        return ['ver_asistencia', 'ver_calificaciones'];
      default:
        return ['ver_asistencia'];
    }
  }

  // Método para verificar permisos
  bool tienePermiso(String permiso) {
    return permisos.contains(permiso);
  }

  // Método para obtener color según rol
  Color get colorRol {
    switch (role) {
      case 'SuperAdmin':
        return const Color(0xFFD32F2F); // Rojo
      case 'Administrador':
        return const Color(0xFF1976D2); // Azul
      case 'DirectorAcademico':
        return const Color(0xFF388E3C); // Verde
      case 'JefeCarrera':
        return const Color(0xFFF57C00); // Naranja
      case 'Docente':
        return const Color(0xFF7B1FA2); // Púrpura
      case 'Secretaria':
        return const Color(0xFF0097A7); // Cyan
      case 'Estudiante':
        return const Color(0xFF00796B); // Verde azulado
      default:
        return const Color(0xFF757575); // Gris
    }
  }

  // Método para obtener ícono según rol
  IconData get iconoRol {
    switch (role) {
      case 'SuperAdmin':
        return Icons.security;
      case 'Administrador':
        return Icons.admin_panel_settings;
      case 'DirectorAcademico':
        return Icons.school;
      case 'JefeCarrera':
        return Icons.engineering;
      case 'Docente':
        return Icons.person;
      case 'Secretaria':
        return Icons.assignment_ind;
      case 'Estudiante':
        return Icons.school;
      default:
        return Icons.person;
    }
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'nombre': nombre,
      'role': role,
      'carnet': carnet,
      'departamento': departamento,
      'carrera': carrera,
      'telefono': telefono,
      'estaActivo': estaActivo,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'ultimoAcceso': ultimoAcceso != null ? Timestamp.fromDate(ultimoAcceso!) : null,
      'permisos': permisos,
    };
  }

  // Método para crear un usuario de prueba (opcional)
  factory Usuario.demo({
    required String username,
    required String email,
    required String nombre,
    required String role,
    required String carnet,
    String? departamento,
    String? carrera,
    String? telefono,
  }) {
    return Usuario(
      id: username,
      username: username,
      email: email,
      nombre: nombre,
      role: role,
      carnet: carnet,
      departamento: departamento,
      carrera: carrera,
      telefono: telefono,
      estaActivo: true,
      fechaRegistro: DateTime.now(),
      permisos: getDefaultPermissions(role),
    );
  }

  // Método copyWith para actualizar propiedades
  Usuario copyWith({
    String? id,
    String? username,
    String? email,
    String? nombre,
    String? role,
    String? carnet,
    String? departamento,
    String? carrera,
    String? telefono,
    bool? estaActivo,
    DateTime? fechaRegistro,
    DateTime? ultimoAcceso,
    List<String>? permisos,
  }) {
    return Usuario(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      role: role ?? this.role,
      carnet: carnet ?? this.carnet,
      departamento: departamento ?? this.departamento,
      carrera: carrera ?? this.carrera,
      telefono: telefono ?? this.telefono,
      estaActivo: estaActivo ?? this.estaActivo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
      permisos: permisos ?? this.permisos,
    );
  }

  @override
  String toString() {
    return 'Usuario($id: $nombre - $role)';
  }
}