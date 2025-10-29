// models/estudiante_model.dart
class Estudiante {
  final String id;
  final String nombre;
  final String apellidos;
  final String ci;
  final String carrera;
  final String curso;
  final String? huellaId;
  final bool activo;
  final DateTime fechaRegistro;

  Estudiante({
    required this.id,
    required this.nombre,
    required this.apellidos,
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
      'nombre': nombre,
      'apellidos': apellidos,
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
      nombre: map['nombre'],
      apellidos: map['apellidos'],
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
    String? nombre,
    String? apellidos,
    String? ci,
    String? carrera,
    String? curso,
    String? huellaId,
    bool? activo,
    DateTime? fechaRegistro,
  }) {
    return Estudiante(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
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
    return nombre.isNotEmpty && 
           apellidos.isNotEmpty && 
           ci.isNotEmpty && 
           carrera.isNotEmpty && 
           curso.isNotEmpty;
  }

  // Nombre completo
  String get nombreCompleto => '$nombre $apellidos';
}