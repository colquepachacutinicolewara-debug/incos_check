import 'package:flutter/material.dart';

class Carrera {
  final String id;
  final String nombre;
  final String color;
  final IconData icon;
  final bool activa;

  Carrera({
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
      'icon': _iconToCode(icon),
      'activa': activa,
    };
  }

  factory Carrera.fromMap(Map<String, dynamic> map) {
    return Carrera(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      color: map['color'] ?? '#1565C0',
      icon: _codeToIcon(map['icon'] ?? 'school'),
      activa: map['activa'] ?? true,
    );
  }

  Carrera copyWith({
    String? id,
    String? nombre,
    String? color,
    IconData? icon,
    bool? activa,
  }) {
    return Carrera(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      activa: activa ?? this.activa,
    );
  }

  static String _iconToCode(IconData icon) {
    return icon.codePoint.toString();
  }

  static IconData _codeToIcon(String code) {
    try {
      return IconData(int.parse(code), fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.school;
    }
  }
}
