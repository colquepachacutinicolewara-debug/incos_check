class DocenteMateria {
  final String id;
  final String docenteId;
  final String materiaId;
  final String? paraleloId;
  final String? turnoId;
  final String? horario;
  final String? diasSemana;
  final String? horaInicio;
  final String? horaFin;
  final String fechaAsignacion;
  final bool activo;

  DocenteMateria({
    required this.id,
    required this.docenteId,
    required this.materiaId,
    this.paraleloId,
    this.turnoId,
    this.horario,
    this.diasSemana,
    this.horaInicio,
    this.horaFin,
    required this.fechaAsignacion,
    this.activo = true,
  });

  // Constructor desde Map
  factory DocenteMateria.fromMap(Map<String, dynamic> map) {
    return DocenteMateria(
      id: map['id']?.toString() ?? '',
      docenteId: map['docente_id']?.toString() ?? '',
      materiaId: map['materia_id']?.toString() ?? '',
      paraleloId: map['paralelo_id']?.toString(),
      turnoId: map['turno_id']?.toString(),
      horario: map['horario']?.toString(),
      diasSemana: map['dias_semana']?.toString(),
      horaInicio: map['hora_inicio']?.toString(),
      horaFin: map['hora_fin']?.toString(),
      fechaAsignacion: map['fecha_asignacion']?.toString() ?? DateTime.now().toIso8601String(),
      activo: (map['activo'] ?? 1) == 1,
    );
  }

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'docente_id': docenteId,
      'materia_id': materiaId,
      'paralelo_id': paraleloId,
      'turno_id': turnoId,
      'horario': horario,
      'dias_semana': diasSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'fecha_asignacion': fechaAsignacion,
      'activo': activo ? 1 : 0,
    };
  }

  // Propiedades computadas
  List<String> get diasList {
    if (diasSemana == null || diasSemana!.isEmpty) return [];
    return diasSemana!.split(',').map((d) => d.trim()).toList();
  }

  String get horarioDisplay {
    if (horaInicio != null && horaFin != null) {
      return '$horaInicio - $horaFin';
    }
    return horario ?? 'Horario no definido';
  }

  String get diasDisplay {
    if (diasList.isEmpty) return 'Días no definidos';
    return diasList.join(', ');
  }

  bool get tieneHorarioDefinido => horaInicio != null && horaFin != null;

  // Método para copiar
  DocenteMateria copyWith({
    String? id,
    String? docenteId,
    String? materiaId,
    String? paraleloId,
    String? turnoId,
    String? horario,
    String? diasSemana,
    String? horaInicio,
    String? horaFin,
    String? fechaAsignacion,
    bool? activo,
  }) {
    return DocenteMateria(
      id: id ?? this.id,
      docenteId: docenteId ?? this.docenteId,
      materiaId: materiaId ?? this.materiaId,
      paraleloId: paraleloId ?? this.paraleloId,
      turnoId: turnoId ?? this.turnoId,
      horario: horario ?? this.horario,
      diasSemana: diasSemana ?? this.diasSemana,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
      activo: activo ?? this.activo,
    );
  }

  @override
  String toString() {
    return 'DocenteMateria($docenteId - $materiaId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocenteMateria && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}