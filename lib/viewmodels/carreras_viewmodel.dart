// viewmodels/carreras_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/carrera_model.dart';
import '../models/database_helper.dart';

class CarrerasViewModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<CarreraModel> _carreras = [];
  bool _isLoading = false;
  String? _error;
  
  // Estados para notificaciones
  bool _mostrarBurbuja = false;
  String _mensajeBurbuja = '';
  Color _colorBurbuja = Colors.green;

  // Getters para notificaciones
  bool get mostrarBurbuja => _mostrarBurbuja;
  String get mensajeBurbuja => _mensajeBurbuja;
  Color get colorBurbuja => _colorBurbuja;

  CarrerasViewModel() {
    _loadCarreras();
  }

  List<CarreraModel> get carreras => _carreras;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CarreraModel> get carrerasActivas {
    return _carreras.where((carrera) => carrera.activa).toList();
  }

  List<String> get nombresCarrerasActivas {
    return carrerasActivas.map((carrera) => carrera.nombre).toList();
  }

  // ✅ MÉTODO PARA RECARGAR CARRERAS DESDE LA BASE DE DATOS
  Future<void> recargarCarreras() async {
    print('🔄 Recargando carreras desde la base de datos...');
    await _loadCarreras();
  }

  Future<void> _loadCarreras() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Primero verificar si hay carreras en la base de datos
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM carreras
      ''');

      final count = (result.first['count'] as int?) ?? 0;

      if (count == 0) {
        // Si no hay carreras, insertar las predefinidas
        await _insertarCarrerasPredefinidas();
      } else {
        // Si ya hay carreras, cargarlas desde la base de datos
        await _cargarCarrerasExistentes();
      }

      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar carreras: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ INSERTAR CARRERAS PREDEFINIDAS EN SQLITE
  Future<void> _insertarCarrerasPredefinidas() async {
    try {
      _carreras.clear();
      
      // Cargar todas las carreras predefinidas
      _cargarCarrerasPredefinidas();
      
      // Insertar cada carrera en SQLite
      for (final carrera in _carreras) {
        await _databaseHelper.rawInsert('''
          INSERT INTO carreras (id, nombre, color, icon_code_point, activa, 
          fecha_creacion, fecha_actualizacion)
          VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', [
          carrera.id,
          carrera.nombre,
          carrera.color,
          carrera.icon.codePoint,
          carrera.activa ? 1 : 0,
          DateTime.now().toIso8601String(),
          DateTime.now().toIso8601String()
        ]);
      }

      print('✅ ${_carreras.length} carreras predefinidas insertadas en SQLite');
      _mostrarMensajeBurbuja('Carreras predefinidas cargadas', Colors.green);
    } catch (e) {
      print('❌ Error insertando carreras predefinidas: $e');
      _mostrarMensajeBurbuja('Error al cargar carreras: $e', Colors.red);
    }
  }

  // ✅ CARGAR CARRERAS EXISTENTES DESDE SQLITE
  Future<void> _cargarCarrerasExistentes() async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM carreras ORDER BY nombre
      ''');

      _carreras = result.map((row) => 
        CarreraModel.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      print('✅ ${_carreras.length} carreras cargadas desde SQLite');
    } catch (e) {
      print('❌ Error cargando carreras desde SQLite: $e');
      // Si hay error, cargar las predefinidas en memoria
      _cargarCarrerasPredefinidas();
      _mostrarMensajeBurbuja('Error al cargar desde BD, usando datos locales', Colors.orange);
    }
  }

  // ✅ CARGAR TODAS LAS CARRERAS PREDEFINIDAS
  void _cargarCarrerasPredefinidas() {
    _carreras.clear();
    
    _carreras.addAll([
      CarreraModel(
        id: 'sistemas_informaticos',
        nombre: 'Sistemas Informáticos',
        color: '#1565C0',
        icon: Icons.computer,
        activa: true,
      ),
      CarreraModel(
        id: 'comercio_internacional',
        nombre: 'Comercio Internacional y Administración Aduanera',
        color: '#FF9800',
        icon: Icons.business,
        activa: true,
      ),
      CarreraModel(
        id: 'secretariado_ejecutivo',
        nombre: 'Secretariado Ejecutivo',
        color: '#4CAF50',
        icon: Icons.work,
        activa: true,
      ),
      CarreraModel(
        id: 'administracion_empresas',
        nombre: 'Administración de Empresas',
        color: '#03A9F4',
        icon: Icons.business_center,
        activa: true,
      ),
      CarreraModel(
        id: 'contaduria_general',
        nombre: 'Contaduría General',
        color: '#FFEB3B',
        icon: Icons.calculate,
        activa: true,
      ),
      CarreraModel(
        id: 'idioma_ingles',
        nombre: 'Idioma Inglés',
        color: '#F44336',
        icon: Icons.language,
        activa: true,
      ),
    ]);

    print('📚 ${_carreras.length} carreras predefinidas cargadas en memoria');
  }

  // ✅ MÉTODO PARA FORZAR RECARGA DE CARRERAS PREDEFINIDAS
  Future<void> forzarRecargaCarrerasPredefinidas() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Primero eliminar todas las carreras existentes
      await _databaseHelper.rawDelete('DELETE FROM carreras', []);
      
      // Luego insertar las predefinidas
      await _insertarCarrerasPredefinidas();
      
      _mostrarMensajeBurbuja('Carreras recargadas correctamente', Colors.green);
    } catch (e) {
      _mostrarMensajeBurbuja('Error al recargar carreras: $e', Colors.red);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> agregarCarrera(
    String nombre,
    String color,
    IconData icono,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (nombre.isEmpty) {
        throw Exception('El nombre de la carrera no puede estar vacío');
      }

      final carreraId = 'carrera_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();

      await _databaseHelper.rawInsert('''
        INSERT INTO carreras (id, nombre, color, icon_code_point, activa, 
        fecha_creacion, fecha_actualizacion)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', [
        carreraId,
        nombre.trim(),
        color,
        icono.codePoint,
        1,
        now,
        now
      ]);

      await _loadCarreras();
      _mostrarMensajeBurbuja('Carrera agregada correctamente', Colors.green);
    } catch (e) {
      _error = 'Error al agregar carrera: ${e.toString()}';
      _mostrarMensajeBurbuja('Error al agregar carrera: ${e.toString()}', Colors.red);
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editarCarrera(
    String id,
    String nombre,
    String color,
    IconData icono,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (nombre.isEmpty) {
        throw Exception('El nombre de la carrera no puede estar vacío');
      }

      await _databaseHelper.rawUpdate('''
        UPDATE carreras 
        SET nombre = ?, color = ?, icon_code_point = ?, fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        nombre.trim(),
        color,
        icono.codePoint,
        DateTime.now().toIso8601String(),
        id
      ]);

      await _loadCarreras();
      _mostrarMensajeBurbuja('Carrera actualizada correctamente', Colors.green);
    } catch (e) {
      _error = 'Error al editar carrera: ${e.toString()}';
      _mostrarMensajeBurbuja('Error al editar carrera: ${e.toString()}', Colors.red);
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleActivarCarrera(String id) async {
    try {
      final carrera = _carreras.firstWhere((c) => c.id == id);
      final nuevoEstado = !carrera.activa;

      await _databaseHelper.rawUpdate('''
        UPDATE carreras 
        SET activa = ?, fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        nuevoEstado ? 1 : 0,
        DateTime.now().toIso8601String(),
        id
      ]);

      await _loadCarreras();
      _mostrarMensajeBurbuja(
        'Carrera ${nuevoEstado ? 'activada' : 'desactivada'}', 
        nuevoEstado ? Colors.green : Colors.orange
      );
    } catch (e) {
      _error = 'Error al cambiar estado de carrera: ${e.toString()}';
      _mostrarMensajeBurbuja('Error al cambiar estado: ${e.toString()}', Colors.red);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> eliminarCarrera(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseHelper.rawDelete('''
        DELETE FROM carreras WHERE id = ?
      ''', [id]);

      await _loadCarreras();
      _mostrarMensajeBurbuja('Carrera eliminada', Colors.red);
    } catch (e) {
      _error = 'Error al eliminar carrera: ${e.toString()}';
      _mostrarMensajeBurbuja('Error al eliminar carrera: ${e.toString()}', Colors.red);
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ MÉTODO PARA MOSTRAR BURBUJAS DE NOTIFICACIÓN
  void _mostrarMensajeBurbuja(String mensaje, Color color) {
    _mensajeBurbuja = mensaje;
    _colorBurbuja = color;
    _mostrarBurbuja = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      _mostrarBurbuja = false;
      notifyListeners();
    });
  }

  void ocultarBurbuja() {
    _mostrarBurbuja = false;
    notifyListeners();
  }

  CarreraModel? obtenerCarreraPorId(String id) {
    try {
      return _carreras.firstWhere((carrera) => carrera.id == id);
    } catch (e) {
      return null;
    }
  }

  // 🔧 Métodos utilitarios
  static Color parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> reintentarCarga() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    await _loadCarreras();
  }
}