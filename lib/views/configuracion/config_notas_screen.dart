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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Configuración de Notas de Asistencia',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: viewModel.isLoading ? null : () => _guardarConfiguracion(context, viewModel),
            tooltip: 'Guardar Cambios',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.isLoading ? null : viewModel.cargarConfiguracion,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context, viewModel),
    );
  }

  Widget _buildContent(BuildContext context, ConfigViewModel viewModel) {
    final config = viewModel.configuracion;
    final parametros = config.parametrosMap;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información general
          _buildInfoConfiguracion(context, viewModel),
          
          // Configuración básica
          _buildConfiguracionBasica(context, viewModel),
          
          // Parámetros de asistencia
          _buildParametrosAsistencia(context, viewModel, parametros),
          
          // Configuración de cálculo
          _buildConfiguracionCalculo(context, viewModel, parametros),
          
          // Botones de acción
          _buildBotonesAccion(context, viewModel),
          
          // Mostrar error si existe
          if (viewModel.error != null) _buildErrorWidget(viewModel),
        ],
      ),
    );
  }

  Widget _buildInfoConfiguracion(BuildContext context, ConfigViewModel viewModel) {
    final config = viewModel.configuracion;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.assignment_outlined,
              color: Colors.teal,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.descripcion ?? 'Sin descripción',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Puntaje máximo: ${config.puntajeMaximo} puntos'),
                  Text('Tipo de fórmula: ${config.formulaTipo}'),
                  Text('Estado: ${config.activo ? 'Activo' : 'Inactivo'}'),
                  const SizedBox(height: 4),
                  Text(
                    'Última actualización: ${_formatearFecha(config.fechaActualizacion)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
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
    final config = viewModel.configuracion;

    return Card(
      elevation: 2,
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
              initialValue: config.nombre,
              decoration: const InputDecoration(
                labelText: 'Nombre de la configuración',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              onChanged: (value) {
                _actualizarConfiguracion(viewModel, config.copyWith(nombre: value));
              },
            ),
            const SizedBox(height: 16),
            
            // Descripción
            TextFormField(
              initialValue: config.descripcion,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              onChanged: (value) {
                _actualizarConfiguracion(viewModel, config.copyWith(descripcion: value));
              },
            ),
            const SizedBox(height: 16),
            
            // Puntaje máximo
            DropdownButtonFormField<double>(
              value: config.puntajeMaximo,
              items: [5.0, 10.0, 20.0, 100.0].map((puntaje) {
                return DropdownMenuItem(
                  value: puntaje,
                  child: Text('$puntaje puntos'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _actualizarConfiguracion(viewModel, config.copyWith(puntajeMaximo: value));
                }
              },
              decoration: const InputDecoration(
                labelText: 'Puntaje máximo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.score),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tipo de fórmula
            DropdownButtonFormField<String>(
              value: config.formulaTipo,
              items: ['BIMESTRAL', 'TRIMESTRAL', 'SEMESTRAL', 'ANUAL'].map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(tipo),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _actualizarConfiguracion(viewModel, config.copyWith(formulaTipo: value));
                }
              },
              decoration: const InputDecoration(
                labelText: 'Tipo de fórmula',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calculate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParametrosAsistencia(BuildContext context, ConfigViewModel viewModel, Map<String, dynamic> parametros) {
    final config = viewModel.configuracion;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parámetros de Asistencia',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Asistencia mínima requerida
            TextFormField(
              initialValue: config.asistenciaMinima.toString(),
              decoration: const InputDecoration(
                labelText: 'Asistencia mínima requerida (%)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.percent),
                helperText: 'Porcentaje mínimo de asistencia requerido',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final porcentaje = double.tryParse(value) ?? 80.0;
                viewModel.actualizarParametro('asistencia_minima', porcentaje);
              },
            ),
            const SizedBox(height: 16),
            
            // Tolerancia en minutos
            TextFormField(
              initialValue: config.toleranciaMinutos.toString(),
              decoration: const InputDecoration(
                labelText: 'Tolerancia en minutos',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
                helperText: 'Minutos de tolerancia para no contar como retraso',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final minutos = int.tryParse(value) ?? 15;
                viewModel.actualizarParametro('tolerancia_minutos', minutos);
              },
            ),
            const SizedBox(height: 16),
            
            // Penalización por retraso
            TextFormField(
              initialValue: config.penalizacionRetraso.toString(),
              decoration: const InputDecoration(
                labelText: 'Penalización por retraso (horas)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.watch_later),
                helperText: 'Horas descontadas por cada retraso',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final penalizacion = double.tryParse(value) ?? 0.5;
                viewModel.actualizarParametro('penalizacion_retraso', penalizacion);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfiguracionCalculo(BuildContext context, ConfigViewModel viewModel, Map<String, dynamic> parametros) {
    final config = viewModel.configuracion;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración de Cálculo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Mínimo aprobatorio
            TextFormField(
              initialValue: config.minimoAprobatorio.toString(),
              decoration: const InputDecoration(
                labelText: 'Mínimo aprobatorio (puntos)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
                helperText: 'Puntaje mínimo necesario para aprobar',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final minimo = double.tryParse(value) ?? 7.0;
                viewModel.actualizarParametro('minimo_aprobatorio', minimo);
              },
            ),
            const SizedBox(height: 16),
            
            // Considera puntualidad
            SwitchListTile(
              title: const Text('Considerar puntualidad'),
              subtitle: const Text('Incluir la puntualidad en el cálculo de la nota'),
              value: config.consideraPuntualidad,
              onChanged: (value) {
                viewModel.actualizarParametro('considera_puntualidad', value);
              },
            ),
            
            // Estado activo
            SwitchListTile(
              title: const Text('Configuración activa'),
              subtitle: const Text('Esta configuración está actualmente en uso'),
              value: config.activo,
              onChanged: (value) {
                _actualizarConfiguracion(viewModel, config.copyWith(activo: value));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesAccion(BuildContext context, ConfigViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: viewModel.isLoading 
                  ? null 
                  : () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: viewModel.isLoading
                  ? null
                  : () => _guardarConfiguracion(context, viewModel),
              icon: viewModel.isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              label: viewModel.isLoading 
                  ? const Text('Guardando...')
                  : const Text('Guardar Configuración'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ConfigViewModel viewModel) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              viewModel.error!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red.shade600, size: 20),
            onPressed: viewModel.clearError,
          ),
        ],
      ),
    );
  }

  // Método auxiliar para actualizar la configuración
  void _actualizarConfiguracion(ConfigViewModel viewModel, ConfigNotasAsistencia nuevaConfig) {
    // Necesitas agregar un método en tu ViewModel para actualizar la configuración
    // Por ahora, usaremos una solución temporal
    _guardarConfiguracionDirectamente(viewModel, nuevaConfig);
  }

  Future<void> _guardarConfiguracionDirectamente(ConfigViewModel viewModel, ConfigNotasAsistencia config) async {
    // Llamar al método guardarConfiguracion del ViewModel
    await viewModel.guardarConfiguracion(config);
  }

  Future<void> _guardarConfiguracion(BuildContext context, ConfigViewModel viewModel) async {
    final resultado = await viewModel.guardarConfiguracion(viewModel.configuracion);
    
    if (resultado && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración guardada correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${viewModel.error ?? "No se pudo guardar la configuración"}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}