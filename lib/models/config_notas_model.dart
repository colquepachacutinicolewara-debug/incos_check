import 'dart:convert';

class ConfigNotasAsistencia {
  final String id;
  final String nombre;
  final String? descripcion;
  final double puntajeMaximo;
  final String formulaTipo;
  final String? parametros;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  ConfigNotasAsistencia({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.puntajeMaximo = 10.0,
    this.formulaTipo = 'BIMESTRAL',
    this.parametros,
    this.activo = true,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  // Obtener parámetros como Map
  Map<String, dynamic> get parametrosMap {
    if (parametros == null || parametros!.isEmpty) {
      return _parametrosPorDefecto;
    }
    try {
      return Map<String, dynamic>.from(json.decode(parametros!));
    } catch (e) {
      return _parametrosPorDefecto;
    }
  }

  // PARÁMETROS POR DEFECTO
  static final Map<String, dynamic> _parametrosPorDefecto = {
    'asistencia_minima': 80.0,
    'tolerancia_minutos': 15,
    'considera_puntualidad': true,
    'penalizacion_retraso': 0.5,
    'minimo_aprobatorio': 7.0,
  };

  // Getters para parámetros comunes
  double get asistenciaMinima => (parametrosMap['asistencia_minima'] ?? 80.0).toDouble();
  int get toleranciaMinutos => (parametrosMap['tolerancia_minutos'] ?? 15).toInt();
  bool get consideraPuntualidad => parametrosMap['considera_puntualidad'] ?? true;
  double get penalizacionRetraso => (parametrosMap['penalizacion_retraso'] ?? 0.5).toDouble();
  double get minimoAprobatorio => (parametrosMap['minimo_aprobatorio'] ?? 7.0).toDouble();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'puntaje_maximo': puntajeMaximo,
      'formula_tipo': formulaTipo,
      'parametros': parametros,
      'activo': activo ? 1 : 0,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  factory ConfigNotasAsistencia.fromMap(Map<String, dynamic> map) {
    return ConfigNotasAsistencia(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString(),
      puntajeMaximo: (map['puntaje_maximo'] ?? 10.0).toDouble(),
      formulaTipo: map['formula_tipo']?.toString() ?? 'BIMESTRAL',
      parametros: map['parametros']?.toString(),
      activo: (map['activo'] ?? 1) == 1,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] ?? DateTime.now().toIso8601String()),
      fechaActualizacion: DateTime.parse(map['fecha_actualizacion'] ?? DateTime.now().toIso8601String()),
    );
  }

  ConfigNotasAsistencia copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? puntajeMaximo,
    String? formulaTipo,
    String? parametros,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return ConfigNotasAsistencia(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      puntajeMaximo: puntajeMaximo ?? this.puntajeMaximo,
      formulaTipo: formulaTipo ?? this.formulaTipo,
      parametros: parametros ?? this.parametros,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  // Método para actualizar parámetros
  ConfigNotasAsistencia withParametros(Map<String, dynamic> nuevosParametros) {
    final params = parametrosMap;
    params.addAll(nuevosParametros);
    
    return copyWith(
      parametros: json.encode(params),
      fechaActualizacion: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ConfigNotasAsistencia($nombre - $puntajeMaximo puntos)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConfigNotasAsistencia && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}