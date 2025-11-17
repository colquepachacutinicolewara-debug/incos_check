import 'dart:convert';

class Bimestre {
  final String id;
  final String periodoId;
  final String nombre;
  final Map<String, dynamic> fechas;
  final Map<String, dynamic>? datosEstudiantes;

  Bimestre({
    required this.id,
    required this.periodoId,
    required this.nombre,
    required this.fechas,
    this.datosEstudiantes,
  });

  // Constructor desde Map
  factory Bimestre.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> fechasData = {};
    Map<String, dynamic>? datosEstudiantesData;

    try {
      if (map['fechas'] is String) {
        fechasData = Map<String, dynamic>.from(json.decode(map['fechas']));
      } else if (map['fechas'] is Map) {
        fechasData = Map<String, dynamic>.from(map['fechas']);
      }

      if (map['datos_estudiantes'] != null) {
        if (map['datos_estudiantes'] is String) {
          datosEstudiantesData = Map<String, dynamic>.from(json.decode(map['datos_estudiantes']));
        } else if (map['datos_estudiantes'] is Map) {
          datosEstudiantesData = Map<String, dynamic>.from(map['datos_estudiantes']);
        }
      }
    } catch (e) {
      print('Error parsing bimestre data: $e');
    }

    return Bimestre(
      id: map['id']?.toString() ?? '',
      periodoId: map['periodo_id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      fechas: fechasData,
      datosEstudiantes: datosEstudiantesData,
    );
  }

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'periodo_id': periodoId,
      'nombre': nombre,
      'fechas': json.encode(fechas),
      'datos_estudiantes': datosEstudiantes != null ? json.encode(datosEstudiantes) : null,
    };
  }

  // Propiedades computadas
  String? get fechaInicio => fechas['inicio']?.toString();
  String? get fechaFin => fechas['fin']?.toString();

  String get rangoFechas {
    if (fechaInicio != null && fechaFin != null) {
      return '$fechaInicio - $fechaFin';
    }
    return 'Fechas no definidas';
  }

  int get numeroBimestre {
    final match = RegExp(r'(\d+)').firstMatch(nombre);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 1;
    }
    return 1;
  }

  String get displayName => 'Bimestre $numeroBimestre';

  bool get tieneFechasDefinidas => fechaInicio != null && fechaFin != null;

  // Método para copiar
  Bimestre copyWith({
    String? id,
    String? periodoId,
    String? nombre,
    Map<String, dynamic>? fechas,
    Map<String, dynamic>? datosEstudiantes,
  }) {
    return Bimestre(
      id: id ?? this.id,
      periodoId: periodoId ?? this.periodoId,
      nombre: nombre ?? this.nombre,
      fechas: fechas ?? this.fechas,
      datosEstudiantes: datosEstudiantes ?? this.datosEstudiantes,
    );
  }

  @override
  String toString() {
    return 'Bimestre($id: $nombre - $periodoId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bimestre && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}