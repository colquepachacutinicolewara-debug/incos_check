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
      backgroundColor: viewModel.getBackgroundColor(context),
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
            onPressed: viewModel.cargarNotas,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Controles de cálculo
                _buildControlesCalculo(context, viewModel),
                
                // Filtros
                _buildFiltros(context, viewModel),
                
                // Lista de notas
                _buildListaNotas(context, viewModel),
              ],
            ),
    );
  }

  Widget _buildControlesCalculo(BuildContext context, NotasViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Cálculo Automático de Notas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: 'bim2_2024', // Valor por defecto
                    items: ['bim1_2024', 'bim2_2024', 'bim3_2024', 'bim4_2024'].map((bimestre) {
                      return DropdownMenuItem(
                        value: bimestre,
                        child: Text(_obtenerNombreBimestre(bimestre)),
                      );
                    }).toList(),
                    onChanged: (value) {},
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar Bimestre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _calcularNotasBimestre(context, viewModel),
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calcular'),
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
              'Calcula las notas de asistencia para todos los estudiantes',
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: viewModel.filtroBimestre,
              items: ['Todos', 'bim1_2024', 'bim2_2024', 'bim3_2024', 'bim4_2024'].map((bimestre) {
                return DropdownMenuItem(
                  value: bimestre,
                  child: Text(bimestre == 'Todos' ? 'Todos los bimestres' : _obtenerNombreBimestre(bimestre)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.cambiarFiltroBimestre(value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Filtrar por bimestre',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: viewModel.filtroEstado,
              items: ['Todos', 'APROBADO', 'REPROBADO', 'PENDIENTE'].map((estado) {
                return DropdownMenuItem(
                  value: estado,
                  child: Text(_obtenerNombreEstado(estado)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.cambiarFiltroEstado(value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Filtrar por estado',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaNotas(BuildContext context, NotasViewModel viewModel) {
    if (viewModel.notasFiltradas.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'No hay notas calculadas',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Presiona "Calcular" para generar las notas de asistencia',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: viewModel.notasFiltradas.length,
        itemBuilder: (context, index) {
          final nota = viewModel.notasFiltradas[index];
          return _buildTarjetaNota(context, nota);
        },
      ),
    );
  }

  Widget _buildTarjetaNota(BuildContext context, NotaAsistencia nota) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          'Estudiante ID: ${nota.estudianteId}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bimestre: ${_obtenerNombreBimestre(nota.bimestreId)}'),
            Text('Asistencia: ${nota.porcentajeDisplay}'),
            Text('Estado: ${nota.estadoDisplay}'),
          ],
        ),
        trailing: Chip(
          label: Text(nota.estaAprobado ? 'APROBADO' : 'REPROBADO'),
          backgroundColor: nota.colorEstado.withOpacity(0.1),
          labelStyle: TextStyle(
            color: nota.colorEstado,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      case 'APROBADO': return 'Aprobado';
      case 'REPROBADO': return 'Reprobado';
      case 'PENDIENTE': return 'Pendiente';
      default: return estado;
    }
  }

  Future<void> _calcularNotasBimestre(BuildContext context, NotasViewModel viewModel) async {
    final bimestreId = 'bim2_2024'; // Por defecto segundo bimestre
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calcular Notas'),
        content: Text(
          '¿Calcular notas de asistencia para ${_obtenerNombreBimestre(bimestreId)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await viewModel.calcularNotasBimestre(bimestreId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notas calculadas correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Calcular'),
          ),
        ],
      ),
    );
  }
}