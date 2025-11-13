// models/nivel_model.dart
import 'dart:convert';

class NivelModel {
  final String id;
  final String nombre;
  final bool activo;
  final int orden;
  final List<dynamic> paralelos;

  NivelModel({
    required this.id,
    required this.nombre,
    required this.activo,
    required this.orden,
    required this.paralelos,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'activo': activo ? 1 : 0,
      'orden': orden,
      'paralelos': json.encode(paralelos),
    };
  }

  static NivelModel fromMap(Map<String, dynamic> map) {
    List<dynamic> paralelos = [];
    try {
      if (map['paralelos'] is String) {
        paralelos = json.decode(map['paralelos']);
      } else if (map['paralelos'] is List) {
        paralelos = List<dynamic>.from(map['paralelos']);
      }
    } catch (e) {
      print('Error parsing paralelos: $e');
    }

    return NivelModel(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      activo: (map['activo'] ?? 1) == 1,
      orden: map['orden'] ?? 99,
      paralelos: paralelos,
    );
  }

  NivelModel copyWith({
    String? id,
    String? nombre,
    bool? activo,
    int? orden,
    List<dynamic>? paralelos,
  }) {
    return NivelModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      activo: activo ?? this.activo,
      orden: orden ?? this.orden,
      paralelos: paralelos ?? this.paralelos,
    );
  }

  int get totalParalelos => paralelos.length;
  bool get tieneParalelos => paralelos.isNotEmpty;
  String get paralelosDisplay => paralelos.join(', ');

  List<String> get paralelosList {
    return paralelos.map((p) => p.toString()).toList();
  }

  @override
  String toString() {
    return 'NivelModel($id: $nombre - $totalParalelos paralelos)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NivelModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}  