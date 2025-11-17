import 'package:flutter/material.dart';
import 'dart:convert';

class PeriodoAcademico {
  final String id;
  final String nombre;
  final String tipo;
  final int numero;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;
  final List<String> fechasClases;
  final String descripcion;
  final DateTime fechaCreacion;
  final int? totalClases;
  final int? duracionDias;

  PeriodoAcademico({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.numero,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.fechasClases,
    required this.descripcion,
    required this.fechaCreacion,
    this.totalClases,
    this.duracionDias,
  });

  // Getters computados
  int get totalClasesComputed => fechasClases.length;
  int get duracionDiasComputed => fechaFin.difference(fechaInicio).inDays;
  bool get estaActivo => estado == 'En Curso';
  bool get puedeEditar => estado == 'Planificado' || estado == 'En Curso';

  String get rangoFechas =>
      '${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year} - '
      '${fechaFin.day}/${fechaFin.month}/${fechaFin.year}';

  Color get colorEstado {
    switch (estado) {
      case 'Planificado':
        return Colors.blue;
      case 'En Curso':
        return Colors.green;
      case 'Finalizado':
        return Colors.grey;
      case 'Cancelado':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String get estadoDisplay {
    switch (estado) {
      case 'En Curso':
        return 'En Curso';
      case 'Planificado':
        return 'Planificado';
      case 'Finalizado':
        return 'Finalizado';
      case 'Cancelado':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'numero': numero,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'estado': estado,
      'fechas_clases': json.encode(fechasClases),
      'descripcion': descripcion,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'total_clases': totalClasesComputed,
      'duracion_dias': duracionDiasComputed,
    };
  }

  factory PeriodoAcademico.fromMap(Map<String, dynamic> map) {
    List<String> fechasClases = [];
    try {
      if (map['fechas_clases'] is String) {
        fechasClases = List<String>.from(json.decode(map['fechas_clases']));
      } else if (map['fechas_clases'] is List) {
        fechasClases = List<String>.from(map['fechas_clases']);
      }
    } catch (e) {
      print('Error parsing fechas_clases: $e');
    }

    return PeriodoAcademico(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      tipo: map['tipo'] ?? '',
      numero: map['numero'] ?? 0,
      fechaInicio: DateTime.parse(map['fecha_inicio'] ?? DateTime.now().toIso8601String()),
      fechaFin: DateTime.parse(map['fecha_fin'] ?? DateTime.now().toIso8601String()),
      estado: map['estado'] ?? '',
      fechasClases: fechasClases,
      descripcion: map['descripcion'] ?? '',
      fechaCreacion: DateTime.parse(map['fecha_creacion'] ?? DateTime.now().toIso8601String()),
      totalClases: map['total_clases'],
      duracionDias: map['duracion_dias'],
    );
  }

  PeriodoAcademico copyWith({
    String? id,
    String? nombre,
    String? tipo,
    int? numero,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? estado,
    List<String>? fechasClases,
    String? descripcion,
    DateTime? fechaCreacion,
  }) {
    return PeriodoAcademico(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      numero: numero ?? this.numero,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      fechasClases: fechasClases ?? this.fechasClases,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'PeriodoAcademico($id: $nombre - $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PeriodoAcademico && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}