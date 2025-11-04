import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/biometrico_model.dart';
import '../utils/helpers.dart';

class RegistroHuellasViewModel with ChangeNotifier {
  final LocalAuthentication _auth = LocalAuthentication();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RegistroHuellasModel _model = RegistroHuellasModel(
    huellas: const [
      HuellaModel(numero: 0, nombreDedo: 'Pulgar derecho', icono: '👍'),
      HuellaModel(numero: 1, nombreDedo: 'Índice derecho', icono: '👆'),
      HuellaModel(numero: 2, nombreDedo: 'Medio derecho', icono: '✌️'),
    ],
    huellaActual: 0,
    isLoading: false,
    errorMessage: '',
    estadoBiometrico: BiometricoEstadoModel(
      disponible: false,
      soloHuellaDigital: false,
      mensaje: 'Verificando sensor...',
      submensaje: 'Espere por favor',
    ),
  );

  RegistroHuellasModel get model => _model;

  // Métodos públicos para la vista
  Future<void> verificarSoporteBiometrico() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = await _auth
          .getAvailableBiometrics();

      final bool tieneHuella = availableBiometrics.contains(
        BiometricType.fingerprint,
      );
      final bool tieneRostro = availableBiometrics.contains(BiometricType.face);
      final bool tieneIris = availableBiometrics.contains(BiometricType.iris);

      final nuevoEstado = BiometricoEstadoModel(
        disponible: canCheckBiometrics && availableBiometrics.isNotEmpty,
        soloHuellaDigital: tieneHuella && !tieneRostro && !tieneIris,
        mensaje: _getMensajeEstado(canCheckBiometrics, availableBiometrics),
        submensaje: _getSubmensajeEstado(tieneHuella, tieneRostro, tieneIris),
      );

