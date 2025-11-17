import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/reporte_viewmodel.dart';
import '../../models/reporte_generado_model.dart';
import '../../utils/constants.dart';

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReportesViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Reportes Generados'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                Provider.of<ReportesViewModel>(context, listen: false).cargarReportes();
              },
            ),
          ],
        ),
        body: const _ReportesScreenBody(),
      ),
    );
  }
}

class _ReportesScreenBody extends StatelessWidget {
  const _ReportesScreenBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ReportesViewModel>(context);

    if (viewModel.isLoading && viewModel.reportes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.error != null && viewModel.reportes.isEmpty) {
      return _buildErrorView(viewModel, context);
    }

    return Column(
      children: [
        // Filtros
        _buildFiltros(viewModel),
        
        // Estadísticas
        _buildEstadisticas(viewModel),
        
        // Lista de reportes
        Expanded(
          child: _buildListaReportes(viewModel, context),
        ),
      ],
    );
  }

  Widget _buildFiltros(ReportesViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filtro por tipo
            Row(
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 8),
                const Text('Tipo:'),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: viewModel.filtroTipo,
                    isExpanded: true,
                    items: ['Todos', 'ASISTENCIA_BIMESTRAL', 'ASISTENCIA_ESTADISTICAS']
                        .map((tipo) => DropdownMenuItem(
                              value: tipo,
                              child: Text(_formatearTipo(tipo)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        viewModel.cambiarFiltroTipo(value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Filtro por formato
            Row(
              children: [
                const Icon(Icons.format_shapes, size: 20),
                const SizedBox(width: 8),
                const Text('Formato:'),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: viewModel.filtroFormato,
                    isExpanded: true,
                    items: ['Todos', 'PDF', 'EXCEL']
                        .map((formato) => DropdownMenuItem(
                              value: formato,
                              child: Text(formato),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        viewModel.cambiarFiltroFormato(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticas(ReportesViewModel viewModel) {
    final stats = viewModel.obtenerEstadisticasReportes();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total',
            stats['total'].toString(),
            Icons.description,
          ),
          _buildStatItem(
            'PDF',
            stats['pdf'].toString(),
            Icons.picture_as_pdf,
          ),
          _buildStatItem(
            'Excel',
            stats['excel'].toString(),
            Icons.table_chart,
          ),
          _buildStatItem(
            'Esta semana',
            stats['ultima_semana'].toString(),
            Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildListaReportes(ReportesViewModel viewModel, BuildContext context) {
    final reportes = viewModel.reportesFiltrados;

    if (reportes.isEmpty) {
      return _buildEmptyState(viewModel);
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.cargarReportes(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reportes.length,
        itemBuilder: (context, index) {
          final reporte = reportes[index];
          return _buildReporteCard(reporte, viewModel, context);
        },
      ),
    );
  }

  Widget _buildReporteCard(ReporteGenerado reporte, ReportesViewModel viewModel, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _buildIconoFormato(reporte.formato),
        title: Text(
          reporte.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${_formatearTipo(reporte.tipoReporte)}'),
            Text('Generado: ${_formatearFecha(reporte.fechaGeneracion)}'),
            if (reporte.usuarioGenerador != null)
              Text('Por: ${reporte.usuarioGenerador}'),
            if (reporte.tamanoBytes != null)
              Text('Tamaño: ${_formatearTamano(reporte.tamanoBytes!)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            _manejarAccionReporte(value, reporte, viewModel, context);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'descargar',
              child: Row(
                children: [
                  Icon(Icons.download, size: 20),
                  SizedBox(width: 8),
                  Text('Descargar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'compartir',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20),
                  SizedBox(width: 8),
                  Text('Compartir'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'eliminar',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          _mostrarDetallesReporte(reporte, context);
        },
      ),
    );
  }

  Widget _buildIconoFormato(String formato) {
    final icon = formato == 'PDF' ? Icons.picture_as_pdf : Icons.table_chart;
    final color = formato == 'PDF' ? Colors.red : Colors.green;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildEmptyState(ReportesViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay reportes generados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los reportes que generes aparecerán aquí',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: viewModel.cargarReportes,
            icon: const Icon(Icons.refresh),
            label: const Text('Recargar'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ReportesViewModel viewModel, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar reportes',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: viewModel.clearError,
                  child: const Text('Descartar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: viewModel.cargarReportes,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _manejarAccionReporte(String accion, ReporteGenerado reporte, 
      ReportesViewModel viewModel, BuildContext context) {
    switch (accion) {
      case 'descargar':
        _descargarReporte(reporte, context);
        break;
      case 'compartir':
        _compartirReporte(reporte, context);
        break;
      case 'eliminar':
        _eliminarReporte(reporte, viewModel, context);
        break;
    }
  }

  void _descargarReporte(ReporteGenerado reporte, BuildContext context) {
    // TODO: Implementar descarga real
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descargando ${reporte.titulo}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _compartirReporte(ReporteGenerado reporte, BuildContext context) {
    // TODO: Implementar compartir real
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartiendo ${reporte.titulo}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _eliminarReporte(ReporteGenerado reporte, ReportesViewModel viewModel, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Reporte'),
        content: Text('¿Estás seguro de eliminar el reporte "${reporte.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final resultado = await viewModel.eliminarReporte(reporte.id);
              
              if (resultado && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reporte eliminado correctamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${viewModel.error}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
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

  void _mostrarDetallesReporte(ReporteGenerado reporte, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reporte.titulo),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem('Tipo', _formatearTipo(reporte.tipoReporte)),
              _buildDetalleItem('Formato', reporte.formato),
              _buildDetalleItem('Fecha', _formatearFecha(reporte.fechaGeneracion)),
              if (reporte.usuarioGenerador != null)
                _buildDetalleItem('Generado por', reporte.usuarioGenerador!),
              if (reporte.tamanoBytes != null)
                _buildDetalleItem('Tamaño', _formatearTamano(reporte.tamanoBytes!)),
              if (reporte.periodoId != null)
                _buildDetalleItem('Período', reporte.periodoId!),
              if (reporte.materiaId != null)
                _buildDetalleItem('Materia', reporte.materiaId!),
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

  Widget _buildDetalleItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatearTipo(String tipo) {
    switch (tipo) {
      case 'ASISTENCIA_BIMESTRAL':
        return 'Asistencia Bimestral';
      case 'ASISTENCIA_ESTADISTICAS':
        return 'Estadísticas de Asistencia';
      default:
        return tipo;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  String _formatearTamano(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}