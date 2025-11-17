class Respaldo {
  final String id;
  final String tipoRespaldo;
  final String? descripcion;
  final String rutaArchivo;
  final DateTime fechaRespaldo;
  final int? tamanoBytes;
  final String usuarioRespaldo;
  final String estado;
  final String? observaciones;
  final String? checksum;

  Respaldo({
    required this.id,
    required this.tipoRespaldo,
    this.descripcion,
    required this.rutaArchivo,
    required this.fechaRespaldo,
    this.tamanoBytes,
    required this.usuarioRespaldo,
    this.estado = 'COMPLETADO',
    this.observaciones,
    this.checksum,
  });

  // Constructor desde Map
  factory Respaldo.fromMap(Map<String, dynamic> map) {
    return Respaldo(
      id: map['id']?.toString() ?? '',
      tipoRespaldo: map['tipo_respaldo']?.toString() ?? '',
      descripcion: map['descripcion']?.toString(),
      rutaArchivo: map['ruta_archivo']?.toString() ?? '',
      fechaRespaldo: DateTime.parse(map['fecha_respaldo'] ?? DateTime.now().toIso8601String()),
      tamanoBytes: int.tryParse(map['tamano_bytes']?.toString() ?? '0'),
      usuarioRespaldo: map['usuario_respaldo']?.toString() ?? 'sistema',
      estado: map['estado']?.toString() ?? 'COMPLETADO',
      observaciones: map['observaciones']?.toString(),
      checksum: map['checksum']?.toString(),
    );
  }

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo_respaldo': tipoRespaldo,
      'descripcion': descripcion,
      'ruta_archivo': rutaArchivo,
      'fecha_respaldo': fechaRespaldo.toIso8601String(),
      'tamano_bytes': tamanoBytes,
      'usuario_respaldo': usuarioRespaldo,
      'estado': estado,
      'observaciones': observaciones,
      'checksum': checksum,
    };
  }

  // Propiedades computadas
  bool get esCompleto => tipoRespaldo == 'COMPLETO';
  bool get esIncremental => tipoRespaldo == 'INCREMENTAL';
  
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
    return '${fechaRespaldo.day}/${fechaRespaldo.month}/${fechaRespaldo.year} ${fechaRespaldo.hour}:${fechaRespaldo.minute.toString().padLeft(2, '0')}';
  }

  // Método para copiar
  Respaldo copyWith({
    String? id,
    String? tipoRespaldo,
    String? descripcion,
    String? rutaArchivo,
    DateTime? fechaRespaldo,
    int? tamanoBytes,
    String? usuarioRespaldo,
    String? estado,
    String? observaciones,
    String? checksum,
  }) {
    return Respaldo(
      id: id ?? this.id,
      tipoRespaldo: tipoRespaldo ?? this.tipoRespaldo,
      descripcion: descripcion ?? this.descripcion,
      rutaArchivo: rutaArchivo ?? this.rutaArchivo,
      fechaRespaldo: fechaRespaldo ?? this.fechaRespaldo,
      tamanoBytes: tamanoBytes ?? this.tamanoBytes,
      usuarioRespaldo: usuarioRespaldo ?? this.usuarioRespaldo,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      checksum: checksum ?? this.checksum,
    );
  }

  @override
  String toString() {
    return 'Respaldo($id: $tipoRespaldo - $fechaDisplay)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Respaldo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}