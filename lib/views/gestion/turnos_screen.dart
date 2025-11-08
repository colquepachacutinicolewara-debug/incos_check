// views/turnos_scren.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:incos_check/utils/constants.dart';
import 'niveles_screen.dart';
import '../../../viewmodels/turnos_viewmodel.dart';
import '../../../models/turnos_model.dart';
import '../../repositories/data_repository.dart';

class TurnosScreen extends StatelessWidget {
  final String tipo;
  final Map<String, dynamic> carrera;

  const TurnosScreen({super.key, required this.tipo, required this.carrera});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final repository = context.read<DataRepository>();
        return TurnosViewModel(
          tipo: tipo,
          carrera: carrera,
          repository: repository,
        );
      },
      child: _TurnosScreenContent(tipo: tipo, carrera: carrera),
    );
  }
}

class _TurnosScreenContent extends StatelessWidget {
  final String tipo;
  final Map<String, dynamic> carrera;

  const _TurnosScreenContent({required this.tipo, required this.carrera});

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TurnosViewModel>(context);
    final turnos = viewModel.turnos;
    final isLoading = viewModel.isLoading;
    final error = viewModel.error;

    // Mostrar loading
    if (isLoading && turnos.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${carrera['nombre']} - Turnos',
            style: AppTextStyles.heading2Dark(
              context,
            ).copyWith(color: Colors.white),
          ),
          backgroundColor: viewModel.parseColor(carrera['color']),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando turnos...'),
            ],
          ),
        ),
      );
    }

    // Mostrar error
    if (error != null && turnos.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${carrera['nombre']} - Turnos',
            style: AppTextStyles.heading2Dark(
              context,
            ).copyWith(color: Colors.white),
          ),
          backgroundColor: viewModel.parseColor(carrera['color']),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyDark(context),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => viewModel.recargarTurnos(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: viewModel.parseColor(carrera['color']),
                ),
                child: Text(
                  'Reintentar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Color carreraColor = viewModel.parseColor(carrera['color']);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${carrera['nombre']} - Turnos',
          style: AppTextStyles.heading2Dark(
            context,
          ).copyWith(color: Colors.white),
        ),
        backgroundColor: carreraColor,
      ),
      body: turnos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 64,
                    color: AppColors.textSecondaryDark(context),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay turnos configurados',
                    style: AppTextStyles.heading3Dark(
                      context,
                    ).copyWith(color: _getTextColor(context)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Presiona el botón + para agregar un turno',
                    style: AppTextStyles.bodyDark(
                      context,
                    ).copyWith(color: _getSecondaryTextColor(context)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacing.medium),
              itemCount: turnos.length,
              itemBuilder: (context, index) {
                final turno = turnos[index];
                return _buildTurnoCard(turno, context, carreraColor, viewModel);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAgregarTurnoDialog(context, viewModel),
        backgroundColor: carreraColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTurnoCard(
    TurnoModel turno,
    BuildContext context,
    Color color,
    TurnosViewModel viewModel,
  ) {
    Color turnoColor = viewModel.parseColor(turno.color);
    bool isActivo = turno.activo;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      color: isActivo
          ? Theme.of(context).cardColor
          : Colors.grey.shade300.withOpacity(0.5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActivo ? turnoColor : Colors.grey,
          child: Icon(turno.icon, color: Colors.white),
        ),
        title: Row(
          children: [
            Text(
              'Turno ${turno.nombre}',
              style: AppTextStyles.heading3Dark(context).copyWith(
                color: isActivo ? _getTextColor(context) : Colors.grey,
              ),
            ),
            if (!isActivo) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Inactivo',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Horario: ${turno.horario}',
              style: AppTextStyles.bodyDark(context).copyWith(
                color: isActivo ? _getTextColor(context) : Colors.grey,
              ),
            ),
            Text(
              'Días: ${turno.dias}',
              style: AppTextStyles.bodyDark(context).copyWith(
                color: isActivo ? _getTextColor(context) : Colors.grey,
              ),
            ),
            Text(
              'Registro: ${turno.rangoAsistencia}',
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: isActivo ? AppColors.success : Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              _handleMenuAction(value, turno, viewModel, context),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20, color: _getTextColor(context)),
                  SizedBox(width: 8),
                  Text(
                    'Modificar',
                    style: AppTextStyles.bodyDark(
                      context,
                    ).copyWith(color: _getTextColor(context)),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle_active',
              child: Row(
                children: [
                  Icon(
                    turno.activo ? Icons.toggle_off : Icons.toggle_on,
                    size: 20,
                    color: _getTextColor(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    turno.activo ? 'Desactivar' : 'Activar',
                    style: AppTextStyles.bodyDark(
                      context,
                    ).copyWith(color: _getTextColor(context)),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Eliminar',
                    style: AppTextStyles.bodyDark(
                      context,
                    ).copyWith(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: isActivo
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NivelesScreen(
                      tipo: tipo,
                      carrera: carrera,
                      turno: turno.toMap(),
                    ),
                  ),
                );
              }
            : null,
      ),
    );
  }

  void _handleMenuAction(
    String action,
    TurnoModel turno,
    TurnosViewModel viewModel,
    BuildContext context,
  ) {
    switch (action) {
      case 'edit':
        _showEditarTurnoDialog(turno, viewModel, context);
        break;
      case 'toggle_active':
        _toggleActivarTurno(turno, viewModel, context);
        break;
      case 'delete':
        _showEliminarTurnoDialog(turno, viewModel, context);
        break;
    }
  }

  void _toggleActivarTurno(
    TurnoModel turno,
    TurnosViewModel viewModel,
    BuildContext context,
  ) {
    viewModel.toggleActivarTurno(turno);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Turno ${turno.nombre} ${!turno.activo ? 'activado' : 'desactivado'}',
          style: AppTextStyles.bodyDark(context).copyWith(color: Colors.white),
        ),
        backgroundColor: !turno.activo ? AppColors.success : AppColors.warning,
      ),
    );
  }

  void _showAgregarTurnoDialog(
    BuildContext context,
    TurnosViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => _TurnoDialog(
        title: 'Agregar Turno',
        onSave: (nombre, icon, horario, rangoAsistencia, dias, color) {
          final nuevoTurno = TurnoModel(
            id: viewModel.generarTurnoId(),
            nombre: nombre,
            icon: icon,
            horario: horario,
            rangoAsistencia: rangoAsistencia,
            dias: dias,
            color: color,
            activo: true,
            niveles: [],
          );

          viewModel.agregarTurno(nuevoTurno);

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Turno "$nombre" agregado correctamente',
                style: AppTextStyles.bodyDark(
                  context,
                ).copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _showEditarTurnoDialog(
    TurnoModel turno,
    TurnosViewModel viewModel,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => _TurnoDialog(
        title: 'Modificar Turno',
        nombreInicial: turno.nombre,
        iconoInicial: turno.icon,
        horarioInicial: turno.horario,
        rangoAsistenciaInicial: turno.rangoAsistencia,
        diasInicial: turno.dias,
        colorInicial: turno.color,
        onSave: (nombre, icon, horario, rangoAsistencia, dias, color) {
          final turnoActualizado = turno.copyWith(
            nombre: nombre,
            icon: icon,
            horario: horario,
            rangoAsistencia: rangoAsistencia,
            dias: dias,
            color: color,
          );

          viewModel.actualizarTurno(turno.id, turnoActualizado);

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Turno "$nombre" modificado correctamente',
                style: AppTextStyles.bodyDark(
                  context,
                ).copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _showEliminarTurnoDialog(
    TurnoModel turno,
    TurnosViewModel viewModel,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Eliminar Turno',
          style: AppTextStyles.heading2Dark(
            context,
          ).copyWith(color: _getTextColor(context)),
        ),
        content: Text(
          '¿Estás seguro de eliminar el Turno ${turno.nombre}? Esta acción no se puede deshacer.',
          style: AppTextStyles.bodyDark(
            context,
          ).copyWith(color: _getTextColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: _getTextColor(context)),
            ),
          ),
          TextButton(
            onPressed: () {
              String nombreTurno = turno.nombre;

              viewModel.eliminarTurno(turno.id);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Turno "$nombreTurno" eliminado',
                    style: AppTextStyles.bodyDark(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text(
              'Eliminar',
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Diálogo para agregar/modificar turnos (MANTIENE TU DISEÑO ORIGINAL)
class _TurnoDialog extends StatefulWidget {
  final String title;
  final String? nombreInicial;
  final IconData? iconoInicial;
  final String? horarioInicial;
  final String? rangoAsistenciaInicial;
  final String? diasInicial;
  final String? colorInicial;
  final Function(
    String nombre,
    IconData icon,
    String horario,
    String rangoAsistencia,
    String dias,
    String color,
  )
  onSave;

  const _TurnoDialog({
    required this.title,
    this.nombreInicial,
    this.iconoInicial,
    this.horarioInicial,
    this.rangoAsistenciaInicial,
    this.diasInicial,
    this.colorInicial,
    required this.onSave,
  });

  @override
  State<_TurnoDialog> createState() => _TurnoDialogState();
}

class _TurnoDialogState extends State<_TurnoDialog> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();
  final TextEditingController _rangoAsistenciaController =
      TextEditingController();
  final TextEditingController _diasController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  IconData _iconoSeleccionado = Icons.wb_sunny;

  // Opciones predefinidas para turnos (TUS DATOS ORIGINALES)
  final List<Map<String, dynamic>> _turnosPredefinidos = [
    {
      'nombre': 'Mañana',
      'icon': Icons.wb_sunny,
      'horario': '08:00 - 13:00',
      'rangoAsistencia': '07:45 - 08:15',
      'dias': 'Lunes a Viernes',
      'color': '#FFA000',
    },
    {
      'nombre': 'Tarde',
      'icon': Icons.brightness_6,
      'horario': '14:00 - 18:00',
      'rangoAsistencia': '13:45 - 14:15',
      'dias': 'Lunes a Viernes',
      'color': '#FF9800',
    },
    {
      'nombre': 'Noche',
      'icon': Icons.nights_stay,
      'horario': '18:30 - 22:00',
      'rangoAsistencia': '18:30 - 19:30',
      'dias': 'Lunes a Viernes',
      'color': '#1565C0',
    },
    {
      'nombre': 'Sábados',
      'icon': Icons.weekend,
      'horario': '08:00 - 12:00',
      'rangoAsistencia': '07:45 - 08:30',
      'dias': 'Sábados',
      'color': '#4CAF50',
    },
    {
      'nombre': 'Intensivo',
      'icon': Icons.flash_on,
      'horario': '07:00 - 16:00',
      'rangoAsistencia': '06:45 - 07:15',
      'dias': 'Lunes a Sábado',
      'color': '#F44336',
    },
  ];

  // Íconos adicionales para turnos (TUS DATOS ORIGINALES)
  final List<Map<String, dynamic>> _iconosTurnos = [
    {'icon': Icons.wb_sunny, 'nombre': 'Mañana'},
    {'icon': Icons.brightness_6, 'nombre': 'Tarde'},
    {'icon': Icons.nights_stay, 'nombre': 'Noche'},
    {'icon': Icons.weekend, 'nombre': 'Fin de semana'},
    {'icon': Icons.flash_on, 'nombre': 'Intensivo'},
    {'icon': Icons.schedule, 'nombre': 'Horario'},
    {'icon': Icons.access_time, 'nombre': 'Tiempo'},
    {'icon': Icons.timelapse, 'nombre': 'Duración'},
  ];

  // Colores para turnos (TUS DATOS ORIGINALES)
  final List<Map<String, dynamic>> _coloresTurnos = [
    {'nombre': 'Naranja Mañana', 'color': '#FFA000'},
    {'nombre': 'Naranja Tarde', 'color': '#FF9800'},
    {'nombre': 'Azul Noche', 'color': '#1565C0'},
    {'nombre': 'Verde Sábados', 'color': '#4CAF50'},
    {'nombre': 'Rojo Intensivo', 'color': '#F44336'},
    {'nombre': 'Morado Especial', 'color': '#9C27B0'},
    {'nombre': 'Verde Claro', 'color': '#8BC34A'},
    {'nombre': 'Azul Claro', 'color': '#03A9F4'},
  ];

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.nombreInicial ?? '';
    _iconoSeleccionado = widget.iconoInicial ?? Icons.wb_sunny;
    _horarioController.text = widget.horarioInicial ?? '';
    _rangoAsistenciaController.text = widget.rangoAsistenciaInicial ?? '';
    _diasController.text = widget.diasInicial ?? 'Lunes a Viernes';
    _colorController.text = widget.colorInicial ?? '#FFA000';
  }

  void _seleccionarTurnoPredefinido(Map<String, dynamic> turno) {
    setState(() {
      _nombreController.text = turno['nombre'];
      _iconoSeleccionado = turno['icon'];
      _horarioController.text = turno['horario'];
      _rangoAsistenciaController.text = turno['rangoAsistencia'];
      _diasController.text = turno['dias'];
      _colorController.text = turno['color'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      title: Text(
        widget.title,
        style: AppTextStyles.heading2Dark(
          context,
        ).copyWith(color: _getTextColor(context)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TURNOS PREDEFINIDOS (TU DISEÑO ORIGINAL)
            Text(
              'Turnos predefinidos:',
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: _turnosPredefinidos.map((turno) {
                return FilterChip(
                  label: Text(
                    turno['nombre'],
                    style: AppTextStyles.bodyDark(context).copyWith(
                      color: _nombreController.text == turno['nombre']
                          ? _parseColor(turno['color'])
                          : _getTextColor(context),
                    ),
                  ),
                  selected: _nombreController.text == turno['nombre'],
                  onSelected: (selected) {
                    if (selected) {
                      _seleccionarTurnoPredefinido(turno);
                    }
                  },
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  selectedColor: _parseColor(turno['color']).withOpacity(0.2),
                  checkmarkColor: _parseColor(turno['color']),
                );
              }).toList(),
            ),

            SizedBox(height: AppSpacing.medium),
            Divider(color: _getBorderColor(context)),
            SizedBox(height: AppSpacing.medium),

            // NOMBRE DEL TURNO (TU DISEÑO ORIGINAL)
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del turno',
                labelStyle: AppTextStyles.bodyDark(context),
                hintText: 'Ej: Mañana, Tarde, Sábados, etc.',
                hintStyle: AppTextStyles.bodyDark(
                  context,
                ).copyWith(color: _getSecondaryTextColor(context)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
              ),
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: _getTextColor(context)),
            ),
            SizedBox(height: AppSpacing.small),

            // HORARIO (TU DISEÑO ORIGINAL)
            TextField(
              controller: _horarioController,
              decoration: InputDecoration(
                labelText: 'Horario (Ej: 08:00 - 13:00)',
                labelStyle: AppTextStyles.bodyDark(context),
                hintText: 'Formato: HH:MM - HH:MM',
                hintStyle: AppTextStyles.bodyDark(
                  context,
                ).copyWith(color: _getSecondaryTextColor(context)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
              ),
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: _getTextColor(context)),
            ),
            SizedBox(height: AppSpacing.small),

            // RANGO DE ASISTENCIA (TU DISEÑO ORIGINAL)
            TextField(
              controller: _rangoAsistenciaController,
              decoration: InputDecoration(
                labelText: 'Rango para registro de asistencia',
                labelStyle: AppTextStyles.bodyDark(context),
                hintText: 'Ej: 07:45 - 08:15',
                hintStyle: AppTextStyles.bodyDark(
                  context,
                ).copyWith(color: _getSecondaryTextColor(context)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
              ),
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: _getTextColor(context)),
            ),
            SizedBox(height: AppSpacing.small),

            // DÍAS (TU DISEÑO ORIGINAL)
            TextField(
              controller: _diasController,
              decoration: InputDecoration(
                labelText: 'Días de clase',
                labelStyle: AppTextStyles.bodyDark(context),
                hintText: 'Ej: Lunes a Viernes, Sábados, etc.',
                hintStyle: AppTextStyles.bodyDark(
                  context,
                ).copyWith(color: _getSecondaryTextColor(context)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
              ),
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: _getTextColor(context)),
            ),
            SizedBox(height: AppSpacing.medium),

            // SELECTOR DE ICONOS (TU DISEÑO ORIGINAL)
            Text(
              'Ícono del turno:',
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: _iconosTurnos.map((iconInfo) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _iconoSeleccionado = iconInfo['icon'];
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _iconoSeleccionado == iconInfo['icon']
                          ? _parseColor(_colorController.text).withOpacity(0.2)
                          : _getBackgroundColor(context),
                      borderRadius: BorderRadius.circular(24),
                      border: _iconoSeleccionado == iconInfo['icon']
                          ? Border.all(
                              color: _parseColor(_colorController.text),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Icon(
                      iconInfo['icon'],
                      color: _iconoSeleccionado == iconInfo['icon']
                          ? _parseColor(_colorController.text)
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: AppSpacing.medium),

            // SELECTOR DE COLORES (TU DISEÑO ORIGINAL)
            Text(
              'Color del turno:',
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: _coloresTurnos.map((colorInfo) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _colorController.text = colorInfo['color'];
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _parseColor(colorInfo['color']),
                      borderRadius: BorderRadius.circular(18),
                      border: _colorController.text == colorInfo['color']
                          ? Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              width: 3,
                            )
                          : null,
                    ),
                    child: _colorController.text == colorInfo['color']
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: AppSpacing.medium),

            // VISTA PREVIA (TU DISEÑO ORIGINAL)
            Container(
              padding: EdgeInsets.all(AppSpacing.medium),
              decoration: BoxDecoration(
                color: _getBackgroundColor(context),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: _getBorderColor(context)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _parseColor(_colorController.text),
                    child: Icon(_iconoSeleccionado, color: Colors.white),
                  ),
                  SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nombreController.text.isNotEmpty
                              ? 'Turno ${_nombreController.text}'
                              : 'Turno',
                          style: AppTextStyles.heading3Dark(
                            context,
                          ).copyWith(color: _getTextColor(context)),
                        ),
                        Text(
                          'Horario: ${_horarioController.text}',
                          style: AppTextStyles.bodyDark(
                            context,
                          ).copyWith(color: _getTextColor(context)),
                        ),
                        Text(
                          'Días: ${_diasController.text}',
                          style: AppTextStyles.bodyDark(
                            context,
                          ).copyWith(color: _getTextColor(context)),
                        ),
                        Text(
                          'Registro: ${_rangoAsistenciaController.text}',
                          style: AppTextStyles.bodyDark(
                            context,
                          ).copyWith(color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: AppTextStyles.bodyDark(
              context,
            ).copyWith(color: _getTextColor(context)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nombreController.text.isNotEmpty &&
                _horarioController.text.isNotEmpty &&
                _rangoAsistenciaController.text.isNotEmpty &&
                _diasController.text.isNotEmpty) {
              widget.onSave(
                _nombreController.text,
                _iconoSeleccionado,
                _horarioController.text,
                _rangoAsistenciaController.text,
                _diasController.text,
                _colorController.text,
              );
            }
          },
          child: Text(
            'Guardar',
            style: AppTextStyles.bodyDark(
              context,
            ).copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}
