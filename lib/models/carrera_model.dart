// carrera_model.dart
import 'package:flutter/material.dart';

class Carrera {
  final int id;
  final String nombre;
  final String color;
  final IconData icon;
  bool activa;
  bool seleccionada;

  Carrera({
    required this.id,
    required this.nombre,
    required this.color,
    required this.icon,
    this.activa = true,
    this.seleccionada = false,
  });

  factory Carrera.fromMap(Map<String, dynamic> map) {
    return Carrera(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      color: map['color'] as String,
      icon: map['icon'] as IconData,
      activa: map['activa'] as bool? ?? true,
      seleccionada: map['seleccionada'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
      'icon': icon,
      'activa': activa,
      'seleccionada': seleccionada,
    };
  }

  Carrera copyWith({
    int? id,
    String? nombre,
    String? color,
    IconData? icon,
    bool? activa,
    bool? seleccionada,
  }) {
    return Carrera(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      activa: activa ?? this.activa,
      seleccionada: seleccionada ?? this.seleccionada,
    );
  }

  @override
  String toString() {
    return 'Carrera{id: $id, nombre: $nombre, activa: $activa, seleccionada: $seleccionada}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Carrera && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
