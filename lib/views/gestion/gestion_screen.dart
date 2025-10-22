import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';

class GestionScreen extends StatelessWidget {
  const GestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión Académica',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary, // Cambiado a CELESTE
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(AppSpacing.medium),
        childAspectRatio: 1.0,
        children: [
          _buildMenuCard(
            context,
            AppStrings.estudiantes,
            Icons.people,
            UserThemeColors.estudiante,
            () => _navigateToScreen(context, 'estudiantes'),
          ),
          _buildMenuCard(
            context,
            'Cursos',
            Icons.book,
            AppColors.success,
            () => _navigateToScreen(context, 'cursos'),
          ),
          _buildMenuCard(
            context,
            'Carreras',
            Icons.school,
            AppColors.warning,
            () => _navigateToScreen(context, 'carreras'),
          ),
          _buildMenuCard(
            context,
            AppStrings.docentes,
            Icons.person,
            UserThemeColors.docente,
            () => _navigateToScreen(context, 'docentes'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(AppSpacing.small),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(height: AppSpacing.small),
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String screen) {
    // Implementar navegación según el screen
    Helpers.showSnackBar(context, 'Navegando a $screen');
  }
}