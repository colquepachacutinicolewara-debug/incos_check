import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';
import '../../views/gestion/estudiantes_screen.dart'; // Importar la pantalla de estudiantes
import '../../views/gestion/cursos_screen.dart'; // Importar la pantalla de cursos
import '../../views/gestion/carreras_screen.dart'; // Importar la pantalla de carreras
import '../../views/gestion/docentes_screen.dart'; // Importar la pantalla de docentes

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
        backgroundColor: AppColors.secondary, // Color celeste
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
            () => _navigateToEstudiantes(context),
          ),
          _buildMenuCard(
            context,
            'Cursos',
            Icons.book,
            AppColors.success,
            () => _navigateToCursos(context),
          ),
          _buildMenuCard(
            context,
            'Carreras',
            Icons.school,
            AppColors.warning,
            () => _navigateToCarreras(context),
          ),
          _buildMenuCard(
            context,
            AppStrings.docentes,
            Icons.person,
            UserThemeColors.docente,
            () => _navigateToDocentes(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
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

  // ESTUNDENT CORREGIDOS
  void _navigateToEstudiantes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EstudiantesScreen(
          carrera: 'INGENIERÍA DE SISTEMAS',
          turno: 'Mañana',
          curso: '3RO B',
          codigoCurso: '3B-SIS',
        ),
      ),
    );
  }

  //  CURSOS CORRIGIDO
  void _navigateToCursos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CursosScreen(
          carrera: 'INGENIERÍA DE SISTEMAS',
          turno: 'Mañana',
        ),
      ),
    );
  }

  void _navigateToCarreras(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarreraScreen()),
    );
  }

  void _navigateToDocentes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DocentesScreen()),
    );
  }
}
