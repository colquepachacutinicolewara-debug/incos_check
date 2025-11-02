class NivelModel {
  final String id;
  final String nombre;
  final bool activo;
  final int orden;
  final List<dynamic> paralelos;

  NivelModel({
    required this.id,
    required this.nombre,
    required this.activo,
    required this.orden,
    required this.paralelos,
  });

  factory NivelModel.fromMap(Map<String, dynamic> map) {
    return NivelModel(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      activo: map['activo'] ?? true,
      orden: map['orden'] ?? 99,
      paralelos: map['paralelos'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'activo': activo,
      'orden': orden,
      'paralelos': paralelos,
    };
  }

  NivelModel copyWith({
    String? id,
    String? nombre,
    bool? activo,
    int? orden,
    List<dynamic>? paralelos,
  }) {
    return NivelModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      activo: activo ?? this.activo,
      orden: orden ?? this.orden,
      paralelos: paralelos ?? this.paralelos,
    );
  }
}
