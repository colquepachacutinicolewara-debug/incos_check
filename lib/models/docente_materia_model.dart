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
  final String fechaCreacion;
  final String fechaActualizacion;

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
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  // ✅ CONSTRUCTOR FROM MAP COMPLETO
  factory Docente.fromMap(Map<String, dynamic> map) {
    return Docente(
      id: map['id'] as String? ?? '',
      apellidoPaterno: map['apellido_paterno'] as String? ?? '',
      apellidoMaterno: map['apellido_materno'] as String? ?? '',
      nombres: map['nombres'] as String? ?? '',
      ci: map['ci'] as String? ?? '',
      carrera: map['carrera'] as String? ?? 'Informática',
      turno: map['turno'] as String? ?? 'MAÑANA',
      email: map['email'] as String? ?? '',
      telefono: map['telefono'] as String? ?? '',
      estado: map['estado'] as String? ?? 'ACTIVO',
      fechaCreacion: map['fecha_creacion'] as String? ?? DateTime.now().toIso8601String(),
      fechaActualizacion: map['fecha_actualizacion'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  // ✅ MÉTODO COPYWITH COMPLETO
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
    String? fechaCreacion,
    String? fechaActualizacion,
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

  // ✅ MÉTODO TO MAP COMPLETO
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
      'fecha_creacion': fechaCreacion,
      'fecha_actualizacion': fechaActualizacion,
    };
  }

  // ✅ GETTERS ÚTILES
  bool get estaActivo => estado == 'ACTIVO';
  
  String get nombreCompleto {
    return '$apellidoPaterno ${apellidoMaterno.isNotEmpty ? apellidoMaterno : ''} $nombres'
        .replaceAll('  ', ' ')
        .trim();
  }

  @override
  String toString() {
    return 'Docente($nombreCompleto, CI: $ci, $carrera, $turno)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Docente && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}