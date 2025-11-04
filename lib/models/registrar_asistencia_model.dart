import 'package:flutter/material.dart';

class Estudiante {
  final String nombre;
  final String curso;
  final bool huellaAsignada;

  Estudiante({
    required this.nombre,
    required this.curso,
    required this.huellaAsignada,
  });
}

class EstadoRegistroAsistencia {
  final List<bool> asistencias;
  final bool isLoading;
  final bool biometricAvailable;
  final List<Estudiante> estudiantes;

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
    List<Estudiante>? estudiantes,
  }) {
    return EstadoRegistroAsistencia(
      asistencias: asistencias ?? this.asistencias,
      isLoading: isLoading ?? this.isLoading,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      estudiantes: estudiantes ?? this.estudiantes,
    );
  }

  int get totalAsistenciasRegistradas {
    return asistencias.where((element) => element).length;
  }

  int get totalEstudiantes => asistencias.length;
}
