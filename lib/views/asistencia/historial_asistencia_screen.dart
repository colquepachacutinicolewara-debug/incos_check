import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/views/gestion/materias_screen.dart';
import 'package:incos_check/views/gestion/bimestres_screen.dart';
import 'package:incos_check/viewmodels/materia_viewmodel.dart';
import 'package:incos_check/models/materia_model.dart';

class HistorialAsistenciaScreen extends StatefulWidget {
  const HistorialAsistenciaScreen({super.key});

  @override
  State<HistorialAsistenciaScreen> createState() =>
      _HistorialAsistenciaScreenState();
}

class _HistorialAsistenciaScreenState extends State<HistorialAsistenciaScreen> {
  bool _mostrarTodasMaterias = false;

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
            // Obtener las materias según el filtro
            List<Materia> materiasMostrar;

            if (_mostrarTodasMaterias) {
              // Mostrar todas las materias sin filtrar
              materiasMostrar = viewModel.materias;
            } else {
              // Filtrar por año seleccionado
              materiasMostrar = viewModel.materias
                  .where(
                    (materia) => materia.anio == viewModel.anioSeleccionado,
                  )
                  .toList();
            }

            // Filtrar por búsqueda si hay texto
            final query = viewModel.searchController.text.toLowerCase();
            final materiasFiltradas = query.isEmpty
                ? materiasMostrar
                : materiasMostrar
                      .where(
                        (materia) =>
                            materia.nombre.toLowerCase().contains(query) ||
                            materia.codigo.toLowerCase().contains(query) ||
                            materia.carrera.toLowerCase().contains(query),
                      )
                      .toList();

            return Column(
              children: [
                // Filtros
                Container(
                  padding: const EdgeInsets.all(16),
                  color: _getFilterBackgroundColor(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtrar cursos:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Botón para Todas las Materias
                      Container(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Icon(
                            _mostrarTodasMaterias
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: _mostrarTodasMaterias
                                ? AppColors.primary
                                : _getSecondaryTextColor(context),
                          ),
                          label: Text(
                            'Mostrar todas las materias',
                            style: TextStyle(
                              color: _mostrarTodasMaterias
                                  ? AppColors.primary
                                  : _getTextColor(context),
                              fontWeight: _mostrarTodasMaterias
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _mostrarTodasMaterias
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.transparent,
                            side: BorderSide(
                              color: _mostrarTodasMaterias
                                  ? AppColors.primary
                                  : _getBorderColor(context),
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () {
                            setState(() {
                              _mostrarTodasMaterias = !_mostrarTodasMaterias;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Selector de Año (solo visible cuando no se muestran todas las materias)
                      if (!_mostrarTodasMaterias) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nivel:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getSecondaryTextColor(context),
                                    ),
                                  ),
                                  DropdownButton<int>(
                                    value: viewModel.anioSeleccionado,
                                    isExpanded: true,
                                    underline: SizedBox(),
                                    dropdownColor: _getDropdownBackgroundColor(
                                      context,
                                    ),
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
                                              style: TextStyle(
                                                color: _getTextColor(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 2,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              color: Colors.green,
                                              size: 16,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '🟢 SEGUNDO AÑO',
                                              style: TextStyle(
                                                color: _getTextColor(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 3,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              color: Colors.blue,
                                              size: 16,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '🔵 TERCER AÑO',
                                              style: TextStyle(
                                                color: _getTextColor(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      viewModel.setAnioSeleccionado(value!);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Buscador
                      TextField(
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
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                            borderSide: BorderSide(
                              color: _getBorderColor(context),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                            borderSide: BorderSide(
                              color: _getBorderColor(context),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          filled: true,
                          fillColor: _getSearchBackgroundColor(context),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),

                      // Información del filtro aplicado
                      if (_mostrarTodasMaterias || query.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_alt,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _obtenerTextoFiltros(
                                    _mostrarTodasMaterias,
                                    query,
                                    viewModel.anioSeleccionado,
                                  ),
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Título de la sección
                if (!_mostrarTodasMaterias)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.medium,
                      vertical: AppSpacing.small,
                    ),
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

                // Lista de materias
                Expanded(
                  child: materiasFiltradas.isEmpty
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
                      : ListView.builder(
                          itemCount: materiasFiltradas.length,
                          padding: EdgeInsets.all(AppSpacing.medium),
                          itemBuilder: (context, index) {
                            final materia = materiasFiltradas[index];
                            return _buildMateriaCard(
                              materia,
                              context,
                              viewModel,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _obtenerTextoFiltros(
    bool mostrarTodas,
    String query,
    int anioSeleccionado,
  ) {
    List<String> filtros = [];

    if (mostrarTodas) {
      filtros.add('Todas las materias');
    } else {
      filtros.add('${anioSeleccionado}° Año');
    }

    if (query.isNotEmpty) {
      filtros.add('Búsqueda: "$query"');
    }

    return 'Filtros: ${filtros.join(' • ')}';
  }

  Widget _buildMateriaCard(
    Materia materia,
    BuildContext context,
    MateriaViewModel viewModel,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      color: _getCardColor(context),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: materia.color,
          child: Icon(
            viewModel.obtenerIconoMateria(materia.nombre),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          materia.nombre,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: _getTextColor(context),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Código: ${materia.codigo}',
              style: TextStyle(color: _getSecondaryTextColor(context)),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _buildInfoChip(
                  materia.anioDisplay,
                  Icons.grade,
                  viewModel.getColorAnio(materia.anio),
                  context,
                ),
                _buildInfoChip(
                  materia.carrera,
                  Icons.school,
                  Colors.purple,
                  context,
                ),
              ],
            ),
          ],
        ),
        onTap: () => _navigateToBimestres(context, materia.nombre),
      ),
    );
  }

  Widget _buildInfoChip(
    String text,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Funciones para colores del tema
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

  Color _getFilterBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  Color _getSearchBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color _getDropdownBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
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
