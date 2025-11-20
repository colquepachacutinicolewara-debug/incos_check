import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/gestion_viewmodel.dart';
import 'carreras_screen.dart';
import 'turnos_screen.dart';
import '../../views/gestion/materias_screen.dart';
import 'docentes_screen.dart';
import 'niveles_screen.dart';
import '../gestion/paralelos_scren.dart';
import '../gestion/estudiantes_screen.dart';
import '../../views/horario/horarios_screen.dart';
import '../../views/horario/horario_main_screen.dart';

class GestionScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const GestionScreen({super.key, this.userData});

  @override
  State<GestionScreen> createState() => _GestionScreenState();
}

class _GestionScreenState extends State<GestionScreen> {
  bool _modoOscuro = false;

  // FUNCIONES DE COLOR MANUALES (igual que en CarreraContaduria)
  Color _getBackgroundColor() {
    return _modoOscuro ? Colors.grey.shade900 : Colors.grey.shade100;
  }

  Color _getCardColor() {
    return _modoOscuro ? Colors.grey.shade800 : Colors.white;
  }

  Color _getTextColor() {
    return _modoOscuro ? Colors.white : Colors.black;
  }

  Color _getSecondaryTextColor() {
    return _modoOscuro ? Colors.white70 : Colors.black87;
  }

  Color _getDropdownBackgroundColor() {
    return _modoOscuro ? Colors.grey.shade800 : Colors.grey.shade50;
  }

  Color _getBorderColor() {
    return _modoOscuro ? Colors.grey.shade600 : Colors.grey.shade300;
  }

  Color _getErrorColor() {
    return _modoOscuro ? Colors.red.shade400 : AppColors.error;
  }

