// models/estudiante_model.dart
class Estudiante {
  final String id;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String ci;
  final String carrera;
  final String curso;
  final String? huellaId;
  final bool activo;
  final DateTime fechaRegistro;

  Estudiante({
    required this.id,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.ci,
    required this.carrera,
    required this.curso,
    this.huellaId,
    this.activo = true,
    required this.fechaRegistro,
  });

  // Convertir a Map para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'ci': ci,
      'carrera': carrera,
      'curso': curso,
      'huellaId': huellaId,
      'activo': activo ? 1 : 0,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  // Crear desde Map
  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id'],
      nombres: map['nombres'],
      apellidoPaterno: map['apellidoPaterno'],
      apellidoMaterno: map['apellidoMaterno'],
      ci: map['ci'],
      carrera: map['carrera'],
      curso: map['curso'],
      huellaId: map['huellaId'],
      activo: map['activo'] == 1,
      fechaRegistro: DateTime.parse(map['fechaRegistro']),
    );
  }

  // Copiar con nuevos valores
  Estudiante copyWith({
    String? id,
    String? nombres,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? ci,
    String? carrera,
    String? curso,
    String? huellaId,
    bool? activo,
    DateTime? fechaRegistro,
  }) {
    return Estudiante(
      id: id ?? this.id,
      nombres: nombres ?? this.nombres,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      ci: ci ?? this.ci,
      carrera: carrera ?? this.carrera,
      curso: curso ?? this.curso,
      huellaId: huellaId ?? this.huellaId,
      activo: activo ?? this.activo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  // Validar datos del estudiante
  bool get isValid {
    return nombres.isNotEmpty &&
        apellidoPaterno.isNotEmpty &&
        ci.isNotEmpty &&
        carrera.isNotEmpty &&
        curso.isNotEmpty;
  }

  // Nombre completo
  String get nombreCompleto => '$apellidoPaterno $apellidoMaterno $nombres';

  // Apellidos completos
  String get apellidosCompletos => '$apellidoPaterno $apellidoMaterno';
}
