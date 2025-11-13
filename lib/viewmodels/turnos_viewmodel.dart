// viewmodels/turnos_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/turnos_model.dart';
import '../models/database_helper.dart';

class TurnosViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  String tipo;
  Map<String, dynamic> carrera;

  List<TurnoModel> _turnos = [];
  bool _isLoading = false;
  String? _error;

  List<TurnoModel> get turnos => _turnos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TurnosViewModel({ // ✅ CONSTRUCTOR SIMPLIFICADO
    this.tipo = 'Turnos',
    Map<String, dynamic>? carrera,
  }) : carrera = carrera ?? {'id': '', 'nombre': 'General', 'color': '#1565C0'} {
    _cargarTurnosDesdeSQLite();
  }

  Future<void> _cargarTurnosDesdeSQLite() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM turnos 
        WHERE activo = 1 
        ORDER BY nombre
      ''');

      _turnos = result.map((row) => 
        TurnoModel.fromMap(row['id'].toString(), Map<String, dynamic>.from(row))
      ).toList();

      // Si no hay turnos, cargar los por defecto
      if (_turnos.isEmpty) {
        await _cargarTurnosPorDefecto();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar turnos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cargarTurnosPorDefecto() async {
    final turnosPorDefecto = [
      TurnoModel(
        id: 'turno_manana',
        nombre: 'Mañana',
        icon: Icons.wb_sunny,
        horario: '06:30 - 12:30',
        rangoAsistencia: '06:00-12:00',
        dias: 'Lunes a Viernes',
        color: '#FFA000',
        activo: true,
        niveles: ['Todos'],
      ),
      TurnoModel(
        id: 'turno_tarde',
        nombre: 'Tarde',
        icon: Icons.brightness_6,
        horario: '12:30 - 18:30',
        rangoAsistencia: '12:00-18:00',
        dias: 'Lunes a Viernes',
        color: '#1976D2',
        activo: true,
        niveles: ['Todos'],
      ),
      TurnoModel(
        id: 'turno_noche',
        nombre: 'Noche',
        icon: Icons.nights_stay,
        horario: '18:30 - 22:30',
        rangoAsistencia: '18:00-22:00',
        dias: 'Lunes a Viernes',
        color: '#7B1FA2',
        activo: true,
        niveles: ['Todos'],
      ),
    ];

    // Insertar turnos por defecto en SQLite
    for (final turno in turnosPorDefecto) {
      await _databaseHelper.rawInsert('''
        INSERT OR IGNORE INTO turnos (id, nombre, icon_code_point, horario, rango_asistencia, dias, color, activo, niveles, fecha_creacion, fecha_actualizacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        turno.id,
        turno.nombre,
        turno.icon.codePoint,
        turno.horario,
        turno.rangoAsistencia,
        turno.dias,
        turno.color,
        turno.activo ? 1 : 0,
        turno.niveles.join(','), // Guardar como string separado por comas
        DateTime.now().toIso8601String(),
        DateTime.now().toIso8601String(),
      ]);
    }

    _turnos = turnosPorDefecto;
  }

  Future<bool> agregarTurno(TurnoModel nuevoTurno) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Verificar si ya existe un turno con el mismo nombre
      final existe = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM turnos 
        WHERE nombre = ? AND activo = 1
      ''', [nuevoTurno.nombre]);

      final count = (existe.first['count'] as int?) ?? 0;
      if (count > 0) {
        _error = 'Ya existe un turno con el nombre ${nuevoTurno.nombre}';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _databaseHelper.rawInsert('''
        INSERT INTO turnos (id, nombre, icon_code_point, horario, rango_asistencia, dias, color, activo, niveles, fecha_creacion, fecha_actualizacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        nuevoTurno.id,
        nuevoTurno.nombre,
        nuevoTurno.icon.codePoint,
        nuevoTurno.horario,
        nuevoTurno.rangoAsistencia,
        nuevoTurno.dias,
        nuevoTurno.color,
        nuevoTurno.activo ? 1 : 0,
        nuevoTurno.niveles.join(','),
        DateTime.now().toIso8601String(),
        DateTime.now().toIso8601String(),
      ]);

      await _cargarTurnosDesdeSQLite();
      return true;
    } catch (e) {
      _error = 'Error al agregar turno: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarTurno(TurnoModel turnoActualizado) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Verificar si ya existe otro turno con el mismo nombre (excluyendo el actual)
      final existe = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count FROM turnos 
        WHERE nombre = ? AND id != ? AND activo = 1
      ''', [turnoActualizado.nombre, turnoActualizado.id]);

      final count = (existe.first['count'] as int?) ?? 0;
      if (count > 0) {
        _error = 'Ya existe otro turno con el nombre ${turnoActualizado.nombre}';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _databaseHelper.rawUpdate('''
        UPDATE turnos SET 
        nombre = ?, icon_code_point = ?, horario = ?, rango_asistencia = ?, 
        dias = ?, color = ?, activo = ?, niveles = ?, fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        turnoActualizado.nombre,
        turnoActualizado.icon.codePoint,
        turnoActualizado.horario,
        turnoActualizado.rangoAsistencia,
        turnoActualizado.dias,
        turnoActualizado.color,
        turnoActualizado.activo ? 1 : 0,
        turnoActualizado.niveles.join(','),
        DateTime.now().toIso8601String(),
        turnoActualizado.id,
      ]);

      await _cargarTurnosDesdeSQLite();
      return true;
    } catch (e) {
      _error = 'Error al actualizar turno: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarTurno(String turnoId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _databaseHelper.rawUpdate('''
        UPDATE turnos SET activo = 0, fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        DateTime.now().toIso8601String(),
        turnoId,
      ]);

      await _cargarTurnosDesdeSQLite();
      return true;
    } catch (e) {
      _error = 'Error al eliminar turno: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void toggleActivarTurno(TurnoModel turno) {
    final turnoActualizado = turno.copyWith(activo: !turno.activo);
    actualizarTurno(turnoActualizado);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> recargarTurnos() async {
    await _cargarTurnosDesdeSQLite();
  }

  Color parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  String generarTurnoId() {
    return 'turno_${DateTime.now().millisecondsSinceEpoch}';
  }
}