  // Switch para cambiar entre modo claro y oscuro
  Widget _buildThemeSwitch() {
    return Switch(
      value: _modoOscuro,
      onChanged: (value) {
        setState(() {
          _modoOscuro = value;
        });
      },
      activeThumbColor: AppColors.secondary,
    );
  }

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
        backgroundColor: _getBackgroundColor(),
        appBar: AppBar(
          title: Text(
            'Gestión Académica',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.secondary,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Row(
              children: [
                Icon(
                  _modoOscuro ? Icons.nightlight_round : Icons.wb_sunny,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                _buildThemeSwitch(),
              ],
            ),
          ],
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.secondary),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Cargando gestión académica...',
            style: TextStyle(color: _getTextColor()),
          ),
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
            Icon(Icons.error_outline, size: 64, color: _getErrorColor()),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Error al cargar',
              style: AppTextStyles.heading2.copyWith(color: _getTextColor()),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              viewModel.error,
              style: AppTextStyles.body.copyWith(color: _getSecondaryTextColor()),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton(
              onPressed: () => viewModel.refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
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
              color: _getDropdownBackgroundColor(),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: _getBorderColor()),
            ),
            child: _buildDropdownCarreras(viewModel),
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

        // Indicador de tema actual
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
          padding: const EdgeInsets.all(AppSpacing.small),
          decoration: BoxDecoration(
            color: _modoOscuro ? Colors.blue.shade800 : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _modoOscuro ? Icons.nightlight_round : Icons.wb_sunny,
                color: _modoOscuro ? Colors.white : Colors.blue.shade800,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                _modoOscuro ? 'Modo Oscuro' : 'Modo Claro',
                style: TextStyle(
                  color: _modoOscuro ? Colors.white : Colors.blue.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.medium),

        // Grid de opciones de gestión (8 CARDS - AGREGADO TERCER AÑO B)
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(AppSpacing.medium),
            childAspectRatio: 1.0,
            children: [
              _buildMenuCard(
                'Estudiantes',
                Icons.people,
                UserThemeColors.estudiante,
                viewModel.getEstudiantesCount(viewModel.carreraSeleccionada),
                () => _navigateToEstudiantes(context, viewModel),
              ),
              _buildMenuCard(
                'Cursos',
                Icons.book,
                AppColors.success,
                viewModel.getCursosCount(viewModel.carreraSeleccionada),
                () => _navigateToCursos(context),
              ),
              _buildMenuCard(
                'Carreras',
                Icons.school,
                AppColors.warning,
                viewModel.carreras.length,
                () => _navigateToCarrerasGestion(context, viewModel),
              ),
              _buildMenuCard(
                'Docentes',
                Icons.person,
                UserThemeColors.docente,
                viewModel.getDocentesCount(viewModel.carreraSeleccionada),
                () => _navigateToDocentes(context, viewModel),
              ),
              _buildMenuCard(
                'Turnos',
                Icons.schedule,
                Colors.orange,
                viewModel.getTurnosCount(viewModel.carreraSeleccionada),
                () => _navigateToTurnos(context, viewModel),
              ),
              _buildMenuCard(
                'Grados',
                Icons.layers,
                Colors.purple,
                viewModel.getNivelesCount(viewModel.carreraSeleccionada),
                () => _navigateToNiveles(context, viewModel),
              ),
              _buildMenuCard(
                'Paralelos',
                Icons.groups,
                Colors.teal,
                viewModel.getParalelosCount(viewModel.carreraSeleccionada),
                () => _navigateToParalelos(context, viewModel),
              ),
              // ✅ NUEVO CARD PARA TERCER AÑO B
              _buildMenuCard(
                'Horarios',
                Icons.calendar_today,
                const Color.fromARGB(255, 237, 106, 178),
                viewModel.getHorariosCount(),
                () => _navigateToHorariosMain(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownCarreras(GestionViewModel viewModel) {
    final carrerasUnicas = viewModel.carreras.toSet().toList();

    return Container(
      decoration: BoxDecoration(
        color: _getDropdownBackgroundColor(),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: viewModel.carreraSeleccionada,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: _getDropdownBackgroundColor(),
              style: TextStyle(color: _getTextColor(), fontSize: 16),
              items: carrerasUnicas.map((String carrera) {
                return DropdownMenuItem<String>(
                  value: carrera,
                  child: Text(
                    carrera,
                    style: TextStyle(color: _getTextColor()),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null && newValue != viewModel.carreraSeleccionada) {
                  viewModel.seleccionarCarrera(newValue);
                  
                  // Feedback visual
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cambiando a: $newValue'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
              icon: Icon(Icons.arrow_drop_down, color: _getTextColor()),
            ),
          ),
          if (viewModel.loading)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    String title,
    IconData icon,
    Color color,
    int count,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(AppSpacing.small),
      color: _getCardColor(),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 35, color: color),
                  ),
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
                          count > 99 ? '99+' : count.toString(),
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
                  color: _getTextColor(),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                _obtenerSubtituloCard(title),
                style: TextStyle(
                  color: _getSecondaryTextColor(),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _obtenerSubtituloCard(String titulo) {
    switch (titulo) {
      case 'Tercer Año B':
        return 'Horarios & Asistencia';
      case 'Estudiantes':
        return 'Gestión de alumnos';
      case 'Cursos':
        return 'Materias académicas';
      case 'Carreras':
        return 'Programas de estudio';
      case 'Docentes':
        return 'Personal docente';
      case 'Turnos':
        return 'Horarios de clases';
      case 'Grados':
        return 'Niveles académicos';
      case 'Paralelos':
        return 'Grupos de estudio';
      default:
        return 'Gestión';
    }
  }

  // ========== FUNCIONES DE NAVEGACIÓN ==========

  void _navigateToEstudiantes(BuildContext context, GestionViewModel viewModel) {
    final carreraConfig = viewModel.getCarreraConfig(viewModel.carreraSeleccionada);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EstudiantesListScreen(
          tipo: 'Gestión',
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
      MaterialPageRoute(builder: (context) => const MateriasScreen()),
    );
  }

  void _navigateToDocentes(BuildContext context, GestionViewModel viewModel) {
    final carreraConfig = viewModel.getCarreraConfig(viewModel.carreraSeleccionada);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocentesScreen(carrera: carreraConfig.toMap()),
      ),
    );
  }

  void _navigateToCarrerasGestion(BuildContext context, GestionViewModel viewModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarrerasScreen(
          tipo: 'Gestión',
          carreraSeleccionada: viewModel.carreraSeleccionada,
          onCarrerasActualizadas: (nuevasCarreras) async {
            // Actualizar el ViewModel con las nuevas carreras
            await viewModel.actualizarCarreras(nuevasCarreras);
            
            // Mostrar feedback al usuario
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Carreras actualizadas correctamente'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
        ),
      ),
    ).then((_) {
      // Cuando regresa de la pantalla de carreras, sincronizar
      if (mounted) {
        final viewModel = context.read<GestionViewModel>();
        viewModel.sincronizarCarreras();
      }
    });
  }

  void _navigateToTurnos(BuildContext context, GestionViewModel viewModel) {
    final carreraConfig = viewModel.getCarreraConfig(viewModel.carreraSeleccionada);
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
    final carreraConfig = viewModel.getCarreraConfig(viewModel.carreraSeleccionada);
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
    final carreraConfig = viewModel.getCarreraConfig(viewModel.carreraSeleccionada);
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

  // ✅ NUEVA FUNCIÓN DE NAVEGACIÓN PARA TERCER AÑO B
  void _navigateToHorariosMain(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => HorariosMainScreen()),
  );
}
}