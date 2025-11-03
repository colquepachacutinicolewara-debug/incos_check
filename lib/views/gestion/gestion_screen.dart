// views/gestion_screen.dart
import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/gestion_viewmodel.dart';
import 'carreras_screen.dart';
import 'turnos_screen.dart';
import '../../views/gestion/materias_screen.dart';
import '../../views/gestion/programas/programas_screen.dart';
import 'docentes_screen.dart';

class GestionScreen extends StatefulWidget {
  const GestionScreen({super.key});

  @override
  State<GestionScreen> createState() => _GestionScreenState();
}

class _GestionScreenState extends State<GestionScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GestionViewModel(),
      child: Scaffold(
        backgroundColor: _getBackgroundColor(context),
        appBar: AppBar(
          title: Text(
            'Gestión Académica',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.secondary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer<GestionViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Selector de Carrera
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.medium,
                    ),
                    decoration: BoxDecoration(
                      color: viewModel.getDropdownBackgroundColor(context),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(
                        color: viewModel.getBorderColor(context),
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: viewModel.carreraSeleccionada,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: viewModel.getDropdownBackgroundColor(
                        context,
                      ),
                      items: viewModel.carreras.map((String carrera) {
                        return DropdownMenuItem<String>(
                          value: carrera,
                          child: Text(
                            carrera,
                            style: TextStyle(
                              color: viewModel.getTextColor(context),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          viewModel.seleccionarCarrera(newValue);
                        }
                      },
                    ),
                  ),
                ),

                // Título de la carrera seleccionada
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Carrera: ${viewModel.carreraSeleccionada}',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.medium),

                // Grid de opciones de gestión
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    childAspectRatio: 1.0,
                    children: [
                      _buildMenuCard(
                        context,
                        viewModel,
                        'Estudiantes',
                        Icons.people,
                        UserThemeColors.estudiante,
                        () => _navigateToEstudiantes(context, viewModel),
                      ),
                      _buildMenuCard(
                        context,
                        viewModel,
                        'Cursos',
                        Icons.book,
                        AppColors.success,
                        () => _navigateToCursos(context),
                      ),
                      _buildMenuCard(
                        context,
                        viewModel,
                        'Carreras',
                        Icons.school,
                        AppColors.warning,
                        () => _navigateToCarrerasGestion(context, viewModel),
                      ),
                      _buildMenuCard(
                        context,
                        viewModel,
                        'Docentes',
                        Icons.person,
                        UserThemeColors.docente,
                        () => _navigateToDocentes(context, viewModel),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    GestionViewModel viewModel,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(AppSpacing.small),
      color: viewModel.getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.small),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: AppSpacing.small),
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: viewModel.getTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                viewModel.carreraSeleccionada,
                style: TextStyle(
                  color: viewModel.getSecondaryTextColor(context),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Funciones de navegación
  void _navigateToEstudiantes(
    BuildContext context,
    GestionViewModel viewModel,
  ) {
    final carreraConfig = viewModel.getCarreraConfig(
      viewModel.carreraSeleccionada,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TurnosScreen(tipo: 'Estudiantes', carrera: carreraConfig.toMap()),
        ),
      );
    });
  }

  void _navigateToCursos(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MateriasScreen()),
      );
    });
  }

  void _navigateToDocentes(BuildContext context, GestionViewModel viewModel) {
    final carreraConfig = viewModel.getCarreraConfig(
      viewModel.carreraSeleccionada,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocentesScreen(carrera: carreraConfig.toMap()),
        ),
      );
    });
  }

  void _navigateToCarrerasGestion(
    BuildContext context,
    GestionViewModel viewModel,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CarrerasScreen(
            tipo: 'Gestión',
            carreraSeleccionada: viewModel.carreraSeleccionada,
            onCarrerasActualizadas: viewModel.actualizarCarreras,
          ),
        ),
      );
    });
  }

  void _navigateToProgramas(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProgramasScreen()),
      );
    });
  }

  // Helper method para background color
  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.grey.shade100;
  }
}
