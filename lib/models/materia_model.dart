// models/materia_model.dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  String get nombreCompleto => '$codigo - $nombre';
  String get anioDisplay => '$anio° Año';
  String get paraleloDisplay => 'Paralelo $paralelo';
  String get turnoDisplay => 'Turno $turno';

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
      'color': color.value,
      'activo': activo,
      'paralelo': paralelo,
      'turno': turno,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'carrera': carrera,
      'anio': anio,
      'color': color.value,
      'activo': activo,
      'paralelo': paralelo,
      'turno': turno,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      id: map['id'] ?? '',
      codigo: map['codigo'] ?? '',
      nombre: map['nombre'] ?? '',
      carrera: map['carrera'] ?? '',
      anio: map['anio'] ?? 1,
      color: Color(map['color'] ?? 0xFF1565C0),
      activo: map['activo'] ?? true,
      paralelo: map['paralelo'] ?? 'A',
      turno: map['turno'] ?? 'Mañana',
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  factory Materia.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Materia(
      id: doc.id,
      codigo: data['codigo'] ?? '',
      nombre: data['nombre'] ?? '',
      carrera: data['carrera'] ?? '',
      anio: data['anio'] ?? 1,
      color: Color(data['color'] ?? 0xFF1565C0),
      activo: data['activo'] ?? true,
      paralelo: data['paralelo'] ?? 'A',
      turno: data['turno'] ?? 'Mañana',
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Materia &&
        other.codigo == codigo &&
        other.paralelo == paralelo &&
        other.turno == turno &&
        other.anio == anio &&
        other.carrera == carrera;
  }

  @override
  int get hashCode {
    return codigo.hashCode ^ paralelo.hashCode ^ turno.hashCode ^ anio.hashCode ^ carrera.hashCode;
  }
}