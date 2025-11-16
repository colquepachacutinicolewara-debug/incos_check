import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/asistencia_diaria_viewmodel.dart';
import '../../models/horario_clase_model.dart';
import '../../models/estudiante_model.dart';
import '../../models/asistencia_diaria_model.dart';

class TomarAsistenciaScreen extends StatefulWidget {
  final HorarioClase horario;

  const TomarAsistenciaScreen({super.key, required this.horario});

  @override
  State<TomarAsistenciaScreen> createState() => _TomarAsistenciaScreenState();
}

class _TomarAsistenciaScreenState extends State<TomarAsistenciaScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AsistenciaDiariaViewModel(),
      child: _TomarAsistenciaScreenContent(horario: widget.horario),
    );
  }
}

class _TomarAsistenciaScreenContent extends StatelessWidget {
  final HorarioClase horario;

  const _TomarAsistenciaScreenContent({required this.horario});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AsistenciaDiariaViewModel>();

    return Scaffold(
      backgroundColor: viewModel.getBackgroundColor(context),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tomar Asistencia',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              '${horario.diaSemana} - ${horario.periodoDisplay}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: horario.colorPeriodo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.cargarAsistenciasDelDia,
            tooltip: 'Recargar',
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _mostrarEstadisticas(context, viewModel),
            tooltip: 'Estadísticas',
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Información del horario
                _buildInfoHorario(context),
                
                // Lista de estudiantes
                _buildListaEstudiantes(context, viewModel),
              ],
            ),
    );
  }

  Widget _buildInfoHorario(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              color: horario.colorPeriodo,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    horario.periodoDisplay,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Horario: ${horario.horarioCompleto}'),
                  Text('Materia ID: ${horario.materiaId}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaEstudiantes(
    BuildContext context, 
    AsistenciaDiariaViewModel viewModel
  ) {
    if (viewModel.estudiantes.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'No hay estudiantes registrados',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: viewModel.estudiantes.length,
        itemBuilder: (context, index) {
          final estudiante = viewModel.estudiantes[index];
          final asistencia = viewModel.obtenerAsistenciaEstudiante(
            estudiante.id, 
            horario.periodoNumero
          );

          return _buildTarjetaEstudiante(
            context, 
            viewModel, 
            estudiante, 
            asistencia
          );
        },
      ),
    );
  }

  Widget _buildTarjetaEstudiante(
    BuildContext context,
    AsistenciaDiariaViewModel viewModel,
    Estudiante estudiante,
    AsistenciaDiaria? asistencia,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _obtenerColorEstado(asistencia?.estado).withOpacity(0.1),
          child: Icon(
            _obtenerIconoEstado(asistencia?.estado),
            color: _obtenerColorEstado(asistencia?.estado),
          ),
        ),
        title: Text(
          estudiante.nombreCompleto,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: asistencia != null ? Colors.grey.shade700 : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CI: ${estudiante.ci}'),
            if (asistencia != null)
              Text(
                'Estado: ${asistencia.estadoDisplay}',
                style: TextStyle(
                  color: _obtenerColorEstado(asistencia.estado),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: _buildBotonesEstado(context, viewModel, estudiante, asistencia),
        ),
      ),
    );
  }

  List<Widget> _buildBotonesEstado(
    BuildContext context,
    AsistenciaDiariaViewModel viewModel,
    Estudiante estudiante,
    AsistenciaDiaria? asistencia,
  ) {
    if (asistencia != null) {
      return [
        Chip(
          label: Text(asistencia.estadoDisplay),
          backgroundColor: _obtenerColorEstado(asistencia.estado).withOpacity(0.1),
          labelStyle: TextStyle(
            color: _obtenerColorEstado(asistencia.estado),
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => _mostrarDialogoCambiarEstado(
            context, 
            viewModel, 
            estudiante, 
            asistencia
          ),
          tooltip: 'Cambiar estado',
        ),
      ];
    }

    return [
      IconButton(
        icon: const Icon(Icons.check, color: Colors.green),
        onPressed: () => _registrarAsistencia(
          context, 
          viewModel, 
          estudiante, 
          'P'
        ),
        tooltip: 'Presente',
      ),
      IconButton(
        icon: const Icon(Icons.schedule, color: Colors.orange),
        onPressed: () => _registrarAsistencia(
          context, 
          viewModel, 
          estudiante, 
          'R'
        ),
        tooltip: 'Retraso',
      ),
      IconButton(
        icon: const Icon(Icons.close, color: Colors.red),
        onPressed: () => _registrarAsistencia(
          context, 
          viewModel, 
          estudiante, 
          'A'
        ),
        tooltip: 'Ausente',
      ),
    ];
  }

  Color _obtenerColorEstado(String? estado) {
    switch (estado) {
      case 'P': return Colors.green;
      case 'A': return Colors.red;
      case 'R': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _obtenerIconoEstado(String? estado) {
    switch (estado) {
      case 'P': return Icons.check;
      case 'A': return Icons.close;
      case 'R': return Icons.schedule;
      default: return Icons.person;
    }
  }

  Future<void> _registrarAsistencia(
    BuildContext context,
    AsistenciaDiariaViewModel viewModel,
    Estudiante estudiante,
    String estado,
  ) async {
    await viewModel.registrarAsistencia(
      estudianteId: estudiante.id,
      materiaId: horario.materiaId,
      horarioClaseId: horario.id,
      periodoNumero: horario.periodoNumero,
      estado: estado,
      usuarioRegistro: 'docente_actual', // Cambiar por usuario real
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Asistencia registrada: ${estudiante.nombreCompleto} - $estado'),
          backgroundColor: _obtenerColorEstado(estado),
        ),
      );
    }
  }

  void _mostrarDialogoCambiarEstado(
    BuildContext context,
    AsistenciaDiariaViewModel viewModel,
    Estudiante estudiante,
    AsistenciaDiaria asistencia,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado de Asistencia'),
        content: Text('Estudiante: ${estudiante.nombreCompleto}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          _buildBotonEstadoDialogo(
            context, 
            viewModel, 
            estudiante, 
            'P', 
            'Presente', 
            Colors.green
          ),
          _buildBotonEstadoDialogo(
            context, 
            viewModel, 
            estudiante, 
            'R', 
            'Retraso', 
            Colors.orange
          ),
          _buildBotonEstadoDialogo(
            context, 
            viewModel, 
            estudiante, 
            'A', 
            'Ausente', 
            Colors.red
          ),
        ],
      ),
    );
  }

  Widget _buildBotonEstadoDialogo(
    BuildContext context,
    AsistenciaDiariaViewModel viewModel,
    Estudiante estudiante,
    String estado,
    String label,
    Color color,
  ) {
    return TextButton(
      onPressed: () async {
        Navigator.pop(context);
        await _registrarAsistencia(context, viewModel, estudiante, estado);
      },
      child: Text(
        label,
        style: TextStyle(color: color),
      ),
    );
  }

  void _mostrarEstadisticas(
    BuildContext context, 
    AsistenciaDiariaViewModel viewModel
  ) {
    final estadisticas = viewModel.obtenerEstadisticasDia();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estadísticas de Asistencia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEstadisticaItem('Total registros', '${estadisticas['total']}'),
            _buildEstadisticaItem('Presentes', '${estadisticas['presentes']}', Colors.green),
            _buildEstadisticaItem('Ausentes', '${estadisticas['ausentes']}', Colors.red),
            _buildEstadisticaItem('Retrasos', '${estadisticas['retrasos']}', Colors.orange),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Porcentaje de asistencia: ${estadisticas['porcentaje']}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
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

  Widget _buildEstadisticaItem(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}