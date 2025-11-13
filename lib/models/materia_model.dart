// models/materia_model.dart
import 'package:flutter/material.dart';

class Materia {
  final String id;
  final String codigo;
  final String nombre;
  final String carrera;
  final int anio;
  final Color color;
  final bool activo;
  final String paralelo;
  final String turno;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Materia({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.carrera,
    required this.anio,
    required this.color,
    this.activo = true,
    required this.paralelo,
    required this.turno,
    this.createdAt,
    this.updatedAt,
  });

  // Propiedades computadas
  String get nombreCompleto => '$codigo - $nombre';
  String get anioDisplay => '$anio° Año';
  String get paraleloDisplay => 'Paralelo $paralelo';
  String get turnoDisplay => 'Turno $turno';

  String get displayInfo => '$codigo - $nombre ($paralelo)';

  Materia copyWith({
    String? id,
    String? codigo,
    String? nombre,
    String? carrera,
    int? anio,
    Color? color,
    bool? activo,
    String? paralelo,
    String? turno,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Materia(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      carrera: carrera ?? this.carrera,
      anio: anio ?? this.anio,
      color: color ?? this.color,
      activo: activo ?? this.activo,
      paralelo: paralelo ?? this.paralelo,
      turno: turno ?? this.turno,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'carrera': carrera,
      'anio': anio,
      'color': color.value.toRadixString(16).padLeft(8, '0').toUpperCase(),
      'activo': activo ? 1 : 0,
      'paralelo': paralelo,
      'turno': turno,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Materia.fromMap(Map<String, dynamic> map) {
    Color parseColor(String colorString) {
      try {
        // Si es un string hexadecimal (con o sin #)
        String hexColor = colorString.replaceAll('#', '');
        if (hexColor.length == 6) {
          hexColor = 'FF$hexColor'; // Agregar alpha
        }
        return Color(int.parse(hexColor, radix: 16));
      } catch (e) {
        return const Color(0xFF1565C0);
      }
    }

    return Materia(
      id: map['id'] ?? '',
      codigo: map['codigo'] ?? '',
      nombre: map['nombre'] ?? '',
      carrera: map['carrera'] ?? '',
      anio: map['anio'] ?? 1,
      color: parseColor(map['color']?.toString() ?? 'FF1565C0'),
      activo: (map['activo'] ?? 1) == 1,
      paralelo: map['paralelo'] ?? 'A',
      turno: map['turno'] ?? 'Mañana',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  @override
  String toString() {
    return 'Materia($id: $nombreCompleto)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Materia &&
        other.id == id &&
        other.codigo == codigo &&
        other.paralelo == paralelo &&
        other.turno == turno;
  }

  @override
  int get hashCode {
    return id.hashCode ^ codigo.hashCode ^ paralelo.hashCode ^ turno.hashCode;
  }
}