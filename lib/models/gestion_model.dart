// models/gestion_model.dart
import 'package:flutter/material.dart';
import 'dart:convert';

class CarreraConfig {
  final int id;
  final String nombre;
  final String color;
  final IconData icon;
  final bool activa;

  CarreraConfig({
    required this.id,
    required this.nombre,
    required this.color,
    required this.icon,
    required this.activa,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
      'icon': icon.codePoint,
      'activa': activa ? 1 : 0,
    };
  }

  factory CarreraConfig.fromMap(Map<String, dynamic> map) {
    return CarreraConfig(
      id: map['id'] ?? 0,
      nombre: map['nombre'] ?? '',
      color: map['color'] ?? '#1565C0',
      icon: _getIconFromCode(map['icon'] ?? Icons.school.codePoint),
      activa: (map['activa'] ?? 1) == 1,
    );
  }

  static IconData _getIconFromCode(int codePoint) {
    try {
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.school;
    }
  }

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF1565C0);
    }
  }

  CarreraConfig copyWith({
    int? id,
    String? nombre,
    String? color,
    IconData? icon,
    bool? activa,
  }) {
    return CarreraConfig(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      activa: activa ?? this.activa,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarreraConfig && other.nombre == nombre;
  }

  @override
  int get hashCode => nombre.hashCode;

  @override
  String toString() {
    return 'CarreraConfig($id: $nombre)';
  }
}

class GestionEstado {
  final String carreraSeleccionada;
  final List<String> carreras;

  GestionEstado({
    required this.carreraSeleccionada,
    required this.carreras,
  });

  GestionEstado copyWith({
    String? carreraSeleccionada,
    List<String>? carreras,
  }) {
    return GestionEstado(
      carreraSeleccionada: carreraSeleccionada ?? this.carreraSeleccionada,
      carreras: carreras ?? this.carreras,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carrera_seleccionada': carreraSeleccionada,
      'carreras': json.encode(carreras),
    };
  }

  factory GestionEstado.fromMap(Map<String, dynamic> map) {
    List<String> carreras = [];
    try {
      if (map['carreras'] is String) {
        carreras = List<String>.from(json.decode(map['carreras']));
      } else if (map['carreras'] is List) {
        carreras = List<String>.from(map['carreras']);
      }
    } catch (e) {
      print('Error parsing carreras: $e');
    }

    return GestionEstado(
      carreraSeleccionada: map['carrera_seleccionada'] ?? '',
      carreras: carreras,
    );
  }

  bool get tieneCarreras => carreras.isNotEmpty;
  bool get tieneCarreraSeleccionada => carreraSeleccionada.isNotEmpty;
  int get totalCarreras => carreras.length;

  List<String> get carrerasDisponibles {
    if (carreraSeleccionada.isEmpty) return carreras;
    return carreras.where((c) => c != carreraSeleccionada).toList();
  }

  @override
  String toString() {
    return 'GestionEstado(seleccionada: $carreraSeleccionada, total: $totalCarreras)';
  }
}