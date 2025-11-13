// views/asistencia/asistencia_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../utils/constants.dart';
import 'registrar_asistencia_screen.dart';
import 'historial_asistencia_screen.dart';
import '../../viewmodels/asistencia_viewmodel.dart';
import '../../models/asistencia_model.dart';

class AsistenciaScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const AsistenciaScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return _AsistenciaScreenContent(userData: userData);
  }
}

class _AsistenciaScreenContent extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const _AsistenciaScreenContent({this.userData});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AsistenciaViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 320;

    // Mostrar loading
    if (viewModel.isLoading) {
      return Scaffold(
        backgroundColor: viewModel.getBackgroundColor(context),
        appBar: AppBar(
          title: Text(
            'Asistencia',
            style: AppTextStyles.heading1.copyWith(
              fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 24),
              color: viewModel.getTextColor(context),
            ),
          ),
          backgroundColor: viewModel.getAppBarColor(context),
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Mostrar error si existe
    if (viewModel.error != null) {
      return Scaffold(
        backgroundColor: viewModel.getBackgroundColor(context),
        appBar: AppBar(
          title: Text(
            'Asistencia',
            style: AppTextStyles.heading1.copyWith(
              fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 24),
              color: viewModel.getTextColor(context),
            ),
          ),
          backgroundColor: viewModel.getAppBarColor(context),
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: viewModel.refreshData,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 50),
                SizedBox(height: 16),
                Text(
                  'Error al cargar datos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: viewModel.getTextColor(context),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  viewModel.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: viewModel.getTextColor(context)),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: viewModel.refreshData,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Contenido normal
    return Scaffold(
      backgroundColor: viewModel.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Asistencia',
          style: AppTextStyles.heading1.copyWith(
            fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 24),
            color: viewModel.getTextColor(context),
          ),
        ),
        backgroundColor: viewModel.getAppBarColor(context),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: viewModel.getTextColor(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.refreshData,
          ),
        ],
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
            _buildAlertaAsistencia(
              isSmallScreen,
              isVerySmallScreen,
              context,
              viewModel,
            ),
            SizedBox(
              height: isVerySmallScreen
                  ? 8
                  : (isSmallScreen ? AppSpacing.medium : AppSpacing.large),
            ),

            // Cards principales - Responsive
            _buildCardsResponsive(
              isSmallScreen,
              isVerySmallScreen,
              context,
              viewModel,
            ),
            SizedBox(
              height: isVerySmallScreen
                  ? 8
                  : (isSmallScreen ? AppSpacing.medium : AppSpacing.large),
            ),

            // Gráfico de asistencias
            _buildGraficoAsistencias(
              isSmallScreen,
              isVerySmallScreen,
              context,
              viewModel,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertaAsistencia(
    bool isSmallScreen,
    bool isVerySmallScreen,
    BuildContext context,
    AsistenciaViewModel viewModel,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isVerySmallScreen
            ? 8
            : (isSmallScreen ? AppSpacing.small : AppSpacing.medium),
      ),
      decoration: BoxDecoration(
        color: viewModel.asistenciaRegistradaHoy
            ? AppColors.success
            : AppColors.warning,
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
            viewModel.asistenciaRegistradaHoy ? Icons.check_circle : Icons.info,
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
                  viewModel.asistenciaRegistradaHoy
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
                  viewModel.asistenciaRegistradaHoy
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
          if (!viewModel.asistenciaRegistradaHoy)
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
    AsistenciaViewModel viewModel,
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
            viewModel: viewModel,
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
            viewModel: viewModel,
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
            viewModel: viewModel,
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
            viewModel: viewModel,
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
              viewModel: viewModel,
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
              viewModel: viewModel,
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
    required AsistenciaViewModel viewModel,
  }) {
    return Card(
      elevation: 4,
      color: viewModel.getCardColor(context),
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
    AsistenciaViewModel viewModel,
  ) {
    return Card(
      elevation: 4,
      color: viewModel.getCardColor(context),
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
              'Estadísticas de Asistencia',
              style: AppTextStyles.heading2.copyWith(
                fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                color: viewModel.getTextColor(context),
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
                    color: viewModel.getChartTextColor(context),
                  ),
                ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 100,
                  interval: 20,
                  labelStyle: TextStyle(
                    fontSize: isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12),
                    color: viewModel.getChartTextColor(context),
                  ),
                ),
                series: <CartesianSeries<AsistenciaData, String>>[
                  ColumnSeries<AsistenciaData, String>(
                    dataSource: viewModel.datosAsistencia,
                    xValueMapper: (AsistenciaData data, _) => data.dia,
                    yValueMapper: (AsistenciaData data, _) => data.porcentaje,
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(
                        fontSize: isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12),
                        color: Colors.white,
                      ),
                    ),
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
              viewModel,
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
    AsistenciaViewModel viewModel,
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
                viewModel,
              ),
              _buildIndicador(
                AppColors.success,
                'Pres.',
                isSmallScreen,
                isVerySmallScreen,
                context,
                viewModel,
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
                viewModel,
              ),
              _buildIndicador(
                AppColors.warning,
                'Tard.',
                isSmallScreen,
                isVerySmallScreen,
                context,
                viewModel,
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
                viewModel,
              ),
              _buildIndicador(
                AppColors.success,
                'Presente',
                isSmallScreen,
                isVerySmallScreen,
                context,
                viewModel,
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
                viewModel,
              ),
              _buildIndicador(
                AppColors.warning,
                'Tardanza',
                isSmallScreen,
                isVerySmallScreen,
                context,
                viewModel,
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
            viewModel,
          ),
          _buildIndicador(
            AppColors.success,
            'Presente',
            isSmallScreen,
            isVerySmallScreen,
            context,
            viewModel,
          ),
          _buildIndicador(
            AppColors.error,
            'Ausente',
            isSmallScreen,
            isVerySmallScreen,
            context,
            viewModel,
          ),
          _buildIndicador(
            AppColors.warning,
            'Tardanza',
            isSmallScreen,
            isVerySmallScreen,
            context,
            viewModel,
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
    AsistenciaViewModel viewModel,
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
            color: viewModel.getTextColor(context),
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
}
