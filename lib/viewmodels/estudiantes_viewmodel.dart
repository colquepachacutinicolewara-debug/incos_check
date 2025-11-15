// viewmodels/estudiantes_viewmodel.dart - VERSIÓN CORREGIDA
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:async';
import '../models/estudiante_model.dart';
import '../models/database_helper.dart';

class EstudiantesViewModel with ChangeNotifier {
  List<Estudiante> _estudiantes = [];
  List<Estudiante> _estudiantesFiltrados = [];
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Listas para los dropdowns
  List<Map<String, dynamic>> _carreras = [];
  List<Map<String, dynamic>> _turnos = [];
  List<Map<String, dynamic>> _niveles = [];
  List<Map<String, dynamic>> _paralelos = [];

  String tipo;
  Map<String, dynamic> carrera;
  Map<String, dynamic> turno;
  Map<String, dynamic> nivel;
  Map<String, dynamic> paralelo;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Getters para las listas
  List<Map<String, dynamic>> get carreras => _carreras;
  List<Map<String, dynamic>> get turnos => _turnos;
  List<Map<String, dynamic>> get niveles => _niveles;
  List<Map<String, dynamic>> get paralelos => _paralelos;

  // CONSTRUCTOR CORREGIDO
  EstudiantesViewModel({
    this.tipo = 'Estudiantes',
    Map<String, dynamic>? carrera,
    Map<String, dynamic>? turno,
    Map<String, dynamic>? nivel,
    Map<String, dynamic>? paralelo,
  }) : carrera = carrera ?? {'id': 'info', 'nombre': 'Informática', 'color': '#1565C0'},
       turno = turno ?? {'id': 'turno_manana', 'nombre': 'Mañana'},
       nivel = nivel ?? {'id': 'nivel_secundaria', 'nombre': 'Secundaria'},
       paralelo = paralelo ?? {'id': 'paralelo_a', 'nombre': 'A'} {
    _inicializarViewModel();
  }

  void _inicializarViewModel() {
    _cargarDatosIniciales();
    searchController.addListener(_filtrarEstudiantes);
  }

  // Getters
  List<Estudiante> get estudiantes => _estudiantes;
  List<Estudiante> get estudiantesFiltrados => _estudiantesFiltrados;

  // ✅ CARGA DATOS INICIALES (estudiantes + dropdowns) - CORREGIDO
  Future<void> _cargarDatosIniciales() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Cargando datos iniciales...');
      
      // Cargar datos para dropdowns
      await _cargarCarreras();
      await _cargarTurnos();
      await _cargarNiveles();
      await _cargarParalelos();
      
      // Cargar estudiantes
      await _loadEstudiantesFromDB();

      _isLoading = false;
      notifyListeners();

