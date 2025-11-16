//lib/views/horarios/agregar_horario_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/horario_viewmodel.dart';
import '../../models/horario_clase_model.dart';

class AgregarHorarioScreen extends StatefulWidget {
  const AgregarHorarioScreen({super.key});

  @override
  State<AgregarHorarioScreen> createState() => _AgregarHorarioScreenState();
}

class _AgregarHorarioScreenState extends State<AgregarHorarioScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _materiaIdController = TextEditingController();
  final _paraleloIdController = TextEditingController();
  final _docenteIdController = TextEditingController();
  final _horaInicioController = TextEditingController();
  final _horaFinController = TextEditingController();
  
  String _diaSeleccionado = 'Lunes';
  int _periodoSeleccionado = 1;
  bool _activo = true;

  final List<String> _diasSemana = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'
  ];

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
          'Agregar Horario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _guardarHorario(context, viewModel),
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
                    // Materia ID
                    TextFormField(
                      controller: _materiaIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID de Materia',
                        border: OutlineInputBorder(),
                        hintText: 'Ej: materia_bd2',
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
                        hintText: 'Ej: paralelo_b',
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
                        hintText: 'Ej: docente_001',
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
                          child: Text('Período $periodo (${_obtenerHorarioPeriodo(periodo)})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _periodoSeleccionado = value;
                            _actualizarHorariosAutomaticos(value);
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

                    // Botón guardar
                    ElevatedButton.icon(
                      onPressed: () => _guardarHorario(context, viewModel),
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Horario'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _obtenerHorarioPeriodo(int periodo) {
    switch (periodo) {
      case 1: return '7:00-8:00';
      case 2: return '8:00-9:00';
      case 3: return '9:00-10:00';
      default: return '';
    }
  }

  void _actualizarHorariosAutomaticos(int periodo) {
    switch (periodo) {
      case 1:
        _horaInicioController.text = '19:00';
        _horaFinController.text = '20:00';
        break;
      case 2:
        _horaInicioController.text = '20:00';
        _horaFinController.text = '21:00';
        break;
      case 3:
        _horaInicioController.text = '21:00';
        _horaFinController.text = '22:00';
        break;
    }
  }

  bool _esHoraValida(String hora) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(hora);
  }

  Future<void> _guardarHorario(
    BuildContext context, 
    HorarioViewModel viewModel
  ) async {
    if (_formKey.currentState!.validate()) {
      final nuevoHorario = HorarioClase(
        id: 'horario_${DateTime.now().millisecondsSinceEpoch}',
        materiaId: _materiaIdController.text.trim(),
        paraleloId: _paraleloIdController.text.trim(),
        docenteId: _docenteIdController.text.trim(),
        diaSemana: _diaSeleccionado,
        periodoNumero: _periodoSeleccionado,
        horaInicio: _horaInicioController.text.trim(),
        horaFin: _horaFinController.text.trim(),
        activo: _activo,
        fechaCreacion: DateTime.now(),
      );

      final resultado = await viewModel.agregarHorario(nuevoHorario);
      
      if (resultado && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horario agregado correctamente'),
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