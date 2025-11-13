// models/carrera_model.dart
import 'package:flutter/material.dart';

class CarreraModel {
  final String id;
  final String nombre;
  final String color;
  final IconData icon;
  final bool activa;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  CarreraModel({
    required this.id,
    required this.nombre,
    required this.color,
    required this.icon,
    required this.activa,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  CarreraModel copyWith({
    String? id,
    String? nombre,
    String? color,
    IconData? icon,
    bool? activa,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return CarreraModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      activa: activa ?? this.activa,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
      'icon_code_point': icon.codePoint,
      'activa': activa ? 1 : 0,
      'fecha_creacion': fechaCreacion?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory CarreraModel.fromMap(Map<String, dynamic> map) {
    return CarreraModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      color: map['color'] ?? '#1565C0',
      icon: _codePointToIcon(map['icon_code_point']),
      activa: (map['activa'] ?? 1) == 1,
      fechaCreacion: map['fecha_creacion'] != null 
          ? DateTime.parse(map['fecha_creacion'])
          : null,
      fechaActualizacion: map['fecha_actualizacion'] != null 
          ? DateTime.parse(map['fecha_actualizacion'])
          : null,
    );
  }

  static IconData _codePointToIcon(dynamic codePoint) {
    try {
      final int code = codePoint is int ? codePoint : int.tryParse(codePoint.toString()) ?? Icons.school.codePoint;
      return IconData(code, fontFamily: 'MaterialIcons');
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

  String get nombreCorto {
    if (nombre.length <= 15) return nombre;
    return '${nombre.substring(0, 15)}...';
  }

  @override
  String toString() {
    return 'CarreraModel($id: $nombre)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarreraModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}