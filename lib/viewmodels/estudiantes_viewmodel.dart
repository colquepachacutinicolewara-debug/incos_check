// viewmodels/estudiantes_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/data_repository.dart';
import '../models/estudiante_model.dart';

class EstudiantesViewModel with ChangeNotifier {
  List<Estudiante> _estudiantes = [];
  List<Estudiante> _estudiantesFiltrados = [];
  final TextEditingController searchController = TextEditingController();

  final DataRepository _repository;
  StreamSubscription? _estudiantesSubscription;

  final String tipo;
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;
  final Map<String, dynamic> nivel;
  final Map<String, dynamic> paralelo;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  EstudiantesViewModel({
    required this.tipo,
    required this.carrera,
    required this.turno,
    required this.nivel,
    required this.paralelo,
    required DataRepository repository,
  }) : _repository = repository {
    _inicializarViewModel();
  }

  void _inicializarViewModel() {
    _cargarEstudiantesDesdeFirestore();
    searchController.addListener(_filtrarEstudiantes);
  }

  // Getters
  List<Estudiante> get estudiantes => _estudiantes;
  List<Estudiante> get estudiantesFiltrados => _estudiantesFiltrados;

  // ✅ CARGA DESDE FIRESTORE
  void _cargarEstudiantesDesdeFirestore() {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Cargando estudiantes desde Firestore...');
      print('   - Carrera: ${carrera['id']}');
      print('   - Turno: ${turno['id']}');
      print('   - Nivel: ${nivel['id']}');
      print('   - Paralelo: ${paralelo['id']}');

      // Cancelar suscripción anterior si existe
      _estudiantesSubscription?.cancel();

      // Usar el stream específico por grupo
      _estudiantesSubscription = _repository
          .getEstudiantesByGrupoStream(
            carreraId: carrera['id']?.toString() ?? '',
            turnoId: turno['id']?.toString() ?? '',
            nivelId: nivel['id']?.toString() ?? '',
            paraleloId: paralelo['id']?.toString() ?? '',
          )
          .listen(_onEstudiantesSnapshot, onError: _onEstudiantesError);
    } catch (e) {
      _onEstudiantesError(e);
    }
  }

  void _onEstudiantesSnapshot(QuerySnapshot snapshot) {
    try {
      print('📥 Recibidos ${snapshot.docs.length} estudiantes de Firestore');

      _estudiantes = snapshot.docs.map((doc) {
        return Estudiante.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();

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
    final query = searchController.text.toLowerCase();
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
  }

  // ✅ AGREGAR ESTUDIANTE
  Future<bool> agregarEstudiante({
    required String nombres,
    required String paterno,
    required String materno,
    required String ci,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 Agregando estudiante: $nombres $paterno $materno');

      // Crear el estudiante
      final nuevoEstudiante = Estudiante(
        id: '', // ID vacío para nuevo documento
        nombres: nombres.trim(),
        apellidoPaterno: paterno.trim(),
        apellidoMaterno: materno.trim(),
        ci: ci.trim(),
        fechaRegistro: DateTime.now().toString().split(' ')[0],
        huellasRegistradas: 0,
        carreraId: carrera['id']?.toString(),
        turnoId: turno['id']?.toString(),
        nivelId: nivel['id']?.toString(),
        paraleloId: paralelo['id']?.toString(),
      );

      // Agregar a Firestore
      await _repository.addEstudiante(nuevoEstudiante.toFirestore());

      _isLoading = false;
      notifyListeners();

      print('✅ Estudiante agregado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error agregando estudiante: $e');
      _error = 'Error al agregar estudiante: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ EDITAR ESTUDIANTE
  Future<bool> editarEstudiante({
    required String id,
    required String nombres,
    required String paterno,
    required String materno,
    required String ci,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 Editando estudiante: $id');

      // Buscar el estudiante actual
      final estudianteExistente = _estudiantes.firstWhere(
        (e) => e.id == id,
        orElse: () => throw Exception('Estudiante no encontrado'),
      );

      // Crear estudiante actualizado
      final estudianteActualizado = estudianteExistente.copyWith(
        nombres: nombres.trim(),
        apellidoPaterno: paterno.trim(),
        apellidoMaterno: materno.trim(),
        ci: ci.trim(),
      );

      // Actualizar en Firestore
      await _repository.updateEstudiante(
        id,
        estudianteActualizado.toFirestore(),
      );

      _isLoading = false;
      notifyListeners();

      print('✅ Estudiante editado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error editando estudiante: $e');
      _error = 'Error al editar estudiante: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ ELIMINAR ESTUDIANTE
  Future<bool> eliminarEstudiante(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 Eliminando estudiante: $id');

      await _repository.deleteEstudiante(id);

      _isLoading = false;
      notifyListeners();

      print('✅ Estudiante eliminado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error eliminando estudiante: $e');
      _error = 'Error al eliminar estudiante: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ ACTUALIZAR HUELLAS
  Future<bool> actualizarHuellasEstudiante(
    String id,
    int huellasRegistradas,
  ) async {
    try {
      print(
        '🔄 Actualizando huellas del estudiante: $id a $huellasRegistradas',
      );

      await _repository.updateEstudiante(id, {
        'huellasRegistradas': huellasRegistradas,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });

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
    _cargarEstudiantesDesdeFirestore();
  }

  // ✅ MÉTODOS DE EXPORTACIÓN (MANTENIDOS)
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
    _estudiantesSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
