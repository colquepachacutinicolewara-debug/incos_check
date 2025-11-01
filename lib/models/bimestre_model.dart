import 'package:flutter/widgets.dart';

import '../../utils/constants.dart';

class PeriodoAcademico {
  final String id;
  final String nombre;
  final String tipo; // 'Bimestral', 'Semestral', 'Trimestral'
  final int numero;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado; // 'Planificado', 'En Curso', 'Finalizado', 'Cancelado'
  final List<String> fechasClases;
  final String? descripcion;
  final DateTime fechaCreacion;

  PeriodoAcademico({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.numero,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.fechasClases,
    this.descripcion,
    required this.fechaCreacion,
  });

  int get totalClases => fechasClases.length;
  int get duracionDias => fechaFin.difference(fechaInicio).inDays;

  String get rangoFechas =>
      '${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year} - '
      '${fechaFin.day}/${fechaFin.month}/${fechaFin.year}';

  bool get estaActivo => estado == 'En Curso';
  bool get puedeEditar => estado == 'Planificado' || estado == 'En Curso';

  Color get colorEstado => PeriodoColors.getColorPorEstado(estado);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'numero': numero,
      'fechaInicio': fechaInicio.millisecondsSinceEpoch,
      'fechaFin': fechaFin.millisecondsSinceEpoch,
      'estado': estado,
      'fechasClases': fechasClases,
      'descripcion': descripcion,
      'fechaCreacion': fechaCreacion.millisecondsSinceEpoch,
    };
  }

  factory PeriodoAcademico.fromMap(Map<String, dynamic> map) {
    return PeriodoAcademico(
      id: map['id'],
      nombre: map['nombre'],
      tipo: map['tipo'],
      numero: map['numero'],
      fechaInicio: DateTime.fromMillisecondsSinceEpoch(map['fechaInicio']),
      fechaFin: DateTime.fromMillisecondsSinceEpoch(map['fechaFin']),
      estado: map['estado'],
      fechasClases: List<String>.from(map['fechasClases']),
      descripcion: map['descripcion'],
      fechaCreacion: DateTime.fromMillisecondsSinceEpoch(map['fechaCreacion']),
    );
  }

  PeriodoAcademico copyWith({
    String? nombre,
    String? tipo,
    int? numero,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? estado,
    List<String>? fechasClases,
    String? descripcion,
  }) {
    return PeriodoAcademico(
      id: id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      numero: numero ?? this.numero,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      fechasClases: fechasClases ?? this.fechasClases,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion,
    );
  }
}
