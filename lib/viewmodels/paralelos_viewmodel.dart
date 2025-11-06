// paralelos_viewmodel.dart
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
    _loadParalelos();
  }

  void _loadParalelos() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _paralelosSubscription?.cancel();

    try {
      _paralelosSubscription = _repository
          .getParalelosStream(_carreraId!, _turnoId!, _nivelId!)
          .listen(
            (snapshot) {
              _paralelos = snapshot.docs.map((doc) {
                return Paralelo.fromFirestore(doc);
              }).toList();

              _isLoading = false;
              _error = null;
              notifyListeners();
            },
            onError: (error) {
              _error = 'Error al cargar paralelos: $error';
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      _error = 'Error inesperado al cargar paralelos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reintentarCarga() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    _loadParalelos();
  }

  Future<bool> agregarParalelo(
    String nombre,
    String carreraId,
    String turnoId,
    String nivelId,
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

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
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final nuevoParalelo = Paralelo.createForFirestore(nombre: nombre);

      await _repository.addParalelo(carreraId, turnoId, nivelId, nuevoParalelo);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar paralelo: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cambiarEstadoParalelo(
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
      return true;
    } catch (e) {
      _error = 'Error al cambiar estado: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editarParalelo(
    Paralelo paralelo,
    String nuevoNombre,
    String carreraId,
    String turnoId,
    String nivelId,
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

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
        _isLoading = false;
        notifyListeners();
        return false;
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

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al editar paralelo: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarParalelo(
    Paralelo paralelo,
    String carreraId,
    String turnoId,
    String nivelId,
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deleteParalelo(
        carreraId,
        turnoId,
        nivelId,
        paralelo.id,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar paralelo: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
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

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

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

  @override
  void dispose() {
    _paralelosSubscription?.cancel();
    _nombreController.dispose();
    _editarNombreController.dispose();
    super.dispose();
  }
}
