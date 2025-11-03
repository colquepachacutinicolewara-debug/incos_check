import 'package:flutter/material.dart';

class TurnoModel {
  final String id;
  final String nombre;
  final IconData icon;
  final String horario;
  final String rangoAsistencia;
  final String dias;
  final String color;
  final bool activo;
  final List<dynamic> niveles;

  TurnoModel({
    required this.id,
    required this.nombre,
    required this.icon,
    required this.horario,
    required this.rangoAsistencia,
    required this.dias,
    required this.color,
    required this.activo,
    required this.niveles,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'icon': icon,
      'horario': horario,
      'rangoAsistencia': rangoAsistencia,
      'dias': dias,
      'color': color,
      'activo': activo,
      'niveles': niveles,
    };
  }

  static TurnoModel fromMap(Map<String, dynamic> map) {
    return TurnoModel(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      icon: map['icon'] as IconData,
      horario: map['horario']?.toString() ?? '',
      rangoAsistencia: map['rangoAsistencia']?.toString() ?? '',
      dias: map['dias']?.toString() ?? '',
      color: map['color']?.toString() ?? '#FFA000',
      activo: map['activo'] ?? false,
      niveles: map['niveles'] ?? [],
    );
  }

  TurnoModel copyWith({
    String? id,
    String? nombre,
    IconData? icon,
    String? horario,
    String? rangoAsistencia,
    String? dias,
    String? color,
    bool? activo,
    List<dynamic>? niveles,
  }) {
    return TurnoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      icon: icon ?? this.icon,
      horario: horario ?? this.horario,
      rangoAsistencia: rangoAsistencia ?? this.rangoAsistencia,
      dias: dias ?? this.dias,
      color: color ?? this.color,
      activo: activo ?? this.activo,
      niveles: niveles ?? this.niveles,
    );
  }
}
