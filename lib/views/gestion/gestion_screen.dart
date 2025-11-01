import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';
import 'carreras_screen.dart';
import '../../views/gestion/programas/programas_screen.dart';

class GestionScreen extends StatelessWidget {
  const GestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión Académica',
          style: AppTextStyles.heading2Dark(
            context,
          ).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(AppSpacing.medium),
        childAspectRatio: 1.0,
        children: [
          _buildMenuCard(
            context,
            'Estudiantes',
            Icons.people,
            UserThemeColors.estudiante,
            () => _navigateToCarreras(context, 'Estudiantes'),
          ),
          _buildMenuCard(
            context,
            'Cursos',
            Icons.book,
            AppColors.success,
            () => _navigateToCarreras(context, 'Cursos'),
          ),
          _buildMenuCard(
            context,
            'Carreras',
            Icons.school,
            AppColors.warning,
            () => _navigateToProgramas(context),
          ),
          _buildMenuCard(
            context,
            'Docentes',
            Icons.person,
            UserThemeColors.docente,
            () => _navigateToCarreras(context, 'Docentes'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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
              style: AppTextStyles.bodyDark(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCarreras(BuildContext context, String tipo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarrerasScreen(tipo: tipo)),
    );
  }

  void _navigateToProgramas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProgramasScreen()),
    );
  }
}
