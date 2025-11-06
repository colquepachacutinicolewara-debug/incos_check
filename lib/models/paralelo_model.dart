// paralelo_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Paralelo {
  final String id;
  final String nombre;
  final bool activo;
  final List<Map<String, dynamic>> estudiantes;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  Paralelo({
    required this.id,
    required this.nombre,
    required this.activo,
    required this.estudiantes,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  Paralelo copyWith({
    String? id,
    String? nombre,
    bool? activo,
    List<Map<String, dynamic>>? estudiantes,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Paralelo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      activo: activo ?? this.activo,
      estudiantes: estudiantes ?? this.estudiantes,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'activo': activo,
      'estudiantes': estudiantes,
      'fechaCreacion': fechaCreacion?.millisecondsSinceEpoch,
      'fechaActualizacion': fechaActualizacion?.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toFirestore() {
    final map = {
      'nombre': nombre,
      'activo': activo,
      'estudiantes': estudiantes,
      'fechaActualizacion': FieldValue.serverTimestamp(),
    };

    if (id.isEmpty) {
      map['fechaCreacion'] = FieldValue.serverTimestamp();
    } else if (fechaCreacion != null) {
      map['fechaCreacion'] = Timestamp.fromDate(fechaCreacion!);
    }

    return map;
  }

  factory Paralelo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Paralelo(
      id: doc.id,
      nombre: data['nombre'] as String? ?? '',
      activo: data['activo'] as bool? ?? true,
      estudiantes: List<Map<String, dynamic>>.from(data['estudiantes'] ?? []),
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate(),
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp?)?.toDate(),
    );
  }

  factory Paralelo.fromMap(Map<String, dynamic> map) {
    return Paralelo(
      id: map['id'] as String? ?? '',
      nombre: map['nombre'] as String? ?? '',
      activo: map['activo'] as bool? ?? true,
      estudiantes: List<Map<String, dynamic>>.from(map['estudiantes'] ?? []),
      fechaCreacion: map['fechaCreacion'] is Timestamp
          ? (map['fechaCreacion'] as Timestamp).toDate()
          : null,
      fechaActualizacion: map['fechaActualizacion'] is Timestamp
          ? (map['fechaActualizacion'] as Timestamp).toDate()
          : null,
    );
  }

  static Map<String, dynamic> createForFirestore({
    required String nombre,
    bool activo = true,
  }) {
    return {
      'nombre': nombre,
      'activo': activo,
      'estudiantes': [],
      'fechaCreacion': FieldValue.serverTimestamp(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'nombre': nombre,
      'activo': activo,
      'fechaActualizacion': FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() {
    return 'Paralelo($id: $nombre - ${activo ? "Activo" : "Inactivo"} - ${estudiantes.length} estudiantes)';
  }
}
