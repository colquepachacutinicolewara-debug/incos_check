// models/registrar_asistencia_model.dart
import 'dart:convert';

class EstudianteAsistencia {
  final String nombre;
  final String curso;
  final bool huellaAsignada;

  EstudianteAsistencia({
    required this.nombre,
    required this.curso,
    required this.huellaAsignada,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'curso': curso,
      'huella_asignada': huellaAsignada ? 1 : 0,
    };
  }

  factory EstudianteAsistencia.fromMap(Map<String, dynamic> map) {
    return EstudianteAsistencia(
      nombre: map['nombre'] ?? '',
      curso: map['curso'] ?? '',
      huellaAsignada: (map['huella_asignada'] ?? 0) == 1,
    );
  }

  EstudianteAsistencia copyWith({
    String? nombre,
    String? curso,
    bool? huellaAsignada,
  }) {
    return EstudianteAsistencia(
      nombre: nombre ?? this.nombre,
      curso: curso ?? this.curso,
      huellaAsignada: huellaAsignada ?? this.huellaAsignada,
    );
  }

  String get iniciales {
    final partes = nombre.split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.length >= 2 ? nombre.substring(0, 2).toUpperCase() : nombre.toUpperCase();
  }

  @override
  String toString() {
    return 'EstudianteAsistencia($nombre - $curso)';
  }
}

class EstadoRegistroAsistencia {
  final List<bool> asistencias;
  final bool isLoading;
  final bool biometricAvailable;
  final List<EstudianteAsistencia> estudiantes;

  EstadoRegistroAsistencia({
    required this.asistencias,
    required this.isLoading,
    required this.biometricAvailable,
    required this.estudiantes,
  });

  EstadoRegistroAsistencia copyWith({
    List<bool>? asistencias,
    bool? isLoading,
    bool? biometricAvailable,
    List<EstudianteAsistencia>? estudiantes,
  }) {
    return EstadoRegistroAsistencia(
      asistencias: asistencias ?? this.asistencias,
      isLoading: isLoading ?? this.isLoading,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      estudiantes: estudiantes ?? this.estudiantes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'asistencias': json.encode(asistencias),
      'is_loading': isLoading ? 1 : 0,
      'biometric_available': biometricAvailable ? 1 : 0,
      'estudiantes': json.encode(estudiantes.map((e) => e.toMap()).toList()),
    };
  }

  factory EstadoRegistroAsistencia.fromMap(Map<String, dynamic> map) {
    List<bool> asistencias = [];
    try {
      if (map['asistencias'] is String) {
        asistencias = List<bool>.from(json.decode(map['asistencias']).map((x) => x == true));
      } else if (map['asistencias'] is List) {
        asistencias = List<bool>.from(map['asistencias']);
      }
    } catch (e) {
      print('Error parsing asistencias: $e');
    }

    List<EstudianteAsistencia> estudiantes = [];
    try {
      if (map['estudiantes'] is String) {
        final List<dynamic> datos = json.decode(map['estudiantes']);
        estudiantes = datos.map((item) => EstudianteAsistencia.fromMap(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      print('Error parsing estudiantes: $e');
    }

    return EstadoRegistroAsistencia(
      asistencias: asistencias,
      isLoading: (map['is_loading'] ?? 0) == 1,
      biometricAvailable: (map['biometric_available'] ?? 0) == 1,
      estudiantes: estudiantes,
    );
  }

  int get totalAsistenciasRegistradas => asistencias.where((element) => element).length;
  int get totalEstudiantes => asistencias.length;
  double get porcentajeCompletado => totalEstudiantes > 0 ? totalAsistenciasRegistradas / totalEstudiantes : 0.0;
  bool get estaCompletado => totalAsistenciasRegistradas == totalEstudiantes;
  bool get puedeRegistrarBiometrico => biometricAvailable && !isLoading;

  int get estudiantesConHuella {
    return estudiantes.where((e) => e.huellaAsignada).length;
  }

  @override
  String toString() {
    return 'EstadoRegistroAsistencia($totalAsistenciasRegistradas/$totalEstudiantes - Loading: $isLoading)';
  }
}