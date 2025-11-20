import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/notas_viewmodel.dart';
import '../../models/nota_asistencia_model.dart';

class CalcularNotasScreen extends StatelessWidget {
  const CalcularNotasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotasViewModel(),
      child: const _CalcularNotasScreenContent(),
    );
  }
}

class _CalcularNotasScreenContent extends StatelessWidget {
  const _CalcularNotasScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotasViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Cálculo de Notas de Asistencia',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.isLoading ? null : viewModel.cargarNotas,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context, viewModel),
    );
  }

  Widget _buildContent(BuildContext context, NotasViewModel viewModel) {
    return Column(
      children: [
        // Estadísticas
        _buildEstadisticas(context, viewModel),
        
        // Controles de cálculo
        _buildControlesCalculo(context, viewModel),
        
        // Filtros
        _buildFiltros(context, viewModel),
        
        // Lista de notas
        Expanded(child: _buildListaNotas(context, viewModel)),
      ],
    );
  }

  Widget _buildEstadisticas(BuildContext context, NotasViewModel viewModel) {
    final stats = viewModel.obtenerEstadisticas();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total',
              stats['total'].toString(),
              Icons.people,
              Colors.blue,
            ),
            _buildStatItem(
              'Aprobados',
              stats['aprobados'].toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatItem(
              'Reprobados',
              stats['reprobados'].toString(),
              Icons.cancel,
              Colors.red,
            ),
            _buildStatItem(
              'Promedio',
              stats['promedio'].toStringAsFixed(1),
              Icons.assessment,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildControlesCalculo(BuildContext context, NotasViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Cálculo de Notas de Asistencia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: 'bim2_2024',
                    items: [
                      'bim1_2024', 
                      'bim2_2024', 
                      'bim3_2024', 
                      'bim4_2024'
                    ].map((bimestre) {
                      return DropdownMenuItem(
                        value: bimestre,
                        child: Text(_obtenerNombreBimestre(bimestre)),
                      );
                    }).toList(),
                    onChanged: viewModel.isLoading ? null : (value) {},
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar Bimestre',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: viewModel.isLoading 
                      ? null 
                      : () => _calcularNotasBimestre(context, viewModel, 'bim2_2024'),
                  icon: viewModel.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.calculate),
                  label: viewModel.isLoading 
                      ? const Text('Calculando...')
                      : const Text('Calcular Notas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Calcula las notas de asistencia para todos los estudiantes activos',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros(BuildContext context, NotasViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: viewModel.filtroBimestre,
              items: [
                'Todos', 
                'bim1_2024', 
                'bim2_2024', 
                'bim3_2024', 
                'bim4_2024'
              ].map((bimestre) {
                return DropdownMenuItem(
                  value: bimestre,
                  child: Text(
                    bimestre == 'Todos' 
                        ? 'Todos los bimestres' 
                        : _obtenerNombreBimestre(bimestre)
                  ),
                );
              }).toList(),
              onChanged: viewModel.isLoading 
                  ? null 
                  : (value) {
                      if (value != null) {
                        viewModel.cambiarFiltroBimestre(value);
                      }
                    },
              decoration: const InputDecoration(
                labelText: 'Filtrar por bimestre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.filter_list),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: viewModel.filtroEstado,
              items: [
                'Todos', 
                'PENDIENTE', 
                'CALCULADO', 
                'APROBADO', 
                'REPROBADO'
              ].map((estado) {
                return DropdownMenuItem(
                  value: estado,
                  child: Text(_obtenerNombreEstado(estado)),
                );
              }).toList(),
              onChanged: viewModel.isLoading 
                  ? null 
                  : (value) {
                      if (value != null) {
                        viewModel.cambiarFiltroEstado(value);
                      }
                    },
              decoration: const InputDecoration(
                labelText: 'Filtrar por estado',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaNotas(BuildContext context, NotasViewModel viewModel) {
    if (viewModel.notasFiltradas.isEmpty) {
      return _buildEmptyState(context, viewModel);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${viewModel.notasFiltradas.length} notas encontradas',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              if (viewModel.error != null)
                _buildErrorWidget(viewModel),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: viewModel.notasFiltradas.length,
            itemBuilder: (context, index) {
              final nota = viewModel.notasFiltradas[index];
              return _buildTarjetaNota(context, nota);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, NotasViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay notas de asistencia',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Presiona "Calcular Notas" para generar las notas de asistencia para el bimestre seleccionado',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _calcularNotasBimestre(context, viewModel, 'bim2_2024'),
            icon: const Icon(Icons.calculate),
            label: const Text('Calcular Notas Ahora'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaNota(BuildContext context, NotaAsistencia nota) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: nota.colorNota.withOpacity(0.1),
          child: Text(
            nota.notaDisplay,
            style: TextStyle(
              color: nota.colorNota,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          'Estudiante: ${nota.estudianteId}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Bimestre: ${_obtenerNombreBimestre(nota.bimestreId)}'),
            Text('Asistencia: ${nota.asistenciaDisplay} (${nota.porcentajeDisplay})'),
            Text('Estado: ${nota.estadoDisplay}'),
            if (nota.observaciones != null && nota.observaciones!.isNotEmpty)
              Text(
                'Observaciones: ${nota.observaciones}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Chip(
              label: Text(
                nota.estaAprobado ? 'APROBADO' : 'REPROBADO',
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: nota.colorEstado.withOpacity(0.1),
              labelStyle: TextStyle(
                color: nota.colorEstado,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Calculado: ${_formatearFecha(nota.fechaCalculo)}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(NotasViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
          const SizedBox(width: 4),
          Text(
            'Error',
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _obtenerNombreBimestre(String bimestreId) {
    switch (bimestreId) {
      case 'bim1_2024': return '1er Bimestre 2024';
      case 'bim2_2024': return '2do Bimestre 2024';
      case 'bim3_2024': return '3er Bimestre 2024';
      case 'bim4_2024': return '4to Bimestre 2024';
      default: return bimestreId;
    }
  }

  String _obtenerNombreEstado(String estado) {
    switch (estado) {
      case 'PENDIENTE': return 'Pendiente';
      case 'CALCULADO': return 'Calculado';
      case 'APROBADO': return 'Aprobado';
      case 'REPROBADO': return 'Reprobado';
      default: return estado;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  Future<void> _calcularNotasBimestre(BuildContext context, NotasViewModel viewModel, String bimestreId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calcular Notas de Asistencia'),
        content: Text(
          '¿Deseas calcular las notas de asistencia para ${_obtenerNombreBimestre(bimestreId)}?\n\n'
          'Esta acción calculará las notas para todos los estudiantes activos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Calcular',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await viewModel.calcularNotasBimestre(bimestreId);
      
      if (context.mounted) {
        if (viewModel.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Notas calculadas correctamente para ${_obtenerNombreBimestre(bimestreId)}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${viewModel.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }
}