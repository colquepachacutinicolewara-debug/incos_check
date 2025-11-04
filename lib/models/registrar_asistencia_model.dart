class Estudiante {
  final String nombre;
  final String curso;
  final bool huellaAsignada;

  Estudiante({
    required this.nombre,
    required this.curso,
    required this.huellaAsignada,
  });

  // Para fácil conversión desde Map
  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      nombre: map['nombre'] ?? '',
      curso: map['curso'] ?? '',
      huellaAsignada: map['huellaAsignada'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'nombre': nombre, 'curso': curso, 'huellaAsignada': huellaAsignada};
  }
}
