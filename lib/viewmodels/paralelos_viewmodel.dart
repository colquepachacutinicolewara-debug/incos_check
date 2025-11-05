import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/repositories/data_repository.dart';
import 'package:incos_check/models/paralelo_model.dart';
import 'dart:async';

class ParalelosViewModel extends ChangeNotifier {
  final DataRepository _repository;

  List<Paralelo> _paralelos = [];
  bool _isLoading = false;
  String? _error;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _editarNombreController = TextEditingController();

  String? _carreraId;
  String? _turnoId;
  String? _nivelId;
  StreamSubscription? _paralelosSubscription;

  List<Paralelo> get paralelos => _paralelos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TextEditingController get nombreController => _nombreController;
  TextEditingController get editarNombreController => _editarNombreController;

  ParalelosViewModel(this._repository);

  // Funciones para obtener colores según el tema
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : AppColors.background;
  }

  Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }

  Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  Color getInfoBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blue.shade900.withOpacity(0.3)
        : Colors.blue.shade50;
  }

  Color getInfoTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blue.shade200
        : Colors.blue.shade800;
  }

  void inicializarYcargarParalelos(
    String carreraId,
    String carreraNombre,
    String carreraColor,
    String nivelId,
    String turnoId,
  ) {
    _carreraId = carreraId;
    _turnoId = turnoId;
    _nivelId = nivelId;
    _cargarParalelosFirestore(carreraId, turnoId, nivelId);
  }

  void _cargarParalelosFirestore(
    String carreraId,
    String turnoId,
    String nivelId,
  ) {
    _setLoading(true);
    _error = null;

    // Cancelar suscripción anterior si existe
    _paralelosSubscription?.cancel();

    _paralelosSubscription = _repository
        .getParalelosStream(carreraId, turnoId, nivelId)
        .listen(
          (snapshot) {
            _paralelos = snapshot.docs.map((doc) {
              return Paralelo.fromFirestore(doc);
            }).toList();
            _setLoading(false);
            notifyListeners();
          },
          onError: (error) {
            _error = 'Error cargando paralelos: $error';
            _setLoading(false);
            notifyListeners();
          },
        );
  }

  Future<void> agregarParalelo(
    String nombre,
    String carreraId,
    String turnoId,
    String nivelId,
    BuildContext context,
  ) async {
    try {
      _setLoading(true);

      // Verificar si ya existe un paralelo con ese nombre
      final existe = await _repository.paraleloExists(
        carreraId,
        turnoId,
        nivelId,
        nombre,
      );

      if (existe) {
        _showSnackBar(
          context,
          'Ya existe un paralelo con la letra $nombre',
          Colors.orange,
        );
        _setLoading(false);
        return;
      }

      // Usar el método estático para crear el mapa para Firestore
      final nuevoParalelo = Paralelo.createForFirestore(nombre: nombre);

      // Agregar a Firestore
      await _repository.addParalelo(carreraId, turnoId, nivelId, nuevoParalelo);

      _showSnackBar(
        context,
        'Paralelo $nombre agregado correctamente',
        Colors.green,
      );
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _showSnackBar(context, 'Error al agregar paralelo: $e', Colors.red);
    }
  }

  Future<void> cambiarEstadoParalelo(
    Paralelo paralelo,
    bool nuevoEstado,
    String carreraId,
    String turnoId,
    String nivelId,
  ) async {
    try {
      await _repository.updateParalelo(
        carreraId,
        turnoId,
        nivelId,
        paralelo.id,
        {
          'activo': nuevoEstado,
          'fechaActualizacion': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Error al cambiar estado: $e');
    }
  }

  Future<void> editarParalelo(
    Paralelo paralelo,
    String nuevoNombre,
    String carreraId,
    String turnoId,
    String nivelId,
    BuildContext context,
  ) async {
    try {
      _setLoading(true);

      // Verificar si ya existe otro paralelo con ese nombre
      final existe = await _repository.paraleloExists(
        carreraId,
        turnoId,
        nivelId,
        nuevoNombre,
      );

      if (existe) {
        _showSnackBar(
          context,
          'Ya existe un paralelo con la letra $nuevoNombre',
          Colors.orange,
        );
        _setLoading(false);
        return;
      }

      await _repository.updateParalelo(
        carreraId,
        turnoId,
        nivelId,
        paralelo.id,
        {
          'nombre': nuevoNombre,
          'fechaActualizacion': FieldValue.serverTimestamp(),
        },
      );

      _showSnackBar(
        context,
        'Paralelo actualizado a $nuevoNombre',
        Colors.blue,
      );
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _showSnackBar(context, 'Error al editar paralelo: $e', Colors.red);
    }
  }

  Future<void> eliminarParalelo(
    Paralelo paralelo,
    String carreraId,
    String turnoId,
    String nivelId,
    BuildContext context,
  ) async {
    try {
      _setLoading(true);

      await _repository.deleteParalelo(
        carreraId,
        turnoId,
        nivelId,
        paralelo.id,
      );

      _showSnackBar(
        context,
        'Paralelo ${paralelo.nombre} eliminado',
        Colors.red,
      );
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _showSnackBar(context, 'Error al eliminar paralelo: $e', Colors.red);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Color parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _paralelosSubscription?.cancel();
    _nombreController.dispose();
    _editarNombreController.dispose();
    super.dispose();
  }
}
