import 'package:flutter/material.dart';

class CarreraModel {
  final int id;
  final String nombre;
  final String color;
  final IconData icon;
  final bool activa;

  CarreraModel({
    required this.id,
    required this.nombre,
    required this.color,
    required this.icon,
    required this.activa,
  });

  CarreraModel copyWith({
    int? id,
    String? nombre,
    String? color,
    IconData? icon,
    bool? activa,
  }) {
    return CarreraModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      activa: activa ?? this.activa,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
      'icon': icon,
      'activa': activa,
    };
  }

  static CarreraModel fromMap(Map<String, dynamic> map) {
    return CarreraModel(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      color: map['color'] as String,
      icon: map['icon'] as IconData,
      activa: map['activa'] as bool,
    );
  }
}
