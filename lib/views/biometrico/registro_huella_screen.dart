// screens/registro_huellas_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/huella_model.dart';
import '../../viewmodels/registro_huellas_viewmodel.dart';
import '../../utils/constants.dart';

class RegistroHuellasScreen extends StatelessWidget {
  final Map<String, dynamic> estudiante;
  final Function(int huellasRegistradas)? onHuellasRegistradas;
  
  const RegistroHuellasScreen({
    super.key,
    required this.estudiante,
    this.onHuellasRegistradas,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegistroHuellasViewModel()..configurarEstudiante(estudiante),
      child: _RegistroHuellasView(
        estudiante: estudiante,
        onHuellasRegistradas: onHuellasRegistradas,
      ),
    );
  }
}

class _RegistroHuellasView extends StatefulWidget {
  final Map<String, dynamic> estudiante;
  final Function(int huellasRegistradas)? onHuellasRegistradas;
  
  const _RegistroHuellasView({
    required this.estudiante,
    this.onHuellasRegistradas,
  });

  @override
  State<_RegistroHuellasView> createState() => __RegistroHuellasViewState();
}

class __RegistroHuellasViewState extends State<_RegistroHuellasView> {
  @override
  void initState() {
    super.initState();
    // Escuchar cambios en el ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<RegistroHuellasViewModel>();
      viewModel.addListener(_onViewModelChanged);
    });
  }

  void _onViewModelChanged() {
    final viewModel = context.read<RegistroHuellasViewModel>();
    
    // Si hay huellas registradas y tenemos callback, notificar
    if (viewModel.huellasRegistradas > 0 && widget.onHuellasRegistradas != null) {
      widget.onHuellasRegistradas!(viewModel.huellasRegistradas);
    }
  }

  @override
  void dispose() {
    final viewModel = context.read<RegistroHuellasViewModel>();
    viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegistroHuellasViewModel>();
    final huellaActual = viewModel.huellas[viewModel.huellaActual];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Registro de Huellas',
          style: AppTextStyles.heading1.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 2,
        actions: [
          // Botón para finalizar
          IconButton(
            icon: const Icon(Icons.done, color: Colors.white),
            onPressed: () {
              if (widget.onHuellasRegistradas != null) {
                widget.onHuellasRegistradas!(viewModel.huellasRegistradas);
              }
              Navigator.pop(context);
            },
            tooltip: 'Finalizar registro',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del estudiante
            _buildInfoEstudiante(context),
            const SizedBox(height: 20),
            
            // Estado del sensor
            _buildEstadoSensor(context, viewModel),
            const SizedBox(height: 20),
            
            // Progreso
            _buildProgreso(context, viewModel),
            const SizedBox(height: 20),
            
            // Huella actual
            _buildHuellaActual(context, viewModel, huellaActual),
            const SizedBox(height: 20),
            
            // Mensajes de error/éxito
            if (viewModel.errorMessage.isNotEmpty)
              _buildMensajeError(context, viewModel),
            
            const Spacer(),
            
            // Botones de navegación
            _buildBotonesNavegacion(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoEstudiante(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.estudiante['nombres']} ${widget.estudiante['apellido_paterno']}',
                    style: AppTextStyles.heading2,
                  ),
                  Text(
                    'CI: ${widget.estudiante['ci']}',
                    style: AppTextStyles.body,
                  ),
                  Text(
                    'Huellas registradas: ${widget.estudiante['huellas_registradas'] ?? 0}/3',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
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

  Widget _buildEstadoSensor(BuildContext context, RegistroHuellasViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: viewModel.sensorConectado 
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: viewModel.sensorConectado ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        children: [
          Icon(
            viewModel.sensorConectado ? Icons.check_circle : Icons.error,
            color: viewModel.sensorConectado ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              viewModel.sensorConectado 
                  ? '✅ Sensor de huellas conectado'
                  : '❌ Sensor de huellas desconectado',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: viewModel.sensorConectado ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgreso(BuildContext context, RegistroHuellasViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progreso: ${viewModel.huellaActual + 1}/${viewModel.huellas.length}',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (viewModel.huellaActual + 1) / viewModel.huellas.length,
          backgroundColor: Colors.grey[300],
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        Text(
          'Huellas registradas: ${viewModel.huellasRegistradas}/3',
          style: AppTextStyles.body.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHuellaActual(
    BuildContext context, 
    RegistroHuellasViewModel viewModel, 
    HuellaModel huella
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              huella.registrada ? '✅ REGISTRADA' : '📝 POR REGISTRAR',
              style: AppTextStyles.heading2.copyWith(
                color: huella.registrada ? Colors.green : AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              huella.icono,
              style: const TextStyle(fontSize: 50),
            ),
            const SizedBox(height: 16),
            Text(
              huella.nombreDedo,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (!huella.registrada)
              ElevatedButton.icon(
                onPressed: viewModel.isLoading || !viewModel.sensorConectado
                    ? null
                    : () => viewModel.registrarHuellaActual(),
                icon: const Icon(Icons.fingerprint),
                label: Text(
                  viewModel.isLoading ? 'Registrando...' : 'Registrar Huella',
                  style: AppTextStyles.button,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMensajeError(BuildContext context, RegistroHuellasViewModel viewModel) {
    final isError = viewModel.errorMessage.contains('❌');
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError 
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.red : Colors.green,
        ),
      ),
      child: Text(
        viewModel.errorMessage,
        style: AppTextStyles.body.copyWith(
          color: isError ? Colors.red : Colors.green,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBotonesNavegacion(BuildContext context, RegistroHuellasViewModel viewModel) {
    return Row(
      children: [
        // Botón anterior
        Expanded(
          child: ElevatedButton(
            onPressed: viewModel.huellaActual > 0 ? () => viewModel.anteriorHuella() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
            ),
            child: const Text('Anterior'),
          ),
        ),
        const SizedBox(width: 16),
        
        // Botón siguiente/Finalizar
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (viewModel.huellaActual < viewModel.huellas.length - 1) {
                viewModel.siguienteHuella();
              } else {
                // Última huella, notificar y cerrar
                if (widget.onHuellasRegistradas != null) {
                  widget.onHuellasRegistradas!(viewModel.huellasRegistradas);
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              viewModel.huellaActual < viewModel.huellas.length - 1 
                  ? 'Siguiente' 
                  : 'Finalizar',
            ),
          ),
        ),
      ],
    );
  }
}