      print('✅ Datos iniciales cargados correctamente');
    } catch (e) {
      _onEstudiantesError(e);
    }
  }

  // ✅ CARGAR CARRERAS
  Future<void> _cargarCarreras() async {
    try {
      final result = await _databaseHelper.rawQuery(
        'SELECT id, nombre, color FROM carreras WHERE activa = 1 ORDER BY nombre'
      );
      _carreras = result.map((row) => Map<String, dynamic>.from(row)).toList();
      print('📚 Carreras cargadas: ${_carreras.length}');
    } catch (e) {
      print('❌ Error cargando carreras: $e');
      _carreras = [];
    }
  }

  // ✅ CARGAR TURNOS
  Future<void> _cargarTurnos() async {
    try {
      final result = await _databaseHelper.rawQuery(
        'SELECT id, nombre, color FROM turnos WHERE activo = 1 ORDER BY nombre'
      );
      _turnos = result.map((row) => Map<String, dynamic>.from(row)).toList();
      print('🕒 Turnos cargados: ${_turnos.length}');
    } catch (e) {
      print('❌ Error cargando turnos: $e');
      _turnos = [];
    }
  }

  // ✅ CARGAR NIVELES
  Future<void> _cargarNiveles() async {
    try {
      final result = await _databaseHelper.rawQuery(
        'SELECT id, nombre FROM niveles WHERE activo = 1 ORDER BY orden'
      );
      _niveles = result.map((row) => Map<String, dynamic>.from(row)).toList();
      print('📊 Niveles cargados: ${_niveles.length}');
    } catch (e) {
      print('❌ Error cargando niveles: $e');
      _niveles = [];
    }
  }

  // ✅ CARGAR PARALELOS
  Future<void> _cargarParalelos() async {
    try {
      final result = await _databaseHelper.rawQuery(
        'SELECT id, nombre FROM paralelos WHERE activo = 1 ORDER BY nombre'
      );
      _paralelos = result.map((row) => Map<String, dynamic>.from(row)).toList();
      print('🔤 Paralelos cargados: ${_paralelos.length}');
    } catch (e) {
      print('❌ Error cargando paralelos: $e');
      _paralelos = [];
    }
  }

  // ✅ CARGA ESTUDIANTES DESDE SQLITE - CORREGIDO
  Future<void> _loadEstudiantesFromDB() async {
    try {
      // ✅ CONSULTA SIMPLIFICADA - SIN FILTROS PARA VER TODOS LOS ESTUDIANTES
      String query = 'SELECT * FROM estudiantes';
      List<Object?> params = [];

      print('🔍 Ejecutando consulta: $query');
      print('🎯 Filtros aplicados:');
      print('   - Carrera: ${carrera['id']}');
      print('   - Turno: ${turno['id']}');
      print('   - Nivel: ${nivel['id']}');
      print('   - Paralelo: ${paralelo['id']}');

      final result = await _databaseHelper.rawQuery(query, params);

      print('📥 Recibidos ${result.length} estudiantes de SQLite');

      _estudiantes = result.map((row) => 
        Estudiante.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      _isLoading = false;
      _error = null;
      _ordenarEstudiantes();
      notifyListeners();

      print('✅ Estudiantes cargados: ${_estudiantes.length}');
      
      // Debug: mostrar información de los estudiantes cargados
      for (var estudiante in _estudiantes) {
        print('   👤 ${estudiante.nombreCompleto} - CI: ${estudiante.ci}');
        print('      Carrera: ${estudiante.carreraId} | Turno: ${estudiante.turnoId}');
        print('      Nivel: ${estudiante.nivelId} | Paralelo: ${estudiante.paraleloId}');
      }
    } catch (e) {
      _onEstudiantesError(e);
    }
  }

  void _onEstudiantesError(dynamic error) {
    print('❌ Error cargando estudiantes: $error');
    _isLoading = false;
    _error = 'Error al cargar estudiantes: $error';
    notifyListeners();
  }

  void _ordenarEstudiantes() {
    _estudiantes.sort((a, b) {
      int comparacion = a.apellidoPaterno.compareTo(b.apellidoPaterno);
      if (comparacion != 0) return comparacion;
      comparacion = a.apellidoMaterno.compareTo(b.apellidoMaterno);
      if (comparacion != 0) return comparacion;
      return a.nombres.compareTo(b.nombres);
    });
    _filtrarEstudiantes();
  }

  void _filtrarEstudiantes() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      final query = searchController.text.toLowerCase().trim();
      if (query.isEmpty) {
        _estudiantesFiltrados = List.from(_estudiantes);
      } else {
        _estudiantesFiltrados = _estudiantes.where((estudiante) {
          return estudiante.nombres.toLowerCase().contains(query) ||
              estudiante.apellidoPaterno.toLowerCase().contains(query) ||
              estudiante.apellidoMaterno.toLowerCase().contains(query) ||
              estudiante.ci.contains(query);
        }).toList();
      }
      notifyListeners();
    });
  }

  // ✅ MÉTODO MEJORADO PARA OPERACIONES CRUD
  Future<bool> _executeDatabaseOperation(
    String operation, 
    Future<void> Function() operationFn
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await operationFn();
      
      // ✅ RECARGAR TODOS LOS ESTUDIANTES SIN FILTROS
      await _loadEstudiantesFromDB();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(operation, e);
      return false;
    }
  }

  // ✅ AGREGAR ESTUDIANTE - COMPLETO CON TODOS LOS CAMPOS
  Future<bool> agregarEstudiante({
    required String nombres,
    required String paterno,
    required String materno,
    required String ci,
    required String carreraId,
    required String turnoId,
    required String nivelId,
    required String paraleloId,
  }) async {
    return _executeDatabaseOperation('agregar estudiante', () async {
      // Verificar si ya existe un estudiante con el mismo CI
      final existing = await _databaseHelper.rawQuery(
        'SELECT COUNT(*) as count FROM estudiantes WHERE ci = ?',
        [ci.trim()]
      );
      
      final count = existing.first['count'] as int? ?? 0;
      final ciExists = count > 0;
      
      if (ciExists) {
        throw Exception('Ya existe un estudiante con este CI: $ci');
      }

      // Crear el estudiante con TODOS los campos
      final estudianteId = 'est_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();
      final fechaRegistro = DateTime.now().toString().split(' ')[0];

      print('🎯 Insertando estudiante con todos los campos:');
      print('   - ID: $estudianteId');
      print('   - Nombres: $nombres');
      print('   - Paterno: $paterno');
      print('   - Materno: $materno');
      print('   - CI: $ci');
      print('   - Carrera ID: $carreraId');
      print('   - Turno ID: $turnoId');
      print('   - Nivel ID: $nivelId');
      print('   - Paralelo ID: $paraleloId');

      // Agregar a SQLite
      final result = await _databaseHelper.rawInsert('''
        INSERT INTO estudiantes (
          id, nombres, apellido_paterno, apellido_materno, ci,
          fecha_registro, huellas_registradas, carrera_id, turno_id, 
          nivel_id, paralelo_id, fecha_creacion, fecha_actualizacion
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        estudianteId,
        nombres.trim(),
        paterno.trim(),
        materno.trim(),
        ci.trim(),
        fechaRegistro,
        0, // huellas_registradas por defecto
        carreraId.isNotEmpty ? carreraId : 'info',
        turnoId.isNotEmpty ? turnoId : 'turno_manana',
        nivelId.isNotEmpty ? nivelId : 'nivel_secundaria',
        paraleloId.isNotEmpty ? paraleloId : 'paralelo_a',
        now,
        now
      ]);

      print('✅ Estudiante agregado exitosamente: $nombres $paterno - ID: $result');
    });
  }

  // ✅ EDITAR ESTUDIANTE - COMPLETO CON TODOS LOS CAMPOS
  Future<bool> editarEstudiante({
    required String id,
    required String nombres,
    required String paterno,
    required String materno,
    required String ci,
    required String carreraId,
    required String turnoId,
    required String nivelId,
    required String paraleloId,
  }) async {
    return _executeDatabaseOperation('editar estudiante', () async {
      // Verificar si el CI ya existe en otro estudiante
      final existing = await _databaseHelper.rawQuery(
        'SELECT COUNT(*) as count FROM estudiantes WHERE ci = ? AND id != ?',
        [ci.trim(), id]
      );
      
      final count = existing.first['count'] as int? ?? 0;
      final ciExists = count > 0;
      
      if (ciExists) {
        throw Exception('Ya existe otro estudiante con este CI: $ci');
      }

      print('🎯 Actualizando estudiante:');
      print('   - ID: $id');
      print('   - Nuevos datos:');
      print('     Nombres: $nombres');
      print('     Paterno: $paterno');
      print('     Materno: $materno');
      print('     CI: $ci');
      print('     Carrera: $carreraId');
      print('     Turno: $turnoId');
      print('     Nivel: $nivelId');
      print('     Paralelo: $paraleloId');

      // Actualizar en SQLite con TODOS los campos
      final result = await _databaseHelper.rawUpdate('''
        UPDATE estudiantes 
        SET nombres = ?, apellido_paterno = ?, apellido_materno = ?, ci = ?,
            carrera_id = ?, turno_id = ?, nivel_id = ?, paralelo_id = ?,
            fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        nombres.trim(),
        paterno.trim(),
        materno.trim(),
        ci.trim(),
        carreraId.isNotEmpty ? carreraId : 'info',
        turnoId.isNotEmpty ? turnoId : 'turno_manana',
        nivelId.isNotEmpty ? nivelId : 'nivel_secundaria',
        paraleloId.isNotEmpty ? paraleloId : 'paralelo_a',
        DateTime.now().toIso8601String(),
        id
      ]);

      print('✅ Estudiante editado exitosamente: $id - Filas afectadas: $result');
    });
  }

  // ✅ ELIMINAR ESTUDIANTE
  Future<bool> eliminarEstudiante(String id) async {
    return _executeDatabaseOperation('eliminar estudiante', () async {
      print('🔄 Eliminando estudiante: $id');

      final result = await _databaseHelper.rawDelete('''
        DELETE FROM estudiantes WHERE id = ?
      ''', [id]);

      print('✅ Estudiante eliminado exitosamente: $id - Filas afectadas: $result');
    });
  }

  // ✅ ACTUALIZAR HUELLAS
  Future<bool> actualizarHuellasEstudiante(
    String id,
    int huellasRegistradas,
  ) async {
    try {
      print('🔄 Actualizando huellas del estudiante: $id a $huellasRegistradas');

      final result = await _databaseHelper.rawUpdate('''
        UPDATE estudiantes 
        SET huellas_registradas = ?, fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        huellasRegistradas,
        DateTime.now().toIso8601String(),
        id
      ]);

      // Recargar la lista para reflejar los cambios
      await _loadEstudiantesFromDB();

      print('✅ Huellas actualizadas exitosamente - Filas afectadas: $result');
      return true;
    } catch (e) {
      print('❌ Error actualizando huellas: $e');
      _error = 'Error al actualizar huellas: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ REINTENTAR CARGA - CORREGIDO
  Future<void> reintentarCarga() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    await _cargarDatosIniciales();
  }

  // ✅ MÉTODO HELPER PARA ERRORES
  void _handleError(String operation, dynamic error) {
    print('❌ Error $operation: $error');
    _error = 'Error al $operation: ${error.toString()}';
    _isLoading = false;
    notifyListeners();
  }

  // ✅ VERIFICAR SI LA BASE DE DATOS TIENE ESTUDIANTES
  Future<bool> tieneEstudiantes() async {
    try {
      final result = await _databaseHelper.rawQuery(
        'SELECT COUNT(*) as count FROM estudiantes'
      );
      final count = result.first['count'] as int? ?? 0;
      print('🔍 Verificación: La base de datos tiene $count estudiantes');
      return count > 0;
    } catch (e) {
      print('❌ Error verificando estudiantes: $e');
      return false;
    }
  }

  // ✅ OBTENER TODOS LOS ESTUDIANTES SIN FILTROS (PARA DEBUG)
  Future<void> cargarTodosLosEstudiantes() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _databaseHelper.rawQuery(
        'SELECT * FROM estudiantes ORDER BY apellido_paterno, apellido_materno, nombres'
      );

      _estudiantes = result.map((row) => 
        Estudiante.fromMap(Map<String, dynamic>.from(row))
      ).toList();

      _isLoading = false;
      _ordenarEstudiantes();
      notifyListeners();

      print('🎯 Todos los estudiantes cargados: ${_estudiantes.length}');
    } catch (e) {
      _onEstudiantesError(e);
    }
  }

  // Los métodos de exportación permanecen igual...
  Future<void> exportarExcel({
    bool simple = true,
    String asignatura = 'BASE DE DATOS II',
  }) async {
    try {
      final csvContent = buildCsvString(simple, asignatura);
      
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/lista_estudiantes_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      await file.writeAsString(csvContent, flush: true);
      await Share.shareXFiles([XFile(file.path)], text: 'Lista de estudiantes');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> exportarPDF({
    bool simple = true,
    String asignatura = 'BASE DE DATOS II',
  }) async {
    try {
      final doc = buildPdfDocument(_estudiantesFiltrados, simple, asignatura);
      final bytes = await doc.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'lista_estudiantes_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      rethrow;
    }
  }

  pw.Document buildPdfDocument(
    List<Estudiante> estudiantes,
    bool simple,
    String asignatura,
  ) {
    final doc = pw.Document();

    estudiantes.sort((a, b) {
      int c = a.apellidoPaterno.compareTo(b.apellidoPaterno);
      if (c != 0) return c;
      c = a.apellidoMaterno.compareTo(b.apellidoMaterno);
      if (c != 0) return c;
      return a.nombres.compareTo(b.nombres);
    });

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'INSTITUTO TÉCNICO COMERCIAL "INCOS - EL ALTO"',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(asignatura, style: pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'CARRERA: ${carrera['nombre']}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'TURNO: ${turno['nombre']}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'CURSO: ${nivel['nombre']} - Paralelo ${paralelo['nombre']}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 8),
                ],
              ),
            ),
            pw.SizedBox(height: 6),
            if (simple)
              pw.Column(
                children: [
                  pw.Table.fromTextArray(
                    headers: ['NRO', 'ESTUDIANTES'],
                    data: List<List<String>>.generate(estudiantes.length, (i) {
                      final e = estudiantes[i];
                      return [
                        '${i + 1}',
                        '${e.apellidoPaterno} ${e.apellidoMaterno} ${e.nombres}',
                      ];
                    }),
                  ),
                ],
              )
            else
              pw.Column(
                children: [
                  pw.Table.fromTextArray(
                    headers: ['NRO', 'ESTUDIANTE', 'CI', 'Registro', 'Huellas'],
                    data: List<List<String>>.generate(estudiantes.length, (i) {
                      final e = estudiantes[i];
                      return [
                        '${i + 1}',
                        '${e.apellidoPaterno} ${e.apellidoMaterno} ${e.nombres}',
                        e.ci,
                        e.fechaRegistro,
                        '${e.huellasRegistradas}/3',
                      ];
                    }),
                  ),
                ],
              ),
          ];
        },
      ),
    );

    return doc;
  }

  String buildCsvString(bool simple, String asignatura) {
    final sb = StringBuffer();
    sb.writeln('INSTITUCIÓN,$asignatura,,');
    sb.writeln(
      'CARRERA: ${carrera['nombre']},TURNO: ${turno['nombre']},NIVEL: ${nivel['nombre']},PARAL: ${paralelo['nombre']}',
    );
    sb.writeln();

    final estudiantesExportar = _estudiantesFiltrados;
    estudiantesExportar.sort((a, b) {
      int c = a.apellidoPaterno.compareTo(b.apellidoPaterno);
      if (c != 0) return c;
      c = a.apellidoMaterno.compareTo(b.apellidoMaterno);
      if (c != 0) return c;
      return a.nombres.compareTo(b.nombres);
    });

    if (simple) {
      sb.writeln('NRO,ESTUDIANTE');
      int nro = 1;
      for (var e in estudiantesExportar) {
        final name = '${e.apellidoPaterno} ${e.apellidoMaterno} ${e.nombres}'
            .replaceAll(',', '');
        sb.writeln('$nro,"$name"');
        nro++;
      }
    } else {
      sb.writeln('NRO,ESTUDIANTE,CI,FECHA REGISTRO,HUELLAS');
      int nro = 1;
      for (var e in estudiantesExportar) {
        final name = '${e.apellidoPaterno} ${e.apellidoMaterno} ${e.nombres}'
            .replaceAll(',', '');
        sb.writeln(
          '$nro,"$name",${e.ci},${e.fechaRegistro},${e.huellasRegistradas}/3',
        );
        nro++;
      }
    }

    return sb.toString();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}