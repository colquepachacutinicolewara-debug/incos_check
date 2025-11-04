// viewmodels/estudiantes_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class EstudiantesViewModel with ChangeNotifier {
  List<Map<String, dynamic>> _estudiantes = [];
  List<Map<String, dynamic>> _estudiantesFiltrados = [];
  final TextEditingController searchController = TextEditingController();

  // Datos del contexto
  final String tipo;
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;
  final Map<String, dynamic> nivel;
  final Map<String, dynamic> paralelo;

  EstudiantesViewModel({
    required this.tipo,
    required this.carrera,
    required this.turno,
    required this.nivel,
    required this.paralelo,
  }) {
    _cargarDatosIniciales();
    searchController.addListener(_filtrarEstudiantes);
  }

  // Getters
  List<Map<String, dynamic>> get estudiantes => _estudiantes;
  List<Map<String, dynamic>> get estudiantesFiltrados => _estudiantesFiltrados;

  void _cargarDatosIniciales() {
    _estudiantes = [
      {
        'id': 1,
        'nombres': 'Juan Carlos',
        'apellidoPaterno': 'Pérez',
        'apellidoMaterno': 'Gómez',
        'ci': '1234567',
        'fechaRegistro': '2024-01-15',
        'huellasRegistradas': 3,
      },
      {
        'id': 2,
        'nombres': 'María Elena',
        'apellidoPaterno': 'López',
        'apellidoMaterno': 'Martínez',
        'ci': '7654321',
        'fechaRegistro': '2024-01-16',
        'huellasRegistradas': 2,
      },
      {
        'id': 3,
        'nombres': 'Ana María',
        'apellidoPaterno': 'García',
        'apellidoMaterno': 'López',
        'ci': '9876543',
        'fechaRegistro': '2024-01-17',
        'huellasRegistradas': 0,
      },
    ];
    _ordenarEstudiantes();
    _estudiantesFiltrados = List.from(_estudiantes);
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

  // AGREGAR ESTUDIANTE
  void agregarEstudiante({
    required String nombres,
    required String paterno,
    required String materno,
    required String ci,
  }) {
    final nuevoId = DateTime.now().millisecondsSinceEpoch;
    final nuevaFecha = DateTime.now().toString().split(' ')[0];

    _estudiantes.add({
      'id': nuevoId,
      'nombres': nombres.trim(),
      'apellidoPaterno': paterno.trim(),
      'apellidoMaterno': materno.trim(),
      'ci': ci.trim(),
      'fechaRegistro': nuevaFecha,
      'huellasRegistradas': 0,
    });

    _ordenarEstudiantes();
    notifyListeners();
  }

  // EDITAR ESTUDIANTE - SIMPLIFICADO Y CORREGIDO
  void editarEstudiante({
    required int id,
    required String nombres,
    required String paterno,
    required String materno,
    required String ci,
  }) {
    final index = _estudiantes.indexWhere(
      (estudiante) => estudiante['id'] == id,
    );

    if (index != -1) {
      // Actualizar solo los campos editables
      _estudiantes[index]['nombres'] = nombres.trim();
      _estudiantes[index]['apellidoPaterno'] = paterno.trim();
      _estudiantes[index]['apellidoMaterno'] = materno.trim();
      _estudiantes[index]['ci'] = ci.trim();

      _ordenarEstudiantes();
      notifyListeners();
    }
  }

  // ELIMINAR ESTUDIANTE
  void eliminarEstudiante(int id) {
    _estudiantes.removeWhere((estudiante) => estudiante['id'] == id);
    _filtrarEstudiantes();
    notifyListeners();
  }

  void actualizarHuellasEstudiante(int id, int huellasRegistradas) {
    final index = _estudiantes.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      _estudiantes[index]['huellasRegistradas'] = huellasRegistradas;
      notifyListeners();
    }
  }

  // Resto de métodos sin cambios...
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
    searchController.dispose();
    super.dispose();
  }
}
