// viewmodels/estudiantes_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:async';

// AGREGAR: Importar DataRepository y Firestore
import '../repositories/data_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EstudiantesViewModel with ChangeNotifier {
  List<Map<String, dynamic>> _estudiantes = [];
  List<Map<String, dynamic>> _estudiantesFiltrados = [];
  final TextEditingController searchController = TextEditingController();

  // AGREGADO: DataRepository y StreamSubscription
  final DataRepository _repository;
  StreamSubscription? _estudiantesSubscription;

  // Datos del contexto
  final String tipo;
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;
  final Map<String, dynamic> nivel;
  final Map<String, dynamic> paralelo;

  // Estado de carga
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // CORREGIDO: Constructor con DataRepository (sin _ en parámetro)
  EstudiantesViewModel({
    required this.tipo,
    required this.carrera,
    required this.turno,
    required this.nivel,
    required this.paralelo,
    required DataRepository repository, // CORREGIDO: sin _
  }) : _repository = repository {
    // ASIGNACIÓN en initializer list
    _inicializarViewModel();
  }

  void _inicializarViewModel() {
    _cargarEstudiantesDesdeFirestore(); // NUEVO: Cargar desde Firestore
    searchController.addListener(_filtrarEstudiantes);
  }

  // Getters
  List<Map<String, dynamic>> get estudiantes => _estudiantes;
  List<Map<String, dynamic>> get estudiantesFiltrados => _estudiantesFiltrados;

  // NUEVO: Cargar estudiantes desde Firestore
  void _cargarEstudiantesDesdeFirestore() {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Usar el stream específico por grupo si tenemos los IDs
      if (carrera['id'] != null &&
          turno['id'] != null &&
          nivel['id'] != null &&
          paralelo['id'] != null) {
        _estudiantesSubscription = _repository
            .getEstudiantesByGrupoStream(
              carreraId: carrera['id'],
              turnoId: turno['id'],
              nivelId: nivel['id'],
              paraleloId: paralelo['id'],
            )
            .listen(_onEstudiantesSnapshot, onError: _onEstudiantesError);
      } else {
        // Fallback: cargar todos los estudiantes
        _estudiantesSubscription = _repository.getEstudiantesStream().listen(
          _onEstudiantesSnapshot,
          onError: _onEstudiantesError,
        );
      }
    } catch (e) {
      _onEstudiantesError(e);
    }
  }

  void _onEstudiantesSnapshot(QuerySnapshot snapshot) {
    try {
      _estudiantes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, // Usar el ID de Firestore
          'nombres': data['nombres'] ?? '',
          'apellidoPaterno': data['apellidoPaterno'] ?? '',
          'apellidoMaterno': data['apellidoMaterno'] ?? '',
          'ci': data['ci'] ?? '',
          'fechaRegistro': data['fechaRegistro'] ?? '',
          'huellasRegistradas': data['huellasRegistradas'] ?? 0,
          'carreraId': data['carreraId'] ?? '',
          'turnoId': data['turnoId'] ?? '',
          'nivelId': data['nivelId'] ?? '',
          'paraleloId': data['paraleloId'] ?? '',
        };
      }).toList();

      _isLoading = false;
      _error = null;
      _ordenarEstudiantes();
      notifyListeners();
    } catch (e) {
      _onEstudiantesError(e);
    }
  }

  void _onEstudiantesError(dynamic error) {
    print('Error cargando estudiantes: $error');
    _isLoading = false;
    _error = 'Error al cargar estudiantes: $error';

    // Cargar datos locales de respaldo
    _cargarDatosLocalesDeRespaldo();
    notifyListeners();
  }

  // NUEVO: Datos de respaldo locales
  void _cargarDatosLocalesDeRespaldo() {
    _estudiantes = [
      {
        'id': 'local_1',
        'nombres': 'Juan Carlos',
        'apellidoPaterno': 'Pérez',
        'apellidoMaterno': 'Gómez',
        'ci': '1234567',
        'fechaRegistro': '2024-01-15',
        'huellasRegistradas': 3,
      },
      {
        'id': 'local_2',
        'nombres': 'María Elena',
        'apellidoPaterno': 'López',
        'apellidoMaterno': 'Martínez',
        'ci': '7654321',
        'fechaRegistro': '2024-01-16',
        'huellasRegistradas': 2,
      },
    ];
    _ordenarEstudiantes();
  }

  void _ordenarEstudiantes() {
    _estudiantes.sort((a, b) {
      int comparacion = a['apellidoPaterno'].compareTo(b['apellidoPaterno']);
      if (comparacion != 0) return comparacion;
      comparacion = a['apellidoMaterno'].compareTo(b['apellidoMaterno']);
      if (comparacion != 0) return comparacion;
      return a['nombres'].compareTo(b['nombres']);
    });
    _filtrarEstudiantes();
  }

  void _filtrarEstudiantes() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      _estudiantesFiltrados = List.from(_estudiantes);
    } else {
      _estudiantesFiltrados = _estudiantes.where((estudiante) {
        return estudiante['nombres'].toLowerCase().contains(query) ||
            estudiante['apellidoPaterno'].toLowerCase().contains(query) ||
            estudiante['apellidoMaterno'].toLowerCase().contains(query) ||
            estudiante['ci'].contains(query);
      }).toList();
    }
    notifyListeners();
  }

  // MODIFICADO: Agregar estudiante con Firestore
  Future<void> agregarEstudiante({
    required String nombres,
    required String paterno,
    required String materno,
    required String ci,
  }) async {
    try {
      final data = {
        'nombres': nombres.trim(),
        'apellidoPaterno': paterno.trim(),
        'apellidoMaterno': materno.trim(),
        'ci': ci.trim(),
        'fechaRegistro': DateTime.now().toString().split(' ')[0],
        'huellasRegistradas': 0,
        'carreraId': carrera['id'] ?? '',
        'turnoId': turno['id'] ?? '',
        'nivelId': nivel['id'] ?? '',
        'paraleloId': paralelo['id'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _repository.addDocument('estudiantes', data);

      // El stream se actualizará automáticamente con el nuevo estudiante
    } catch (e) {
      print('Error agregando estudiante: $e');
      throw Exception('Error al agregar estudiante: $e');
    }
  }

  // MODIFICADO: Editar estudiante con Firestore
  Future<void> editarEstudiante({
    required String id, // Cambiado de int a String para Firestore ID
    required String nombres,
    required String paterno,
    required String materno,
    required String ci,
  }) async {
    try {
      final data = {
        'nombres': nombres.trim(),
        'apellidoPaterno': paterno.trim(),
        'apellidoMaterno': materno.trim(),
        'ci': ci.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _repository.updateDocument('estudiantes', id, data);

      // El stream se actualizará automáticamente
    } catch (e) {
      print('Error editando estudiante: $e');
      throw Exception('Error al editar estudiante: $e');
    }
  }

  // MODIFICADO: Eliminar estudiante con Firestore
  Future<void> eliminarEstudiante(String id) async {
    // Cambiado de int a String
    try {
      await _repository.db.collection('estudiantes').doc(id).delete();

      // El stream se actualizará automáticamente
    } catch (e) {
      print('Error eliminando estudiante: $e');
      throw Exception('Error al eliminar estudiante: $e');
    }
  }

  // MODIFICADO: Actualizar huellas con Firestore
  Future<void> actualizarHuellasEstudiante(
    String id,
    int huellasRegistradas,
  ) async {
    try {
      await _repository.updateDocument('estudiantes', id, {
        'huellasRegistradas': huellasRegistradas,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // El stream se actualizará automáticamente
    } catch (e) {
      print('Error actualizando huellas: $e');
      throw Exception('Error al actualizar huellas: $e');
    }
  }

  // MÉTODOS DE EXPORTACIÓN (SIN CAMBIOS - se mantiene toda la funcionalidad)
  Future<void> exportarExcel({
    bool simple = true,
    String asignatura = 'BASE DE DATOS II',
  }) async {
    try {
      final sb = StringBuffer();
      sb.writeln('INSTITUCIÓN,$asignatura,,');
      sb.writeln(
        'CARRERA: ${carrera['nombre']},TURNO: ${turno['nombre']},NIVEL: ${nivel['nombre']},PARAL: ${paralelo['nombre']}',
      );
      sb.writeln();

      final estudiantesExportar = _estudiantesFiltrados;
      estudiantesExportar.sort((a, b) {
        int c = a['apellidoPaterno'].compareTo(b['apellidoPaterno']);
        if (c != 0) return c;
        c = a['apellidoMaterno'].compareTo(b['apellidoMaterno']);
        if (c != 0) return c;
        return a['nombres'].compareTo(b['nombres']);
      });

      if (simple) {
        sb.writeln('NRO,ESTUDIANTE');
        int nro = 1;
        for (var e in estudiantesExportar) {
          final name =
              '${e['apellidoPaterno']} ${e['apellidoMaterno']} ${e['nombres']}'
                  .replaceAll(',', '');
          sb.writeln('$nro,"$name"');
          nro++;
        }
      } else {
        sb.writeln('NRO,ESTUDIANTE,CI,FECHA REGISTRO,HUELLAS');
        int nro = 1;
        for (var e in estudiantesExportar) {
          final name =
              '${e['apellidoPaterno']} ${e['apellidoMaterno']} ${e['nombres']}'
                  .replaceAll(',', '');
          sb.writeln(
            '$nro,"$name",${e['ci']},${e['fechaRegistro']},${e['huellasRegistradas']}/3',
          );
          nro++;
        }
      }

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/lista_estudiantes_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      await file.writeAsString(sb.toString(), flush: true);
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
    List<Map<String, dynamic>> estudiantes,
    bool simple,
    String asignatura,
  ) {
    final doc = pw.Document();

    estudiantes.sort((a, b) {
      int c = a['apellidoPaterno'].compareTo(b['apellidoPaterno']);
      if (c != 0) return c;
      c = a['apellidoMaterno'].compareTo(b['apellidoMaterno']);
      if (c != 0) return c;
      return a['nombres'].compareTo(b['nombres']);
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
                        '${e['apellidoPaterno']} ${e['apellidoMaterno']} ${e['nombres']}',
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
                        '${e['apellidoPaterno']} ${e['apellidoMaterno']} ${e['nombres']}',
                        e['ci'],
                        e['fechaRegistro'],
                        '${e['huellasRegistradas']}/3',
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
      int c = a['apellidoPaterno'].compareTo(b['apellidoPaterno']);
      if (c != 0) return c;
      c = a['apellidoMaterno'].compareTo(b['apellidoMaterno']);
      if (c != 0) return c;
      return a['nombres'].compareTo(b['nombres']);
    });

    if (simple) {
      sb.writeln('NRO,ESTUDIANTE');
      int nro = 1;
      for (var e in estudiantesExportar) {
        final name =
            '${e['apellidoPaterno']} ${e['apellidoMaterno']} ${e['nombres']}'
                .replaceAll(',', '');
        sb.writeln('$nro,"$name"');
        nro++;
      }
    } else {
      sb.writeln('NRO,ESTUDIANTE,CI,FECHA REGISTRO,HUELLAS');
      int nro = 1;
      for (var e in estudiantesExportar) {
        final name =
            '${e['apellidoPaterno']} ${e['apellidoMaterno']} ${e['nombres']}'
                .replaceAll(',', '');
        sb.writeln(
          '$nro,"$name",${e['ci']},${e['fechaRegistro']},${e['huellasRegistradas']}/3',
        );
        nro++;
      }
    }

    return sb.toString();
  }

  @override
  void dispose() {
    _estudiantesSubscription?.cancel(); // AGREGADO: Cancelar subscription
    searchController.dispose();
    super.dispose();
  }
}
