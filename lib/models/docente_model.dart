// models/docente_model.dart - VERSIÓN CORREGIDA
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
  final String? usuarioId;

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
    this.usuarioId,
  });

  // ========== PROPIEDADES CALCULADAS MEJORADAS ==========
  bool get estaActivo => estado == 'ACTIVO';
  String get nombreCompleto => '$nombres $apellidoPaterno $apellidoMaterno';
  String get nombreCorto => '$nombres $apellidoPaterno';
  String get iniciales => nombres.isNotEmpty && apellidoPaterno.isNotEmpty 
      ? '${nombres[0]}${apellidoPaterno[0]}' 
      : '??';

  // ========== CONVERSIÓN SQLITE MEJORADA ==========
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
      'usuario_id': usuarioId,
    };
  }

  factory Docente.fromMap(Map<String, dynamic> map) {
    return Docente(
      id: map['id']?.toString() ?? '',
      apellidoPaterno: map['apellido_paterno']?.toString() ?? '',
      apellidoMaterno: map['apellido_materno']?.toString() ?? '',
      nombres: map['nombres']?.toString() ?? '',
      ci: map['ci']?.toString() ?? '',
      carrera: map['carrera']?.toString() ?? 'Sistemas Informáticos',
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
      usuarioId: map['usuario_id']?.toString(),
    );
  }

  // ========== MÉTODO PARA CREAR USUARIO AUTOMÁTICO ==========
  // Este método se implementará en el servicio para evitar importación circular
  Map<String, dynamic> toUserCreationMap() {
    return {
      'id': 'doc_$id',
      'ci': ci,
      'nombre_completo': nombreCompleto,
      'email': email,
      'telefono': telefono,
      'carrera': carrera,
      'turno': turno,
    };
  }

  // ========== MÉTODOS DE UTILIDAD ==========
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
    String? usuarioId,
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
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }

  Map<String, dynamic> toAuthMap() {
    return {
      'id': id,
      'ci': ci,
      'nombre_completo': nombreCompleto,
      'email': email,
      'carrera': carrera,
      'turno': turno,
      'telefono': telefono,
      'usuario_id': usuarioId,
    };
  }

  @override
  String toString() => 'Docente($id: $nombreCompleto - $carrera)';

  @override
  bool operator ==(Object other) => identical(this, other) || other is Docente && other.id == id;

  @override
  int get hashCode => id.hashCode;
}