import 'dart:convert';
class ConfigNotasAsistencia {
  final String id;
  final String nombre;
  final double puntajeTotal;
  final Map<String, dynamic> reglasCalculo;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  ConfigNotasAsistencia({
    required this.id,
    required this.nombre,
    this.puntajeTotal = 10.0,
    required this.reglasCalculo,
    this.activo = true,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  // REGLAS PREDEFINIDAS
  static Map<String, dynamic> get reglasPorDefecto {
    return {
      'retraso_penaliza_media_hora': true,
      'minimo_aprobatorio': 7.0,
      'calculo_automatico': true,
      'considerar_puntualidad': true,
      'tolerancia_minutos': 15,
    };
  }

  double get minimoAprobatorio => (reglasCalculo['minimo_aprobatorio'] ?? 7.0).toDouble();
  bool get retrasoPenaliza => reglasCalculo['retraso_penaliza_media_hora'] ?? true;
  bool get calculoAutomatico => reglasCalculo['calculo_automatico'] ?? true;
  int get toleranciaMinutos => reglasCalculo['tolerancia_minutos'] ?? 15;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'puntaje_total': puntajeTotal,
      'reglas_calculo': reglasCalculo,
      'activo': activo ? 1 : 0,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  factory ConfigNotasAsistencia.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> reglas = {};
    
    try {
      if (map['reglas_calculo'] is String) {
        reglas = Map<String, dynamic>.from(json.decode(map['reglas_calculo']));
      } else if (map['reglas_calculo'] is Map) {
        reglas = Map<String, dynamic>.from(map['reglas_calculo']);
      }
    } catch (e) {
      reglas = reglasPorDefecto;
    }

    return ConfigNotasAsistencia(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      puntajeTotal: (map['puntaje_total'] ?? 10.0).toDouble(),
      reglasCalculo: reglas,
      activo: (map['activo'] ?? 1) == 1,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] ?? DateTime.now().toIso8601String()),
      fechaActualizacion: DateTime.parse(map['fecha_actualizacion'] ?? DateTime.now().toIso8601String()),
    );
  }

  ConfigNotasAsistencia copyWith({
    String? id,
    String? nombre,
    double? puntajeTotal,
    Map<String, dynamic>? reglasCalculo,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return ConfigNotasAsistencia(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      puntajeTotal: puntajeTotal ?? this.puntajeTotal,
      reglasCalculo: reglasCalculo ?? this.reglasCalculo,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return 'ConfigNotasAsistencia($nombre - $puntajeTotal puntos)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConfigNotasAsistencia && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}