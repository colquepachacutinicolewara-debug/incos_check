// models/reporte_model.dart
import 'dart:convert';

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

  Map<String, dynamic> toMap() {
    return {
      'progress': progress,
      'status': status,
      'features': json.encode(features),
    };
  }

  factory ReporteModel.fromMap(Map<String, dynamic> map) {
    List<String> features = [];
    try {
      if (map['features'] is String) {
        features = List<String>.from(json.decode(map['features']));
      } else if (map['features'] is List) {
        features = List<String>.from(map['features']);
      }
    } catch (e) {
      print('Error parsing features: $e');
      features = const [
        "Reportes de asistencia por estudiante",
        "Reportes de asistencia por curso",
        "Estadísticas mensuales y anuales",
        "Exportación a PDF y Excel",
        "Gráficos y visualizaciones",
      ];
    }

    return ReporteModel(
      progress: (map['progress'] ?? 0.7).toDouble(),
      status: map['status'] ?? "Reportes en Desarrollo",
      features: features,
    );
  }

  ReporteModel copyWith({
    double? progress,
    String? status,
    List<String>? features,
  }) {
    return ReporteModel(
      progress: progress ?? this.progress,
      status: status ?? this.status,
      features: features ?? this.features,
    );
  }

  String get progressText => "${(progress * 100).toInt()}% Completado";
  int get progressPercentage => (progress * 100).toInt();
  bool get estaCompletado => progress >= 1.0;
  bool get enDesarrollo => progress < 1.0;

  int get totalFeatures => features.length;
  int get featuresImplementadas => (totalFeatures * progress).round();

  @override
  String toString() {
    return 'ReporteModel($progressText - $status)';
  }
}