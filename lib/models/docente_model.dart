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
      'created_at': fechaCreacion?.toIso8601String(),
      'updated_at': fechaActualizacion?.toIso8601String(),
    };
  }

  // Crear desde Map desde SQLite
  factory Docente.fromMap(Map<String, dynamic> map) {
    return Docente(
      id: map['id'] as String,
      apellidoPaterno: map['apellido_paterno'] as String,
      apellidoMaterno: map['apellido_materno'] as String,
      nombres: map['nombres'] as String,
      ci: map['ci'] as String,
      carrera: map['carrera'] as String,
      turno: map['turno'] as String,
      email: map['email'] as String,
      telefono: map['telefono'] as String,
      estado: map['estado'] as String,
      fechaCreacion: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : null,
      fechaActualizacion: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
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