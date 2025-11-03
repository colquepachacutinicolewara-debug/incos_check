class Paralelo {
  final String id;
  final String nombre;
  final bool activo;
  final List<Map<String, dynamic>> estudiantes;

  Paralelo({
    required this.id,
    required this.nombre,
    required this.activo,
    required this.estudiantes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'activo': activo,
      'estudiantes': estudiantes,
    };
  }

  factory Paralelo.fromMap(Map<String, dynamic> map) {
    return Paralelo(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      activo: map['activo'] ?? true,
      estudiantes: List<Map<String, dynamic>>.from(map['estudiantes'] ?? []),
    );
  }
}
