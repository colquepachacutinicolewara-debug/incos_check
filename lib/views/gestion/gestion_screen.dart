import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';
import 'carreras_screen.dart';
import 'turnos_screen.dart'; // Asegúrate de importar TurnosScreen
import '../../views/gestion/programas/programas_screen.dart';

class GestionScreen extends StatefulWidget {
  const GestionScreen({super.key});

  @override
  State<GestionScreen> createState() => _GestionScreenState();
}

class _GestionScreenState extends State<GestionScreen> {
  String _carreraSeleccionada = 'Sistemas Informáticos';
  List<String> _carreras = ['Sistemas Informáticos'];

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

  // Método para actualizar carreras desde CarrerasScreen
  void _actualizarCarreras(List<String> nuevasCarreras) {
    // Usar post frame callback para evitar el error durante build
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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Selector de Carrera
          Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
              decoration: BoxDecoration(
                color: _getDropdownBackgroundColor(context),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: _getBorderColor(context)),
              ),
              child: DropdownButton<String>(
                value: _carreraSeleccionada,
                isExpanded: true,
                underline: SizedBox(),
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
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
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

          SizedBox(height: AppSpacing.medium),

          // Grid de opciones de gestión
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(AppSpacing.medium),
              childAspectRatio: 1.0,
              children: [
                _buildMenuCard(
                  context,
                  'Estudiantes',
                  Icons.people,
                  UserThemeColors.estudiante,
                  () => _navigateToEstudiantes(context), // ✅ DIRECTO A TURNOS
                ),
                _buildMenuCard(
                  context,
                  'Cursos',
                  Icons.book,
                  AppColors.success,
                  () => _navigateToCarreras(context, 'Cursos'), // ✅ A CARRERAS
                ),
                _buildMenuCard(
                  context,
                  'Carreras',
                  Icons.school,
                  AppColors.warning,
                  () =>
                      _navigateToCarrerasGestion(context), // ✅ GESTIÓN CARRERAS
                ),
                _buildMenuCard(
                  context,
                  'Docentes',
                  Icons.person,
                  UserThemeColors.docente,
                  () =>
                      _navigateToCarreras(context, 'Docentes'), // ✅ A CARRERAS
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
      margin: EdgeInsets.all(AppSpacing.small),
      color: _getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.small),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              SizedBox(height: AppSpacing.small),
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.small),
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

  // ✅ NUEVO MÉTODO: Estudiantes va DIRECTAMENTE a TurnosScreen
  void _navigateToEstudiantes(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Crear un objeto carrera con la carrera seleccionada
      Map<String, dynamic> carreraSeleccionadaObj;

      // Determinar color e icono según la carrera seleccionada
      if (_carreraSeleccionada == 'Sistemas Informáticos') {
        carreraSeleccionadaObj = {
          'id': 1,
          'nombre': _carreraSeleccionada,
          'color': '#1565C0',
          'icon': Icons.computer,
          'activa': true,
        };
      } else if (_carreraSeleccionada == 'Idioma Inglés') {
        carreraSeleccionadaObj = {
          'id': 2,
          'nombre': _carreraSeleccionada,
          'color': '#F44336',
          'icon': Icons.language,
          'activa': true,
        };
      } else {
        // Para cualquier otra carrera nueva
        carreraSeleccionadaObj = {
          'id': DateTime.now().millisecondsSinceEpoch,
          'nombre': _carreraSeleccionada,
          'color': '#9C27B0',
          'icon': Icons.school,
          'activa': true,
        };
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TurnosScreen(
            tipo: 'Estudiantes',
            carrera: carreraSeleccionadaObj,
          ),
        ),
      );
    });
  }

  // ✅ MÉTODO: Cursos y Docentes van a CarrerasScreen
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

  // ✅ MÉTODO: Gestión de Carreras
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

  void _navigateToProgramas(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProgramasScreen()),
      );
    });
  }
}
