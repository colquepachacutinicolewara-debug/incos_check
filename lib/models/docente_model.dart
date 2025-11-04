import 'package:cloud_firestore/cloud_firestore.dart';

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
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

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

  // Crear Docente desde Firestore
  factory Docente.fromFirestore(String docId, Map<String, dynamic> data) {
    return Docente(
      id: docId,
      apellidoPaterno: data['apellidoPaterno'] ?? '',
      apellidoMaterno: data['apellidoMaterno'] ?? '',
      nombres: data['nombres'] ?? '',
      ci: data['ci'] ?? '',
      carrera: data['carrera'] ?? '',
      turno: data['turno'] ?? 'MAÑANA',
      email: data['email'] ?? '',
      telefono: data['telefono'] ?? '',
      estado: data['estado'] ?? 'Activo',
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp).toDate(),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'nombres': nombres,
      'ci': ci,
      'carrera': carrera,
      'turno': turno,
      'email': email,
      'telefono': telefono,
      'estado': estado,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaActualizacion': Timestamp.fromDate(fechaActualizacion),
    };
  }

  // Para compatibilidad con tu UI existente
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

  // Para crear nuevos docentes
  factory Docente.createNew({
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String nombres,
    required String ci,
    required String carrera,
    required String turno,
    required String email,
    required String telefono,
    required String estado,
  }) {
    final now = DateTime.now();
    return Docente(
      id: '', // Firestore generará el ID
      apellidoPaterno: apellidoPaterno,
      apellidoMaterno: apellidoMaterno,
      nombres: nombres,
      ci: ci,
      carrera: carrera,
      turno: turno,
      email: email,
      telefono: telefono,
      estado: estado,
      fechaCreacion: now,
      fechaActualizacion: now,
    );
  }

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
      fechaActualizacion: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Docente(id: $id, nombre: $nombres $apellidoPaterno, carrera: $carrera)';
  }
}
