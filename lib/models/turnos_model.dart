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
      'nombre': nombre,
      'icon': icon.codePoint,
      'horario': horario,
      'rangoAsistencia': rangoAsistencia,
      'dias': dias,
      'color': color,
      'activo': activo,
      'niveles': niveles,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  static TurnoModel fromMap(String id, Map<String, dynamic> map) {
    final iconCode = map['icon'] ?? Icons.wb_sunny.codePoint;
    final IconData icon = IconData(iconCode, fontFamily: 'MaterialIcons');

    return TurnoModel(
      id: id,
      nombre: map['nombre']?.toString() ?? 'Sin nombre',
      icon: icon,
      horario: map['horario']?.toString() ?? 'Sin horario',
      rangoAsistencia: map['rangoAsistencia']?.toString() ?? 'Sin rango',
      dias: map['dias']?.toString() ?? 'Sin días',
      color: map['color']?.toString() ?? '#FFA000',
      activo: map['activo'] ?? true,
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
