import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de construcción
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.construction,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Título
            Text(
              "Reportes en Desarrollo",
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "Estamos trabajando en esta sección para brindarte reportes detallados y útiles de tu sistema de gestión académica.",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Indicador de progreso
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: 0.7, // 70% completado
                backgroundColor: AppColors.textSecondary.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                borderRadius: BorderRadius.circular(10),
                minHeight: 8,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Porcentaje
            Text(
              "70% Completado",
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Características próximas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Próximamente:",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildFeatureItem("Reportes de asistencia por estudiante"),
                  _buildFeatureItem("Reportes de asistencia por curso"),
                  _buildFeatureItem("Estadísticas mensuales y anuales"),
                  _buildFeatureItem("Exportación a PDF y Excel"),
                  _buildFeatureItem("Gráficos y visualizaciones"),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Botón de notificación
            ElevatedButton.icon(
              onPressed: () {
                // Mostrar snackbar de confirmación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Te notificaremos cuando los reportes estén disponibles",
                      style: AppTextStyles.body.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              icon: Icon(Icons.notifications_active, color: Colors.white),
              label: Text(
                "Notificarme cuando esté listo",
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}