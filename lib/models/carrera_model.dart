import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarreraModel {
  final String id;
  final String nombre;
  final String color;
  final IconData icono;
  final bool activa;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  CarreraModel({
    required this.id,
    required this.nombre,
    required this.color,
    required this.icono,
    required this.activa,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  // Getter para compatibilidad (puedes usar icono o icon)
  IconData get icon => icono;

  // Método fromFirestore
  static CarreraModel fromFirestore(String id, Map<String, dynamic> data) {
    return CarreraModel(
      id: id,
      nombre: data['nombre'] ?? '',
      color: data['color'] ?? '#2196F3',
      icono: _getIconFromCode(data['iconCode'] ?? Icons.school.codePoint),
      activa: data['activa'] ?? true,
      fechaCreacion: data['fechaCreacion'] != null
          ? (data['fechaCreacion'] as Timestamp).toDate()
          : null,
      fechaActualizacion: data['fechaActualizacion'] != null
          ? (data['fechaActualizacion'] as Timestamp).toDate()
          : null,
    );
  }

  // Método para convertir a mapa (para Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'color': color,
      'iconCode': icono.codePoint,
      'activa': activa,
      'fechaCreacion': fechaCreacion != null
          ? Timestamp.fromDate(fechaCreacion!)
          : FieldValue.serverTimestamp(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    };
  }

  // Método toMap para la UI
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
      'icon': icono,
      'iconCode': icono.codePoint,
      'activa': activa,
      'fechaCreacion': fechaCreacion,
      'fechaActualizacion': fechaActualizacion,
    };
  }

  // Método auxiliar para obtener IconData desde codePoint
  static IconData _getIconFromCode(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  // Método para obtener Color desde string
  Color get colorValue {
    try {
      return Color(int.parse(color.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  // Copiar con cambios
  CarreraModel copyWith({
    String? id,
    String? nombre,
    String? color,
    IconData? icono,
    bool? activa,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return CarreraModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
      icono: icono ?? this.icono,
      activa: activa ?? this.activa,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return 'CarreraModel(id: $id, nombre: $nombre, activa: $activa)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarreraModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
