// models/huella_model.dart
class HuellaModel {
  final String id;
  final String estudianteId;
  final int numeroDedo;
  final String nombreDedo;
  final String icono;
  final bool registrada;
  final String? templateData; // Datos de la huella (podría ser el ID del ESP32)
  final String fechaRegistro;

  HuellaModel({
    required this.id,
    required this.estudianteId,
    required this.numeroDedo,
    required this.nombreDedo,
    required this.icono,
    required this.registrada,
    this.templateData,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'estudiante_id': estudianteId,
      'numero_dedo': numeroDedo,
      'nombre_dedo': nombreDedo,
      'icono': icono,
      'registrada': registrada ? 1 : 0,
      'template_data': templateData,
      'fecha_registro': fechaRegistro,
    };
  }

  factory HuellaModel.fromMap(Map<String, dynamic> map) {
    return HuellaModel(
      id: map['id']?.toString() ?? '',
      estudianteId: map['estudiante_id']?.toString() ?? '',
      numeroDedo: int.tryParse(map['numero_dedo']?.toString() ?? '0') ?? 0,
      nombreDedo: map['nombre_dedo']?.toString() ?? '',
      icono: map['icono']?.toString() ?? '',
      registrada: (map['registrada'] as int?) == 1,
      templateData: map['template_data']?.toString(),
      fechaRegistro: map['fecha_registro']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  HuellaModel copyWith({
    String? id,
    String? estudianteId,
    int? numeroDedo,
    String? nombreDedo,
    String? icono,
    bool? registrada,
    String? templateData,
    String? fechaRegistro,
  }) {
    return HuellaModel(
      id: id ?? this.id,
      estudianteId: estudianteId ?? this.estudianteId,
      numeroDedo: numeroDedo ?? this.numeroDedo,
      nombreDedo: nombreDedo ?? this.nombreDedo,
      icono: icono ?? this.icono,
      registrada: registrada ?? this.registrada,
      templateData: templateData ?? this.templateData,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}