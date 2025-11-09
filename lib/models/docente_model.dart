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

  // Método copyWith mejorado
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

  // Para uso local
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
      'fechaCreacion': fechaCreacion?.millisecondsSinceEpoch,
      'fechaActualizacion': fechaActualizacion?.millisecondsSinceEpoch,
    };
  }

  // Para Firestore - CORREGIDO
  Map<String, dynamic> toFirestore() {
    final map = {
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'nombres': nombres,
      'ci': ci,
      'carrera': carrera,
      'turno': turno,
      'email': email,
      'telefono': telefono,
      'estado': estado,
      'fechaActualizacion': FieldValue.serverTimestamp(),
    };

    // Solo agregar fechaCreacion si es nuevo documento
    if (id.isEmpty) {
      map['fechaCreacion'] = FieldValue.serverTimestamp();
    } else if (fechaCreacion != null) {
      map['fechaCreacion'] = Timestamp.fromDate(fechaCreacion!);
    }

    return map;
  }

  // Factory desde Firestore - CORREGIDO
  factory Docente.fromFirestore(String id, Map<String, dynamic> data) {
    return Docente(
      id: id,
      apellidoPaterno: data['apellidoPaterno'] as String? ?? '',
      apellidoMaterno: data['apellidoMaterno'] as String? ?? '',
      nombres: data['nombres'] as String? ?? '',
      ci: data['ci'] as String? ?? '',
      carrera: data['carrera'] as String? ?? '',
      turno: data['turno'] as String? ?? 'MAÑANA',
      email: data['email'] as String? ?? '',
      telefono: data['telefono'] as String? ?? '',
      estado: data['estado'] as String? ?? Estados.activo,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate(),
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp?)?.toDate(),
    );
  }

  // Factory desde Map local
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
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['fechaCreacion'] as int)
          : null,
      fechaActualizacion: map['fechaActualizacion'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['fechaActualizacion'] as int,
            )
          : null,
    );
  }

  @override
  String toString() {
    return 'Docente($id: $nombres $apellidoPaterno $apellidoMaterno)';
  }
}
