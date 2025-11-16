import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/config_viewmodel.dart';
import '../../models/config_notas_model.dart';

class ConfigNotasScreen extends StatelessWidget {
  const ConfigNotasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConfigViewModel(),
      child: const _ConfigNotasScreenContent(),
    );
  }
}

class _ConfigNotasScreenContent extends StatelessWidget {
  const _ConfigNotasScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ConfigViewModel>();

    return Scaffold(
      backgroundColor: viewModel.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Configuración de Notas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (viewModel.configuracionModificada)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _guardarConfiguracion(context, viewModel),
              tooltip: 'Guardar Cambios',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.cargarConfiguracion,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información general
                  _buildInfoConfiguracion(context, viewModel),
                  
                  // Configuración básica
                  _buildConfiguracionBasica(context, viewModel),
                  
                  // Reglas de cálculo
                  _buildReglasCalculo(context, viewModel),
                  
                  // Botones de acción
                  _buildBotonesAccion(context, viewModel),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoConfiguracion(BuildContext context, ConfigViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.settings,
              color: Colors.teal,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.configuracion.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Puntaje total: ${viewModel.configuracion.puntajeTotal} puntos'),
                  Text('Estado: ${viewModel.configuracion.activo ? 'Activo' : 'Inactivo'}'),
                  if (viewModel.configuracionModificada)
                    Text(
                      '⚠️ Tienes cambios sin guardar',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfiguracionBasica(BuildContext context, ConfigViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración Básica',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Nombre de la configuración
            TextFormField(
              initialValue: viewModel.configuracion.nombre,
              decoration: const InputDecoration(
                labelText: 'Nombre de la configuración',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                viewModel.actualizarNombre(value);
              },
            ),
            const SizedBox(height: 16),
            
            // Puntaje total
            DropdownButtonFormField<double>(
              value: viewModel.configuracion.puntajeTotal,
              items: viewModel.opcionesPuntajeTotal.map((puntaje) {
                return DropdownMenuItem(
                  value: double.parse(puntaje),
                  child: Text('$puntaje puntos'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.actualizarPuntajeTotal(value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Puntaje total',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReglasCalculo(BuildContext context, ConfigViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reglas de Cálculo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Mínimo aprobatorio
            DropdownButtonFormField<double>(
              value: viewModel.configuracion.minimoAprobatorio,
              items: viewModel.opcionesMinimoAprobatorio.map((minimo) {
                return DropdownMenuItem(
                  value: double.parse(minimo),
                  child: Text('$minimo puntos'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.actualizarRegla('minimo_aprobatorio', value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Mínimo aprobatorio',
                border: OutlineInputBorder(),
                helperText: 'Nota mínima para aprobar',
              ),
            ),
            const SizedBox(height: 16),
            
            // Retraso penaliza media hora
            SwitchListTile(
              title: const Text('Retraso penaliza media hora'),
              subtitle: const Text('Cada retraso cuenta como 0.5 horas de asistencia'),
              value: viewModel.configuracion.retrasoPenaliza,
              onChanged: (value) {
                viewModel.actualizarRegla('retraso_penaliza_media_hora', value);
              },
            ),
            
            // Cálculo automático
            SwitchListTile(
              title: const Text('Cálculo automático'),
              subtitle: const Text('Calcular notas automáticamente al final del bimestre'),
              value: viewModel.configuracion.calculoAutomatico,
              onChanged: (value) {
                viewModel.actualizarRegla('calculo_automatico', value);
              },
            ),
            
            // Tolerancia en minutos
            TextFormField(
              initialValue: viewModel.configuracion.toleranciaMinutos.toString(),
              decoration: const InputDecoration(
                labelText: 'Tolerancia en minutos',
                border: OutlineInputBorder(),
                helperText: 'Minutos de tolerancia para no contar como retraso',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final minutos = int.tryParse(value) ?? 15;
                viewModel.actualizarRegla('tolerancia_minutos', minutos);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesAccion(BuildContext context, ConfigViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: viewModel.configuracionModificada 
                  ? () => _mostrarDialogoDescartar(context, viewModel)
                  : () => Navigator.pop(context),
              icon: const Icon(Icons.cancel),
              label: const Text('Cancelar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: viewModel.configuracionModificada
                  ? () => _guardarConfiguracion(context, viewModel)
                  : null,
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarConfiguracion(BuildContext context, ConfigViewModel viewModel) async {
    final resultado = await viewModel.guardarConfiguracion(viewModel.configuracion);
    
    if (resultado && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración guardada correctamente'),
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
  }

  void _mostrarDialogoDescartar(BuildContext context, ConfigViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar Cambios'),
        content: const Text('¿Estás seguro de descartar los cambios no guardados?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              viewModel.cargarConfiguracion();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Descartar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}