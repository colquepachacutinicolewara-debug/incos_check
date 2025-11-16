import 'package:flutter/material.dart';

class AsistenciaDiaria {
  final String id;
  final String estudianteId;
  final String materiaId;
  final String horarioClaseId;
  final DateTime fecha;
  final int periodoNumero;
  final String estado; // 'P', 'A', 'R'
  final int minutosRetraso;
  final String? observaciones;
  final DateTime fechaCreacion;
  final String? usuarioRegistro;

  AsistenciaDiaria({
    required this.id,
    required this.estudianteId,
    required this.materiaId,
    required this.horarioClaseId,
    required this.fecha,
    required this.periodoNumero,
    this.estado = 'A',
    this.minutosRetraso = 0,
    this.observaciones,
    required this.fechaCreacion,
    this.usuarioRegistro,
  });

  bool get estaPresente => estado == 'P';
  bool get estaAusente => estado == 'A';
  bool get estaRetraso => estado == 'R';
  
  double get valorAsistencia {
    switch (estado) {
      case 'P': return 1.0;
      case 'R': return 0.5;
      case 'A': return 0.0;
      default: return 0.0;
    }
  }

  String get estadoDisplay {
    switch (estado) {
      case 'P': return 'Presente';
      case 'A': return 'Ausente';
      case 'R': return 'Retraso';
      default: return estado;
    }
  }

  Color get colorEstado {
    switch (estado) {
      case 'P': return Colors.green;
      case 'A': return Colors.red;
      case 'R': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String get iconoEstado {
    switch (estado) {
      case 'P': return '✅';
      case 'A': return '❌';
      case 'R': return '⏰';
      default: return '❓';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'estudiante_id': estudianteId,
      'materia_id': materiaId,
      'horario_clase_id': horarioClaseId,
      'fecha': fecha.toIso8601String().split('T')[0], // Solo la fecha
      'periodo_numero': periodoNumero,
      'estado': estado,
      'minutos_retraso': minutosRetraso,
      'observaciones': observaciones,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'usuario_registro': usuarioRegistro,
    };
  }

  factory AsistenciaDiaria.fromMap(Map<String, dynamic> map) {
    return AsistenciaDiaria(
      id: map['id'] ?? '',
      estudianteId: map['estudiante_id'] ?? '',
      materiaId: map['materia_id'] ?? '',
      horarioClaseId: map['horario_clase_id'] ?? '',
      fecha: DateTime.parse(map['fecha'] ?? DateTime.now().toIso8601String()),
      periodoNumero: map['periodo_numero'] ?? 0,
      estado: map['estado'] ?? 'A',
      minutosRetraso: map['minutos_retraso'] ?? 0,
      observaciones: map['observaciones'],
      fechaCreacion: DateTime.parse(map['fecha_creacion'] ?? DateTime.now().toIso8601String()),
      usuarioRegistro: map['usuario_registro'],
    );
  }

  AsistenciaDiaria copyWith({
    String? id,
    String? estudianteId,
    String? materiaId,
    String? horarioClaseId,
    DateTime? fecha,
    int? periodoNumero,
    String? estado,
    int? minutosRetraso,
    String? observaciones,
    DateTime? fechaCreacion,
    String? usuarioRegistro,
  }) {
    return AsistenciaDiaria(
      id: id ?? this.id,
      estudianteId: estudianteId ?? this.estudianteId,
      materiaId: materiaId ?? this.materiaId,
      horarioClaseId: horarioClaseId ?? this.horarioClaseId,
      fecha: fecha ?? this.fecha,
      periodoNumero: periodoNumero ?? this.periodoNumero,
      estado: estado ?? this.estado,
      minutosRetraso: minutosRetraso ?? this.minutosRetraso,
      observaciones: observaciones ?? this.observaciones,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      usuarioRegistro: usuarioRegistro ?? this.usuarioRegistro,
    );
  }

  @override
  String toString() {
    return 'AsistenciaDiaria($estudianteId - $fecha - $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AsistenciaDiaria && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}