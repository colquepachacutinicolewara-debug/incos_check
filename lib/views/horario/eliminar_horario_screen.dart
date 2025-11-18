// views/horarios/eliminar_horario_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/horario_viewmodel.dart';
import '../../models/horario_clase_model.dart';

class EliminarHorarioScreen extends StatefulWidget {
  final HorarioClase horario;

  const EliminarHorarioScreen({super.key, required this.horario});

  @override
  State<EliminarHorarioScreen> createState() => _EliminarHorarioScreenState();
}

class _EliminarHorarioScreenState extends State<EliminarHorarioScreen> {
  bool _confirmado = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HorarioViewModel>();

    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text(
          'Eliminar Horario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono de advertencia
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                  color: Colors.red,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Título
            const Text(
              'Confirmar Eliminación',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Información del horario a eliminar
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Horario a eliminar:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem('Materia:', widget.horario.materiaId),
                    _buildInfoItem('Paralelo:', widget.horario.paraleloId),
                    _buildInfoItem('Docente:', widget.horario.docenteId),
                    _buildInfoItem('Día:', widget.horario.diaSemana),
                    _buildInfoItem('Horario:', '${widget.horario.horaInicio} - ${widget.horario.horaFin}'),
                    _buildInfoItem('Período:', '${widget.horario.periodoNumero}°'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Advertencia
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Advertencia',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Esta acción no se puede deshacer. El horario será eliminado permanentemente del sistema.',
                    style: TextStyle(
                      color: Color.fromRGBO(239, 108, 0, 1),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Confirmación
            CheckboxListTile(
              title: const Text(
                'He leído y comprendo que esta acción es irreversible',
                style: TextStyle(fontSize: 14),
              ),
              value: _confirmado,
              onChanged: (value) {
                setState(() {
                  _confirmado = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            
            const Spacer(),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _confirmado ? () => _eliminarHorario(context, viewModel) : null,
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.red.shade200,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarHorario(
    BuildContext context, 
    HorarioViewModel viewModel
  ) async {
    final resultado = await viewModel.eliminarHorario(widget.horario.id);
    
    if (resultado && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horario eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Cerrar pantalla de eliminación
      Navigator.pop(context); // Cerrar pantalla anterior si es necesario
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${viewModel.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}