// models/asistencia_model.dart
import 'dart:convert';

class AsistenciaData {
  final String dia;
  final int porcentaje;

  AsistenciaData(this.dia, this.porcentaje);

  // Constructor desde Map
  factory AsistenciaData.fromMap(Map<String, dynamic> data) {
    return AsistenciaData(
      data['dia'] ?? '', 
      (data['porcentaje'] ?? 0).toInt()
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dia': dia,
      'porcentaje': porcentaje,
    };
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
      asistenciaRegistradaHoy: asistenciaRegistradaHoy ?? this.asistenciaRegistradaHoy,
      datosAsistencia: datosAsistencia ?? this.datosAsistencia,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
    );
  }

  // Constructor desde SQLite
  factory EstadoAsistencia.fromMap(Map<String, dynamic> data) {
    final datosAsistencia = <AsistenciaData>[];
    
    if (data['datos_asistencia'] != null && data['datos_asistencia'].toString().isNotEmpty) {
      try {
        final List<dynamic> datos = json.decode(data['datos_asistencia']);
        datosAsistencia.addAll(
          datos.map((item) => AsistenciaData.fromMap(Map<String, dynamic>.from(item)))
        );
      } catch (e) {
        print('Error parsing datos_asistencia: $e');
      }
    }

    return EstadoAsistencia(
      asistenciaRegistradaHoy: (data['asistencia_registrada_hoy'] ?? 0) == 1,
      datosAsistencia: datosAsistencia,
      ultimaActualizacion: data['ultima_actualizacion'] != null 
          ? DateTime.parse(data['ultima_actualizacion'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'asistencia_registrada_hoy': asistenciaRegistradaHoy ? 1 : 0,
      'datos_asistencia': json.encode(datosAsistencia.map((data) => data.toMap()).toList()),
      'ultima_actualizacion': ultimaActualizacion?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Para uso en la UI
  int get totalAsistencias {
    return datosAsistencia.where((data) => data.porcentaje > 0).length;
  }

  double get porcentajeTotal {
    if (datosAsistencia.isEmpty) return 0.0;
    final total = datosAsistencia.fold(0, (sum, data) => sum + data.porcentaje);
    return total / datosAsistencia.length;
  }
}