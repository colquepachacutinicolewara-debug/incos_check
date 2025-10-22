class Estudiante {
  final String id;
  final String nombre;
  final String apellidos;
  final String ci;
  final String carrera;
  final String curso;
  final String? huellaId;
  final bool activo;

  Estudiante({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.ci,
    required this.carrera,
    required this.curso,
    this.huellaId,
    this.activo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'ci': ci,
      'carrera': carrera,
      'curso': curso,
      'huellaId': huellaId,
      'activo': activo,
    };
  }

  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id'],
      nombre: map['nombre'],
      apellidos: map['apellidos'],
      ci: map['ci'],
      carrera: map['carrera'],
      curso: map['curso'],
      huellaId: map['huellaId'],
      activo: map['activo'] ?? true,
    );
  }
}