import 'package:cloud_firestore/cloud_firestore.dart'; // IMPORTACIÓN AGREGADA

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'activo': activo,
      'estudiantes': estudiantes,
      'fechaCreacion': fechaCreacion,
      'fechaActualizacion': fechaActualizacion,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'activo': activo,
      'estudiantes': estudiantes,
      'fechaCreacion': fechaCreacion != null
          ? Timestamp.fromDate(fechaCreacion!)
          : FieldValue.serverTimestamp(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    };
  }

  factory Paralelo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Paralelo(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      activo: data['activo'] ?? true,
      estudiantes: List<Map<String, dynamic>>.from(data['estudiantes'] ?? []),
      fechaCreacion: data['fechaCreacion']?.toDate(),
      fechaActualizacion: data['fechaActualizacion']?.toDate(),
    );
  }

  factory Paralelo.fromMap(Map<String, dynamic> map) {
    return Paralelo(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      activo: map['activo'] ?? true,
      estudiantes: List<Map<String, dynamic>>.from(map['estudiantes'] ?? []),
      fechaCreacion: map['fechaCreacion'] is Timestamp
          ? (map['fechaCreacion'] as Timestamp).toDate()
          : null,
      fechaActualizacion: map['fechaActualizacion'] is Timestamp
          ? (map['fechaActualizacion'] as Timestamp).toDate()
          : null,
    );
  }

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

  // Método para crear un nuevo paralelo para Firestore
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

  // Método para actualizar en Firestore
  Map<String, dynamic> toUpdateMap() {
    return {
      'nombre': nombre,
      'activo': activo,
      'fechaActualizacion': FieldValue.serverTimestamp(),
    };
  }
}
