// models/estudiante_model.dart
class Estudiante {
  final int id;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String ci;
  final String fechaRegistro;
  final int huellasRegistradas;

  Estudiante({
    required this.id,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.ci,
    required this.fechaRegistro,
    required this.huellasRegistradas,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'ci': ci,
      'fechaRegistro': fechaRegistro,
      'huellasRegistradas': huellasRegistradas,
    };
  }

  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id'],
      nombres: map['nombres'],
      apellidoPaterno: map['apellidoPaterno'],
      apellidoMaterno: map['apellidoMaterno'],
      ci: map['ci'],
      fechaRegistro: map['fechaRegistro'],
      huellasRegistradas: map['huellasRegistradas'],
    );
  }

  Estudiante copyWith({
    int? id,
    String? nombres,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? ci,
    String? fechaRegistro,
    int? huellasRegistradas,
  }) {
    return Estudiante(
      id: id ?? this.id,
      nombres: nombres ?? this.nombres,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      ci: ci ?? this.ci,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      huellasRegistradas: huellasRegistradas ?? this.huellasRegistradas,
    );
  }

  String get nombreCompleto => '$apellidoPaterno $apellidoMaterno $nombres';
  bool get tieneTodasLasHuellas => huellasRegistradas >= 3;
}
