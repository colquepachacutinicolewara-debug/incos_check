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

  // Getter para verificar si está activo
  bool get estaActivo => estado == 'ACTIVO';

  // Getter para nombre completo
  String get nombreCompleto => '$apellidoPaterno $apellidoMaterno $nombres';

  // Convertir a Map para SQLite
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
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  // Crear desde Map desde SQLite
  factory Docente.fromMap(Map<String, dynamic> map) {
    return Docente(
      id: map['id']?.toString() ?? '',
      apellidoPaterno: map['apellido_paterno']?.toString() ?? '',
      apellidoMaterno: map['apellido_materno']?.toString() ?? '',
      nombres: map['nombres']?.toString() ?? '',
      ci: map['ci']?.toString() ?? '',
      carrera: map['carrera']?.toString() ?? '',
      turno: map['turno']?.toString() ?? 'MAÑANA',
      email: map['email']?.toString() ?? '',
      telefono: map['telefono']?.toString() ?? '',
      estado: map['estado']?.toString() ?? 'ACTIVO',
      fechaCreacion: map['fecha_creacion'] != null 
          ? DateTime.parse(map['fecha_creacion'])
          : null,
      fechaActualizacion: map['fecha_actualizacion'] != null
          ? DateTime.parse(map['fecha_actualizacion'])
          : null,
    );
  }

  // Copiar con nuevos valores
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
      fechaCreacion: fechaCreacion,
      fechaActualizacion: fechaActualizacion,
    );
  }

  @override
  String toString() {
    return 'Docente(id: $id, nombre: $nombreCompleto, ci: $ci, carrera: $carrera, turno: $turno)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Docente && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}