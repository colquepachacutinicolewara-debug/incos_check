import 'package:flutter/material.dart';

class NotaAsistencia {
  final String id;
  final String estudianteId;
  final String materiaId;
  final String periodoId;
  final String bimestreId;
  
  // DATOS DE ASISTENCIA
  final int totalHorasProgramadas;
  final int horasAsistidas;
  final int horasRetraso;
  final int horasFalta;
  
  // CÁLCULO
  final double porcentajeAsistencia;
  final double notaFinal; // Sobre 10 puntos
  final String estado;
  final DateTime fechaCalculo;
  final String? observaciones;

  NotaAsistencia({
    required this.id,
    required this.estudianteId,
    required this.materiaId,
    required this.periodoId,
    required this.bimestreId,
    this.totalHorasProgramadas = 0,
    this.horasAsistidas = 0,
    this.horasRetraso = 0,
    this.horasFalta = 0,
    this.porcentajeAsistencia = 0.0,
    this.notaFinal = 0.0,
    this.estado = 'PENDIENTE',
    required this.fechaCalculo,
    this.observaciones,
  });

  // CALCULAR NOTA AUTOMÁTICAMENTE
  double calcularNota() {
    if (totalHorasProgramadas == 0) return 0.0;
    
    // Horas efectivas: Presente = 1, Retraso = 0.5
    final horasEfectivas = horasAsistidas + (horasRetraso * 0.5);
    final porcentaje = (horasEfectivas / totalHorasProgramadas) * 100;
    
    // Convertir a nota sobre 10
    return (porcentaje / 100) * 10;
  }

  String get estadoDisplay {
    switch (estado) {
      case 'PENDIENTE': return 'Pendiente';
      case 'CALCULADO': return 'Calculado';
      case 'APROBADO': return 'Aprobado';
      case 'REPROBADO': return 'Reprobado';
      default: return estado;
    }
  }

  Color get colorEstado {
    switch (estado) {
      case 'APROBADO': return Colors.green;
      case 'REPROBADO': return Colors.red;
      case 'CALCULADO': return Colors.blue;
      case 'PENDIENTE': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Color get colorNota {
    if (notaFinal >= 7.0) return Colors.green;
    if (notaFinal >= 5.0) return Colors.orange;
    return Colors.red;
  }

  String get notaDisplay => notaFinal.toStringAsFixed(1);
  String get porcentajeDisplay => '${porcentajeAsistencia.toStringAsFixed(1)}%';

  bool get estaAprobado => notaFinal >= 7.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'estudiante_id': estudianteId,
      'materia_id': materiaId,
      'periodo_id': periodoId,
      'bimestre_id': bimestreId,
      'total_horas_programadas': totalHorasProgramadas,
      'horas_asistidas': horasAsistidas,
      'horas_retraso': horasRetraso,
      'horas_falta': horasFalta,
      'porcentaje_asistencia': porcentajeAsistencia,
      'nota_final': notaFinal,
      'estado': estado,
      'fecha_calculo': fechaCalculo.toIso8601String(),
      'observaciones': observaciones,
    };
  }

  factory NotaAsistencia.fromMap(Map<String, dynamic> map) {
    return NotaAsistencia(
      id: map['id'] ?? '',
      estudianteId: map['estudiante_id'] ?? '',
      materiaId: map['materia_id'] ?? '',
      periodoId: map['periodo_id'] ?? '',
      bimestreId: map['bimestre_id'] ?? '',
      totalHorasProgramadas: map['total_horas_programadas'] ?? 0,
      horasAsistidas: map['horas_asistidas'] ?? 0,
      horasRetraso: map['horas_retraso'] ?? 0,
      horasFalta: map['horas_falta'] ?? 0,
      porcentajeAsistencia: (map['porcentaje_asistencia'] ?? 0.0).toDouble(),
      notaFinal: (map['nota_final'] ?? 0.0).toDouble(),
      estado: map['estado'] ?? 'PENDIENTE',
      fechaCalculo: DateTime.parse(map['fecha_calculo'] ?? DateTime.now().toIso8601String()),
      observaciones: map['observaciones'],
    );
  }

  NotaAsistencia copyWith({
    String? id,
    String? estudianteId,
    String? materiaId,
    String? periodoId,
    String? bimestreId,
    int? totalHorasProgramadas,
    int? horasAsistidas,
    int? horasRetraso,
    int? horasFalta,
    double? porcentajeAsistencia,
    double? notaFinal,
    String? estado,
    DateTime? fechaCalculo,
    String? observaciones,
  }) {
    return NotaAsistencia(
      id: id ?? this.id,
      estudianteId: estudianteId ?? this.estudianteId,
      materiaId: materiaId ?? this.materiaId,
      periodoId: periodoId ?? this.periodoId,
      bimestreId: bimestreId ?? this.bimestreId,
      totalHorasProgramadas: totalHorasProgramadas ?? this.totalHorasProgramadas,
      horasAsistidas: horasAsistidas ?? this.horasAsistidas,
      horasRetraso: horasRetraso ?? this.horasRetraso,
      horasFalta: horasFalta ?? this.horasFalta,
      porcentajeAsistencia: porcentajeAsistencia ?? this.porcentajeAsistencia,
      notaFinal: notaFinal ?? this.notaFinal,
      estado: estado ?? this.estado,
      fechaCalculo: fechaCalculo ?? this.fechaCalculo,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  @override
  String toString() {
    return 'NotaAsistencia($estudianteId - $notaFinal/10)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotaAsistencia && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}