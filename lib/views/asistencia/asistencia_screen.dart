import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../utils/constants.dart';
import 'registrar_asistencia_screen.dart';
import 'historial_asistencia_screen.dart';

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({super.key});

  @override
  State<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  // Datos de ejemplo para el gráfico
  final List<AsistenciaData> _datosAsistencia = [
    AsistenciaData('Lun', 85),
    AsistenciaData('Mar', 92),
    AsistenciaData('Mié', 78),
    AsistenciaData('Jue', 95),
    AsistenciaData('Vie', 88),
    AsistenciaData('Sáb', 70),
    AsistenciaData('Dom', 65),
  ];

  bool _asistenciaRegistradaHoy = false;

  // Funciones para obtener colores según el tema
  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : AppColors.background;
  }

  Color _getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color _getAppBarColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }

  Color _getChartTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 320;

    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          AppStrings.asistencia,
          style: AppTextStyles.heading1.copyWith(
            fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 24),
            color: _getTextColor(context),
          ),
        ),
        backgroundColor: _getAppBarColor(context),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _getTextColor(context)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          isVerySmallScreen
              ? 6
              : (isSmallScreen ? AppSpacing.small : AppSpacing.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alerta de asistencia del día
            _buildAlertaAsistencia(isSmallScreen, isVerySmallScreen, context),
            SizedBox(
              height: isVerySmallScreen
                  ? 8
                  : (isSmallScreen ? AppSpacing.medium : AppSpacing.large),
            ),

            // Cards principales - Responsive
            _buildCardsResponsive(isSmallScreen, isVerySmallScreen, context),
            SizedBox(
              height: isVerySmallScreen
                  ? 8
                  : (isSmallScreen ? AppSpacing.medium : AppSpacing.large),
            ),

            // Gráfico de asistencias
            _buildGraficoAsistencias(isSmallScreen, isVerySmallScreen, context),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertaAsistencia(
    bool isSmallScreen,
    bool isVerySmallScreen,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isVerySmallScreen
            ? 8
            : (isSmallScreen ? AppSpacing.small : AppSpacing.medium),
      ),
      decoration: BoxDecoration(
        color: _asistenciaRegistradaHoy ? AppColors.success : AppColors.warning,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _asistenciaRegistradaHoy ? Icons.check_circle : Icons.info,
            color: Colors.white,
            size: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 24),
          ),
          SizedBox(
            width: isVerySmallScreen
                ? 6
                : (isSmallScreen ? AppSpacing.small : AppSpacing.medium),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _asistenciaRegistradaHoy
                      ? 'Asistencia Registrada'
                      : 'Pendiente',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isVerySmallScreen
                        ? 12
                        : (isSmallScreen ? 14 : 16),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: isVerySmallScreen ? 1 : (isSmallScreen ? 2 : 4),
                ),
                Text(
                  _asistenciaRegistradaHoy
                      ? '¡Registro completado!'
                      : 'Registra tu asistencia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isVerySmallScreen
                        ? 10
                        : (isSmallScreen ? 12 : 14),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!_asistenciaRegistradaHoy)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.add,
                color: Colors.white,
                size: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 24),
              ),
              onPressed: () {
                _navegarARegistrarAsistencia(context);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCardsResponsive(
    bool isSmallScreen,
    bool isVerySmallScreen,
    BuildContext context,
  ) {
    if (isVerySmallScreen) {
      // Para pantallas muy pequeñas, mostrar en columna con textos más cortos
      return Column(
        children: [
          _buildCard(
            icono: Icons.fingerprint,
            titulo: 'Registrar',
            color: AppColors.primary,
            onTap: () {
              _navegarARegistrarAsistencia(context);
            },
            isSmallScreen: isSmallScreen,
            isVerySmallScreen: isVerySmallScreen,
            context: context,
          ),
          SizedBox(height: 8),
          _buildCard(
            icono: Icons.history,
            color: AppColors.secondary,
            titulo: 'Historial',
            onTap: () {
              _navegarAHistorialAsistencia(context);
            },
            isSmallScreen: isSmallScreen,
            isVerySmallScreen: isVerySmallScreen,
            context: context,
          ),
        ],
      );
    } else if (isSmallScreen) {
      // Para pantallas pequeñas, mostrar en columna
      return Column(
        children: [
          _buildCard(
            icono: Icons.fingerprint,
            titulo: 'Registrar',
            color: AppColors.primary,
            onTap: () {
              _navegarARegistrarAsistencia(context);
            },
            isSmallScreen: isSmallScreen,
            isVerySmallScreen: isVerySmallScreen,
            context: context,
          ),
          SizedBox(height: AppSpacing.medium),
          _buildCard(
            icono: Icons.history,
            color: AppColors.secondary,
            titulo: 'Historial',
            onTap: () {
              _navegarAHistorialAsistencia(context);
            },
            isSmallScreen: isSmallScreen,
            isVerySmallScreen: isVerySmallScreen,
            context: context,
          ),
        ],
      );
    } else {
      // Para pantallas normales, mostrar en fila
      return Row(
        children: [
          Expanded(
            child: _buildCard(
              titulo: 'Registrar',
              icono: Icons.fingerprint,
              color: AppColors.primary,
              onTap: () {
                _navegarARegistrarAsistencia(context);
              },
              isSmallScreen: isSmallScreen,
              isVerySmallScreen: isVerySmallScreen,
              context: context,
            ),
          ),
          SizedBox(width: AppSpacing.medium),
          Expanded(
            child: _buildCard(
              icono: Icons.history,
              titulo: 'Historial',
              color: AppColors.secondary,
              onTap: () {
                _navegarAHistorialAsistencia(context);
              },
              isSmallScreen: isSmallScreen,
              isVerySmallScreen: isVerySmallScreen,
              context: context,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildCard({
    required String titulo,
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
    required bool isSmallScreen,
    required bool isVerySmallScreen,
    required BuildContext context,
  }) {
    return Card(
      elevation: 4,
      color: _getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          padding: EdgeInsets.all(
            isVerySmallScreen
                ? 8
                : (isSmallScreen ? AppSpacing.medium : AppSpacing.large),
          ),
          height: isVerySmallScreen ? 80 : (isSmallScreen ? 90 : 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icono,
                size: isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 32),
                color: color,
              ),
              SizedBox(
                height: isVerySmallScreen
                    ? 4
                    : (isSmallScreen ? AppSpacing.small : AppSpacing.medium),
              ),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading3.copyWith(
                  color: color,
                  fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 16),
                  fontWeight: isVerySmallScreen
                      ? FontWeight.w500
                      : FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraficoAsistencias(
    bool isSmallScreen,
    bool isVerySmallScreen,
    BuildContext context,
  ) {
    return Card(
      elevation: 4,
      color: _getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          isVerySmallScreen
              ? 8
              : (isSmallScreen ? AppSpacing.small : AppSpacing.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas',
              style: AppTextStyles.heading2.copyWith(
                fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                color: _getTextColor(context),
              ),
            ),
            SizedBox(
              height: isVerySmallScreen
                  ? 6
                  : (isSmallScreen ? AppSpacing.small : AppSpacing.medium),
            ),
            SizedBox(
              height: isVerySmallScreen ? 120 : (isSmallScreen ? 140 : 200),
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle: TextStyle(
                    fontSize: isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12),
                    color: _getChartTextColor(context),
                  ),
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: TextStyle(
                    fontSize: isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12),
                    color: _getChartTextColor(context),
                  ),
                ),
                series: <CartesianSeries<AsistenciaData, String>>[
                  ColumnSeries<AsistenciaData, String>(
                    dataSource: _datosAsistencia,
                    xValueMapper: (AsistenciaData data, _) => data.dia,
                    yValueMapper: (AsistenciaData data, _) => data.porcentaje,
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: isVerySmallScreen
                  ? 6
                  : (isSmallScreen ? AppSpacing.small : AppSpacing.medium),
            ),
            _buildIndicadoresResponsive(
              isSmallScreen,
              isVerySmallScreen,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicadoresResponsive(
    bool isSmallScreen,
    bool isVerySmallScreen,
    BuildContext context,
  ) {
    if (isVerySmallScreen) {
      // Para pantallas muy pequeñas, mostrar en 2 filas con textos cortos
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIndicador(
                AppColors.primary,
                'Asist.',
                isSmallScreen,
                isVerySmallScreen,
                context,
              ),
              _buildIndicador(
                AppColors.success,
                'Pres.',
                isSmallScreen,
                isVerySmallScreen,
                context,
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIndicador(
                AppColors.error,
                'Aus.',
                isSmallScreen,
                isVerySmallScreen,
                context,
              ),
              _buildIndicador(
                AppColors.warning,
                'Tard.',
                isSmallScreen,
                isVerySmallScreen,
                context,
              ),
            ],
          ),
        ],
      );
    } else if (isSmallScreen) {
      // Para pantallas pequeñas, mostrar en 2 filas
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIndicador(
                AppColors.primary,
                'Asistencia',
                isSmallScreen,
                isVerySmallScreen,
                context,
              ),
              _buildIndicador(
                AppColors.success,
                'Presente',
                isSmallScreen,
                isVerySmallScreen,
                context,
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIndicador(
                AppColors.error,
                'Ausente',
                isSmallScreen,
                isVerySmallScreen,
                context,
              ),
              _buildIndicador(
                AppColors.warning,
                'Tardanza',
                isSmallScreen,
                isVerySmallScreen,
                context,
              ),
            ],
          ),
        ],
      );
    } else {
      // Para pantallas normales, mostrar en una sola fila
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIndicador(
            AppColors.primary,
            'Asistencia',
            isSmallScreen,
            isVerySmallScreen,
            context,
          ),
          _buildIndicador(
            AppColors.success,
            'Presente',
            isSmallScreen,
            isVerySmallScreen,
            context,
          ),
          _buildIndicador(
            AppColors.error,
            'Ausente',
            isSmallScreen,
            isVerySmallScreen,
            context,
          ),
          _buildIndicador(
            AppColors.warning,
            'Tardanza',
            isSmallScreen,
            isVerySmallScreen,
            context,
          ),
        ],
      );
    }
  }

  Widget _buildIndicador(
    Color color,
    String texto,
    bool isSmallScreen,
    bool isVerySmallScreen,
    BuildContext context,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12),
          height: isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: isVerySmallScreen ? 2 : (isSmallScreen ? 2 : 4)),
        Text(
          texto,
          style: AppTextStyles.body.copyWith(
            fontSize: isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12),
            color: _getTextColor(context),
          ),
        ),
      ],
    );
  }

  void _navegarARegistrarAsistencia(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistrarAsistenciaScreen(),
      ),
    );
  }

  void _navegarAHistorialAsistencia(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HistorialAsistenciaScreen(),
      ),
    );
  }

  void _registrarAsistencia() {
    setState(() {
      _asistenciaRegistradaHoy = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Asistencia registrada exitosamente',
          style: AppTextStyles.button.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class AsistenciaData {
  final String dia;
  final int porcentaje;

  AsistenciaData(this.dia, this.porcentaje);
}
