import 'package:flutter/material.dart';

class HorarioClase {
  final String id;
  final String materiaId;
  final String paraleloId;
  final String docenteId;
  final String diaSemana;
  final int periodoNumero;
  final String horaInicio;
  final String horaFin;
  final bool activo;
  final DateTime fechaCreacion;

  HorarioClase({
    required this.id,
    required this.materiaId,
    required this.paraleloId,
    required this.docenteId,
    required this.diaSemana,
    required this.periodoNumero,
    required this.horaInicio,
    required this.horaFin,
    this.activo = true,
    required this.fechaCreacion,
  });

  String get periodoDisplay {
    switch (periodoNumero) {
      case 1: return '1° (7:00-8:00)';
      case 2: return '2° (8:00-9:00)';
      case 3: return '3° (9:00-10:00)';
      default: return 'Período $periodoNumero';
    }
  }

  String get horarioCompleto => '$horaInicio - $horaFin';

  Color get colorPeriodo {
    switch (periodoNumero) {
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.orange;
      default: return Colors.grey;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materia_id': materiaId,
      'paralelo_id': paraleloId,
      'docente_id': docenteId,
      'dia_semana': diaSemana,
      'periodo_numero': periodoNumero,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'activo': activo ? 1 : 0,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  factory HorarioClase.fromMap(Map<String, dynamic> map) {
    return HorarioClase(
      id: map['id'] ?? '',
      materiaId: map['materia_id'] ?? '',
      paraleloId: map['paralelo_id'] ?? '',
      docenteId: map['docente_id'] ?? '',
      diaSemana: map['dia_semana'] ?? '',
      periodoNumero: map['periodo_numero'] ?? 0,
      horaInicio: map['hora_inicio'] ?? '',
      horaFin: map['hora_fin'] ?? '',
      activo: (map['activo'] ?? 1) == 1,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] ?? DateTime.now().toIso8601String()),
    );
  }

  HorarioClase copyWith({
    String? id,
    String? materiaId,
    String? paraleloId,
    String? docenteId,
    String? diaSemana,
    int? periodoNumero,
    String? horaInicio,
    String? horaFin,
    bool? activo,
    DateTime? fechaCreacion,
  }) {
    return HorarioClase(
      id: id ?? this.id,
      materiaId: materiaId ?? this.materiaId,
      paraleloId: paraleloId ?? this.paraleloId,
      docenteId: docenteId ?? this.docenteId,
      diaSemana: diaSemana ?? this.diaSemana,
      periodoNumero: periodoNumero ?? this.periodoNumero,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'HorarioClase($diaSemana - $periodoDisplay)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HorarioClase && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}