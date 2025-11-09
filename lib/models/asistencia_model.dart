// models/asistencia_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AsistenciaData {
  final String dia;
  final int porcentaje;

  AsistenciaData(this.dia, this.porcentaje);

  // Constructor desde Firestore
  factory AsistenciaData.fromFirestore(Map<String, dynamic> data) {
    return AsistenciaData(data['dia'] ?? '', (data['porcentaje'] ?? 0).toInt());
  }

  Map<String, dynamic> toFirestore() {
    return {'dia': dia, 'porcentaje': porcentaje};
  }
}

class EstadoAsistencia {
  final bool asistenciaRegistradaHoy;
  final List<AsistenciaData> datosAsistencia;
  final DateTime? ultimaActualizacion;

  EstadoAsistencia({
    required this.asistenciaRegistradaHoy,
    required this.datosAsistencia,
    this.ultimaActualizacion,
  });

  EstadoAsistencia copyWith({
    bool? asistenciaRegistradaHoy,
    List<AsistenciaData>? datosAsistencia,
    DateTime? ultimaActualizacion,
  }) {
    return EstadoAsistencia(
      asistenciaRegistradaHoy:
          asistenciaRegistradaHoy ?? this.asistenciaRegistradaHoy,
      datosAsistencia: datosAsistencia ?? this.datosAsistencia,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
    );
  }

  // Constructor desde Firestore
  factory EstadoAsistencia.fromFirestore(Map<String, dynamic> data) {
    final datosAsistencia =
        (data['datosAsistencia'] as List<dynamic>?)
            ?.map(
              (item) =>
                  AsistenciaData.fromFirestore(Map<String, dynamic>.from(item)),
            )
            .toList() ??
        [];

    return EstadoAsistencia(
      asistenciaRegistradaHoy: data['asistenciaRegistradaHoy'] ?? false,
      datosAsistencia: datosAsistencia,
      ultimaActualizacion: data['ultimaActualizacion'] != null
          ? (data['ultimaActualizacion'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'asistenciaRegistradaHoy': asistenciaRegistradaHoy,
      'datosAsistencia': datosAsistencia
          .map((data) => data.toFirestore())
          .toList(),
      'ultimaActualizacion': FieldValue.serverTimestamp(),
    };
  }
}
