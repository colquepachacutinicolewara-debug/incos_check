// docente_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

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
      'fechaCreacion': fechaCreacion ?? FieldValue.serverTimestamp(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    };
  }

  factory Docente.fromFirestore(String id, Map<String, dynamic> data) {
    return Docente(
      id: id,
      apellidoPaterno: data['apellidoPaterno'] as String,
      apellidoMaterno: data['apellidoMaterno'] as String,
      nombres: data['nombres'] as String,
      ci: data['ci'] as String,
      carrera: data['carrera'] as String,
      turno: data['turno'] as String,
      email: data['email'] as String,
      telefono: data['telefono'] as String,
      estado: data['estado'] as String? ?? Estados.activo,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate(),
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp?)?.toDate(),
    );
  }

  factory Docente.fromMap(Map<String, dynamic> map) {
    return Docente(
      id: map['id'] as String,
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
}
