import 'dart:convert';
class ReporteGenerado {
  final String id;
  final String tipoReporte;
  final String titulo;
  final String periodoId;
  final String? materiaId;
  final String? bimestreId;
  final String formato;
  final Map<String, dynamic>? parametros;
  final String? rutaArchivo;
  final DateTime fechaGeneracion;
  final String usuarioGenerador;
  final String estado;
  final int? tamanoBytes;

  ReporteGenerado({
    required this.id,
    required this.tipoReporte,
    required this.titulo,
    required this.periodoId,
    this.materiaId,
    this.bimestreId,
    this.formato = 'PDF',
    this.parametros,
    this.rutaArchivo,
    required this.fechaGeneracion,
    required this.usuarioGenerador,
    this.estado = 'COMPLETADO',
    this.tamanoBytes,
  });

  // Constructor desde Map
  factory ReporteGenerado.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? parametrosData;

    try {
      if (map['parametros'] != null && map['parametros'].toString().isNotEmpty) {
        if (map['parametros'] is String) {
          parametrosData = Map<String, dynamic>.from(json.decode(map['parametros']));
        } else if (map['parametros'] is Map) {
          parametrosData = Map<String, dynamic>.from(map['parametros']);
        }
      }
    } catch (e) {
      print('Error parsing parametros: $e');
    }

    return ReporteGenerado(
      id: map['id']?.toString() ?? '',
      tipoReporte: map['tipo_reporte']?.toString() ?? '',
      titulo: map['titulo']?.toString() ?? '',
      periodoId: map['periodo_id']?.toString() ?? '',
      materiaId: map['materia_id']?.toString(),
      bimestreId: map['bimestre_id']?.toString(),
      formato: map['formato']?.toString() ?? 'PDF',
      parametros: parametrosData,
      rutaArchivo: map['ruta_archivo']?.toString(),
      fechaGeneracion: DateTime.parse(map['fecha_generacion'] ?? DateTime.now().toIso8601String()),
      usuarioGenerador: map['usuario_generador']?.toString() ?? '',
      estado: map['estado']?.toString() ?? 'COMPLETADO',
      tamanoBytes: int.tryParse(map['tamano_bytes']?.toString() ?? '0'),
    );
  }

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo_reporte': tipoReporte,
      'titulo': titulo,
      'periodo_id': periodoId,
      'materia_id': materiaId,
      'bimestre_id': bimestreId,
      'formato': formato,
      'parametros': parametros != null ? json.encode(parametros) : null,
      'ruta_archivo': rutaArchivo,
      'fecha_generacion': fechaGeneracion.toIso8601String(),
      'usuario_generador': usuarioGenerador,
      'estado': estado,
      'tamano_bytes': tamanoBytes,
    };
  }

  // Propiedades computadas
  bool get esPDF => formato.toUpperCase() == 'PDF';
  bool get esExcel => formato.toUpperCase() == 'EXCEL';
  
  bool get estaCompletado => estado == 'COMPLETADO';
  bool get estaFallido => estado == 'FALLIDO';
  bool get estaEnProgreso => estado == 'EN_PROGRESO';

  String get tamanoDisplay {
    if (tamanoBytes == null) return 'Desconocido';
    
    if (tamanoBytes! < 1024) {
      return '$tamanoBytes B';
    } else if (tamanoBytes! < 1048576) {
      return '${(tamanoBytes! / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(tamanoBytes! / 1048576).toStringAsFixed(1)} MB';
    }
  }

  String get fechaDisplay {
    return '${fechaGeneracion.day}/${fechaGeneracion.month}/${fechaGeneracion.year} ${fechaGeneracion.hour}:${fechaGeneracion.minute.toString().padLeft(2, '0')}';
  }

  String get tipoDisplay {
    switch (tipoReporte) {
      case 'ASISTENCIA_BIMESTRAL':
        return 'Asistencia Bimestral';
      case 'ASISTENCIA_ESTADISTICAS':
        return 'Estadísticas de Asistencia';
      case 'NOTAS_ASISTENCIA':
        return 'Notas de Asistencia';
      default:
        return tipoReporte;
    }
  }

  // Método para copiar
  ReporteGenerado copyWith({
    String? id,
    String? tipoReporte,
    String? titulo,
    String? periodoId,
    String? materiaId,
    String? bimestreId,
    String? formato,
    Map<String, dynamic>? parametros,
    String? rutaArchivo,
    DateTime? fechaGeneracion,
    String? usuarioGenerador,
    String? estado,
    int? tamanoBytes,
  }) {
    return ReporteGenerado(
      id: id ?? this.id,
      tipoReporte: tipoReporte ?? this.tipoReporte,
      titulo: titulo ?? this.titulo,
      periodoId: periodoId ?? this.periodoId,
      materiaId: materiaId ?? this.materiaId,
      bimestreId: bimestreId ?? this.bimestreId,
      formato: formato ?? this.formato,
      parametros: parametros ?? this.parametros,
      rutaArchivo: rutaArchivo ?? this.rutaArchivo,
      fechaGeneracion: fechaGeneracion ?? this.fechaGeneracion,
      usuarioGenerador: usuarioGenerador ?? this.usuarioGenerador,
      estado: estado ?? this.estado,
      tamanoBytes: tamanoBytes ?? this.tamanoBytes,
    );
  }

  @override
  String toString() {
    return 'ReporteGenerado($id: $tipoDisplay - $fechaDisplay)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReporteGenerado && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}