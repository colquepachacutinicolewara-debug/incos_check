class AsistenciaCompleta {
  final String id;
  final String estudianteId;
  final String estudianteNombre;
  final String materiaId;
  final String bimestreId;
  final Map<String, String> asistencias; // fecha -> estado
  final String carrera;
  final String turno;
  final String curso;

  AsistenciaCompleta({
    required this.id,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.materiaId,
    required this.bimestreId,
    required this.asistencias,
    required this.carrera,
    required this.turno,
    required this.curso,
  });

  int get totalAsistencias {
    int total = 0;
    for (String estado in asistencias.values) {
      if (estado.trim().isNotEmpty && estado.toUpperCase() == 'P') {
        total++;
      }
    }
    return total;
  }

  int get totalClases => asistencias.length;
  String get totalDisplay => '$totalAsistencias/$totalClases';
  double get porcentaje =>
      totalClases > 0 ? (totalAsistencias / totalClases) * 100 : 0;

  String getEstadoPorFecha(String fecha) {
    return asistencias[fecha] ?? '';
  }
}
