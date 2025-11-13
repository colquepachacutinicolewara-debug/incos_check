// models/docente_model.dart
class Docente {
  final String id;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String nombres;
  final String ci;
  final String carrera;
  final String turno;
  final String email;
  final String telefono;
  final String estado;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

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
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  Docente copyWith({
    String? id,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? nombres,
    String? ci,
    String? carrera,
    String? turno,
    String? email,
    String? telefono,
    String? estado,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
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
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'nombres': nombres,
      'ci': ci,
      'carrera': carrera,
      'turno': turno,
      'email': email,
      'telefono': telefono,
      'estado': estado,
      'fecha_creacion': fechaCreacion?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Docente.fromMap(Map<String, dynamic> map) {
    return Docente(
      id: map['id'] ?? '',
      apellidoPaterno: map['apellido_paterno'] ?? '',
      apellidoMaterno: map['apellido_materno'] ?? '',
      nombres: map['nombres'] ?? '',
      ci: map['ci'] ?? '',
      carrera: map['carrera'] ?? '',
      turno: map['turno'] ?? 'MAÑANA',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      estado: map['estado'] ?? 'ACTIVO',
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'])
          : null,
      fechaActualizacion: map['fecha_actualizacion'] != null
          ? DateTime.parse(map['fecha_actualizacion'])
          : null,
    );
  }

  // Propiedades computadas
  String get nombreCompleto => '$nombres $apellidoPaterno $apellidoMaterno';
  String get nombreCorto => '$nombres $apellidoPaterno';
  bool get estaActivo => estado == 'ACTIVO';

  String get turnoDisplay {
    switch (turno.toUpperCase()) {
      case 'MAÑANA':
        return 'Mañana';
      case 'TARDE':
        return 'Tarde';
      case 'NOCHE':
        return 'Noche';
      default:
        return turno;
    }
  }

  @override
  String toString() {
    return 'Docente($id: $nombreCompleto - $ci)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Docente && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}