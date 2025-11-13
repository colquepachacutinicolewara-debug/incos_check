// models/programa_model.dart
class Programa {
  final String nombre;
  final String iconoNombre;

  const Programa({
    required this.nombre,
    required this.iconoNombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'icono_nombre': iconoNombre,
    };
  }

  factory Programa.fromMap(Map<String, dynamic> map) {
    return Programa(
      nombre: map['nombre'] ?? '',
      iconoNombre: map['icono_nombre'] ?? '',
    );
  }

  Programa copyWith({
    String? nombre,
    String? iconoNombre,
  }) {
    return Programa(
      nombre: nombre ?? this.nombre,
      iconoNombre: iconoNombre ?? this.iconoNombre,
    );
  }

  String get displayName => nombre;
  String get iconPath => 'assets/icons/$iconoNombre.png';

  @override
  String toString() {
    return 'Programa($nombre)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Programa && other.nombre == nombre;
  }

  @override
  int get hashCode => nombre.hashCode;
}