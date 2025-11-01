import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Materia {
  final String id;
  final String codigo;
  final String nombre;
  final String carrera;
  final int anio; // Cambié "año" por "anio" (sin ñ)
  final Color color;
  final bool activo;

  Materia({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.carrera,
    required this.anio,
    required this.color,
    this.activo = true,
  });

  String get nombreCompleto => '$codigo - $nombre';
  String get anioDisplay => '$anio° Año'; // Aquí puedes usar °

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'carrera': carrera,
      'anio': anio,
      'color': color.value,
      'activo': activo,
    };
  }

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      id: map['id'],
      codigo: map['codigo'],
      nombre: map['nombre'],
      carrera: map['carrera'],
      anio: map['anio'],
      color: Color(map['color']),
      activo: map['activo'] ?? true,
    );
  }
}
