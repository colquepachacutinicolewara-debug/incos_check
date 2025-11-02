import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/views/gestion/materias_screen.dart';
import 'package:incos_check/views/gestion/bimestres_screen.dart';
import 'package:incos_check/models/materia_model.dart';
import 'package:incos_check/viewmodels/materia_viewmodel.dart';

class HistorialAsistenciaScreen extends StatefulWidget {
  const HistorialAsistenciaScreen({super.key});

  @override
  State<HistorialAsistenciaScreen> createState() =>
      _HistorialAsistenciaScreenState();
}

class _HistorialAsistenciaScreenState extends State<HistorialAsistenciaScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MateriaViewModel(),
      child: Scaffold(
        backgroundColor: _getBackgroundColor(context),
        appBar: AppBar(
          title: Text(
            'Historial de Asistencia',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Consumer<MateriaViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Selector de Año
                Padding(
                  padding: EdgeInsets.all(AppSpacing.medium),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.medium,
                    ),
                    decoration: BoxDecoration(
                      color: _getDropdownBackgroundColor(context),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(color: _getBorderColor(context)),
                    ),
                    child: DropdownButton<int>(
                      value: viewModel.anioSeleccionado,
                      isExpanded: true,
                      underline: SizedBox(),
                      dropdownColor: _getDropdownBackgroundColor(context),
                      items: [
                        DropdownMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: Colors.yellow,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '🟡 PRIMER AÑO',
                                style: TextStyle(color: _getTextColor(context)),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.green, size: 16),
                              SizedBox(width: 8),
                              Text(
                                '🟢 SEGUNDO AÑO',
                                style: TextStyle(color: _getTextColor(context)),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.blue, size: 16),
                              SizedBox(width: 8),
                              Text(
                                '🔵 TERCER AÑO',
                                style: TextStyle(color: _getTextColor(context)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        viewModel.setAnioSeleccionado(value!);
                      },
                    ),
                  ),
                ),

                // Buscador
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                  child: TextField(
                    controller: viewModel.searchController,
                    style: TextStyle(color: _getTextColor(context)),
                    decoration: InputDecoration(
                      hintText: 'Buscar materia...',
                      hintStyle: TextStyle(
                        color: _getSecondaryTextColor(context),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: _getSecondaryTextColor(context),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      filled: true,
                      fillColor: _getSearchBackgroundColor(context),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.medium),

                // Título del año seleccionado
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      viewModel.anioSeleccionado == 1
                          ? '🟡 PRIMER AÑO'
                          : viewModel.anioSeleccionado == 2
                          ? '🟢 SEGUNDO AÑO'
                          : '🔵 TERCER AÑO',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: viewModel.anioSeleccionado == 1
                            ? Colors.orange
                            : viewModel.anioSeleccionado == 2
                            ? Colors.green
                            : Colors.blue,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.small),

                Expanded(
                  child:
                      viewModel.materiasFiltradas.isEmpty &&
                          viewModel.searchController.text.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: _getSecondaryTextColor(context),
                              ),
                              SizedBox(height: AppSpacing.medium),
                              Text(
                                'No se encontraron materias',
                                style: TextStyle(
                                  color: _getSecondaryTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.count(
                          crossAxisCount: 2,
                          padding: EdgeInsets.all(AppSpacing.medium),
                          childAspectRatio: 1.0,
                          children: [
                            // Mostrar materias filtradas por año
                            ...viewModel.materiasFiltradas
                                .map(
                                  (materia) => _buildMenuCard(
                                    context,
                                    materia.nombre,
                                    Icons.school,
                                    materia.color,
                                    () => _navigateToBimestres(
                                      context,
                                      materia.nombre,
                                    ),
                                  ),
                                )
                                .toList(),

                            // Card especial para "Todas las Materias" (gestión)
                            if (viewModel.searchController.text.isEmpty)
                              _buildMenuCard(
                                context,
                                'Todas las Materias',
                                Icons.list_alt,
                                AppColors.primary,
                                () => _navigateToMaterias(context),
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

  // Mantener las funciones de colores del tema aquí...
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

  Color _getSearchBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  Color _getDropdownBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.small),
                child: Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToBimestres(BuildContext context, String materia) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BimestresScreen(materiaSeleccionada: materia),
      ),
    );
  }

  void _navigateToMaterias(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MateriasScreen()),
    );
  }
}
