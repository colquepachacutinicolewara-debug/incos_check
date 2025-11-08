import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/gestion_viewmodel.dart';
import 'carreras_screen.dart';
import 'turnos_screen.dart';
import '../../views/gestion/materias_screen.dart';
import '../../views/gestion/programas/programas_screen.dart';
import 'docentes_screen.dart';
import 'niveles_screen.dart';
import '../gestion/paralelos_scren.dart';
import '../gestion/estudiantes_screen.dart';

class GestionScreen extends StatefulWidget {
  const GestionScreen({super.key});

  @override
  State<GestionScreen> createState() => _GestionScreenState();
}

class _GestionScreenState extends State<GestionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<GestionViewModel>();
      viewModel.initialize();
    });
  }

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
            if (viewModel.loading) {
              return _buildLoadingState();
            }

            if (viewModel.error.isNotEmpty) {
              return _buildErrorState(viewModel);
            }

            return _buildContent(context, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.medium),
          Text('Cargando gestión académica...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(GestionViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.medium),
            Text('Error al cargar', style: AppTextStyles.heading2),
            const SizedBox(height: AppSpacing.small),
            Text(
              viewModel.error,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton(
              onPressed: () => viewModel.refresh(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, GestionViewModel viewModel) {
    return Column(
      children: [
        // Selector de Carrera
        Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            decoration: BoxDecoration(
              color: viewModel.getDropdownBackgroundColor(context),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: viewModel.getBorderColor(context)),
            ),
            child: _buildDropdownCarreras(viewModel, context),
          ),
        ),

        // Título de la carrera seleccionada
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
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

        // Grid de opciones de gestión (7 CARDS)
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
                viewModel.getEstudiantesCount(viewModel.carreraSeleccionada),
                () => _navigateToEstudiantes(context, viewModel),
              ),
              _buildMenuCard(
                context,
                viewModel,
                'Cursos',
                Icons.book,
                AppColors.success,
                viewModel.getCursosCount(viewModel.carreraSeleccionada),
                () => _navigateToCursos(context),
              ),
              _buildMenuCard(
                context,
                viewModel,
                'Carreras',
                Icons.school,
                AppColors.warning,
                viewModel.carreras.length,
                () => _navigateToCarrerasGestion(context, viewModel),
              ),
              _buildMenuCard(
                context,
                viewModel,
                'Docentes',
                Icons.person,
                UserThemeColors.docente,
                viewModel.getDocentesCount(viewModel.carreraSeleccionada),
                () => _navigateToDocentes(context, viewModel),
              ),
              _buildMenuCard(
                context,
                viewModel,
                'Turnos',
                Icons.schedule,
                Colors.orange,
                viewModel.getTurnosCount(viewModel.carreraSeleccionada),
                () => _navigateToTurnos(context, viewModel),
              ),
              _buildMenuCard(
                context,
                viewModel,
                'Grados',
                Icons.layers,
                Colors.purple,
                viewModel.getNivelesCount(viewModel.carreraSeleccionada),
                () => _navigateToNiveles(context, viewModel),
              ),
              _buildMenuCard(
                context,
                viewModel,
                'Paralelos',
                Icons.groups,
                Colors.teal,
                viewModel.getParalelosCount(viewModel.carreraSeleccionada),
                () => _navigateToParalelos(context, viewModel),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownCarreras(
    GestionViewModel viewModel,
    BuildContext context,
  ) {
    final carrerasUnicas = viewModel.carreras.toSet().toList();

    return DropdownButton<String>(
      value: viewModel.carreraSeleccionada,
      isExpanded: true,
      underline: const SizedBox(),
      dropdownColor: viewModel.getDropdownBackgroundColor(context),
      items: carrerasUnicas.map((String carrera) {
        return DropdownMenuItem<String>(
          value: carrera,
          child: Text(
            carrera,
            style: TextStyle(color: viewModel.getTextColor(context)),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null && newValue != viewModel.carreraSeleccionada) {
          viewModel.seleccionarCarrera(newValue);
        }
      },
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    GestionViewModel viewModel,
    String title,
    IconData icon,
    Color color,
    int count,
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
              Stack(
                children: [
                  Icon(icon, size: 50, color: color),
                  if (count > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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

  // ========== FUNCIONES DE NAVEGACIÓN CORREGIDAS ==========

  void _navigateToEstudiantes(
    BuildContext context,
    GestionViewModel viewModel,
  ) {
    final carreraConfig = viewModel.getCarreraConfig(
      viewModel.carreraSeleccionada,
    );
    
    // ✅ CORREGIDO: Ahora navega directamente a EstudiantesListScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EstudiantesListScreen(
          tipo: 'Gestión', // O el tipo que necesites
          carrera: carreraConfig.toMap(),
          turno: {
            'id': 'general',
            'nombre': 'General',
            'color': carreraConfig.color,
            'icon': Icons.schedule.codePoint,
          },
          nivel: {
            'id': 'general', 
            'nombre': 'General',
            'orden': 1,
            'activo': true,
          },
          paralelo: {
            'id': 'general',
            'nombre': 'General',
            'activo': true,
            'estudiantes': [],
          },
        ),
      ),
    );
  }

  void _navigateToCursos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MateriasScreen()),
    );
  }

  void _navigateToDocentes(BuildContext context, GestionViewModel viewModel) {
    final carreraConfig = viewModel.getCarreraConfig(
      viewModel.carreraSeleccionada,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocentesScreen(carrera: carreraConfig.toMap()),
      ),
    );
  }

  void _navigateToCarrerasGestion(
    BuildContext context,
    GestionViewModel viewModel,
  ) {
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
  }

  void _navigateToTurnos(BuildContext context, GestionViewModel viewModel) {
    final carreraConfig = viewModel.getCarreraConfig(
      viewModel.carreraSeleccionada,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TurnosScreen(
          tipo: 'Gestión',
          carrera: carreraConfig.toMap(),
        ),
      ),
    );
  }

  void _navigateToNiveles(BuildContext context, GestionViewModel viewModel) {
    final carreraConfig = viewModel.getCarreraConfig(
      viewModel.carreraSeleccionada,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NivelesScreen(
          tipo: 'Gestión',
          carrera: carreraConfig.toMap(),
          turno: {'id': '0', 'nombre': 'General'},
        ),
      ),
    );
  }

  void _navigateToParalelos(BuildContext context, GestionViewModel viewModel) {
    final carreraConfig = viewModel.getCarreraConfig(
      viewModel.carreraSeleccionada,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParalelosScreen(
          tipo: 'Gestión',
          carrera: carreraConfig.toMap(),
          turno: {'id': '0', 'nombre': 'General'},
          nivel: {'id': '0', 'nombre': 'General'},
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.grey.shade100;
  }
}