// models/paralelo_model.dart
import 'dart:convert';

class Paralelo {
  final String id;
  final String nombre;
  final bool activo;
  final List<Map<String, dynamic>> estudiantes;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  Paralelo({
    required this.id,
    required this.nombre,
    required this.activo,
    required this.estudiantes,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  Paralelo copyWith({
    String? id,
    String? nombre,
    bool? activo,
    List<Map<String, dynamic>>? estudiantes,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Paralelo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      activo: activo ?? this.activo,
      estudiantes: estudiantes ?? this.estudiantes,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'activo': activo ? 1 : 0,
      'estudiantes': json.encode(estudiantes),
      'fecha_creacion': fechaCreacion?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Paralelo.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> estudiantes = [];
    try {
      if (map['estudiantes'] is String && map['estudiantes'].toString().isNotEmpty) {
        estudiantes = List<Map<String, dynamic>>.from(
          json.decode(map['estudiantes']).map((x) => Map<String, dynamic>.from(x))
        );
      } else if (map['estudiantes'] is List) {
        estudiantes = List<Map<String, dynamic>>.from(map['estudiantes']);
      }
    } catch (e) {
      print('Error parsing estudiantes: $e');
    }

    return Paralelo(
      id: map['id'] as String? ?? '',
      nombre: map['nombre'] as String? ?? '',
      activo: (map['activo'] ?? 1) == 1,
      estudiantes: estudiantes,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'])
          : null,
      fechaActualizacion: map['fecha_actualizacion'] != null
          ? DateTime.parse(map['fecha_actualizacion'])
          : null,
    );
  }

  int get totalEstudiantes => estudiantes.length;
  bool get tieneEstudiantes => estudiantes.isNotEmpty;
  bool get estaActivo => activo;

  String get displayName => 'Paralelo $nombre';
  String get infoCompleta => 'Paralelo $nombre - $totalEstudiantes estudiantes';

  static Map<String, dynamic> createForInsert({
    required String nombre,
    bool activo = true,
  }) {
    return {
      'nombre': nombre,
      'activo': activo ? 1 : 0,
      'estudiantes': '[]',
      'fecha_creacion': DateTime.now().toIso8601String(),
      'fecha_actualizacion': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'nombre': nombre,
      'activo': activo ? 1 : 0,
      'estudiantes': json.encode(estudiantes),
      'fecha_actualizacion': DateTime.now().toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Paralelo($id: $nombre - ${activo ? "Activo" : "Inactivo"} - $totalEstudiantes estudiantes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Paralelo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}