import 'package:flutter/material.dart';

class NotaAsistencia {
  final String id;
  final String estudianteId;
  final String materiaId;
  final String periodoId;
  final String bimestreId;
  final String configAsistenciaId;
  
  // DATOS DE ASISTENCIA - COINCIDEN CON BD
  final int totalClases;
  final int clasesAsistidas;
  final int clasesFaltadas;
  
  // CÁLCULO
  final double porcentajeAsistencia;
  final double notaCalculada; // Sobre 10 puntos
  final String estado;
  final DateTime fechaCalculo;
  final String? observaciones;

  NotaAsistencia({
    required this.id,
    required this.estudianteId,
    required this.materiaId,
    required this.periodoId,
    required this.bimestreId,
    required this.configAsistenciaId,
    this.totalClases = 0,
    this.clasesAsistidas = 0,
    this.clasesFaltadas = 0,
    this.porcentajeAsistencia = 0.0,
    this.notaCalculada = 0.0,
    this.estado = 'PENDIENTE',
    required this.fechaCalculo,
    this.observaciones,
  });

  // CALCULAR NOTA AUTOMÁTICAMENTE - SEGÚN TU BD
  double calcularNota() {
    if (totalClases == 0) return 0.0;
    
    // Porcentaje básico de asistencia
    final porcentaje = (clasesAsistidas / totalClases) * 100;
    
    // Convertir a nota sobre 10 (ejemplo: 80% = 8.0)
    return (porcentaje / 10).clamp(0.0, 10.0);
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
    if (notaCalculada >= 7.0) return Colors.green;
    if (notaCalculada >= 5.0) return Colors.orange;
    return Colors.red;
  }

  String get notaDisplay => notaCalculada.toStringAsFixed(1);
  String get porcentajeDisplay => '${porcentajeAsistencia.toStringAsFixed(1)}%';
  String get asistenciaDisplay => '$clasesAsistidas/$totalClases';

  bool get estaAprobado => notaCalculada >= 7.0;
  bool get estaCalculado => estado == 'CALCULADO';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'estudiante_id': estudianteId,
      'materia_id': materiaId,
      'periodo_id': periodoId,
      'bimestre_id': bimestreId,
      'config_asistencia_id': configAsistenciaId,
      'total_clases': totalClases,
      'clases_asistidas': clasesAsistidas,
      'clases_faltadas': clasesFaltadas,
      'porcentaje_asistencia': porcentajeAsistencia,
      'nota_calculada': notaCalculada,
      'estado': estado,
      'fecha_calculo': fechaCalculo.toIso8601String(),
      'observaciones': observaciones,
    };
  }

  factory NotaAsistencia.fromMap(Map<String, dynamic> map) {
    return NotaAsistencia(
      id: map['id']?.toString() ?? '',
      estudianteId: map['estudiante_id']?.toString() ?? '',
      materiaId: map['materia_id']?.toString() ?? '',
      periodoId: map['periodo_id']?.toString() ?? '',
      bimestreId: map['bimestre_id']?.toString() ?? '',
      configAsistenciaId: map['config_asistencia_id']?.toString() ?? '',
      totalClases: map['total_clases'] ?? 0,
      clasesAsistidas: map['clases_asistidas'] ?? 0,
      clasesFaltadas: map['clases_faltadas'] ?? 0,
      porcentajeAsistencia: (map['porcentaje_asistencia'] ?? 0.0).toDouble(),
      notaCalculada: (map['nota_calculada'] ?? 0.0).toDouble(),
      estado: map['estado']?.toString() ?? 'PENDIENTE',
      fechaCalculo: DateTime.parse(map['fecha_calculo'] ?? DateTime.now().toIso8601String()),
      observaciones: map['observaciones']?.toString(),
    );
  }

  NotaAsistencia copyWith({
    String? id,
    String? estudianteId,
    String? materiaId,
    String? periodoId,
    String? bimestreId,
    String? configAsistenciaId,
    int? totalClases,
    int? clasesAsistidas,
    int? clasesFaltadas,
    double? porcentajeAsistencia,
    double? notaCalculada,
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
      configAsistenciaId: configAsistenciaId ?? this.configAsistenciaId,
      totalClases: totalClases ?? this.totalClases,
      clasesAsistidas: clasesAsistidas ?? this.clasesAsistidas,
      clasesFaltadas: clasesFaltadas ?? this.clasesFaltadas,
      porcentajeAsistencia: porcentajeAsistencia ?? this.porcentajeAsistencia,
      notaCalculada: notaCalculada ?? this.notaCalculada,
      estado: estado ?? this.estado,
      fechaCalculo: fechaCalculo ?? this.fechaCalculo,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  @override
  String toString() {
    return 'NotaAsistencia($estudianteId - $notaCalculada/10)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotaAsistencia && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}