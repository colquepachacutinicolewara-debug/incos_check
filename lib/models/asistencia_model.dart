import 'package:flutter/material.dart';

class AsistenciaData {
  final String dia;
  final int porcentaje;

  AsistenciaData(this.dia, this.porcentaje);
}

class EstadoAsistencia {
  final bool asistenciaRegistradaHoy;
  final List<AsistenciaData> datosAsistencia;

  EstadoAsistencia({
    required this.asistenciaRegistradaHoy,
    required this.datosAsistencia,
  });

  EstadoAsistencia copyWith({
    bool? asistenciaRegistradaHoy,
    List<AsistenciaData>? datosAsistencia,
  }) {
    return EstadoAsistencia(
      asistenciaRegistradaHoy:
          asistenciaRegistradaHoy ?? this.asistenciaRegistradaHoy,
      datosAsistencia: datosAsistencia ?? this.datosAsistencia,
    );
  }
}
