import 'package:flutter/material.dart';

class DetalleAsistencia {
  final String id;
  final String asistenciaId;
  final String dia;
  final int porcentaje;
  final String estado;
  final String fecha;
  final String? horaRegistro;
  final String estadoPuntualidad;
  final int minutosRetraso;

  DetalleAsistencia({
    required this.id,
    required this.asistenciaId,
    required this.dia,
    required this.porcentaje,
    required this.estado,
    required this.fecha,
    this.horaRegistro,
    this.estadoPuntualidad = 'PUNTUAL',
    this.minutosRetraso = 0,
  });

  // Constructor desde Map
  factory DetalleAsistencia.fromMap(Map<String, dynamic> map) {
    return DetalleAsistencia(
      id: map['id']?.toString() ?? '',
      asistenciaId: map['asistencia_id']?.toString() ?? '',
      dia: map['dia']?.toString() ?? '',
      porcentaje: int.tryParse(map['porcentaje']?.toString() ?? '0') ?? 0,
      estado: map['estado']?.toString() ?? 'A',
      fecha: map['fecha']?.toString() ?? DateTime.now().toIso8601String(),
      horaRegistro: map['hora_registro']?.toString(),
      estadoPuntualidad: map['estado_puntualidad']?.toString() ?? 'PUNTUAL',
      minutosRetraso: int.tryParse(map['minutos_retraso']?.toString() ?? '0') ?? 0,
    );
  }

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'asistencia_id': asistenciaId,
      'dia': dia,
      'porcentaje': porcentaje,
      'estado': estado,
      'fecha': fecha,
      'hora_registro': horaRegistro,
      'estado_puntualidad': estadoPuntualidad,
      'minutos_retraso': minutosRetraso,
    };
  }

  // Propiedades computadas
  bool get estaPresente => estado == 'A';
  bool get estaAusente => estado == 'F';
  bool get estaJustificado => estado == 'J';
  
  bool get esPuntual => estadoPuntualidad == 'PUNTUAL';
  bool get esTardanza => estadoPuntualidad == 'TARDANZA';
  
  Color get colorEstado {
    switch (estado) {
      case 'A': return Colors.green;
      case 'F': return Colors.red;
      case 'J': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Color get colorPuntualidad {
    switch (estadoPuntualidad) {
      case 'PUNTUAL': return Colors.green;
      case 'TARDANZA': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String get estadoDisplay {
    switch (estado) {
      case 'A': return 'Presente';
      case 'F': return 'Ausente';
      case 'J': return 'Justificado';
      default: return estado;
    }
  }

  String get puntualidadDisplay {
    switch (estadoPuntualidad) {
      case 'PUNTUAL': return 'Puntual';
      case 'TARDANZA': return 'Tardanza';
      default: return estadoPuntualidad;
    }
  }

  // Método para copiar
  DetalleAsistencia copyWith({
    String? id,
    String? asistenciaId,
    String? dia,
    int? porcentaje,
    String? estado,
    String? fecha,
    String? horaRegistro,
    String? estadoPuntualidad,
    int? minutosRetraso,
  }) {
    return DetalleAsistencia(
      id: id ?? this.id,
      asistenciaId: asistenciaId ?? this.asistenciaId,
      dia: dia ?? this.dia,
      porcentaje: porcentaje ?? this.porcentaje,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
      horaRegistro: horaRegistro ?? this.horaRegistro,
      estadoPuntualidad: estadoPuntualidad ?? this.estadoPuntualidad,
      minutosRetraso: minutosRetraso ?? this.minutosRetraso,
    );
  }

  @override
  String toString() {
    return 'DetalleAsistencia($id: $estado - $fecha)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DetalleAsistencia && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}