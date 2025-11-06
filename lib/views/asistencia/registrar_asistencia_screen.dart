// views/registrar_asistencia_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/registrar_asistencia_viewmodel.dart';
import '../../utils/constants.dart';

class RegistrarAsistenciaScreen extends StatelessWidget {
  const RegistrarAsistenciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AsistenciaViewModel(),
      child: const _RegistrarAsistenciaView(),
    );
  }
}

class _RegistrarAsistenciaView extends StatelessWidget {
  const _RegistrarAsistenciaView();

  void _escanearQR(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Función de escaneo QR próximamente...",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _mostrarInfoHuella(BuildContext context) {
    final viewModel = context.read<AsistenciaViewModel>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: viewModel.getCardColor(context),
        title: Text(
          "Información de Huellas",
          style: TextStyle(color: viewModel.getTextColor(context)),
        ),
        content: Text(
          "El sistema autentica con cualquier huella registrada en el dispositivo. "
          "En una implementación real, se conectaría con una base de datos que asocie "
          "cada huella a un estudiante específico.\n\n"
          "Estudiantes con ⚠️ no tienen huellas suficientes registradas en el sistema.",
          style: TextStyle(color: viewModel.getSecondaryTextColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Entendido",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarEstadisticas(BuildContext context) {
    final viewModel = context.read<AsistenciaViewModel>();
    final stats = viewModel.getEstadisticas();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: viewModel.getCardColor(context),
        title: Text(
          "Estadísticas de Asistencia",
          style: TextStyle(
            color: viewModel.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow("Total Estudiantes:", "${stats['total']}", context),
            _buildStatRow(
              "Presentes:",
              "${stats['presentes']}",
              context,
              Colors.green,
            ),
            _buildStatRow(
              "Ausentes:",
              "${stats['ausentes']}",
              context,
              Colors.red,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Porcentaje: ${stats['porcentaje'].toStringAsFixed(1)}%",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cerrar",
              style: TextStyle(color: viewModel.getTextColor(context)),
            ),
          ),
          TextButton(
            onPressed: () {
              viewModel.limpiarAsistencias();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Asistencias reiniciadas"),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text("Reiniciar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    BuildContext context, [
    Color? color,
  ]) {
    final viewModel = context.read<AsistenciaViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: viewModel.getTextColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? viewModel.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AsistenciaViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: viewModel.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Registrar Asistencia',
          style: AppTextStyles.heading1.copyWith(
            fontSize: isSmallScreen ? 20 : 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 2,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.white),
            onPressed: () => _mostrarEstadisticas(context),
            tooltip: 'Ver estadísticas',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _mostrarInfoHuella(context),
            tooltip: 'Información sobre huellas',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          children: [
            // Card de escaneo QR
            _buildQRCard(context, viewModel, isSmallScreen),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Estado del sensor biométrico
            if (!viewModel.biometricAvailable)
              _buildBiometricWarning(context, viewModel),

            // Separador
            _buildSeparator(context, viewModel, isSmallScreen),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // Contador de asistencias
            _buildAttendanceCounter(context, viewModel),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // Lista de estudiantes
            _buildStudentsList(context, viewModel, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCard(
    BuildContext context,
    AsistenciaViewModel viewModel,
    bool isSmallScreen,
  ) {
    return Card(
      elevation: 4,
      color: viewModel.getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: isSmallScreen ? 50 : 60,
              color: AppColors.primary,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'Escanear Código QR',
              style: AppTextStyles.heading2.copyWith(
                fontSize: isSmallScreen ? 16 : 18,
                color: viewModel.getTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            ElevatedButton.icon(
              onPressed: viewModel.isLoading
                  ? null
                  : () => _escanearQR(context),
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: Text(
                'Escanear QR',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricWarning(
    BuildContext context,
    AsistenciaViewModel viewModel,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: viewModel.getWarningColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: viewModel.getWarningColor(context)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: viewModel.getWarningColor(context),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Sensor biométrico no disponible",
              style: AppTextStyles.body.copyWith(
                color: viewModel.getWarningColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator(
    BuildContext context,
    AsistenciaViewModel viewModel,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: viewModel.getBorderColor(context),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Registro por huella',
            style: AppTextStyles.body.copyWith(
              fontSize: isSmallScreen ? 14 : 16,
              color: viewModel.getTextColor(context),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: viewModel.getBorderColor(context),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCounter(
    BuildContext context,
    AsistenciaViewModel viewModel,
  ) {
    final stats = viewModel.getEstadisticas();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: viewModel.getAccentColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: viewModel.getAccentColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Asistencias registradas:',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: viewModel.getTextColor(context),
                ),
              ),
              Text(
                '${viewModel.totalAsistencias}/${viewModel.totalEstudiantes}',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: stats['total'] > 0 ? stats['presentes'] / stats['total'] : 0,
            backgroundColor: viewModel.getBorderColor(context),
            color: AppColors.primary,
          ),
          const SizedBox(height: 4),
          Text(
            '${stats['porcentaje'].toStringAsFixed(1)}% de asistencia',
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: viewModel.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(
    BuildContext context,
    AsistenciaViewModel viewModel,
    bool isSmallScreen,
  ) {
    return Expanded(
      child: ListView.builder(
        itemCount: viewModel.estudiantes.length,
        itemBuilder: (context, index) {
          final estudiante = viewModel.estudiantes[index];
          final tieneHuellas = estudiante.tieneTodasLasHuellas;
          final asistenciaRegistrada = viewModel.asistencia[index];

          return Card(
            margin: EdgeInsets.symmetric(
              horizontal: 4,
              vertical: isSmallScreen ? 2 : 4,
            ),
            elevation: 2,
            color: viewModel.getCardColor(context),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: asistenciaRegistrada
                    ? viewModel.getSuccessColor(context).withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                child: Icon(
                  asistenciaRegistrada ? Icons.check_circle : Icons.person,
                  color: asistenciaRegistrada
                      ? viewModel.getSuccessColor(context)
                      : AppColors.primary,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      estudiante.nombreCompleto,
                      style: AppTextStyles.heading3.copyWith(
                        color: viewModel.getTextColor(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!tieneHuellas)
                    Icon(
                      Icons.warning,
                      color: viewModel.getWarningColor(context),
                      size: 16,
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CI: ${estudiante.ci}',
                    style: AppTextStyles.body.copyWith(
                      color: viewModel.getSecondaryTextColor(context),
                    ),
                  ),
                  if (!tieneHuellas)
                    Text(
                      'Huellas registradas: ${estudiante.huellasRegistradas}/3',
                      style: AppTextStyles.body.copyWith(
                        color: viewModel.getWarningColor(context),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              trailing: SizedBox(
                width: isSmallScreen ? 110 : 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!asistenciaRegistrada)
                      ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () => viewModel.autenticarHuella(index, context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tieneHuellas
                              ? AppColors.primary
                              : viewModel.getWarningColor(context),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 12,
                            vertical: 6,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tieneHuellas ? Icons.fingerprint : Icons.warning,
                              size: isSmallScreen ? 14 : 16,
                            ),
                            SizedBox(width: isSmallScreen ? 4 : 6),
                            Text(
                              tieneHuellas ? 'Huella' : 'Manual',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (asistenciaRegistrada)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: viewModel
                              .getSuccessColor(context)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: viewModel.getSuccessColor(context),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              color: viewModel.getSuccessColor(context),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Registrado',
                              style: TextStyle(
                                color: viewModel.getSuccessColor(context),
                                fontSize: isSmallScreen ? 10 : 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
