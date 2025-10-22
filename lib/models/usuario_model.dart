// models/usuario_model.dart
import 'package:flutter/material.dart';
import 'dart:ui';

class Usuario {
  final String id;
  final String username;
  final String email;
  final String nombre;
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
}