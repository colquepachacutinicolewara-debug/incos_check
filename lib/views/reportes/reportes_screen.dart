import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  bool _generando = false;

  // Métodos helper para modo oscuro
  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color _getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  // Datos de ejemplo para gráficos
  final List<ChartData> _asistenciaData = [
    ChartData('Lun', 85),
    ChartData('Mar', 92),
    ChartData('Mié', 78),
    ChartData('Jue', 88),
    ChartData('Vie', 95),
    ChartData('Sáb', 65),
  ];

  final List<ChartData> _rendimientoData = [
    ChartData('Sistemas', 88),
    ChartData('Contabilidad', 76),
    ChartData('Administración', 82),
    ChartData('Comercio', 91),
  ];

  final List<ChartData> _estudiantesData = [
    ChartData('1er Año', 45),
    ChartData('2do Año', 38),
    ChartData('3er Año', 32),
    ChartData('4to Año', 28),
  ];

  // Datos de ejemplo para reportes
  final List<Map<String, dynamic>> _datosAsistencia = [
    {
      'estudiante': 'Juan Pérez',
      'curso': 'Matemáticas',
      'asistencia': 45,
      'total': 50,
      'porcentaje': 90,
    },
    {
      'estudiante': 'María García',
      'curso': 'Matemáticas',
      'asistencia': 48,
      'total': 50,
      'porcentaje': 96,
    },
    {
      'estudiante': 'Carlos López',
      'curso': 'Matemáticas',
      'asistencia': 42,
      'total': 50,
      'porcentaje': 84,
    },
    {
      'estudiante': 'Ana Martínez',
      'curso': 'Programación',
      'asistencia': 49,
      'total': 50,
      'porcentaje': 98,
    },
    {
      'estudiante': 'Pedro Rodríguez',
      'curso': 'Programación',
      'asistencia': 47,
      'total': 50,
      'porcentaje': 94,
    },
  ];

  final List<Map<String, dynamic>> _datosCalificaciones = [
    {
      'estudiante': 'Juan Pérez',
      'materia': 'Matemáticas',
      'parcial1': 85,
      'parcial2': 90,
      'final': 88,
      'estado': 'Aprobado',
    },
    {
      'estudiante': 'María García',
      'materia': 'Matemáticas',
      'parcial1': 92,
      'parcial2': 88,
      'final': 90,
      'estado': 'Aprobado',
    },
    {
      'estudiante': 'Carlos López',
      'materia': 'Programación',
      'parcial1': 78,
      'parcial2': 82,
      'final': 80,
      'estado': 'Aprobado',
    },
    {
      'estudiante': 'Ana Martínez',
      'materia': 'Programación',
      'parcial1': 95,
      'parcial2': 92,
      'final': 94,
      'estado': 'Aprobado',
    },
    {
      'estudiante': 'Pedro Rodríguez',
      'materia': 'Física',
      'parcial1': 45,
      'parcial2': 50,
      'final': 48,
      'estado': 'Reprobado',
    },
  ];

  final List<Map<String, dynamic>> _datosFinancieros = [
    {
      'estudiante': 'Juan Pérez',
      'matricula': 500.0,
      'mensualidad': 300.0,
      'pagado': 800.0,
      'deuda': 0.0,
      'estado': 'Al día',
    },
    {
      'estudiante': 'María García',
      'matricula': 500.0,
      'mensualidad': 300.0,
      'pagado': 500.0,
      'deuda': 300.0,
      'estado': 'Pendiente',
    },
    {
      'estudiante': 'Carlos López',
      'matricula': 500.0,
      'mensualidad': 300.0,
      'pagado': 1100.0,
      'deuda': 0.0,
      'estado': 'Al día',
    },
    {
      'estudiante': 'Ana Martínez',
      'matricula': 500.0,
      'mensualidad': 300.0,
      'pagado': 300.0,
      'deuda': 500.0,
      'estado': 'Pendiente',
    },
  ];

  // ========== GENERACIÓN DE PDF ==========

  Future<void> _generarReportePDF(String tipoReporte) async {
    setState(() => _generando = true);

    try {
      final pdf = pw.Document();
      final now = DateTime.now();

      // Cabecera del PDF
      pdf.addPage(
        pw.MultiPage(
          header: (context) => _buildPDFHeader(now),
          footer: (context) => _buildPDFFooter(now),
          build: (context) => _buildPDFContent(tipoReporte, pdf),
        ),
      );

      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/reporte_${tipoReporte}_${now.millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      setState(() => _generando = false);

      // Abrir archivo
      await OpenFile.open(file.path);

      Helpers.showSnackBar(
        context,
        'Reporte $tipoReporte generado exitosamente',
        type: 'success',
      );
    } catch (e) {
      setState(() => _generando = false);
      Helpers.showSnackBar(context, 'Error al generar PDF: $e', type: 'error');
    }
  }

  pw.Widget _buildPDFHeader(DateTime now) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        children: [
          pw.Text(
            'INSTITUTO INCOS EL ALTO',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Sistema de Gestión Académica',
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Fecha: ${Helpers.formatDate(now)} ${Helpers.formatTime(now)}',
            style: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFFooter(DateTime now) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Página ${now.millisecondsSinceEpoch} - Generado el ${Helpers.formatDate(now)}',
        style: const pw.TextStyle(fontSize: 8),
      ),
    );
  }

  List<pw.Widget> _buildPDFContent(String tipoReporte, pw.Document pdf) {
    switch (tipoReporte) {
      case 'asistencia':
        return _buildPDFAsistencia();
      case 'calificaciones':
        return _buildPDFCalificaciones();
      case 'financiero':
        return _buildPDFFinanciero();
      case 'docentes':
        return _buildPDFDocentes();
      case 'estadistico':
        return _buildPDFEstadistico();
      default:
        return [pw.Text('Reporte no disponible')];
    }
  }

  List<pw.Widget> _buildPDFAsistencia() {
    return [
      pw.Header(
        level: 0,
        child: pw.Text(
          'REPORTE DE ASISTENCIA GENERAL',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.SizedBox(height: 10),
      pw.TableHelper.fromTextArray(
        context: null,
        headers: ['Estudiante', 'Curso', 'Asistencia', 'Total', 'Porcentaje'],
        data: _datosAsistencia
            .map(
              (e) => [
                e['estudiante'],
                e['curso'],
                e['asistencia'].toString(),
                e['total'].toString(),
                '${e['porcentaje']}%',
              ],
            )
            .toList(),
      ),
      pw.SizedBox(height: 20),
      pw.Text('Resumen Estadístico:'),
      pw.Bullet(text: 'Total de estudiantes: ${_datosAsistencia.length}'),
      pw.Bullet(
        text:
            'Asistencia promedio: ${_calcularPromedioAsistencia().toStringAsFixed(1)}%',
      ),
      pw.Bullet(text: 'Mejor asistencia: ${_calcularMejorAsistencia()}%'),
    ];
  }

  List<pw.Widget> _buildPDFCalificaciones() {
    return [
      pw.Header(
        level: 0,
        child: pw.Text(
          'REPORTE DE CALIFICACIONES',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.SizedBox(height: 10),
      pw.TableHelper.fromTextArray(
        context: null,
        headers: [
          'Estudiante',
          'Materia',
          'Parcial 1',
          'Parcial 2',
          'Final',
          'Estado',
        ],
        data: _datosCalificaciones
            .map(
              (e) => [
                e['estudiante'],
                e['materia'],
                e['parcial1'].toString(),
                e['parcial2'].toString(),
                e['final'].toString(),
                e['estado'],
              ],
            )
            .toList(),
      ),
      pw.SizedBox(height: 20),
      pw.Text('Estadísticas:'),
      pw.Bullet(text: 'Total de estudiantes: ${_datosCalificaciones.length}'),
      pw.Bullet(text: 'Aprobados: ${_contarAprobados()}'),
      pw.Bullet(text: 'Reprobados: ${_contarReprobados()}'),
      pw.Bullet(
        text:
            'Promedio general: ${_calcularPromedioGeneral().toStringAsFixed(1)}',
      ),
    ];
  }

  List<pw.Widget> _buildPDFFinanciero() {
    return [
      pw.Header(
        level: 0,
        child: pw.Text(
          'REPORTE FINANCIERO',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.SizedBox(height: 10),
      pw.TableHelper.fromTextArray(
        context: null,
        headers: [
          'Estudiante',
          'Matrícula',
          'Mensualidad',
          'Pagado',
          'Deuda',
          'Estado',
        ],
        data: _datosFinancieros
            .map(
              (e) => [
                e['estudiante'],
                '\$${e['matricula']}',
                '\$${e['mensualidad']}',
                '\$${e['pagado']}',
                '\$${e['deuda']}',
                e['estado'],
              ],
            )
            .toList(),
      ),
      pw.SizedBox(height: 20),
      pw.Text('Resumen Financiero:'),
      pw.Bullet(text: 'Total recaudado: \$${_calcularTotalRecaudado()}'),
      pw.Bullet(text: 'Total pendiente: \$${_calcularTotalPendiente()}'),
      pw.Bullet(text: 'Estudiantes al día: ${_contarAlDia()}'),
      pw.Bullet(text: 'Estudiantes pendientes: ${_contarPendientes()}'),
    ];
  }

  List<pw.Widget> _buildPDFDocentes() {
    return [
      pw.Header(
        level: 0,
        child: pw.Text(
          'REPORTE DE DOCENTES',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Text('Información del cuerpo docente en desarrollo...'),
    ];
  }

  List<pw.Widget> _buildPDFEstadistico() {
    return [
      pw.Header(
        level: 0,
        child: pw.Text(
          'REPORTE ESTADÍSTICO ANUAL',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Text('Estadísticas comparativas y análisis de tendencias...'),
    ];
  }

  // ========== GENERACIÓN DE EXCEL ==========

  Future<void> _exportarExcel(String tipoReporte) async {
    setState(() => _generando = true);

    try {
      final excel = Excel.createExcel();
      final now = DateTime.now();

      // Crear hoja principal
      final Sheet sheet = excel[tipoReporte];

      // Cabecera - CORREGIDO: Usar TextCellValue en lugar de String
      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
        'INSTITUTO INCOS EL ALTO',
      );
      sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(
        'Reporte: ${_getTituloReporte(tipoReporte)}',
      );
      sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue(
        'Fecha: ${Helpers.formatDate(now)} ${Helpers.formatTime(now)}',
      );

      // Datos según el tipo de reporte
      switch (tipoReporte) {
        case 'asistencia':
          _generarExcelAsistencia(sheet);
          break;
        case 'calificaciones':
          _generarExcelCalificaciones(sheet);
          break;
        case 'financiero':
          _generarExcelFinanciero(sheet);
          break;
        case 'docentes':
          _generarExcelDocentes(sheet);
          break;
        case 'estadistico':
          _generarExcelEstadistico(sheet);
          break;
      }

      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/reporte_${tipoReporte}_${now.millisecondsSinceEpoch}.xlsx',
      );
      final excelBytes = excel.save();
      if (excelBytes != null) {
        await file.writeAsBytes(excelBytes);
      }

      setState(() => _generando = false);

      // Abrir archivo
      await OpenFile.open(file.path);

      Helpers.showSnackBar(
        context,
        'Reporte $tipoReporte exportado a Excel',
        type: 'success',
      );
    } catch (e) {
      setState(() => _generando = false);
      Helpers.showSnackBar(
        context,
        'Error al exportar Excel: $e',
        type: 'error',
      );
    }
  }

  void _generarExcelAsistencia(Sheet sheet) {
    // Encabezados - CORREGIDO: Usar TextCellValue
    final headers = [
      'Estudiante',
      'Curso',
      'Asistencia',
      'Total',
      'Porcentaje',
    ];
    for (int i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByString('${String.fromCharCode(65 + i)}5'))
          .value = TextCellValue(
        headers[i],
      );
    }

    // Datos - CORREGIDO: Usar los tipos correctos de CellValue
    for (int i = 0; i < _datosAsistencia.length; i++) {
      final data = _datosAsistencia[i];
      sheet.cell(CellIndex.indexByString('A${6 + i}')).value = TextCellValue(
        data['estudiante'],
      );
      sheet.cell(CellIndex.indexByString('B${6 + i}')).value = TextCellValue(
        data['curso'],
      );
      sheet.cell(CellIndex.indexByString('C${6 + i}')).value = IntCellValue(
        data['asistencia'],
      );
      sheet.cell(CellIndex.indexByString('D${6 + i}')).value = IntCellValue(
        data['total'],
      );
      sheet.cell(CellIndex.indexByString('E${6 + i}')).value = TextCellValue(
        '${data['porcentaje']}%',
      );
    }
  }

  void _generarExcelCalificaciones(Sheet sheet) {
    final headers = [
      'Estudiante',
      'Materia',
      'Parcial 1',
      'Parcial 2',
      'Final',
      'Estado',
    ];
    for (int i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByString('${String.fromCharCode(65 + i)}5'))
          .value = TextCellValue(
        headers[i],
      );
    }

    for (int i = 0; i < _datosCalificaciones.length; i++) {
      final data = _datosCalificaciones[i];
      sheet.cell(CellIndex.indexByString('A${6 + i}')).value = TextCellValue(
        data['estudiante'],
      );
      sheet.cell(CellIndex.indexByString('B${6 + i}')).value = TextCellValue(
        data['materia'],
      );
      sheet.cell(CellIndex.indexByString('C${6 + i}')).value = IntCellValue(
        data['parcial1'],
      );
      sheet.cell(CellIndex.indexByString('D${6 + i}')).value = IntCellValue(
        data['parcial2'],
      );
      sheet.cell(CellIndex.indexByString('E${6 + i}')).value = IntCellValue(
        data['final'],
      );
      sheet.cell(CellIndex.indexByString('F${6 + i}')).value = TextCellValue(
        data['estado'],
      );
    }
  }

  void _generarExcelFinanciero(Sheet sheet) {
    final headers = [
      'Estudiante',
      'Matrícula',
      'Mensualidad',
      'Pagado',
      'Deuda',
      'Estado',
    ];
    for (int i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByString('${String.fromCharCode(65 + i)}5'))
          .value = TextCellValue(
        headers[i],
      );
    }

    for (int i = 0; i < _datosFinancieros.length; i++) {
      final data = _datosFinancieros[i];
      sheet.cell(CellIndex.indexByString('A${6 + i}')).value = TextCellValue(
        data['estudiante'],
      );
      sheet.cell(CellIndex.indexByString('B${6 + i}')).value = DoubleCellValue(
        data['matricula'],
      );
      sheet.cell(CellIndex.indexByString('C${6 + i}')).value = DoubleCellValue(
        data['mensualidad'],
      );
      sheet.cell(CellIndex.indexByString('D${6 + i}')).value = DoubleCellValue(
        data['pagado'],
      );
      sheet.cell(CellIndex.indexByString('E${6 + i}')).value = DoubleCellValue(
        data['deuda'],
      );
      sheet.cell(CellIndex.indexByString('F${6 + i}')).value = TextCellValue(
        data['estado'],
      );
    }
  }

  void _generarExcelDocentes(Sheet sheet) {
    sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue(
      'Reporte de docentes en desarrollo...',
    );
  }

  void _generarExcelEstadistico(Sheet sheet) {
    sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue(
      'Reporte estadístico en desarrollo...',
    );
  }

  // ========== MÉTODOS AUXILIARES ==========

  String _getTituloReporte(String tipo) {
    switch (tipo) {
      case 'asistencia':
        return 'Asistencia General';
      case 'calificaciones':
        return 'Calificaciones';
      case 'financiero':
        return 'Estado Financiero';
      case 'docentes':
        return 'Cuerpo Docente';
      case 'estadistico':
        return 'Estadístico Anual';
      default:
        return 'Reporte';
    }
  }

  double _calcularPromedioAsistencia() {
    final total = _datosAsistencia.fold(0.0, (sum, e) => sum + e['porcentaje']);
    return total / _datosAsistencia.length;
  }

  double _calcularMejorAsistencia() {
    return _datosAsistencia
        .map((e) => e['porcentaje'])
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
  }

  int _contarAprobados() {
    return _datosCalificaciones.where((e) => e['estado'] == 'Aprobado').length;
  }

  int _contarReprobados() {
    return _datosCalificaciones.where((e) => e['estado'] == 'Reprobado').length;
  }

  double _calcularPromedioGeneral() {
    final total = _datosCalificaciones.fold(0.0, (sum, e) => sum + e['final']);
    return total / _datosCalificaciones.length;
  }

  double _calcularTotalRecaudado() {
    return _datosFinancieros.fold(0.0, (sum, e) => sum + e['pagado']);
  }

  double _calcularTotalPendiente() {
    return _datosFinancieros.fold(0.0, (sum, e) => sum + e['deuda']);
  }

  int _contarAlDia() {
    return _datosFinancieros.where((e) => e['estado'] == 'Al día').length;
  }

  int _contarPendientes() {
    return _datosFinancieros.where((e) => e['estado'] == 'Pendiente').length;
  }

  void _imprimirReporte(String tipoReporte) {
    Helpers.showSnackBar(
      context,
      'Función de impresión para $tipoReporte en desarrollo',
      type: 'info',
    );
  }

  // ========== WIDGETS DE LA UI ==========

  Widget _buildMetricCard(
    String titulo,
    String valor,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Card(
      elevation: 4,
      color: _getCardColor(context),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color), // Reducido de 40 a 32
            SizedBox(height: AppSpacing.small),
            Text(
              valor,
              style: AppTextStyles.heading1.copyWith(
                color: color,
                fontSize: 20, // Reducido de 24 a 20
              ),
            ),
            SizedBox(height: AppSpacing.small),
            Text(
              titulo,
              style: AppTextStyles.bodyDark(context).copyWith(
                color: _getSecondaryTextColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 12, // Texto más pequeño
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // Máximo 2 líneas
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String titulo, Widget chart, BuildContext context) {
    return Card(
      elevation: 4,
      color: _getCardColor(context),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: AppTextStyles.heading2Dark(context).copyWith(
                color: _getTextColor(context),
                fontSize: 16, // Texto un poco más pequeño
              ),
            ),
            SizedBox(height: AppSpacing.small), // Reducido de medium a small
            SizedBox(height: 180, child: chart), // Reducido de 200 a 180
          ],
        ),
      ),
    );
  }

  Widget _buildReporteCard(
    String titulo,
    String descripcion,
    IconData icon,
    Color color,
    List<Widget> acciones,
    BuildContext context,
  ) {
    return Card(
      elevation: 4,
      color: _getCardColor(context),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20), // Icono más pequeño
                SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    titulo,
                    style: AppTextStyles.heading2Dark(context).copyWith(
                      color: _getTextColor(context),
                      fontSize: 16, // Texto más pequeño
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.small), // Reducido de small a xsmall
            Text(
              descripcion,
              style: AppTextStyles.bodyDark(context).copyWith(
                color: _getSecondaryTextColor(context),
                fontSize: 12, // Texto más pequeño
              ),
              maxLines: 2, // Máximo 2 líneas
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.small), // Reducido de medium a small
            Row(children: acciones),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Reportes Académicos',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: _generando ? null : () => _exportarExcel('asistencia'),
            tooltip: 'Exportar reporte',
          ),
        ],
      ),
      body: Stack(
        children: [
          _generando
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.medium),
                  child: Column(
                    children: [
                      // Estadísticas rápidas - MEJORADO
                      Text(
                        'Resumen General',
                        style: AppTextStyles.heading1.copyWith(
                          color: _getTextColor(context),
                          fontSize: 20, // Reducido de tamaño por defecto
                        ),
                      ),
                      SizedBox(height: AppSpacing.medium),
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.small, // Reducido
                        mainAxisSpacing: AppSpacing.small, // Reducido
                        childAspectRatio: 0.9, // Más compacto (era 1.0)
                        children: [
                          _buildMetricCard(
                            'Total Estudiantes',
                            '143',
                            Icons.people,
                            Colors.blue,
                            context,
                          ),
                          _buildMetricCard(
                            'Total Docentes',
                            '28',
                            Icons.school,
                            Colors.green,
                            context,
                          ),
                          _buildMetricCard(
                            'Asistencia Promedio',
                            '86%',
                            Icons.calendar_today,
                            Colors.orange,
                            context,
                          ),
                          _buildMetricCard(
                            'Cursos Activos',
                            '15',
                            Icons.book,
                            Colors.purple,
                            context,
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.large),

                      // Gráficos - MEJORADO
                      Text(
                        'Gráficos de Rendimiento',
                        style: AppTextStyles.heading1.copyWith(
                          color: _getTextColor(context),
                          fontSize: 20, // Reducido
                        ),
                      ),
                      SizedBox(height: AppSpacing.medium),
                      _buildChartCard(
                        'Asistencia Semanal',
                        SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            labelStyle: TextStyle(
                              color: _getTextColor(context),
                              fontSize: 10, // Texto más pequeño en ejes
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            labelStyle: TextStyle(
                              color: _getTextColor(context),
                              fontSize: 10, // Texto más pequeño en ejes
                            ),
                          ),
                          series: <CartesianSeries<ChartData, String>>[
                            ColumnSeries<ChartData, String>(
                              dataSource: _asistenciaData,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        context,
                      ),
                      SizedBox(height: AppSpacing.medium),
                      _buildChartCard(
                        'Rendimiento por Carrera',
                        SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            labelStyle: TextStyle(
                              color: _getTextColor(context),
                              fontSize: 10,
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            labelStyle: TextStyle(
                              color: _getTextColor(context),
                              fontSize: 10,
                            ),
                          ),
                          series: <CartesianSeries<ChartData, String>>[
                            BarSeries<ChartData, String>(
                              dataSource: _rendimientoData,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              color: AppColors.success,
                            ),
                          ],
                        ),
                        context,
                      ),
                      SizedBox(height: AppSpacing.medium),
                      _buildChartCard(
                        'Distribución de Estudiantes',
                        SfCircularChart(
                          series: <CircularSeries<ChartData, String>>[
                            PieSeries<ChartData, String>(
                              dataSource: _estudiantesData,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                textStyle: TextStyle(
                                  color: _getTextColor(context),
                                  fontSize: 10, // Texto más pequeño
                                ),
                              ),
                            ),
                          ],
                        ),
                        context,
                      ),
                      SizedBox(height: AppSpacing.large),

                      // Reportes descargables - MEJORADO
                      Text(
                        'Reportes Descargables',
                        style: AppTextStyles.heading1.copyWith(
                          color: _getTextColor(context),
                          fontSize: 20, // Reducido
                        ),
                      ),
                      SizedBox(height: AppSpacing.medium),
                      _buildReporteCard(
                        'Reporte de Asistencia General',
                        'Reporte completo de asistencia de todos los estudiantes por período académico',
                        Icons.assignment,
                        Colors.blue,
                        [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _generando
                                  ? null
                                  : () => _generarReportePDF('asistencia'),
                              icon: Icon(
                                Icons.picture_as_pdf,
                                size: 14,
                              ), // Más pequeño
                              label: Text(
                                'PDF',
                                style: TextStyle(
                                  fontSize: 12,
                                ), // Texto más pequeño
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                ), // Menos padding
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.small),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _generando
                                  ? null
                                  : () => _exportarExcel('asistencia'),
                              icon: Icon(
                                Icons.table_chart,
                                size: 14,
                              ), // Más pequeño
                              label: Text(
                                'Excel',
                                style: TextStyle(
                                  fontSize: 12,
                                ), // Texto más pequeño
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                ), // Menos padding
                              ),
                            ),
                          ),
                        ],
                        context,
                      ),
                      SizedBox(height: AppSpacing.medium),
                      _buildReporteCard(
                        'Reporte de Calificaciones',
                        'Calificaciones finales de todos los estudiantes por materia y paralelo',
                        Icons.grade,
                        Colors.orange,
                        [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _generando
                                  ? null
                                  : () => _generarReportePDF('calificaciones'),
                              icon: Icon(Icons.picture_as_pdf, size: 14),
                              label: Text(
                                'PDF',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.small),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _generando
                                  ? null
                                  : () => _exportarExcel('calificaciones'),
                              icon: Icon(Icons.table_chart, size: 14),
                              label: Text(
                                'Excel',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                        context,
                      ),
                      SizedBox(height: AppSpacing.medium),
                      _buildReporteCard(
                        'Reporte Financiero',
                        'Estado de pagos, deudas y movimientos financieros de estudiantes',
                        Icons.attach_money,
                        Colors.green,
                        [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _generando
                                  ? null
                                  : () => _generarReportePDF('financiero'),
                              icon: Icon(Icons.picture_as_pdf, size: 14),
                              label: Text(
                                'PDF',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.small),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _generando
                                  ? null
                                  : () => _exportarExcel('financiero'),
                              icon: Icon(Icons.table_chart, size: 14),
                              label: Text(
                                'Excel',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                        context,
                      ),
                      SizedBox(height: AppSpacing.large),
                    ],
                  ),
                ),
          if (_generando)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Generando reporte...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Modelo para datos de gráficos
class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}
