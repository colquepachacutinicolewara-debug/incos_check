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
          if (viewModel.configuracionModificada)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: viewModel.isLoading ? null : () => _guardarConfiguracion(context, viewModel),
              tooltip: 'Guardar Cambios',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.isLoading ? null : () => _recargarConfiguracion(context, viewModel),
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
          // Indicador de cambios no guardados
          if (viewModel.configuracionModificada) _buildCambiosNoGuardados(),
          
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

  Widget _buildCambiosNoGuardados() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tienes cambios sin guardar',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
                    config.descripcion ?? 'Sin descripción', // CORRECCIÓN: Manejo de null
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
              onChanged: (value) => viewModel.actualizarNombre(value),
            ),
            const SizedBox(height: 16),
            
            // Descripción - CORREGIDO: Manejo de valor null
            TextFormField(
              initialValue: config.descripcion ?? '', // CORRECCIÓN: Valor por defecto
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              onChanged: (value) => viewModel.actualizarDescripcion(value),
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
                  viewModel.actualizarPuntajeMaximo(value);
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
                  // Actualizar el tipo de fórmula usando parámetros
                  viewModel.actualizarParametro('formula_tipo', value);
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
    final asistenciaMinima = parametros['asistencia_minima'] ?? 80.0;
    final toleranciaMinutos = parametros['tolerancia_minutos'] ?? 15;

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
              initialValue: asistenciaMinima.toString(),
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
              initialValue: toleranciaMinutos.toString(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildConfiguracionCalculo(BuildContext context, ConfigViewModel viewModel, Map<String, dynamic> parametros) {
    final consideraPuntualidad = parametros['considera_puntualidad'] ?? true;

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
            
            // Considera puntualidad
            SwitchListTile(
              title: const Text('Considerar puntualidad'),
              subtitle: const Text('Incluir la puntualidad en el cálculo de la nota'),
              value: consideraPuntualidad,
              onChanged: (value) {
                viewModel.actualizarParametro('considera_puntualidad', value);
              },
            ),
            
            // Estado activo
            SwitchListTile(
              title: const Text('Configuración activa'),
              subtitle: const Text('Esta configuración está actualmente en uso'),
              value: viewModel.configuracion.activo,
              onChanged: (value) {
                // Para cambiar el estado activo necesitarías agregar un método en el ViewModel
                _mostrarDialogoEstadoActivo(context, value, viewModel);
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
                  : () => _manejarVolver(context, viewModel),
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
              onPressed: viewModel.isLoading || !viewModel.configuracionModificada
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

  Future<void> _guardarConfiguracion(BuildContext context, ConfigViewModel viewModel) async {
    final resultado = await viewModel.guardarConfiguracion();
    
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

  Future<void> _recargarConfiguracion(BuildContext context, ConfigViewModel viewModel) async {
    if (viewModel.configuracionModificada) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cambios sin guardar'),
          content: const Text('Tienes cambios sin guardar. ¿Estás seguro de que quieres recargar y perder los cambios?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Recargar'),
            ),
          ],
        ),
      );
      
      if (confirmar != true) return;
    }
    
    await viewModel.cargarConfiguracion();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración recargada'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _manejarVolver(BuildContext context, ConfigViewModel viewModel) {
    if (viewModel.configuracionModificada) {
      _mostrarDialogoSalirSinGuardar(context, viewModel);
    } else {
      Navigator.pop(context);
    }
  }

  void _mostrarDialogoSalirSinGuardar(BuildContext context, ConfigViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambios sin guardar'),
        content: const Text('Tienes cambios sin guardar. ¿Estás seguro de que quieres salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Salir sin guardar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final resultado = await viewModel.guardarConfiguracion();
              if (resultado && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar y salir'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEstadoActivo(BuildContext context, bool nuevoEstado, ConfigViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar estado activo'),
        content: Text('¿Estás seguro de que quieres ${nuevoEstado ? 'activar' : 'desactivar'} esta configuración?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Necesitarías agregar un método en el ViewModel para cambiar el estado activo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Para cambiar el estado activo, contacta al administrador del sistema'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}