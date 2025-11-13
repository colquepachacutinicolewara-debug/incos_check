// viewmodels/paralelos_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/paralelo_model.dart';
import '../models/database_helper.dart';

class ParalelosViewModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance; // ✅ Cambio aquí

  List<Paralelo> _paralelos = [];
  bool _isLoading = false;
  String? _error;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _editarNombreController = TextEditingController();

  String? _carreraId;
  String? _turnoId;
  String? _nivelId;

  List<Paralelo> get paralelos => _paralelos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TextEditingController get nombreController => _nombreController;
  TextEditingController get editarNombreController => _editarNombreController;

  ParalelosViewModel(); // ✅ Constructor sin parámetros

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

  Future<void> _loadParalelos() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM paralelos 
        WHERE activo = 1
        ORDER BY nombre
      ''');

      _paralelos = result.map((row) => 
        Paralelo.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar paralelos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reintentarCarga() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    await _loadParalelos();
  }

  Future<bool> agregarParalelo(
    String nombre,
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Verificar si ya existe
      final existe = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM paralelos 
        WHERE UPPER(nombre) = ?
      ''', [nombre.toUpperCase()]);

      final count = (existe.first['count'] as int?) ?? 0;
      if (count > 0) {
        _showSnackBar(
          context,
          'Ya existe un paralelo con la letra $nombre',
          Colors.orange,
        );
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final nuevoParalelo = Paralelo(
        id: 'paralelo_${DateTime.now().millisecondsSinceEpoch}',
        nombre: nombre.toUpperCase(),
        activo: true,
        estudiantes: [],
      );

      await _databaseHelper.rawInsert('''
        INSERT INTO paralelos (id, nombre, activo, estudiantes, fecha_creacion, fecha_actualizacion)
        VALUES (?, ?, ?, ?, ?, ?)
      ''', [
        nuevoParalelo.id,
        nuevoParalelo.nombre,
        nuevoParalelo.activo ? 1 : 0,
        '[]', // estudiantes vacíos
        DateTime.now().toIso8601String(),
        DateTime.now().toIso8601String(),
      ]);

      await _loadParalelos();
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
  ) async {
    try {
      await _databaseHelper.rawUpdate('''
        UPDATE paralelos SET activo = ?, fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        nuevoEstado ? 1 : 0,
        DateTime.now().toIso8601String(),
        paralelo.id,
      ]);

      await _loadParalelos();
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
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Verificar si ya existe (excluyendo el actual)
      final existe = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM paralelos 
        WHERE UPPER(nombre) = ? AND id != ?
      ''', [nuevoNombre.toUpperCase(), paralelo.id]);

      final count = (existe.first['count'] as int?) ?? 0;
      if (count > 0) {
        _showSnackBar(
          context,
          'Ya existe un paralelo con la letra $nuevoNombre',
          Colors.orange,
        );
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _databaseHelper.rawUpdate('''
        UPDATE paralelos SET nombre = ?, fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        nuevoNombre.toUpperCase(),
        DateTime.now().toIso8601String(),
        paralelo.id,
      ]);

      await _loadParalelos();
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
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseHelper.rawDelete('''
        DELETE FROM paralelos WHERE id = ?
      ''', [paralelo.id]);

      await _loadParalelos();
      return true;
    } catch (e) {
      _error = 'Error al eliminar paralelo: $e';
      _isLoading = false;
      notifyListeners();
      return false;
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

  // Métodos de utilidad para temas
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Color(0xFFF5F5F5);
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

  Color parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _editarNombreController.dispose();
    super.dispose();
  }
}