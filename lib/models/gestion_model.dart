// models/gestion_model.dart
import 'package:flutter/material.dart';

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
      'activa': activa,
    };
  }

  factory CarreraConfig.fromMap(Map<String, dynamic> map) {
    return CarreraConfig(
      id: map['id'],
      nombre: map['nombre'],
      color: map['color'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      activa: map['activa'],
    );
  }
}

class GestionEstado {
  final String carreraSeleccionada;
  final List<String> carreras;

  GestionEstado({required this.carreraSeleccionada, required this.carreras});

  GestionEstado copyWith({
    String? carreraSeleccionada,
    List<String>? carreras,
  }) {
    return GestionEstado(
      carreraSeleccionada: carreraSeleccionada ?? this.carreraSeleccionada,
      carreras: carreras ?? this.carreras,
    );
  }
}
