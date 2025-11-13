// models/biometrico_model.dart
import 'dart:convert';
class HuellaModel {
  final int numero;
  final String nombreDedo;
  final String icono;
  final bool registrada;

  const HuellaModel({
    required this.numero,
    required this.nombreDedo,
    required this.icono,
    this.registrada = false,
  });

  HuellaModel copyWith({
    int? numero,
    String? nombreDedo,
    String? icono,
    bool? registrada,
  }) {
    return HuellaModel(
      numero: numero ?? this.numero,
      nombreDedo: nombreDedo ?? this.nombreDedo,
      icono: icono ?? this.icono,
      registrada: registrada ?? this.registrada,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero_dedo': numero,
      'nombre_dedo': nombreDedo,
      'icono': icono,
      'registrada': registrada ? 1 : 0,
    };
  }

  factory HuellaModel.fromMap(Map<String, dynamic> map) {
    return HuellaModel(
      numero: map['numero_dedo'] ?? 0,
      nombreDedo: map['nombre_dedo'] ?? '',
      icono: map['icono'] ?? '',
      registrada: (map['registrada'] ?? 0) == 1,
    );
  }

  String get estadoTexto => registrada ? 'Registrada' : 'No registrada';
  bool get puedeRegistrar => !registrada;

  @override
  String toString() {
    return 'HuellaModel($numero: $nombreDedo - $estadoTexto)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HuellaModel && other.numero == numero;
  }

  @override
  int get hashCode => numero.hashCode;
}

class BiometricoEstadoModel {
  final bool disponible;
  final bool soloHuellaDigital;
  final String mensaje;
  final String submensaje;

  const BiometricoEstadoModel({
    required this.disponible,
    required this.soloHuellaDigital,
    required this.mensaje,
    required this.submensaje,
  });

  Map<String, dynamic> toMap() {
    return {
      'disponible': disponible ? 1 : 0,
      'solo_huella_digital': soloHuellaDigital ? 1 : 0,
      'mensaje': mensaje,
      'submensaje': submensaje,
    };
  }

  factory BiometricoEstadoModel.fromMap(Map<String, dynamic> map) {
    return BiometricoEstadoModel(
      disponible: (map['disponible'] ?? 0) == 1,
      soloHuellaDigital: (map['solo_huella_digital'] ?? 0) == 1,
      mensaje: map['mensaje'] ?? 'Estado no disponible',
      submensaje: map['submensaje'] ?? 'Verifique la configuración',
    );
  }

  BiometricoEstadoModel copyWith({
    bool? disponible,
    bool? soloHuellaDigital,
    String? mensaje,
    String? submensaje,
  }) {
    return BiometricoEstadoModel(
      disponible: disponible ?? this.disponible,
      soloHuellaDigital: soloHuellaDigital ?? this.soloHuellaDigital,
      mensaje: mensaje ?? this.mensaje,
      submensaje: submensaje ?? this.submensaje,
    );
  }

  bool get puedeUsarBiometrico => disponible;
  bool get requiereHuella => soloHuellaDigital;

  @override
  String toString() {
    return 'BiometricoEstadoModel(disponible: $disponible, mensaje: $mensaje)';
  }
}

class RegistroHuellasModel {
  final List<HuellaModel> huellas;
  final int huellaActual;
  final bool isLoading;
  final String errorMessage;
  final BiometricoEstadoModel estadoBiometrico;

  const RegistroHuellasModel({
    required this.huellas,
    required this.huellaActual,
    required this.isLoading,
    required this.errorMessage,
    required this.estadoBiometrico,
  });

  RegistroHuellasModel copyWith({
    List<HuellaModel>? huellas,
    int? huellaActual,
    bool? isLoading,
    String? errorMessage,
    BiometricoEstadoModel? estadoBiometrico,
  }) {
    return RegistroHuellasModel(
      huellas: huellas ?? this.huellas,
      huellaActual: huellaActual ?? this.huellaActual,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      estadoBiometrico: estadoBiometrico ?? this.estadoBiometrico,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'huellas': json.encode(huellas.map((h) => h.toMap()).toList()),
      'huella_actual': huellaActual,
      'is_loading': isLoading ? 1 : 0,
      'error_message': errorMessage,
      'estado_biometrico': estadoBiometrico.toMap(),
    };
  }

  factory RegistroHuellasModel.fromMap(Map<String, dynamic> map) {
    List<HuellaModel> huellas = [];
    try {
      if (map['huellas'] is String) {
        final List<dynamic> datos = json.decode(map['huellas']);
        huellas = datos.map((item) => HuellaModel.fromMap(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      print('Error parsing huellas: $e');
    }

    return RegistroHuellasModel(
      huellas: huellas,
      huellaActual: map['huella_actual'] ?? 0,
      isLoading: (map['is_loading'] ?? 0) == 1,
      errorMessage: map['error_message'] ?? '',
      estadoBiometrico: BiometricoEstadoModel.fromMap(
        Map<String, dynamic>.from(map['estado_biometrico'] ?? {})
      ),
    );
  }

  int get totalRegistradas => huellas.where((h) => h.registrada).length;
  int get totalHuellas => huellas.length;
  double get progreso => totalHuellas > 0 ? totalRegistradas / totalHuellas : 0.0;
  bool get todasRegistradas => totalRegistradas >= totalHuellas;
  HuellaModel? get huellaActualObj => huellaActual < huellas.length ? huellas[huellaActual] : null;

  @override
  String toString() {
    return 'RegistroHuellasModel(huellas: $totalRegistradas/$totalHuellas, isLoading: $isLoading)';
  }
}