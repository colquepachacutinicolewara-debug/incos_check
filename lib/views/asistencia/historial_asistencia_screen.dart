import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/views/gestion/bimestres_screen.dart';
import '../../viewmodels/historial_asitencia_viewmodel.dart';
import 'package:incos_check/viewmodels/materia_viewmodel.dart';
import 'package:incos_check/models/materia_model.dart';

class HistorialAsistenciaScreen extends StatefulWidget {
  const HistorialAsistenciaScreen({super.key});

  @override
  State<HistorialAsistenciaScreen> createState() => _HistorialAsistenciaScreenState();
}

class _HistorialAsistenciaScreenState extends State<HistorialAsistenciaScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final historialViewModel = context.read<HistorialAsistenciaViewModel>();
    historialViewModel.setQueryBusqueda(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MateriaViewModel()),
        ChangeNotifierProvider(create: (context) => HistorialAsistenciaViewModel()),
      ],
      child: Scaffold(
        backgroundColor: _getBackgroundColor(context),
        appBar: AppBar(
          title: Text(
            'Historial de Asistencia',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final materiaViewModel = context.read<MateriaViewModel>();
                materiaViewModel.recargarMaterias(); // ✅ CORREGIDO
              },
              tooltip: 'Recargar materias',
            ),
          ],
        ),
        body: Consumer2<MateriaViewModel, HistorialAsistenciaViewModel>(
          builder: (context, materiaViewModel, historialViewModel, child) {
            if (materiaViewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return _buildContent(context, materiaViewModel, historialViewModel);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MateriaViewModel materiaViewModel,
    HistorialAsistenciaViewModel historialViewModel,
  ) {
    // Obtener materias filtradas usando TU MateriaViewModel
    final materiasFiltradas = _obtenerMateriasFiltradas(materiaViewModel, historialViewModel);

    return Column(
      children: [
        // Sección de Filtros
        _buildFiltrosSection(context, materiaViewModel, historialViewModel),
        
        // Título del Año (si aplica)
        if (!historialViewModel.mostrarTodasMaterias) 
          _buildAnioTitle(materiaViewModel.anioSeleccionado),
        
        // Lista de Materias
        _buildMateriasList(context, materiasFiltradas, materiaViewModel, historialViewModel),
      ],
    );
  }

  List<Materia> _obtenerMateriasFiltradas(
    MateriaViewModel materiaViewModel,
    HistorialAsistenciaViewModel historialViewModel,
  ) {
    List<Materia> materiasBase;

    if (historialViewModel.mostrarTodasMaterias) {
      // Mostrar todas las materias de tu MateriaViewModel
      materiasBase = materiaViewModel.materias;
    } else {
      // Filtrar por año seleccionado usando TU MateriaViewModel
      materiasBase = materiaViewModel.materias
          .where((materia) => materia.anio == materiaViewModel.anioSeleccionado)
          .toList();
    }

    // Aplicar filtro de búsqueda
    final query = historialViewModel.queryBusqueda.toLowerCase();
    if (query.isEmpty) return materiasBase;

    return materiasBase.where((materia) =>
      materia.nombre.toLowerCase().contains(query) ||
      materia.codigo.toLowerCase().contains(query) ||
      materia.carrera.toLowerCase().contains(query),
    ).toList();
  }

  Widget _buildFiltrosSection(
    BuildContext context,
    MateriaViewModel materiaViewModel,
    HistorialAsistenciaViewModel historialViewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: historialViewModel.getFilterBackgroundColor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar cursos:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: historialViewModel.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),

          // Botón para Todas las Materias
          _buildToggleTodasMaterias(context, historialViewModel),
          const SizedBox(height: 12),

          // Selector de Año (condicional)
          if (!historialViewModel.mostrarTodasMaterias)
            _buildAnioSelector(context, materiaViewModel, historialViewModel),

          // Buscador
          _buildSearchField(context, historialViewModel),

          // Indicador de Filtros Activos
          if (historialViewModel.filtro.filtroActivo)
            _buildFiltrosActivosIndicator(context, materiaViewModel, historialViewModel),
        ],
      ),
    );
  }

  Widget _buildToggleTodasMaterias(
    BuildContext context, 
    HistorialAsistenciaViewModel historialViewModel,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(
          historialViewModel.mostrarTodasMaterias
              ? Icons.check_box
              : Icons.check_box_outline_blank,
          color: historialViewModel.mostrarTodasMaterias
              ? AppColors.primary
              : historialViewModel.getSecondaryTextColor(context),
        ),
        label: Text(
          'Mostrar todas las materias',
          style: TextStyle(
            color: historialViewModel.mostrarTodasMaterias
                ? AppColors.primary
                : historialViewModel.getTextColor(context),
            fontWeight: historialViewModel.mostrarTodasMaterias
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: historialViewModel.mostrarTodasMaterias
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          side: BorderSide(
            color: historialViewModel.mostrarTodasMaterias
                ? AppColors.primary
                : historialViewModel.getBorderColor(context),
          ),
          alignment: Alignment.centerLeft,
        ),
        onPressed: () {
          historialViewModel.toggleMostrarTodasMaterias();
        },
      ),
    );
  }

  Widget _buildAnioSelector(
    BuildContext context,
    MateriaViewModel materiaViewModel,
    HistorialAsistenciaViewModel historialViewModel,
  ) {
    return Column(
      children: [
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
                      color: historialViewModel.getSecondaryTextColor(context),
                    ),
                  ),
                  DropdownButton<int>(
                    value: materiaViewModel.anioSeleccionado,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: historialViewModel.getDropdownBackgroundColor(context),
                    items: _buildAnioDropdownItems(historialViewModel),
                    onChanged: (value) {
                      if (value != null) {
                        materiaViewModel.setAnioSeleccionado(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  List<DropdownMenuItem<int>> _buildAnioDropdownItems(
    HistorialAsistenciaViewModel historialViewModel,
  ) {
    return [
      DropdownMenuItem(
        value: 1,
        child: Row(
          children: [
            const Icon(Icons.circle, color: Colors.yellow, size: 16),
            const SizedBox(width: 8),
            Text(
              'PRIMER AÑO',
              style: TextStyle(color: historialViewModel.getTextColor(context)),
            ),
          ],
        ),
      ),
      DropdownMenuItem(
        value: 2,
        child: Row(
          children: [
            const Icon(Icons.circle, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            Text(
              'SEGUNDO AÑO',
              style: TextStyle(color: historialViewModel.getTextColor(context)),
            ),
          ],
        ),
      ),
      DropdownMenuItem(
        value: 3,
        child: Row(
          children: [
            const Icon(Icons.circle, color: Colors.blue, size: 16),
            const SizedBox(width: 8),
            Text(
              'TERCER AÑO',
              style: TextStyle(color: historialViewModel.getTextColor(context)),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildSearchField(
    BuildContext context, 
    HistorialAsistenciaViewModel historialViewModel,
  ) {
    return TextField(
      controller: _searchController,
      style: TextStyle(color: historialViewModel.getTextColor(context)),
      decoration: InputDecoration(
        hintText: 'Buscar materia...',
        hintStyle: TextStyle(
          color: historialViewModel.getSecondaryTextColor(context),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: historialViewModel.getSecondaryTextColor(context),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: historialViewModel.getBorderColor(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: historialViewModel.getBorderColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: historialViewModel.getSearchBackgroundColor(context),
      ),
    );
  }

  Widget _buildFiltrosActivosIndicator(
    BuildContext context,
    MateriaViewModel materiaViewModel,
    HistorialAsistenciaViewModel historialViewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_alt, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              historialViewModel.obtenerTextoFiltros(materiaViewModel.anioSeleccionado),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.clear, color: AppColors.primary, size: 16),
            onPressed: () {
              historialViewModel.limpiarFiltros();
              _searchController.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnioTitle(int anioSeleccionado) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          anioSeleccionado == 1 ? '🟡 PRIMER AÑO' :
          anioSeleccionado == 2 ? '🟢 SEGUNDO AÑO' : '🔵 TERCER AÑO',
          style: AppTextStyles.heading3.copyWith(
            fontWeight: FontWeight.bold,
            color: anioSeleccionado == 1 ? Colors.orange :
                   anioSeleccionado == 2 ? Colors.green : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildMateriasList(
    BuildContext context,
    List<Materia> materias,
    MateriaViewModel materiaViewModel,
    HistorialAsistenciaViewModel historialViewModel,
  ) {
    if (materias.isEmpty) {
      return _buildEmptyState(historialViewModel);
    }

    return Expanded(
      child: ListView.builder(
        itemCount: materias.length,
        padding: EdgeInsets.all(AppSpacing.medium),
        itemBuilder: (context, index) {
          final materia = materias[index];
          return _buildMateriaCard(materia, context, materiaViewModel, historialViewModel);
        },
      ),
    );
  }

  Widget _buildEmptyState(HistorialAsistenciaViewModel historialViewModel) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: historialViewModel.getSecondaryTextColor(context),
            ),
            SizedBox(height: AppSpacing.medium),
            Text(
              'No se encontraron materias',
              style: TextStyle(
                color: historialViewModel.getSecondaryTextColor(context),
              ),
            ),
            SizedBox(height: AppSpacing.small),
            Text(
              'Ajusta los filtros o recarga los datos',
              style: TextStyle(
                color: historialViewModel.getSecondaryTextColor(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMateriaCard(
    Materia materia,
    BuildContext context,
    MateriaViewModel materiaViewModel,
    HistorialAsistenciaViewModel historialViewModel,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      color: historialViewModel.getCardColor(context),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: materia.color,
          child: Icon(
            materiaViewModel.obtenerIconoMateria(materia.nombre),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          materia.nombre,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: historialViewModel.getTextColor(context),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Código: ${materia.codigo}',
              style: TextStyle(color: historialViewModel.getSecondaryTextColor(context)),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _buildInfoChip(
                  materia.anioDisplay,
                  Icons.grade,
                  materiaViewModel.getColorAnio(materia.anio),
                  context,
                ),
                _buildInfoChip(
                  materia.carrera,
                  Icons.school,
                  Colors.purple,
                  context,
                ),
                if (materia.paralelo.isNotEmpty)
                  _buildInfoChip(
                    'Paralelo ${materia.paralelo}',
                    Icons.groups,
                    materiaViewModel.getColorParalelo(materia.paralelo),
                    context,
                  ),
                if (materia.turno.isNotEmpty)
                  _buildInfoChip(
                    materia.turno,
                    materiaViewModel.obtenerIconoTurno(materia.turno),
                    materia.turno.toLowerCase().contains('mañana') ? Colors.amber : Colors.blue,
                    context,
                  ),
              ],
            ),
          ],
        ),
        onTap: () => _navigateToBimestres(context, materia),
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

  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : AppColors.background;
  }

  void _navigateToBimestres(BuildContext context, Materia materia) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BimestresScreen(materiaSeleccionada: materia.nombre), // ✅ CORREGIDO
      ),
    );
  }
}