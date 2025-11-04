class ReporteModel {
  final double progress;
  final String status;
  final List<String> features;

  const ReporteModel({
    this.progress = 0.7,
    this.status = "Reportes en Desarrollo",
    this.features = const [
      "Reportes de asistencia por estudiante",
      "Reportes de asistencia por curso",
      "Estadísticas mensuales y anuales",
      "Exportación a PDF y Excel",
      "Gráficos y visualizaciones",
    ],
  });

  String get progressText => "${(progress * 100).toInt()}% Completado";
}
