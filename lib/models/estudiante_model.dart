// models/estudiante_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Estudiante {
  final String id;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String ci;
  final String fechaRegistro;
  final int huellasRegistradas;
  final String? carreraId;
  final String? turnoId;
  final String? nivelId;
  final String? paraleloId;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  Estudiante({
    required this.id,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.ci,
    required this.fechaRegistro,
    required this.huellasRegistradas,
    this.carreraId,
    this.turnoId,
    this.nivelId,
    this.paraleloId,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'ci': ci,
      'fechaRegistro': fechaRegistro,
      'huellasRegistradas': huellasRegistradas,
      'carreraId': carreraId,
      'turnoId': turnoId,
      'nivelId': nivelId,
      'paraleloId': paraleloId,
      'fechaCreacion': fechaCreacion?.millisecondsSinceEpoch,
      'fechaActualizacion': fechaActualizacion?.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toFirestore() {
    final map = {
      'nombres': nombres.trim(),
      'apellidoPaterno': apellidoPaterno.trim(),
      'apellidoMaterno': apellidoMaterno.trim(),
      'ci': ci.trim(),
      'fechaRegistro': fechaRegistro,
      'huellasRegistradas': huellasRegistradas,
      'carreraId': carreraId,
      'turnoId': turnoId,
      'nivelId': nivelId,
      'paraleloId': paraleloId,
      'fechaActualizacion': FieldValue.serverTimestamp(),
    };

    // Solo agregar fechaCreacion si es nuevo documento o si ya existe
    if (id.isEmpty) {
      map['fechaCreacion'] = FieldValue.serverTimestamp();
    } else if (fechaCreacion != null) {
      map['fechaCreacion'] = Timestamp.fromDate(fechaCreacion!);
    }

    return map;
  }

  factory Estudiante.fromFirestore(String id, Map<String, dynamic> data) {
    return Estudiante(
      id: id,
      nombres: data['nombres'] as String? ?? '',
      apellidoPaterno: data['apellidoPaterno'] as String? ?? '',
      apellidoMaterno: data['apellidoMaterno'] as String? ?? '',
      ci: data['ci'] as String? ?? '',
      fechaRegistro: data['fechaRegistro'] as String? ?? 
          DateTime.now().toString().split(' ')[0],
      huellasRegistradas: (data['huellasRegistradas'] as num?)?.toInt() ?? 0,
      carreraId: data['carreraId'] as String?,
      turnoId: data['turnoId'] as String?,
      nivelId: data['nivelId'] as String?,
      paraleloId: data['paraleloId'] as String?,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate(),
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp?)?.toDate(),
    );
  }

  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id'] as String,
      nombres: map['nombres'] as String,
      apellidoPaterno: map['apellidoPaterno'] as String,
      apellidoMaterno: map['apellidoMaterno'] as String,
      ci: map['ci'] as String,
      fechaRegistro: map['fechaRegistro'] as String,
      huellasRegistradas: map['huellasRegistradas'] as int,
      carreraId: map['carreraId'] as String?,
      turnoId: map['turnoId'] as String?,
      nivelId: map['nivelId'] as String?,
      paraleloId: map['paraleloId'] as String?,
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

  Estudiante copyWith({
    String? id,
    String? nombres,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? ci,
    String? fechaRegistro,
    int? huellasRegistradas,
    String? carreraId,
    String? turnoId,
    String? nivelId,
    String? paraleloId,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Estudiante(
      id: id ?? this.id,
      nombres: nombres ?? this.nombres,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      ci: ci ?? this.ci,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      huellasRegistradas: huellasRegistradas ?? this.huellasRegistradas,
      carreraId: carreraId ?? this.carreraId,
      turnoId: turnoId ?? this.turnoId,
      nivelId: nivelId ?? this.nivelId,
      paraleloId: paraleloId ?? this.paraleloId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  String get nombreCompleto => '$apellidoPaterno $apellidoMaterno $nombres';
  bool get tieneTodasLasHuellas => huellasRegistradas >= 3;

  @override
  String toString() {
    return 'Estudiante($id: $nombreCompleto - $ci)';
  }
}
