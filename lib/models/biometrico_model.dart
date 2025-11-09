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

  HuellaModel copyWith({bool? registrada}) {
    return HuellaModel(
      numero: numero,
      nombreDedo: nombreDedo,
      icono: icono,
      registrada: registrada ?? this.registrada,
    );
  }
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

  int get totalRegistradas => huellas.where((h) => h.registrada).length;
}
