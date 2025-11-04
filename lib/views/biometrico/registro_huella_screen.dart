import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/biometrico_model.dart';
import '../../viewmodels/registro_huellas_viewmodel.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class RegistroHuellasScreen extends StatefulWidget {
  final Map<String, dynamic> estudiante;
  final Function(int) onHuellasRegistradas;

  const RegistroHuellasScreen({
    super.key,
    required this.estudiante,
    required this.onHuellasRegistradas,
  });

  @override
  State<RegistroHuellasScreen> createState() => _RegistroHuellasScreenState();
}

class _RegistroHuellasScreenState extends State<RegistroHuellasScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegistroHuellasViewModel>().verificarSoporteBiometrico();
    });
  }

  void _finalizarRegistro() async {
    final viewModel = context.read<RegistroHuellasViewModel>();
    final totalRegistradas = viewModel.model.totalRegistradas;

    if (totalRegistradas == 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sin huellas registradas'),
          content: const Text(
            '¿Está seguro de que desea finalizar sin registrar huellas digitales?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    widget.onHuellasRegistradas(totalRegistradas);
    Navigator.pop(context);

    Helpers.showSnackBar(
      context,
      '✅ Registro completado: $totalRegistradas/3 huellas',
      type: 'success',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegistroHuellasViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Registro de Huellas',
            style: AppTextStyles.heading2Dark(
              context,
            ).copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.white),
              onPressed: _finalizarRegistro,
              tooltip: 'Finalizar registro',
            ),
          ],
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(AppSpacing.medium),
          child: Consumer<RegistroHuellasViewModel>(
            builder: (context, viewModel, child) {
              final model = viewModel.model;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del estudiante
                  _buildInfoEstudiante(),
                  SizedBox(height: AppSpacing.large),

                  // Estado del sensor
                  _buildEstadoSensor(model.estadoBiometrico),
                  SizedBox(height: AppSpacing.large),

                  // Mensaje de error
                  if (model.errorMessage.isNotEmpty)
                    _buildMensajeError(model.errorMessage),

                  // Progreso
                  _buildProgresoRegistro(model.totalRegistradas),
                  SizedBox(height: AppSpacing.large),

                  // Selector de huellas
                  _buildSelectorHuellas(viewModel, model),
                  SizedBox(height: AppSpacing.large),

                  // Área de registro
                  _buildAreaRegistro(viewModel, model),
                  SizedBox(height: AppSpacing.large),

                  // Controles de navegación
                  _buildControlesNavegacion(viewModel, model),
                  SizedBox(height: AppSpacing.xlarge),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoEstudiante() {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            widget.estudiante['nombres'][0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          '${widget.estudiante['apellidoPaterno']} ${widget.estudiante['apellidoMaterno']} ${widget.estudiante['nombres']}',
          style: AppTextStyles.heading3Dark(context),
        ),
        subtitle: Text(
          'CI: ${widget.estudiante['ci']}',
          style: AppTextStyles.bodyDark(context),
        ),
      ),
    );
  }

  Widget _buildEstadoSensor(BiometricoEstadoModel estado) {
    Color statusColor;
    IconData statusIcon;

    if (!estado.disponible) {
      statusColor = Colors.red;
      statusIcon = Icons.error;
    } else if (estado.soloHuellaDigital) {
      statusColor = Colors.green;
      statusIcon = Icons.fingerprint;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estado.mensaje,
                  style: AppTextStyles.bodyDark(
                    context,
                  ).copyWith(fontWeight: FontWeight.w500, color: statusColor),
                ),
                Text(
                  estado.submensaje,
                  style: AppTextStyles.bodyDark(
                    context,
                  ).copyWith(fontSize: 12, color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMensajeError(String mensaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgresoRegistro(int registradas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso del Registro',
                style: AppTextStyles.heading3Dark(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$registradas/3',
                style: AppTextStyles.heading3Dark(
                  context,
                ).copyWith(color: AppColors.primary),
              ),
            ],
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: registradas / 3,
            backgroundColor: Colors.grey.shade300,
            color: AppColors.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorHuellas(
    RegistroHuellasViewModel viewModel,
    RegistroHuellasModel model,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccione el dedo a registrar:',
          style: AppTextStyles.heading3Dark(context),
        ),
        SizedBox(height: 8),
        Row(
          children: model.huellas.asMap().entries.map((entry) {
            int index = entry.key;
            HuellaModel huella = entry.value;
            bool isActive = index == model.huellaActual;

            return Expanded(
              child: GestureDetector(
                onTap: () => viewModel.seleccionarHuella(index),
                child: Container(
                  margin: EdgeInsets.only(right: 6),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: Border.all(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(huella.icono, style: TextStyle(fontSize: 18)),
                      SizedBox(height: 4),
                      Text(
                        huella.nombreDedo.split(' ')[0],
                        style: AppTextStyles.bodyDark(context).copyWith(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2),
                      Icon(
                        huella.registrada
                            ? Icons.fingerprint
                            : Icons.fingerprint_outlined,
                        color: huella.registrada ? Colors.green : Colors.grey,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAreaRegistro(
    RegistroHuellasViewModel viewModel,
    RegistroHuellasModel model,
  ) {
    final huellaActual = model.huellas[model.huellaActual];

    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono del dedo
            Text(huellaActual.icono, style: TextStyle(fontSize: 60)),
            SizedBox(height: 16),

            // Nombre del dedo
            Text(
              huellaActual.nombreDedo,
              style: AppTextStyles.heading2Dark(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),

            // Estado o instrucciones
            if (huellaActual.registrada)
              _buildHuellaRegistrada()
            else
              _buildInstruccionesRegistro(model.estadoBiometrico),

            SizedBox(height: 24),

            // Botón de acción
            if (!huellaActual.registrada)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: model.isLoading
                      ? null
                      : () =>
                            viewModel.registrarHuellaActual(widget.estudiante),
                  icon: Icon(
                    model.isLoading ? Icons.hourglass_empty : Icons.fingerprint,
                    size: 24,
                  ),
                  label: Text(
                    model.isLoading ? 'Autenticando...' : 'Registrar Huella',
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruccionesRegistro(BiometricoEstadoModel estado) {
    return Column(
      children: [
        Icon(
          Icons.fingerprint,
          size: 50,
          color: AppColors.primary.withOpacity(0.7),
        ),
        SizedBox(height: 16),
        Text(
          estado.soloHuellaDigital
              ? 'Toque el sensor de huella digital'
              : 'Use su método biométrico configurado',
          style: AppTextStyles.bodyDark(
            context,
          ).copyWith(color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Mantenga el dedo en el sensor hasta sentir la vibración',
          style: AppTextStyles.bodyDark(
            context,
          ).copyWith(color: Colors.grey.shade500, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHuellaRegistrada() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green, width: 3),
          ),
          child: Icon(Icons.check, size: 40, color: Colors.green),
        ),
        SizedBox(height: 16),
        Text(
          '✅ Huella Registrada',
          style: AppTextStyles.heading3Dark(
            context,
          ).copyWith(color: Colors.green, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildControlesNavegacion(
    RegistroHuellasViewModel viewModel,
    RegistroHuellasModel model,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: model.huellaActual > 0 ? viewModel.anteriorHuella : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.grey.shade700,
          ),
          child: Text('Anterior'),
        ),

        Text(
          '${model.huellaActual + 1}/3',
          style: AppTextStyles.heading3Dark(context),
        ),

        ElevatedButton(
          onPressed: model.huellaActual < model.huellas.length - 1
              ? viewModel.siguienteHuella
              : null,
          child: Text('Siguiente'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
