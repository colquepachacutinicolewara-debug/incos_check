//lib/views/horarios/horarios_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/horario_viewmodel.dart';
import '../../models/horario_clase_model.dart';
import 'agregar_horario_screen.dart';
import 'editar_horario_screen.dart';

class HorariosScreen extends StatelessWidget {
  const HorariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HorarioViewModel(),
      child: const _HorariosScreenContent(),
    );
  }
}

class _HorariosScreenContent extends StatelessWidget {
  const _HorariosScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HorarioViewModel>();

    return Scaffold(
      backgroundColor: viewModel.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Gestión de Horarios',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navegarAAgregarHorario(context),
            tooltip: 'Agregar Horario',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.cargarHorarios,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtros
                _buildFiltros(context, viewModel),
                
                // Lista de horarios
                _buildListaHorarios(context, viewModel),
              ],
            ),
    );
  }

  Widget _buildFiltros(BuildContext context, HorarioViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: viewModel.filtroDia,
                    items: ['Todos', ...viewModel.diasSemana].map((dia) {
                      return DropdownMenuItem(
                        value: dia,
                        child: Text(dia),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        viewModel.cambiarFiltroDia(value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por día',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: viewModel.filtroPeriodo,
                    items: ['Todos', '1', '2', '3'].map((periodo) {
                      return DropdownMenuItem(
                        value: periodo,
                        child: Text('Período $periodo'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        viewModel.cambiarFiltroPeriodo(value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por período',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${viewModel.horariosFiltrados.length} horarios encontrados',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaHorarios(BuildContext context, HorarioViewModel viewModel) {
    if (viewModel.horariosFiltrados.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'No hay horarios registrados',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Presiona el botón + para agregar un horario',
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
        itemCount: viewModel.horariosFiltrados.length,
        itemBuilder: (context, index) {
          final horario = viewModel.horariosFiltrados[index];
          return _buildTarjetaHorario(context, viewModel, horario);
        },
      ),
    );
  }

  Widget _buildTarjetaHorario(
    BuildContext context, 
    HorarioViewModel viewModel, 
    HorarioClase horario
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: horario.colorPeriodo.withOpacity(0.1),
          child: Icon(
            Icons.schedule,
            color: horario.colorPeriodo,
          ),
        ),
        title: Text(
          '${horario.diaSemana} - ${horario.periodoDisplay}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Horario: ${horario.horarioCompleto}'),
            Text('Paralelo: ${horario.paraleloId}'),
            Text('Materia ID: ${horario.materiaId}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _navegarAEditarHorario(context, horario),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _mostrarDialogoEliminar(context, viewModel, horario),
              tooltip: 'Eliminar',
            ),
          ],
        ),
        onTap: () => _mostrarDetallesHorario(context, horario),
      ),
    );
  }

  void _navegarAAgregarHorario(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarHorarioScreen()),
    );
  }

  void _navegarAEditarHorario(BuildContext context, HorarioClase horario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarHorarioScreen(horario: horario),
      ),
    );
  }

  void _mostrarDetallesHorario(BuildContext context, HorarioClase horario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del Horario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetalleItem('Día', horario.diaSemana),
            _buildDetalleItem('Período', horario.periodoDisplay),
            _buildDetalleItem('Horario', horario.horarioCompleto),
            _buildDetalleItem('Materia ID', horario.materiaId),
            _buildDetalleItem('Paralelo ID', horario.paraleloId),
            _buildDetalleItem('Docente ID', horario.docenteId),
            _buildDetalleItem('Estado', horario.activo ? 'Activo' : 'Inactivo'),
          ],
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

  Widget _buildDetalleItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$titulo: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminar(
    BuildContext context, 
    HorarioViewModel viewModel, 
    HorarioClase horario
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Horario'),
        content: Text(
          '¿Estás seguro de eliminar el horario de ${horario.diaSemana} - ${horario.periodoDisplay}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final resultado = await viewModel.eliminarHorario(horario.id);
              if (resultado && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Horario eliminado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${viewModel.error}'),
                    backgroundColor: Colors.red,
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
}