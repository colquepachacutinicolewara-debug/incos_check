import 'package:intl/intl.dart';

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
  final String fechaCreacion;
  final String fechaActualizacion;
  final bool activo;
  final String? email;
  final String? telefono;
  final String? codigoEstudiante;

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
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.activo = true,
    this.email,
    this.telefono,
    this.codigoEstudiante,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombres': nombres,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'ci': ci,
      'fecha_registro': fechaRegistro,
      'huellas_registradas': huellasRegistradas,
      'carrera_id': carreraId,
      'turno_id': turnoId,
      'nivel_id': nivelId,
      'paralelo_id': paraleloId,
      'fecha_creacion': fechaCreacion,
      'fecha_actualizacion': fechaActualizacion,
      'activo': activo ? 1 : 0,
      'email': email,
      'telefono': telefono,
      'codigo_estudiante': codigoEstudiante,
    };
  }

  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id']?.toString() ?? '',
      nombres: map['nombres']?.toString() ?? '',
      apellidoPaterno: map['apellido_paterno']?.toString() ?? '',
      apellidoMaterno: map['apellido_materno']?.toString() ?? '',
      ci: map['ci']?.toString() ?? '',
      fechaRegistro: map['fecha_registro']?.toString() ?? 
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
      huellasRegistradas: int.tryParse(map['huellas_registradas']?.toString() ?? '0') ?? 0,
      carreraId: map['carrera_id']?.toString(),
      turnoId: map['turno_id']?.toString(),
      nivelId: map['nivel_id']?.toString(),
      paraleloId: map['paralelo_id']?.toString(),
      fechaCreacion: map['fecha_creacion']?.toString() ?? DateTime.now().toIso8601String(),
      fechaActualizacion: map['fecha_actualizacion']?.toString() ?? DateTime.now().toIso8601String(),
      activo: (map['activo'] ?? 1) == 1,
      email: map['email']?.toString(),
      telefono: map['telefono']?.toString(),
      codigoEstudiante: map['codigo_estudiante']?.toString(),
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
    String? fechaCreacion,
    String? fechaActualizacion,
    bool? activo,
    String? email,
    String? telefono,
    String? codigoEstudiante,
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
      activo: activo ?? this.activo,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      codigoEstudiante: codigoEstudiante ?? this.codigoEstudiante,
    );
  }

  // 🔐 PROPIEDADES PARA AUTENTICACIÓN
  String get nombreCompleto => '$apellidoPaterno $apellidoMaterno $nombres';
  String get nombreCorto => '$nombres $apellidoPaterno';
  bool get tieneTodasLasHuellas => huellasRegistradas >= 3;
  bool get tieneHuellasRegistradas => huellasRegistradas > 0;
  bool get estaActivo => activo;
  
  // 📊 PARA ASISTENCIA Y NOTAS
  bool get puedeMarcarAsistencia => activo && tieneTodasLasHuellas;
  
  // 🎓 INFORMACIÓN ACADÉMICA
  String get infoAcademica {
    return '$carreraId - $nivelId$paraleloId - $turnoId';
  }

  String get estadoHuellas {
    if (huellasRegistradas >= 3) return 'Completas';
    if (huellasRegistradas > 0) return 'Parciales';
    return 'Sin registrar';
  }

  // 📈 MÉTODO PARA CÁLCULO DE NOTA DE ASISTENCIA BIMESTRAL (sobre 10 puntos)
  double calcularNotaAsistenciaBimestral(int totalSesionesBimestre, int asistenciasBimestre) {
    if (totalSesionesBimestre == 0) return 0.0;
    
    // Calcular porcentaje de asistencia
    double porcentaje = (asistenciasBimestre / totalSesionesBimestre) * 100;
    
    // Convertir a nota sobre 10 puntos
    // 100% = 10 puntos, 80% = 8 puntos, 50% = 5 puntos, etc.
    double nota = (porcentaje * 10) / 100;
    
    // Redondear a 2 decimales
    return double.parse(nota.toStringAsFixed(2));
  }

  // 🔐 PARA AUTENTICACIÓN MÓVIL
  Map<String, dynamic> toAuthMap() {
    return {
      'id': id,
      'ci': ci,
      'nombre_completo': nombreCompleto,
      'codigo_estudiante': codigoEstudiante,
      'huellas_registradas': huellasRegistradas,
      'carrera': carreraId,
      'nivel': nivelId,
      'paralelo': paraleloId,
    };
  }

  @override
  String toString() {
    return 'Estudiante($id: $nombreCompleto - $ci)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Estudiante && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}