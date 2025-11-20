// utils/export_helpers.dart
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// printing not required here
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ExportHelpers {
  // Exportar a Excel con formato de tabla de asistencia
  static Future<String> exportToExcel({
    required List<Map<String, dynamic>> estudiantes,
    required String institucion,
    required String turno,
    required String nivel,
    required String paralelo,
    List<DateTime>? fechas,
    DateTime? startDate,
    DateTime? endDate,
    String? turnoHorario,
    bool simple = true,
  }) async {
    try {
      if (!await _requestStoragePermission()) {
        throw 'Permiso de almacenamiento denegado';
      }

      var excel = Excel.createExcel();
      var sheet = excel['Asistencia'];

      // ENCABEZADO INSTITUCIONAL - SIN COMILLAS DOBLES
      sheet.appendRow([
        TextCellValue("INSTITUTO TECNICO COMERCIAL INCOS - EL ALTO"),
      ]);
      sheet.appendRow([TextCellValue("BASE DE DATOS II")]);
      // Use the provided institucion parameter for carrera
      sheet.appendRow([TextCellValue("CARRERA:"), TextCellValue(institucion)]);
      // Fixed malformed string/quotes in TURNO line
      sheet.appendRow([TextCellValue("TURNO:"), TextCellValue(turno)]);
      sheet.appendRow([
        TextCellValue("CURSO:"),
        TextCellValue('$nivel $paralelo'),
      ]);
      sheet.appendRow([TextCellValue('')]);

      // Generar lista de fechas (lunes a viernes) según parámetros
      List<DateTime> fechasDt = _buildFechasList(
        fechas: fechas,
        startDate: startDate,
        endDate: endDate,
      );

      List<String> fechasStr = fechasDt.map((d) {
        final dia = d.day.toString().padLeft(2, '0');
        final mes = d.month.toString().padLeft(2, '0');
        return '$dia/$mes';
      }).toList();

      // ENCABEZADO DE LA TABLA
      List<String> encabezados = ['NRO', 'ESTUDIANTES', ...fechasStr];

      // Metadatos de exportación
      sheet.appendRow([
        TextCellValue('Exportado:'),
        TextCellValue(_formatDateTime(DateTime.now())),
      ]);
      sheet.appendRow(encabezados.map((s) => TextCellValue(s)).toList());

      // DATOS DE ESTUDIANTES
      for (int i = 0; i < estudiantes.length; i++) {
        var estudiante = estudiantes[i];
        String nombreCompleto =
            '${estudiante['apellidoPaterno']} ${estudiante['apellidoMaterno']} ${estudiante['nombres']}';

        List<String> fila = [
          '${i + 1}',
          nombreCompleto,
          ..._generarAsistenciasAleatorias(fechasDt.length),
        ];

        sheet.appendRow(fila.map((s) => TextCellValue(s)).toList());
      }

      final directory =
          await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      String fileName =
          'asistencia_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      String filePath = '${directory.path}/$fileName';

      var file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      return filePath;
    } catch (e) {
      throw 'Error al exportar Excel: $e';
    }
  }

  // Exportar a PDF con formato de tabla de asistencia
  static Future<String> exportToPDF({
    required List<Map<String, dynamic>> estudiantes,
    required String institucion,
    required String turno,
    required String nivel,
    required String paralelo,
    List<DateTime>? fechas,
    DateTime? startDate,
    DateTime? endDate,
    String? turnoHorario,
    bool simple = true,
  }) async {
    try {
      if (!await _requestStoragePermission()) {
        throw 'Permiso de almacenamiento denegado';
      }

      final pdf = pw.Document();

      // Generar lista de fechas (lunes a viernes) según parámetros
      List<DateTime> fechasDt = _buildFechasList(
        fechas: fechas,
        startDate: startDate,
        endDate: endDate,
      );

      List<String> fechasStr = fechasDt.map((d) {
        final dia = d.day.toString().padLeft(2, '0');
        final mes = d.month.toString().padLeft(2, '0');
        return '$dia/$mes';
      }).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                // ENCABEZADO INSTITUCIONAL - SIN COMILLAS DOBLES
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'INSTITUTO TECNICO COMERCIAL INCOS - EL ALTO',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'BASE DE DATOS II',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                    ],
                  ),
                ),

                // INFORMACIÓN DEL CURSO
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('CARRERA: $institucion'),
                        pw.Text(
                          'TURNO: $turno${turnoHorario != null ? ' ($turnoHorario)' : ''}',
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('CURSO: $nivel $paralelo'),
                        pw.Text(
                          'Exportado: ${_formatDateTime(DateTime.now())}',
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // TÍTULO DE LA TABLA
                pw.Center(
                  child: pw.Text(
                    'REGISTRO DE ASISTENCIA',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),

                // TABLA DE ASISTENCIA
                _buildTablaAsistencia(estudiantes, fechasStr),
              ],
            );
          },
        ),
      );

      final directory = await getExternalStorageDirectory();
      String fileName =
          'asistencia_${DateTime.now().millisecondsSinceEpoch}.pdf';
      String filePath = '${directory?.path}/$fileName';

      var file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      throw 'Error al exportar PDF: $e';
    }
  }

  // Construir tabla de asistencia para PDF
  static pw.Widget _buildTablaAsistencia(
    List<Map<String, dynamic>> estudiantes,
    List<String> fechas,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // ENCABEZADO DE LA TABLA
        pw.TableRow(
          children: [
            _celdaTabla('NRO', true),
            _celdaTabla('ESTUDIANTES', true),
            for (String fecha in fechas) _celdaTabla(fecha, true),
          ],
        ),

        // DATOS DE ESTUDIANTES
        for (int i = 0; i < estudiantes.length; i++)
          pw.TableRow(
            children: [
              _celdaTabla('${i + 1}', false),
              _celdaTabla(
                '${estudiantes[i]['apellidoPaterno']} ${estudiantes[i]['apellidoMaterno']} ${estudiantes[i]['nombres']}',
                false,
              ),
              for (String asistencia in _generarAsistenciasAleatorias(
                fechas.length,
              ))
                _celdaTabla(asistencia, false),
            ],
          ),
      ],
    );
  }

  // Helper para crear celdas de tabla
  static pw.Padding _celdaTabla(String texto, bool isHeader) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(4.0),
      child: pw.Text(
        texto,
        style: isHeader
            ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7)
            : pw.TextStyle(fontSize: 7),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // Generar asistencias aleatorias (● presente, - ausente)
  static List<String> _generarAsistenciasAleatorias(int cantidad) {
    List<String> asistencias = [];
    for (int i = 0; i < cantidad; i++) {
      // 90% de probabilidad de asistencia, 10% de ausencia
      asistencias.add(DateTime.now().millisecond % 10 == 0 ? '-' : '●');
    }
    return asistencias;
  }

  // Solicitar permiso de almacenamiento
  static Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  // Construir lista de fechas laborales (lunes a viernes)
  static List<DateTime> _buildFechasList({
    List<DateTime>? fechas,
    DateTime? startDate,
    DateTime? endDate,
    int maxFechas = 20,
  }) {
    if (fechas != null && fechas.isNotEmpty) return fechas;

    DateTime hoy = DateTime.now();
    DateTime inicio = startDate ?? DateTime(hoy.year, hoy.month, 1);
    DateTime fin = endDate ?? hoy;

    List<DateTime> result = [];
    for (
      DateTime d = inicio;
      !d.isAfter(fin);
      d = d.add(const Duration(days: 1))
    ) {
      if (d.weekday >= DateTime.monday && d.weekday <= DateTime.friday) {
        result.add(d);
      }
      if (result.length >= maxFechas) break;
    }

    // Si no encontramos fechas (raro), devolver al menos hoy si es laboral
    if (result.isEmpty) {
      if (hoy.weekday >= DateTime.monday && hoy.weekday <= DateTime.friday) {
        result.add(hoy);
      }
    }

    return result;
  }

  static String _formatDateTime(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min:$ss';
  }
}
