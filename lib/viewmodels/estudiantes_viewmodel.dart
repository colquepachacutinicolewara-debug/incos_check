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

  // Parámetros opcionales con valores por defecto
  String tipo;
  Map<String, dynamic> carrera;
  Map<String, dynamic> turno;
  Map<String, dynamic> nivel;
  Map<String, dynamic> paralelo;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // CONSTRUCTOR CORREGIDO - Sin parámetro DatabaseHelper requerido
  EstudiantesViewModel({
    this.tipo = 'Estudiantes',
    Map<String, dynamic>? carrera,
    Map<String, dynamic>? turno,
    Map<String, dynamic>? nivel,
    Map<String, dynamic>? paralelo,
  }) : carrera = carrera ?? {'id': '', 'nombre': 'General', 'color': '#1565C0'},
       turno = turno ?? {'id': '', 'nombre': 'General'},
       nivel = nivel ?? {'id': '', 'nombre': 'General'},
       paralelo = paralelo ?? {'id': '', 'nombre': 'General'} {
    _inicializarViewModel();
  }

  void _inicializarViewModel() {
    _cargarEstudiantesDesdeDatabase();
    searchController.addListener(_filtrarEstudiantes);
  }

  // Getters
  List<Estudiante> get estudiantes => _estudiantes;
  List<Estudiante> get estudiantesFiltrados => _estudiantesFiltrados;

  // ✅ CARGA DESDE SQLITE
  void _cargarEstudiantesDesdeDatabase() {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Cargando estudiantes desde SQLite...');
      print('   - Carrera: ${carrera['id']}');
      print('   - Turno: ${turno['id']}');
      print('   - Nivel: ${nivel['id']}');
      print('   - Paralelo: ${paralelo['id']}');

      _loadEstudiantesFromDB();
    } catch (e) {
      _onEstudiantesError(e);
    }
  }

  Future<void> _loadEstudiantesFromDB() async {
    try {
      String query = 'SELECT * FROM estudiantes WHERE 1=1';
      List<Object?> params = [];

      // Agregar filtros solo si los IDs no están vacíos
      if (carrera['id']?.toString().isNotEmpty == true) {
        query += ' AND carrera_id = ?';
        params.add(carrera['id']?.toString());
      }
      if (turno['id']?.toString().isNotEmpty == true) {
        query += ' AND turno_id = ?';
        params.add(turno['id']?.toString());
      }
      if (nivel['id']?.toString().isNotEmpty == true) {
        query += ' AND nivel_id = ?';
        params.add(nivel['id']?.toString());
      }
      if (paralelo['id']?.toString().isNotEmpty == true) {
        query += ' AND paralelo_id = ?';
        params.add(paralelo['id']?.toString());
      }

      query += ' ORDER BY apellido_paterno, apellido_materno, nombres';

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
      await _loadEstudiantesFromDB();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(operation, e);
      return false;
    }
  }

  // ✅ AGREGAR ESTUDIANTE - MEJORADO
  Future<bool> agregarEstudiante({
    required String nombres,
    required String paterno,
    required String materno,
    required String ci,
  }) async {
    return _executeDatabaseOperation('agregar estudiante', () async {
      // Verificar si ya existe un estudiante con el mismo CI
      final ciExists = _estudiantes.any((e) => e.ci == ci.trim());
      if (ciExists) {
        throw Exception('Ya existe un estudiante con este CI');
      }

      // Crear el estudiante
      final estudianteId = 'est_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();
      final fechaRegistro = DateTime.now().toString().split(' ')[0];

      // Agregar a SQLite
      await _databaseHelper.rawInsert('''
        INSERT INTO estudiantes (id, nombres, apellido_paterno, apellido_materno, ci,
        fecha_registro, huellas_registradas, carrera_id, turno_id, nivel_id, paralelo_id,
        fecha_creacion, fecha_actualizacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        estudianteId,
        nombres.trim(),
        paterno.trim(),
        materno.trim(),
        ci.trim(),
        fechaRegistro,
        0,
        carrera['id']?.toString() ?? '',
        turno['id']?.toString() ?? '',
        nivel['id']?.toString() ?? '',
        paralelo['id']?.toString() ?? '',
        now,
        now
      ]);

      print('✅ Estudiante agregado exitosamente: $nombres $paterno');
    });
  }

  // ✅ EDITAR ESTUDIANTE - MEJORADO
  Future<bool> editarEstudiante({
    required String id,
    required String nombres,
    required String paterno,
    required String materno,
    required String ci,
  }) async {
    return _executeDatabaseOperation('editar estudiante', () async {
      // Buscar el estudiante actual
      final estudianteExistente = _estudiantes.firstWhere(
        (e) => e.id == id,
        orElse: () => throw Exception('Estudiante no encontrado'),
      );

      // Verificar si el CI ya existe en otro estudiante
      if (ci.trim() != estudianteExistente.ci) {
        final ciExists = _estudiantes.any((e) => e.id != id && e.ci == ci.trim());
        if (ciExists) {
          throw Exception('Ya existe otro estudiante con este CI');
        }
      }

      // Actualizar en SQLite
      await _databaseHelper.rawUpdate('''
        UPDATE estudiantes 
        SET nombres = ?, apellido_paterno = ?, apellido_materno = ?, ci = ?,
            fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        nombres.trim(),
        paterno.trim(),
        materno.trim(),
        ci.trim(),
        DateTime.now().toIso8601String(),
        id
      ]);

      print('✅ Estudiante editado exitosamente: $id');
    });
  }

  // ✅ ELIMINAR ESTUDIANTE - MEJORADO
  Future<bool> eliminarEstudiante(String id) async {
    return _executeDatabaseOperation('eliminar estudiante', () async {
      print('🔄 Eliminando estudiante: $id');

      await _databaseHelper.rawDelete('''
        DELETE FROM estudiantes WHERE id = ?
      ''', [id]);

      print('✅ Estudiante eliminado exitosamente: $id');
    });
  }

  // ✅ ACTUALIZAR HUELLAS
  Future<bool> actualizarHuellasEstudiante(
    String id,
    int huellasRegistradas,
  ) async {
    try {
      print('🔄 Actualizando huellas del estudiante: $id a $huellasRegistradas');

      await _databaseHelper.rawUpdate('''
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

      print('✅ Huellas actualizadas exitosamente');
      return true;
    } catch (e) {
      print('❌ Error actualizando huellas: $e');
      _error = 'Error al actualizar huellas: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ REINTENTAR CARGA
  Future<void> reintentarCarga() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    await _loadEstudiantesFromDB();
  }

  // ✅ MÉTODO HELPER PARA ERRORES
  void _handleError(String operation, dynamic error) {
    print('❌ Error $operation: $error');
    _error = 'Error al $operation: ${error.toString()}';
    _isLoading = false;
    notifyListeners();
  }

  // ✅ MÉTODOS DE EXPORTACIÓN
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