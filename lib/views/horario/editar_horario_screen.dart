//lib/views/horarios/editar_horario_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/horario_viewmodel.dart';
import '../../models/horario_clase_model.dart';

class EditarHorarioScreen extends StatefulWidget {
  final HorarioClase horario;

  const EditarHorarioScreen({super.key, required this.horario});

  @override
  State<EditarHorarioScreen> createState() => _EditarHorarioScreenState();
}

class _EditarHorarioScreenState extends State<EditarHorarioScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _materiaIdController;
  late TextEditingController _paraleloIdController;
  late TextEditingController _docenteIdController;
  late TextEditingController _horaInicioController;
  late TextEditingController _horaFinController;
  
  late String _diaSeleccionado;
  late int _periodoSeleccionado;
  late bool _activo;

  final List<String> _diasSemana = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'
  ];

  @override
  void initState() {
    super.initState();
    _inicializarControladores();
  }

  void _inicializarControladores() {
    _materiaIdController = TextEditingController(text: widget.horario.materiaId);
    _paraleloIdController = TextEditingController(text: widget.horario.paraleloId);
    _docenteIdController = TextEditingController(text: widget.horario.docenteId);
    _horaInicioController = TextEditingController(text: widget.horario.horaInicio);
    _horaFinController = TextEditingController(text: widget.horario.horaFin);
    
    _diaSeleccionado = widget.horario.diaSemana;
    _periodoSeleccionado = widget.horario.periodoNumero;
    _activo = widget.horario.activo;
  }

  @override
  void dispose() {
    _materiaIdController.dispose();
    _paraleloIdController.dispose();
    _docenteIdController.dispose();
    _horaInicioController.dispose();
    _horaFinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HorarioViewModel>();

    return Scaffold(
      backgroundColor: viewModel.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Editar Horario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _guardarCambios(context, viewModel),
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Información del horario
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Editando Horario',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ID: ${widget.horario.id}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Materia ID
                    TextFormField(
                      controller: _materiaIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID de Materia',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el ID de la materia';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Paralelo ID
                    TextFormField(
                      controller: _paraleloIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID de Paralelo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el ID del paralelo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Docente ID
                    TextFormField(
                      controller: _docenteIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID de Docente',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el ID del docente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Día de la semana
                    DropdownButtonFormField<String>(
                      value: _diaSeleccionado,
                      items: _diasSemana.map((dia) {
                        return DropdownMenuItem(
                          value: dia,
                          child: Text(dia),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _diaSeleccionado = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Día de la semana',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Período
                    DropdownButtonFormField<int>(
                      value: _periodoSeleccionado,
                      items: [1, 2, 3].map((periodo) {
                        return DropdownMenuItem(
                          value: periodo,
                          child: Text('Período $periodo'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _periodoSeleccionado = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Período',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hora inicio
                    TextFormField(
                      controller: _horaInicioController,
                      decoration: const InputDecoration(
                        labelText: 'Hora de inicio',
                        border: OutlineInputBorder(),
                        hintText: 'Ej: 19:00',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la hora de inicio';
                        }
                        if (!_esHoraValida(value)) {
                          return 'Formato de hora inválido (HH:MM)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Hora fin
                    TextFormField(
                      controller: _horaFinController,
                      decoration: const InputDecoration(
                        labelText: 'Hora de fin',
                        border: OutlineInputBorder(),
                        hintText: 'Ej: 20:00',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la hora de fin';
                        }
                        if (!_esHoraValida(value)) {
                          return 'Formato de hora inválido (HH:MM)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Estado activo
                    SwitchListTile(
                      title: const Text('Horario activo'),
                      value: _activo,
                      onChanged: (value) {
                        setState(() {
                          _activo = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

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
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _guardarCambios(context, viewModel),
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  bool _esHoraValida(String hora) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(hora);
  }

  Future<void> _guardarCambios(
    BuildContext context, 
    HorarioViewModel viewModel
  ) async {
    if (_formKey.currentState!.validate()) {
      final horarioActualizado = widget.horario.copyWith(
        materiaId: _materiaIdController.text.trim(),
        paraleloId: _paraleloIdController.text.trim(),
        docenteId: _docenteIdController.text.trim(),
        diaSemana: _diaSeleccionado,
        periodoNumero: _periodoSeleccionado,
        horaInicio: _horaInicioController.text.trim(),
        horaFin: _horaFinController.text.trim(),
        activo: _activo,
      );

      final resultado = await viewModel.actualizarHorario(horarioActualizado);
      
      if (resultado && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horario actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
}