      _updateModel(estadoBiometrico: nuevoEstado);
    } catch (e) {
      print('Error verificando biométricos: $e');
      _updateModel(
        estadoBiometrico: BiometricoEstadoModel(
          disponible: false,
          soloHuellaDigital: false,
          mensaje: 'Error al verificar sensor',
          submensaje: 'Reinicie la aplicación',
        ),
        errorMessage: 'Error al verificar sensor biométrico',
      );
    }
  }

  String _getMensajeEstado(bool canCheck, List<BiometricType> disponibles) {
    if (!canCheck) return "Sensor no disponible";
    if (disponibles.contains(BiometricType.fingerprint))
      return "Huella digital lista";
    return "Método biométrico disponible";
  }

  String _getSubmensajeEstado(bool huella, bool rostro, bool iris) {
    if (huella) return "Toque el sensor para registrar";
    if (rostro || iris) return "Se usará el método configurado";
    return "Dispositivo no compatible con huella digital";
  }

  Future<void> registrarHuellaActual(Map<String, dynamic> estudiante) async {
    if (_model.isLoading || _model.huellas[_model.huellaActual].registrada)
      return;

    _updateModel(isLoading: true, errorMessage: '');

    try {
      if (!_model.estadoBiometrico.disponible) {
        _mostrarError('El dispositivo no soporta autenticación biométrica');
        return;
      }

      final availableBiometrics = await _auth.getAvailableBiometrics();
      final bool tieneHuella = availableBiometrics.contains(
        BiometricType.fingerprint,
      );

      if (!tieneHuella) {
        _mostrarError(
          'No se encontró sensor de huella digital en el dispositivo',
        );
        return;
      }

      final bool authenticated = await _auth.authenticate(
        localizedReason:
            'Toque el sensor de huella para registrar su ${_model.huellas[_model.huellaActual].nombreDedo}',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: false,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        await _guardarHuellaEnFirebase(_model.huellaActual, estudiante);
        _marcarHuellaComoRegistrada(_model.huellaActual);

        // Avanzar automáticamente si no es la última
        if (_model.huellaActual < _model.huellas.length - 1) {
          await Future.delayed(const Duration(seconds: 1));
          siguienteHuella();
        }
      } else {
        _mostrarError('Autenticación cancelada o fallida');
      }
    } catch (e) {
      _manejarErrorBiometrico(e);
    } finally {
      _updateModel(isLoading: false);
    }
  }

  void _marcarHuellaComoRegistrada(int index) {
    final nuevasHuellas = List<HuellaModel>.from(_model.huellas);
    nuevasHuellas[index] = nuevasHuellas[index].copyWith(registrada: true);
    _updateModel(huellas: nuevasHuellas);
  }

  Future<void> _guardarHuellaEnFirebase(
    int numeroHuella,
    Map<String, dynamic> estudiante,
  ) async {
    try {
      final estudianteId =
          estudiante['id']?.toString() ?? estudiante['ci'].toString();
      final estudianteRef = _firestore
          .collection('estudiantes')
          .doc(estudianteId);

      final docSnapshot = await estudianteRef.get();
      final Map<String, dynamic> existingData = docSnapshot.data() ?? {};

      List<dynamic> huellasArray = existingData['huellas'] ?? [];

      // Eliminar huella existente para este número
      huellasArray.removeWhere(
        (huella) => huella is Map && huella['numero'] == numeroHuella + 1,
      );

      final nuevaHuella = <String, dynamic>{
        'id':
            'huella_${estudiante['ci']}_${numeroHuella}_${DateTime.now().millisecondsSinceEpoch}',
        'numero': numeroHuella + 1,
        'nombreDedo': _model.huellas[numeroHuella].nombreDedo,
        'fechaRegistro': FieldValue.serverTimestamp(),
        'tipoDispositivo': _model.estadoBiometrico.soloHuellaDigital
            ? 'Huella Digital'
            : 'Biométrico',
        'estado': 'activa',
      };

      huellasArray.add(nuevaHuella);

      await estudianteRef.update({
        'huellas': huellasArray,
        'huellasRegistradas': huellasArray.length,
        'tieneHuellasRegistradas': huellasArray.isNotEmpty,
        'fechaActualizacionHuellas': FieldValue.serverTimestamp(),
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      });

      print('✅ Huella $numeroHuella guardada para estudiante $estudianteId');
    } catch (e) {
      print('❌ Error guardando huella: $e');
      throw Exception('Error al guardar en la base de datos: ${e.toString()}');
    }
  }

  void _manejarErrorBiometrico(dynamic error) {
    print('Error biométrico: $error');

    String mensaje = 'Error de autenticación';
    int duracion = 3;

    if (error.toString().contains('LockedOut')) {
      mensaje =
          'Demasiados intentos fallidos. Espere 30 segundos e intente nuevamente.';
      duracion = 5;
    } else if (error.toString().contains('NotEnrolled')) {
      mensaje = 'No tiene configurada la autenticación biométrica';
    } else if (error.toString().contains('NotAvailable')) {
      mensaje = 'Sensor biométrico no disponible en este dispositivo';
    } else if (error.toString().contains('PasscodeNotSet')) {
      mensaje =
          'Configure un PIN o patrón de desbloqueo en su dispositivo primero';
    } else {
      mensaje = 'Error de autenticación: ${error.toString()}';
    }

    _mostrarError(mensaje, duracion: duracion);
  }

  void _mostrarError(String mensaje, {int duracion = 3}) {
    _updateModel(errorMessage: mensaje);
  }

  void siguienteHuella() {
    if (_model.huellaActual < _model.huellas.length - 1) {
      _updateModel(huellaActual: _model.huellaActual + 1, errorMessage: '');
    }
  }

  void anteriorHuella() {
    if (_model.huellaActual > 0) {
      _updateModel(huellaActual: _model.huellaActual - 1, errorMessage: '');
    }
  }

  void seleccionarHuella(int index) {
    _updateModel(huellaActual: index, errorMessage: '');
  }

  void _updateModel({
    List<HuellaModel>? huellas,
    int? huellaActual,
    bool? isLoading,
    String? errorMessage,
    BiometricoEstadoModel? estadoBiometrico,
  }) {
    _model = _model.copyWith(
      huellas: huellas,
      huellaActual: huellaActual,
      isLoading: isLoading,
      errorMessage: errorMessage,
      estadoBiometrico: estadoBiometrico,
    );
    notifyListeners();
  }
}
