import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';
import 'carreras_screen.dart';
import 'turnos_screen.dart';
import '../../views/gestion/materias_screen.dart'; // Importar MateriasScreen directamente
import '../../views/gestion/programas/programas_screen.dart';

class GestionScreen extends StatefulWidget {
  const GestionScreen({super.key});

  @override
  State<GestionScreen> createState() => _GestionScreenState();
}

class _GestionScreenState extends State<GestionScreen> {
  String _carreraSeleccionada = 'Sistemas Informáticos';
  List<String> _carreras = ['Sistemas Informáticos'];

  // Constantes para strings
  static const _kCarreraDefault = 'Sistemas Informáticos';
  static const _kCarreraIdiomas = 'Idioma Inglés';

  // Configuración de carreras predefinidas
  final Map<String, Map<String, dynamic>> _carrerasConfig = {
    'Sistemas Informáticos': {
      'id': 1,
      'nombre': 'Sistemas Informáticos',
      'color': '#1565C0',
      'icon': Icons.computer,
      'activa': true,
    },
    'Idioma Inglés': {
      'id': 2,
      'nombre': 'Idioma Inglés',
      'color': '#F44336',
      'icon': Icons.language,
      'activa': true,
    },
  };

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

  Color _getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color _getDropdownBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  // Método para obtener configuración de carrera
  Map<String, dynamic> _getCarreraConfig(String carrera) {
    return _carrerasConfig[carrera] ??
        {
          'id': DateTime.now().millisecondsSinceEpoch,
          'nombre': carrera,
          'color': '#9C27B0',
          'icon': Icons.school,
          'activa': true,
        };
  }

  // Método para actualizar carreras desde CarrerasScreen
  void _actualizarCarreras(List<String> nuevasCarreras) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _carreras = nuevasCarreras;
        if (!_carreras.contains(_carreraSeleccionada) && _carreras.isNotEmpty) {
          _carreraSeleccionada = _carreras.first;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Gestión Académica',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Selector de Carrera
          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
              ),
              decoration: BoxDecoration(
                color: _getDropdownBackgroundColor(context),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: _getBorderColor(context)),
              ),
              child: DropdownButton<String>(
                value: _carreraSeleccionada,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: _getDropdownBackgroundColor(context),
                items: _carreras.map((String carrera) {
                  return DropdownMenuItem<String>(
                    value: carrera,
                    child: Text(
                      carrera,
                      style: TextStyle(color: _getTextColor(context)),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _carreraSeleccionada = newValue!;
                  });
                },
              ),
            ),
          ),

          // Título de la carrera seleccionada
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Carrera: $_carreraSeleccionada',
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
                  'Estudiantes',
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
                  () => _navigateToCarrerasGestion(context),
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
      margin: const EdgeInsets.all(AppSpacing.small),
      color: _getCardColor(context),
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
                  color: _getTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                _carreraSeleccionada,
                style: TextStyle(
                  color: _getSecondaryTextColor(context),
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

  // Navegación a TurnosScreen para Estudiantes
  void _navigateToEstudiantes(BuildContext context) {
    final carreraConfig = _getCarreraConfig(_carreraSeleccionada);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TurnosScreen(tipo: 'Estudiantes', carrera: carreraConfig),
        ),
      );
    });
  }

  // Navegación DIRECTA a MateriasScreen para Cursos
  void _navigateToCursos(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MateriasScreen()),
      );
    });
  }

  // Navegación a CarrerasScreen para Cursos y Docentes
  void _navigateToCarreras(BuildContext context, String tipo) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CarrerasScreen(
            tipo: tipo,
            carreraSeleccionada: _carreraSeleccionada,
            onCarrerasActualizadas: _actualizarCarreras,
          ),
        ),
      );
    });
  }

  // Navegación a CarrerasScreen para Gestión
  void _navigateToCarrerasGestion(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CarrerasScreen(
            tipo: 'Gestión',
            carreraSeleccionada: _carreraSeleccionada,
            onCarrerasActualizadas: _actualizarCarreras,
          ),
        ),
      );
    });
  }

  // Navegación a ProgramasScreen
  void _navigateToProgramas(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProgramasScreen()),
      );
    });
  }
}
