import 'package:flutter/material.dart';
class Horario {
  final String id;
  final String dia;
  final String hora;
  final String materiaId;
  final String materiaNombre;
  final String aula;
  final String profesor;
  final Color color;
  final DateTime fechaCreacion;

  Horario({
    required this.id,
    required this.dia,
    required this.hora,
    required this.materiaId,
    required this.materiaNombre,
    required this.aula,
    required this.profesor,
    required this.color,
    required this.fechaCreacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dia': dia,
      'hora': hora,
      'materiaId': materiaId,
      'materiaNombre': materiaNombre,
      'aula': aula,
      'profesor': profesor,
      'color': color.value,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      id: map['id'] ?? '',
      dia: map['dia'] ?? '',
      hora: map['hora'] ?? '',
      materiaId: map['materiaId'] ?? '',
      materiaNombre: map['materiaNombre'] ?? '',
      aula: map['aula'] ?? '',
      profesor: map['profesor'] ?? '',
      color: Color(map['color'] ?? Colors.blue.value),
      fechaCreacion: DateTime.parse(map['fechaCreacion'] ?? DateTime.now().toIso8601String()),
    );
  }
}