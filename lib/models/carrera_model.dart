import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      'icon': icon,
      'activa': activa,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'color': color,
      'icon': icon.codePoint.toString(),
      'activa': activa,
      'fechaCreacion': fechaCreacion,
      'fechaActualizacion': DateTime.now(),
    };
  }

  static CarreraModel fromFirestore(String id, Map<String, dynamic> data) {
    return CarreraModel(
      id: id,
      nombre: data['nombre'] as String,
      color: data['color'] as String,
      icon: IconData(
        int.parse(
          data['icon']?.toString() ?? Icons.school.codePoint.toString(),
        ),
        fontFamily: 'MaterialIcons',
      ),
      activa: data['activa'] as bool? ?? true,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate(),
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp?)?.toDate(),
    );
  }

  static CarreraModel fromMap(Map<String, dynamic> map) {
    return CarreraModel(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      color: map['color'] as String,
      icon: map['icon'] as IconData,
      activa: map['activa'] as bool,
    );
  }
}
