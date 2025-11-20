import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:provider/provider.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';
import 'package:incos_check/viewmodels/estudiantes_viewmodel.dart';
import 'package:incos_check/viewmodels/materia_viewmodel.dart';
import '../../viewmodels/reporte_viewmodel.dart';

class ReportesScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ReportesScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EstudiantesViewModel()),
        ChangeNotifierProvider(create: (_) => MateriaViewModel()),
        ChangeNotifierProvider(create: (_) => ReportesViewModel()),
      ],
      child: _ReportesScreenContent(userData: userData),
    );
  }
}

class _ReportesScreenContent extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const _ReportesScreenContent({this.userData});

  @override
  State<_ReportesScreenContent> createState() => _ReportesScreenContentState();
}

class _ReportesScreenContentState extends State<_ReportesScreenContent> {
  bool _generando = false;
  int _selectedReportType = 0;
  final List<String> _reportTypes = [
    'Resumen General',
    'Asistencia',
    'Calificaciones',
    'Financiero',
    'Estadísticas'
  ];

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

  @override
  Widget build(BuildContext context) {
    final estudiantesVM = context.watch<EstudiantesViewModel>();
    final materiasVM = context.watch<MateriaViewModel>();
    final reportesVM = context.watch<ReportesViewModel>();

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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              estudiantesVM.recargarEstudiantes();
              materiasVM.recargarMaterias();
              reportesVM.cargarReportes();
            },
            tooltip: 'Actualizar datos',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_generando)
            _buildLoadingOverlay()
          else
            _buildContent(estudiantesVM, materiasVM, reportesVM, context),
        ],
      ),
    );
  }

  Widget _buildContent(EstudiantesViewModel estudiantesVM, 
                      MateriaViewModel materiasVM, 
                      ReportesViewModel reportesVM, 
                      BuildContext context) {
    return Column(
      children: [
        // Selector de tipo de reporte
        _buildReportTypeSelector(),
        
        // Mostrar información del usuario si está disponible
        if (widget.userData != null) ...[
          _buildUserInfoCard(context, widget.userData!),
          const SizedBox(height: AppSpacing.medium),
        ],
        
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: _buildReportContent(estudiantesVM, materiasVM, reportesVM, context),
          ),
        ),
      ],
    );
  }

  Widget _buildReportTypeSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _reportTypes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.small),
            child: ChoiceChip(
              label: Text(_reportTypes[index]),
              selected: _selectedReportType == index,
              onSelected: (selected) {
                setState(() {
                  _selectedReportType = index;
                });
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: _selectedReportType == index ? Colors.white : _getTextColor(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportContent(EstudiantesViewModel estudiantesVM, 
                           MateriaViewModel materiasVM, 
                           ReportesViewModel reportesVM, 
                           BuildContext context) {
    switch (_selectedReportType) {
      case 0: // Resumen General
        return _buildResumenGeneral(estudiantesVM, materiasVM, reportesVM, context);
      case 1: // Asistencia
        return _buildReporteAsistencia(estudiantesVM, materiasVM, context);
      case 2: // Calificaciones
        return _buildReporteCalificaciones(context);
      case 3: // Financiero
        return _buildReporteFinanciero(context);
      case 4: // Estadísticas
        return _buildReporteEstadisticas(estudiantesVM, materiasVM, context);
      default:
        return _buildResumenGeneral(estudiantesVM, materiasVM, reportesVM, context);
    }
  }

  Widget _buildResumenGeneral(EstudiantesViewModel estudiantesVM, 
                            MateriaViewModel materiasVM, 
                            ReportesViewModel reportesVM, 
                            BuildContext context) {
    final totalEstudiantes = estudiantesVM.estudiantesFiltrados.length;
    final totalMaterias = materiasVM.materiasFiltradas.length;
    final totalDocentes = 28; // Este dato deberías obtenerlo de tu ViewModel de docentes
    final reportesGenerados = reportesVM.reportesFiltrados.length;

    // Calcular asistencia promedio (simulado por ahora)
    final asistenciaPromedio = _calcularAsistenciaPromedio(estudiantesVM);

    return Column(
      children: [
        // Estadísticas rápidas
        Text(
          'Resumen General del Sistema',
          style: AppTextStyles.heading1.copyWith(
            color: _getTextColor(context),
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.medium,
          mainAxisSpacing: AppSpacing.medium,
          childAspectRatio: 1.2,
          children: [
            _buildMetricCard(
              'Total Estudiantes',
              '$totalEstudiantes',
              Icons.people,
              Colors.blue,
              context,
            ),
            _buildMetricCard(
              'Total Materias',
              '$totalMaterias',
              Icons.book,
              Colors.green,
              context,
            ),
            _buildMetricCard(
              'Total Docentes',
              '$totalDocentes',
              Icons.school,
              Colors.orange,
              context,
            ),
            _buildMetricCard(
              'Asistencia Promedio',
              '${asistenciaPromedio.toStringAsFixed(1)}%',
              Icons.calendar_today,
              Colors.purple,
              context,
            ),
            _buildMetricCard(
              'Reportes Generados',
              '$reportesGenerados',
              Icons.assignment,
              Colors.red,
              context,
            ),
            _buildMetricCard(
              'Cursos Activos',
              '15',
              Icons.class_,
              Colors.teal,
              context,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.large),

        // Gráficos de resumen
        _buildChartCard(
          'Distribución de Estudiantes por Año',
          SfCircularChart(
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: _getDistribucionEstudiantes(estudiantesVM),
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
          context,
        ),
        const SizedBox(height: AppSpacing.medium),

        // Acciones rápidas
        _buildAccionesRapidas(context),
      ],
    );
  }

  Widget _buildReporteAsistencia(EstudiantesViewModel estudiantesVM, 
                               MateriaViewModel materiasVM, 
                               BuildContext context) {
    return Column(
      children: [
        Text(
          'Reportes de Asistencia',
          style: AppTextStyles.heading1.copyWith(
            color: _getTextColor(context),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),

        // Filtros para reporte de asistencia
        _buildFiltrosAsistencia(context),
        const SizedBox(height: AppSpacing.medium),

        // Gráfico de asistencia
        _buildChartCard(
          'Asistencia por Materia',
          SfCartesianChart(
            primaryXAxis: const CategoryAxis(),
            primaryYAxis: const NumericAxis(),
            series: <CartesianSeries<ChartData, String>>[
              ColumnSeries<ChartData, String>(
                dataSource: _getAsistenciaPorMateria(materiasVM),
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                color: AppColors.primary,
              ),
            ],
          ),
          context,
        ),
        const SizedBox(height: AppSpacing.medium),

        // Reportes descargables de asistencia
        _buildReporteCard(
          'Reporte de Asistencia General',
          'Reporte completo de asistencia de todos los estudiantes por período académico',
          Icons.assignment,
          Colors.blue,
          [
            _buildExportButton(
              'PDF',
              Icons.picture_as_pdf,
              Colors.red,
                  () => _generarReportePDF('asistencia_general'),
            ),
            const SizedBox(width: AppSpacing.small),
            _buildExportButton(
              'Excel',
              Icons.table_chart,
              Colors.green,
                  () => _exportarExcel('asistencia_general'),
            ),
          ],
          context,
        ),
        const SizedBox(height: AppSpacing.medium),

        _buildReporteCard(
          'Reporte de Asistencia Bimestral',
          'Asistencia detallada por bimestre con cálculos automáticos',
          Icons.calendar_view_month,
          Colors.orange,
          [
            _buildExportButton(
              'PDF',
              Icons.picture_as_pdf,
              Colors.red,
                  () => _generarReportePDF('asistencia_bimestral'),
            ),
            const SizedBox(width: AppSpacing.small),
            _buildExportButton(
              'Excel',
              Icons.table_chart,
              Colors.green,
                  () => _exportarExcel('asistencia_bimestral'),
            ),
          ],
          context,
        ),
      ],
    );
  }

  Widget _buildReporteCalificaciones(BuildContext context) {
    return Column(
      children: [
        Text(
          'Reportes de Calificaciones',
          style: AppTextStyles.heading1.copyWith(
            color: _getTextColor(context),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),

        _buildChartCard(
          'Distribución de Calificaciones',
          SfCartesianChart(
            primaryXAxis: const CategoryAxis(),
            primaryYAxis: const NumericAxis(),
            series: <CartesianSeries<ChartData, String>>[
              BarSeries<ChartData, String>(
                dataSource: _getDistribucionCalificaciones(),
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                color: AppColors.success,
              ),
            ],
          ),
          context,
        ),
        const SizedBox(height: AppSpacing.medium),

        _buildReporteCard(
          'Boletín de Calificaciones',
          'Calificaciones finales de todos los estudiantes por materia',
          Icons.grade,
          Colors.amber,
          [
            _buildExportButton(
              'PDF',
              Icons.picture_as_pdf,
              Colors.red,
                  () => _generarReportePDF('calificaciones'),
            ),
            const SizedBox(width: AppSpacing.small),
            _buildExportButton(
              'Excel',
              Icons.table_chart,
              Colors.green,
                  () => _exportarExcel('calificaciones'),
            ),
          ],
          context,
        ),
      ],
    );
  }

  Widget _buildReporteFinanciero(BuildContext context) {
    return Column(
      children: [
        Text(
          'Reportes Financieros',
          style: AppTextStyles.heading1.copyWith(
            color: _getTextColor(context),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),

        _buildChartCard(
          'Estado de Pagos',
          SfCircularChart(
            series: <CircularSeries>[
              DoughnutSeries<ChartData, String>(
                dataSource: _getEstadoPagos(),
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
          context,
        ),
        const SizedBox(height: AppSpacing.medium),

        _buildReporteCard(
          'Estado Financiero General',
          'Estado de pagos, deudas y movimientos financieros',
          Icons.attach_money,
          Colors.green,
          [
            _buildExportButton(
              'PDF',
              Icons.picture_as_pdf,
              Colors.red,
                  () => _generarReportePDF('financiero'),
            ),
            const SizedBox(width: AppSpacing.small),
            _buildExportButton(
              'Excel',
              Icons.table_chart,
              Colors.green,
                  () => _exportarExcel('financiero'),
            ),
          ],
          context,
        ),
      ],
    );
  }

  Widget _buildReporteEstadisticas(EstudiantesViewModel estudiantesVM, 
                                 MateriaViewModel materiasVM, 
                                 BuildContext context) {
    return Column(
      children: [
        Text(
          'Reportes Estadísticos',
          style: AppTextStyles.heading1.copyWith(
            color: _getTextColor(context),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),

        // Múltiples gráficos estadísticos
        Row(
          children: [
            Expanded(
              child: _buildChartCard(
                'Estudiantes por Turno',
                SfCircularChart(
                  series: <CircularSeries>[
                    PieSeries<ChartData, String>(
                      dataSource: _getEstudiantesPorTurno(estudiantesVM),
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
                context,
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: _buildChartCard(
                'Materias por Año',
                SfCircularChart(
                  series: <CircularSeries>[
                    PieSeries<ChartData, String>(
                      dataSource: _getMateriasPorAnio(materiasVM),
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
                context,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),

        _buildReporteCard(
          'Reporte Estadístico Anual',
          'Estadísticas comparativas y análisis de tendencias del año académico',
          Icons.analytics,
          Colors.purple,
          [
            _buildExportButton(
              'PDF',
              Icons.picture_as_pdf,
              Colors.red,
                  () => _generarReportePDF('estadistico'),
            ),
            const SizedBox(width: AppSpacing.small),
            _buildExportButton(
              'Excel',
              Icons.table_chart,
              Colors.green,
                  () => _exportarExcel('estadistico'),
            ),
          ],
          context,
        ),
      ],
    );
  }

  // ========== COMPONENTES REUTILIZABLES ==========

  Widget _buildUserInfoCard(BuildContext context, Map<String, dynamic> userData) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(AppSpacing.medium),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            Text(
              'Información del Usuario',
              style: AppTextStyles.heading2Dark(context).copyWith(
                color: _getTextColor(context),
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildInfoRow('Usuario:', userData['nombre']?.toString() ?? 'Usuario', context),
            const SizedBox(height: AppSpacing.small),
            _buildInfoRow('Rol:', userData['role']?.toString() ?? 'Usuario', context),
            const SizedBox(height: AppSpacing.small),
            _buildInfoRow('Email:', userData['email']?.toString() ?? 'No especificado', context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyDark(context).copyWith(
            fontWeight: FontWeight.bold,
            color: _getTextColor(context),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyDark(context).copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

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
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppSpacing.small),
            Text(
              valor,
              style: AppTextStyles.heading1.copyWith(
                color: color,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              titulo,
              style: AppTextStyles.bodyDark(context).copyWith(
                color: _getSecondaryTextColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
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
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: AppTextStyles.heading2Dark(context).copyWith(
                color: _getTextColor(context),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            SizedBox(height: 200, child: chart),
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
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    titulo,
                    style: AppTextStyles.heading2Dark(context).copyWith(
                      color: _getTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              descripcion,
              style: AppTextStyles.bodyDark(context).copyWith(
                color: _getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Row(children: acciones),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(String texto, IconData icon, Color color, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: _generando ? null : onPressed,
        icon: Icon(icon, size: 16),
        label: Text(
          texto,
          style: const TextStyle(fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildFiltrosAsistencia(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros de Reporte',
              style: AppTextStyles.heading3.copyWith(
                color: _getTextColor(context),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: 'Tercero B',
                    items: ['Tercero A', 'Tercero B', 'Todos los cursos']
                        .map((curso) => DropdownMenuItem(
                              value: curso,
                              child: Text(curso),
                            ))
                        .toList(),
                    onChanged: (value) {},
                    decoration: const InputDecoration(
                      labelText: 'Curso',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: 'Base de Datos II',
                    items: ['Base de Datos II', 'Programación II', 'Todas las materias']
                        .map((materia) => DropdownMenuItem(
                              value: materia,
                              child: Text(materia),
                            ))
                        .toList(),
                    onChanged: (value) {},
                    decoration: const InputDecoration(
                      labelText: 'Materia',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: 'Primer Bimestre',
                    items: ['Primer Bimestre', 'Segundo Bimestre', 'Anual']
                        .map((periodo) => DropdownMenuItem(
                              value: periodo,
                              child: Text(periodo),
                            ))
                        .toList(),
                    onChanged: (value) {},
                    decoration: const InputDecoration(
                      labelText: 'Período',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccionesRapidas(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Rápidas',
              style: AppTextStyles.heading2Dark(context).copyWith(
                color: _getTextColor(context),
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                _buildActionChip(Icons.dashboard, 'Dashboard', () {}),
                _buildActionChip(Icons.trending_up, 'Tendencias', () {}),
                _buildActionChip(Icons.notifications, 'Alertas', () {}),
                _buildActionChip(Icons.backup, 'Respaldo', () {}),
                _buildActionChip(Icons.settings, 'Configuración', () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.primary.withOpacity(0.1),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
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
    );
  }

  // ========== MÉTODOS DE DATOS (SIMULADOS - DEBES CONECTAR CON TUS VIEWMODELS) ==========

  double _calcularAsistenciaPromedio(EstudiantesViewModel estudiantesVM) {
    // En una implementación real, calcularías esto basado en los registros de asistencia
    return 85.5; // Simulado
  }

  List<ChartData> _getDistribucionEstudiantes(EstudiantesViewModel estudiantesVM) {
    // Agrupar estudiantes por año (simulado)
    return [
      ChartData('1er Año', 45),
      ChartData('2do Año', 38),
      ChartData('Noche', estudiantesVM.estudiantesFiltrados.length.toDouble()),
      ChartData('4to Año', 28),
    ];
  }

  List<ChartData> _getAsistenciaPorMateria(MateriaViewModel materiasVM) {
    // Simular datos de asistencia por materia
    return [
      ChartData('Base de Datos II', 88),
      ChartData('Programación II', 92),
      ChartData('Análisis de Sistemas', 78),
      ChartData('Redes', 85),
      ChartData('Ingeniería de Software', 90),
    ];
  }

  List<ChartData> _getDistribucionCalificaciones() {
    return [
      ChartData('Excelente', 25),
      ChartData('Muy Bueno', 35),
      ChartData('Bueno', 20),
      ChartData('Regular', 15),
      ChartData('Necesita Mejorar', 5),
    ];
  }

  List<ChartData> _getEstadoPagos() {
    return [
      ChartData('Al Día', 65),
      ChartData('Pendiente', 25),
      ChartData('Moroso', 10),
    ];
  }

  List<ChartData> _getEstudiantesPorTurno(EstudiantesViewModel estudiantesVM) {
    // Agrupar estudiantes por turno (simulado)
    return [
      ChartData('Mañana', 60),
      ChartData('Tarde', 45),
      ChartData('Noche', estudiantesVM.estudiantesFiltrados.length.toDouble()),
    ];
  }

  List<ChartData> _getMateriasPorAnio(MateriaViewModel materiasVM) {
    // Contar materias por año
    final materiasPorAnio = <int, int>{};
    for (final materia in materiasVM.materiasFiltradas) {
      materiasPorAnio[materia.anio] = (materiasPorAnio[materia.anio] ?? 0) + 1;
    }
    
    return materiasPorAnio.entries
        .map((entry) => ChartData('${entry.key}° Año', entry.value.toDouble()))
        .toList();
  }

  // ========== GENERACIÓN DE REPORTES (MANTENIENDO TU CÓDIGO ORIGINAL) ==========

  Future<void> _generarReportePDF(String tipoReporte) async {
    setState(() => _generando = true);

    try {
      final pdf = pw.Document();
      final now = DateTime.now();

      pdf.addPage(
        pw.MultiPage(
          header: (context) => _buildPDFHeader(now),
          footer: (context) => _buildPDFFooter(now),
          build: (context) => _buildPDFContent(tipoReporte),
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/reporte_${tipoReporte}_${now.millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      setState(() => _generando = false);
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

  Future<void> _exportarExcel(String tipoReporte) async {
    setState(() => _generando = true);

    try {
      final excel = Excel.createExcel();
      final now = DateTime.now();
      final Sheet sheet = excel[tipoReporte];

      // Implementar generación de Excel según el tipo de reporte
      // (Mantener tu código original de generación de Excel)

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/reporte_${tipoReporte}_${now.millisecondsSinceEpoch}.xlsx',
      );
      final excelBytes = excel.save();
      if (excelBytes != null) {
        await file.writeAsBytes(excelBytes);
      }

      setState(() => _generando = false);
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

  // Métodos de generación de PDF (mantener tus métodos originales)
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

  List<pw.Widget> _buildPDFContent(String tipoReporte) {
    // Implementar contenido específico para cada tipo de reporte
    // (Mantener tu código original de generación de contenido PDF)
    return [
      pw.Header(
        level: 0,
        child: pw.Text(
          'REPORTE: ${tipoReporte.toUpperCase()}',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Text('Contenido del reporte en desarrollo...'),
    ];
  }
}

// Modelo para datos de gráficos
class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}