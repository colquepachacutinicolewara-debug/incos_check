// ui/biometrico/registro_huella_simple_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/registro_huellas_simple_viewmodel.dart'; // ✅ Nombre corregido
import '../../utils/constants.dart';

class RegistroHuellaSimpleScreen extends StatefulWidget {
  final Map<String, dynamic> estudiante;

  const RegistroHuellaSimpleScreen({
    super.key,
    required this.estudiante,
  });

  @override
  State<RegistroHuellaSimpleScreen> createState() => _RegistroHuellaSimpleScreenState();
}

class _RegistroHuellaSimpleScreenState extends State<RegistroHuellaSimpleScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegistroHuellaSimpleViewModel()..configurarEstudiante(widget.estudiante),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registro de Huella'),
          backgroundColor: AppColors.primary,
        ),
        body: const _RegistroHuellaSimpleContent(),
      ),
    );
  }
}

class _RegistroHuellaSimpleContent extends StatelessWidget {
  const _RegistroHuellaSimpleContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegistroHuellaSimpleViewModel>();
    final estudiante = viewModel.estudiante;

    if (estudiante == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del estudiante
          _buildEstudianteCard(context, estudiante, viewModel),
          
          const SizedBox(height: 20),
          
          // Control de Fingerprint ID
          _buildFingerprintIdControl(context, viewModel),
          
          const SizedBox(height: 20),
          
          // Estado del sensor
          _buildSensorStatus(context, viewModel),
          
          const SizedBox(height: 20),
          
          // Mensajes
          _buildMessages(context, viewModel),
          
          const SizedBox(height: 20),
          
          // Botones de acción
          _buildActionButtons(context, viewModel),
          
          const Spacer(),
          
          // Información adicional
          _buildAdditionalInfo(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildEstudianteCard(BuildContext context, Map<String, dynamic> estudiante, RegistroHuellaSimpleViewModel viewModel) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                estudiante['nombres'][0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${estudiante['nombres']} ${estudiante['apellido_paterno']}',
                    style: AppTextStyles.heading3,
                  ),
                  Text(
                    'CI: ${estudiante['ci']}',
                    style: AppTextStyles.body,
                  ),
                  Text(
                    'ID: ${estudiante['id']}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: viewModel.huellaRegistrada ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                viewModel.huellaRegistrada ? 'HUELLA OK' : 'SIN HUELLA',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFingerprintIdControl(BuildContext context, RegistroHuellaSimpleViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Control de ID de Huella',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 12),
            Text(
              'ID asignado: ${viewModel.fingerprintId}',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 8),
            Text(
              'Rango válido: 1-127',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: viewModel.fingerprintId.toDouble(),
                    min: 1,
                    max: 127,
                    divisions: 126,
                    label: viewModel.fingerprintId.toString(),
                    onChanged: viewModel.huellaRegistrada 
                        ? null 
                        : (value) {
                            viewModel.cambiarFingerprintId(value.toInt());
                          },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: viewModel.fingerprintId.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ID',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: viewModel.huellaRegistrada 
                        ? null 
                        : (value) {
                            final id = int.tryParse(value);
                            if (id != null && id >= 1 && id <= 127) {
                              viewModel.cambiarFingerprintId(id);
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

  Widget _buildSensorStatus(BuildContext context, RegistroHuellaSimpleViewModel viewModel) {
    return Card(
      color: viewModel.sensorConectado ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              viewModel.sensorConectado ? Icons.check_circle : Icons.error,
              color: viewModel.sensorConectado ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.sensorConectado 
                        ? 'Sensor ESP32 Conectado' 
                        : 'Sensor No Disponible',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!viewModel.sensorConectado) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Verifica que el ESP32 esté encendido y conectado a la red WiFi',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (!viewModel.sensorConectado) ...[
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: viewModel.isLoading ? null : viewModel.reintentarConexion,
                tooltip: 'Reintentar conexión',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessages(BuildContext context, RegistroHuellaSimpleViewModel viewModel) {
    if (viewModel.errorMessage.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                viewModel.errorMessage,
                style: AppTextStyles.body.copyWith(color: Colors.red),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: viewModel.limpiarMensajes,
            ),
          ],
        ),
      );
    }

    if (viewModel.successMessage.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                viewModel.successMessage,
                style: AppTextStyles.body.copyWith(color: Colors.green),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: viewModel.limpiarMensajes,
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildActionButtons(BuildContext context, RegistroHuellaSimpleViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: viewModel.isLoading || viewModel.huellaRegistrada || !viewModel.sensorConectado
                ? null
                : viewModel.registrarHuella,
            icon: const Icon(Icons.fingerprint),
            label: Text(viewModel.isLoading ? 'Registrando...' : 'Registrar Huella'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (viewModel.huellaRegistrada)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: viewModel.isLoading ? null : () => _confirmarEliminacion(context),
            tooltip: 'Eliminar huella',
          ),
      ],
    );
  }

  void _confirmarEliminacion(BuildContext context) {
    final viewModel = context.read<RegistroHuellaSimpleViewModel>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Huella?'),
        content: const Text('Esta acción eliminará la huella registrada para este estudiante.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.eliminarHuella();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context, RegistroHuellaSimpleViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Sistema',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '• 1 huella por estudiante',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            '• ID controlado desde la app',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            '• Relación guardada en SQLite',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            '• Verificación en tiempo real',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}