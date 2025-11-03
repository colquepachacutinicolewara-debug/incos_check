class Docente {
  final int id;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String nombres;
  final String ci;
  final String carrera;
  final String turno;
  final String email;
  final String telefono;
  final String estado;

  Docente({
    required this.id,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.nombres,
    required this.ci,
    required this.carrera,
    required this.turno,
    required this.email,
    required this.telefono,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'nombres': nombres,
      'ci': ci,
      'carrera': carrera,
      'turno': turno,
      'email': email,
      'telefono': telefono,
      'estado': estado,
    };
  }

  factory Docente.fromMap(Map<String, dynamic> map) {
    return Docente(
      id: map['id'] as int,
      apellidoPaterno: map['apellidoPaterno'] as String,
      apellidoMaterno: map['apellidoMaterno'] as String,
      nombres: map['nombres'] as String,
      ci: map['ci'] as String,
      carrera: map['carrera'] as String,
      turno: map['turno'] as String,
      email: map['email'] as String,
      telefono: map['telefono'] as String,
      estado: map['estado'] as String,
    );
  }

  Docente copyWith({
    int? id,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? nombres,
    String? ci,
    String? carrera,
    String? turno,
    String? email,
    String? telefono,
    String? estado,
  }) {
    return Docente(
      id: id ?? this.id,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      nombres: nombres ?? this.nombres,
      ci: ci ?? this.ci,
      carrera: carrera ?? this.carrera,
      turno: turno ?? this.turno,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      estado: estado ?? this.estado,
    );
  }
}
