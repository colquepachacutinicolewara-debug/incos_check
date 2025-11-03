import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/data_manager.dart';

class ParalelosViewModel extends ChangeNotifier {
  final DataManager _dataManager = DataManager();
  List<Map<String, dynamic>> _paralelos = [];
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _editarNombreController = TextEditingController();

  List<Map<String, dynamic>> get paralelos => _paralelos;
  TextEditingController get nombreController => _nombreController;
  TextEditingController get editarNombreController => _editarNombreController;

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
    // INICIALIZAR SIEMPRE la carrera en DataManager
    _dataManager.inicializarCarrera(carreraId, carreraNombre, carreraColor);

    // Cargar paralelos desde DataManager
    _cargarParalelosDataManager(carreraId, turnoId, nivelId);
  }

  void _cargarParalelosDataManager(
    String carreraId,
    String turnoId,
    String nivelId,
  ) {
    final paralelosDataManager = _dataManager.getParalelos(
      carreraId,
      turnoId,
      nivelId,
    );

    _paralelos = paralelosDataManager;
    notifyListeners();
  }

  void agregarParalelo(
    String nombre,
    String carreraId,
    String turnoId,
    String nivelId,
    BuildContext context,
  ) {
    // Verificar si ya existe un paralelo con ese nombre
    bool existe = _paralelos.any((p) => p['nombre'] == nombre);

    if (existe) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ya existe un paralelo con la letra $nombre'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Crear nuevo paralelo con ID único
    Map<String, dynamic> nuevoParalelo = {
      'id': '${carreraId}_${turnoId}_${nivelId}_$nombre',
      'nombre': nombre,
      'activo': true,
      'estudiantes': [],
    };

    // Guardar en DataManager
    _dataManager.agregarParalelo(carreraId, turnoId, nivelId, nuevoParalelo);

    _paralelos.add(nuevoParalelo);
    // Ordenar paralelos alfabéticamente
    _paralelos.sort((a, b) => a['nombre'].compareTo(b['nombre']));
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paralelo $nombre agregado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void cambiarEstadoParalelo(
    Map<String, dynamic> paralelo,
    bool nuevoEstado,
    String carreraId,
    String turnoId,
    String nivelId,
  ) {
    paralelo['activo'] = nuevoEstado;
    notifyListeners();

    // Actualizar en DataManager
    _dataManager.actualizarParalelo(
      carreraId,
      turnoId,
      nivelId,
      paralelo['id'].toString(),
      paralelo,
    );
  }

  void editarParalelo(
    Map<String, dynamic> paralelo,
    String nuevoNombre,
    String carreraId,
    String turnoId,
    String nivelId,
    BuildContext context,
  ) {
    // Verificar si ya existe otro paralelo con ese nombre (excluyendo el actual)
    bool existe = _paralelos.any(
      (p) => p['nombre'] == nuevoNombre && p['id'] != paralelo['id'],
    );

    if (existe) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ya existe un paralelo con la letra $nuevoNombre'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    paralelo['nombre'] = nuevoNombre;
    // Reordenar después de editar
    _paralelos.sort((a, b) => a['nombre'].compareTo(b['nombre']));
    notifyListeners();

    // Actualizar en DataManager
    _dataManager.actualizarParalelo(
      carreraId,
      turnoId,
      nivelId,
      paralelo['id'].toString(),
      paralelo,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paralelo actualizado a $nuevoNombre'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void eliminarParalelo(
    Map<String, dynamic> paralelo,
    String carreraId,
    String turnoId,
    String nivelId,
    BuildContext context,
  ) {
    String nombreEliminado = paralelo['nombre'];

    // Eliminar del DataManager
    _dataManager.eliminarParalelo(
      carreraId,
      turnoId,
      nivelId,
      paralelo['id'].toString(),
    );

    _paralelos.removeWhere((p) => p['id'] == paralelo['id']);
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paralelo $nombreEliminado eliminado'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Color parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _editarNombreController.dispose();
    super.dispose();
  }
}
