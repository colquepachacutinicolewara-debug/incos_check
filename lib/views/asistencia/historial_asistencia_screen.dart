// views/historial/historial_asistencia_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/historial_asitencia_viewmodel.dart';
import '../../models/historial_asistencia_model.dart';
import '../../utils/constants.dart';

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
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final viewModel = context.read<HistorialAsistenciaViewModel>();
    viewModel.setQueryBusqueda(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Historial de Consultas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              final viewModel = context.read<HistorialAsistenciaViewModel>();
              if (value == 'clear_all') {
                _showClearAllDialog(viewModel);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Limpiar Todo'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<HistorialAsistenciaViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando historial...',
                    style: TextStyle(
                      color: _getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${viewModel.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.reintentarCarga,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filtros
              Container(
                padding: const EdgeInsets.all(16),
                color: viewModel.getFilterBackgroundColor(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtrar consultas:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: viewModel.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Botón para Todas las Materias
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Icon(
                          viewModel.mostrarTodasMaterias
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: viewModel.mostrarTodasMaterias
                              ? AppColors.primary
                              : viewModel.getSecondaryTextColor(context),
                        ),
                        label: Text(
                          'Mostrar todas las materias',
                          style: TextStyle(
                            color: viewModel.mostrarTodasMaterias
                                ? AppColors.primary
                                : viewModel.getTextColor(context),
                            fontWeight: viewModel.mostrarTodasMaterias
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: viewModel.mostrarTodasMaterias
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                          side: BorderSide(
                            color: viewModel.mostrarTodasMaterias
                                ? AppColors.primary
                                : viewModel.getBorderColor(context),
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: viewModel.toggleMostrarTodasMaterias,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Buscador
                    TextField(
                      controller: _searchController,
                      style: TextStyle(color: viewModel.getTextColor(context)),
                      decoration: InputDecoration(
                        hintText: 'Buscar en consultas...',
                        hintStyle: TextStyle(
                          color: viewModel.getSecondaryTextColor(context),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: viewModel.getSecondaryTextColor(context),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  viewModel.setQueryBusqueda('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: viewModel.getBorderColor(context),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: viewModel.getBorderColor(context),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        filled: true,
                        fillColor: viewModel.getSearchBackgroundColor(context),
                      ),
                    ),

                    // Información del filtro aplicado
                    if (viewModel.filtro.filtroActivo)
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
                                _obtenerTextoFiltros(viewModel),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (viewModel.filtro.filtroActivo)
                              TextButton(
                                onPressed: viewModel.limpiarFiltros,
                                child: Text(
                                  'Limpiar',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Contador de resultados
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: viewModel.getFilterBackgroundColor(context),
                child: Row(
                  children: [
                    Text(
                      '${viewModel.registrosFiltrados.length} consulta${viewModel.registrosFiltrados.length != 1 ? 's' : ''} encontrada${viewModel.registrosFiltrados.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: viewModel.getSecondaryTextColor(context),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (viewModel.registrosFiltrados.length != viewModel.registros.length)
                      Text(
                        'de ${viewModel.registros.length} total',
                        style: TextStyle(
                          color: viewModel.getSecondaryTextColor(context),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              // Lista de consultas
              Expanded(
                child: viewModel.registrosFiltrados.isEmpty
                    ? _buildEmptyState(viewModel)
                    : ListView.builder(
                        itemCount: viewModel.registrosFiltrados.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final registro = viewModel.registrosFiltrados[index];
                          return _buildRegistroCard(registro, viewModel, context);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _agregarRegistroEjemplo(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Agregar registro de ejemplo',
      ),
    );
  }

  Widget _buildEmptyState(HistorialAsistenciaViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: viewModel.getSecondaryTextColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay consultas registradas',
            style: TextStyle(
              fontSize: 18,
              color: viewModel.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las consultas de asistencia aparecerán aquí',
            style: TextStyle(
              color: viewModel.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (viewModel.filtro.filtroActivo)
            ElevatedButton(
              onPressed: viewModel.limpiarFiltros,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Limpiar filtros'),
            ),
        ],
      ),
    );
  }

  Widget _buildRegistroCard(
    RegistroHistorial registro,
    HistorialAsistenciaViewModel viewModel,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: viewModel.getCardColor(context),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(
            Icons.history,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          'Estudiante: ${registro.estudianteId}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: viewModel.getTextColor(context),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Materia: ${registro.materiaId}',
              style: TextStyle(
                color: viewModel.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Periodo: ${registro.periodoId}',
              style: TextStyle(
                color: viewModel.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: viewModel.getSecondaryTextColor(context),
                ),
                const SizedBox(width: 4),
                Text(
                  registro.fechaConsultaFormateada,
                  style: TextStyle(
                    fontSize: 12,
                    color: viewModel.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
            if (registro.tieneFiltros) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  if (registro.filtroMostrarTodasMaterias)
                    _buildFiltroChip('Todas materias', Icons.filter_list, context),
                  if (registro.queryBusqueda?.isNotEmpty ?? false)
                    _buildFiltroChip(
                      'Busqueda: "${registro.queryBusqueda!}"',
                      Icons.search,
                      context,
                    ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: 20, color: _getSecondaryTextColor(context)),
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteDialog(registro, viewModel);
            } else if (value == 'view_details') {
              _showDetailsDialog(registro, context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view_details',
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text('Ver detalles'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  const SizedBox(width: 8),
                  const Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltroChip(String text, IconData icon, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _obtenerTextoFiltros(HistorialAsistenciaViewModel viewModel) {
    List<String> filtros = [];

    if (viewModel.mostrarTodasMaterias) {
      filtros.add('Todas las materias');
    }

    if (viewModel.queryBusqueda.isNotEmpty) {
      filtros.add('Búsqueda: "${viewModel.queryBusqueda}"');
    }

    return 'Filtros: ${filtros.join(' • ')}';
  }

  void _showDeleteDialog(RegistroHistorial registro, HistorialAsistenciaViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Consulta'),
        content: const Text('¿Estás seguro de que quieres eliminar esta consulta del historial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              viewModel.eliminarRegistro(registro.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(HistorialAsistenciaViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Todo el Historial'),
        content: const Text('¿Estás seguro de que quieres eliminar todas las consultas del historial? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              viewModel.limpiarTodoElHistorial();
              Navigator.pop(context);
            },
            child: const Text(
              'Limpiar Todo',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(RegistroHistorial registro, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de la Consulta'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('ID:', registro.id),
              _buildDetailItem('Estudiante ID:', registro.estudianteId),
              _buildDetailItem('Materia ID:', registro.materiaId),
              _buildDetailItem('Periodo ID:', registro.periodoId),
              _buildDetailItem('Fecha:', registro.fechaConsulta.toString()),
              _buildDetailItem('Mostrar todas materias:', registro.filtroMostrarTodasMaterias.toString()),
              if (registro.queryBusqueda != null)
                _buildDetailItem('Búsqueda:', registro.queryBusqueda!),
              if (registro.datosConsulta != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Datos de Consulta:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  registro.datosConsulta.toString(),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _agregarRegistroEjemplo(BuildContext context) {
    final viewModel = context.read<HistorialAsistenciaViewModel>();
    final registro = RegistroHistorial(
      id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
      estudianteId: 'est_${DateTime.now().millisecondsSinceEpoch % 1000}',
      materiaId: 'Matemáticas ${DateTime.now().millisecondsSinceEpoch % 5 + 1}',
      periodoId: 'periodo_2024',
      fechaConsulta: DateTime.now(),
      filtroMostrarTodasMaterias: false,
      queryBusqueda: 'ejemplo',
      datosConsulta: {
        'asistencias_totales': 45,
        'asistencias_presente': 40,
        'porcentaje': 88.9,
        'ultima_actualizacion': DateTime.now().toIso8601String(),
      },
    );
    
    viewModel.agregarRegistroHistorial(registro);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Registro de ejemplo agregado'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // Funciones para colores del tema
  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : const Color(0xFFF5F5F5);
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
}