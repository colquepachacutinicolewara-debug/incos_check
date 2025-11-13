// models/turno_model.dart
import 'package:flutter/material.dart';
import 'dart:convert';

class TurnoModel {
  final String id;
  final String nombre;
  final IconData icon;
  final String horario;
  final String rangoAsistencia;
  final String dias;
  final String color;
  final bool activo;
  final List<dynamic> niveles;

  TurnoModel({
    required this.id,
    required this.nombre,
    required this.icon,
    required this.horario,
    required this.rangoAsistencia,
    required this.dias,
    required this.color,
    required this.activo,
    required this.niveles,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'icon_code_point': icon.codePoint,
      'horario': horario,
      'rango_asistencia': rangoAsistencia,
      'dias': dias,
      'color': color,
      'activo': activo ? 1 : 0,
      'niveles': json.encode(niveles),
    };
  }

  static TurnoModel fromMap(String id, Map<String, dynamic> map) {
    final iconCode = map['icon_code_point'] ?? Icons.wb_sunny.codePoint;
    final IconData icon = IconData(iconCode, fontFamily: 'MaterialIcons');

    List<dynamic> niveles = [];
    try {
      if (map['niveles'] is String) {
        niveles = json.decode(map['niveles']);
      } else if (map['niveles'] is List) {
        niveles = List<dynamic>.from(map['niveles']);
      }
    } catch (e) {
      print('Error parsing niveles: $e');
    }

    return TurnoModel(
      id: id,
      nombre: map['nombre']?.toString() ?? 'Sin nombre',
      icon: icon,
      horario: map['horario']?.toString() ?? 'Sin horario',
      rangoAsistencia: map['rango_asistencia']?.toString() ?? 'Sin rango',
      dias: map['dias']?.toString() ?? 'Sin días',
      color: map['color']?.toString() ?? '#FFA000',
      activo: (map['activo'] ?? 1) == 1,
      niveles: niveles,
    );
  }

  TurnoModel copyWith({
    String? id,
    String? nombre,
    IconData? icon,
    String? horario,
    String? rangoAsistencia,
    String? dias,
    String? color,
    bool? activo,
    List<dynamic>? niveles,
  }) {
    return TurnoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      icon: icon ?? this.icon,
      horario: horario ?? this.horario,
      rangoAsistencia: rangoAsistencia ?? this.rangoAsistencia,
      dias: dias ?? this.dias,
      color: color ?? this.color,
      activo: activo ?? this.activo,
      niveles: niveles ?? this.niveles,
    );
  }

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFFFFA000);
    }
  }

  String get displayName => nombre;
  String get infoCompleta => '$nombre ($horario)';
  bool get estaActivo => activo;
  int get totalNiveles => niveles.length;
  bool get tieneNiveles => niveles.isNotEmpty;

  List<String> get nivelesList {
    return niveles.map((n) => n.toString()).toList();
  }

  String get nivelesDisplay {
    if (niveles.isEmpty) return 'Sin niveles';
    if (niveles.length == 1) return niveles.first.toString();
    return '${niveles.length} niveles';
  }

  @override
  String toString() {
    return 'TurnoModel($id: $nombre - $horario)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TurnoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}