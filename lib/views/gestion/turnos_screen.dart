import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/data_manager.dart';
import 'niveles_screen.dart';

class TurnosScreen extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic> carrera;

  const TurnosScreen({super.key, required this.tipo, required this.carrera});

  @override
  State<TurnosScreen> createState() => _TurnosScreenState();
}

class _TurnosScreenState extends State<TurnosScreen> {
  final DataManager _dataManager = DataManager();
  late List<Map<String, dynamic>> _turnos;

  @override
  void initState() {
    super.initState();
    // Inicializar la carrera si no existe
    _dataManager.inicializarCarrera(
      widget.carrera['id'].toString(),
      widget.carrera['nombre'],
      widget.carrera['color'],
    );
    // Obtener los turnos de esta carrera específica
    _turnos = _dataManager.getTurnos(widget.carrera['id'].toString());

    // Si no hay turnos, agregar algunos por defecto
    if (_turnos.isEmpty) {
      _agregarTurnosPorDefecto();
    }
  }

  void _agregarTurnosPorDefecto() {
    final turnosPorDefecto = [
      {
        'id': '${widget.carrera['id']}_manana',
        'nombre': 'Mañana',
        'icon': Icons.wb_sunny,
        'horario': '08:00 - 13:00',
        'rangoAsistencia': '07:45 - 08:15',
        'dias': 'Lunes a Viernes',
        'color': '#FFA000',
        'activo': true,
        'niveles': [], // Inicializar niveles vacíos
      },
      {
        'id': '${widget.carrera['id']}_noche',
        'nombre': 'Noche',
        'icon': Icons.nights_stay,
        'horario': '18:30 - 22:00',
        'rangoAsistencia': '18:30 - 19:30',
        'dias': 'Lunes a Viernes',
        'color': '#1565C0',
        'activo': true,
        'niveles': [], // Inicializar niveles vacíos
      },
    ];

    for (var turno in turnosPorDefecto) {
      _dataManager.agregarTurno(widget.carrera['id'].toString(), turno);
    }

    setState(() {
      _turnos = _dataManager.getTurnos(widget.carrera['id'].toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    Color carreraColor = _parseColor(widget.carrera['color']);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.carrera['nombre']} - Turnos',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: carreraColor,
      ),
      body: _turnos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay turnos configurados',
                    style: AppTextStyles.heading3,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Presiona el botón + para agregar un turno',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacing.medium),
              itemCount: _turnos.length,
              itemBuilder: (context, index) {
                final turno = _turnos[index];
                return _buildTurnoCard(turno, context, carreraColor);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAgregarTurnoDialog,
        backgroundColor: carreraColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTurnoCard(
    Map<String, dynamic> turno,
    BuildContext context,
    Color color,
  ) {
    Color turnoColor = _parseColor(turno['color']);
    bool isActivo = turno['activo'] ?? false;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      color: isActivo ? null : Colors.grey.shade100,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActivo ? turnoColor : Colors.grey,
          child: Icon(turno['icon'], color: Colors.white),
        ),
        title: Row(
          children: [
            Text(
              'Turno ${turno['nombre']}',
              style: AppTextStyles.heading3.copyWith(
                color: isActivo ? null : Colors.grey,
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
              'Horario: ${turno['horario']}',
              style: AppTextStyles.body.copyWith(
                color: isActivo ? null : Colors.grey,
              ),
            ),
            Text(
              'Días: ${turno['dias']}',
              style: AppTextStyles.body.copyWith(
                color: isActivo ? null : Colors.grey,
              ),
            ),
            Text(
              'Registro: ${turno['rangoAsistencia']}',
              style: AppTextStyles.body.copyWith(
                color: isActivo ? AppColors.success : Colors.grey,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, turno),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(value: 'edit', child: Text('Modificar')),
            PopupMenuItem(
              value: 'toggle_active',
              child: Text(turno['activo'] ? 'Desactivar' : 'Activar'),
            ),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
        onTap: isActivo
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NivelesScreen(
                      tipo: widget.tipo,
                      carrera: widget.carrera,
                      turno: turno,
                    ),
                  ),
                );
              }
            : null,
      ),
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> turno) {
    switch (action) {
      case 'edit':
        _showEditarTurnoDialog(turno);
        break;
      case 'toggle_active':
        _toggleActivarTurno(turno);
        break;
      case 'delete':
        _showEliminarTurnoDialog(turno);
        break;
    }
  }

  void _toggleActivarTurno(Map<String, dynamic> turno) {
    final turnoActualizado = Map<String, dynamic>.from(turno);
    turnoActualizado['activo'] = !(turno['activo'] ?? false);

    _dataManager.actualizarTurno(
      widget.carrera['id'].toString(),
      turno['id'].toString(),
      turnoActualizado,
    );

    setState(() {
      _turnos = _dataManager.getTurnos(widget.carrera['id'].toString());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Turno ${turno['nombre']} ${turnoActualizado['activo'] ? 'activado' : 'desactivado'}',
        ),
        backgroundColor: turnoActualizado['activo']
            ? AppColors.success
            : AppColors.warning,
      ),
    );
  }

  void _showAgregarTurnoDialog() {
    showDialog(
      context: context,
      builder: (context) => _TurnoDialog(
        title: 'Agregar Turno',
        onSave: (nombre, icon, horario, rangoAsistencia, dias, color) {
          final nuevoTurno = {
            'id':
                '${widget.carrera['id']}_${DateTime.now().millisecondsSinceEpoch}',
            'nombre': nombre,
            'icon': icon,
            'horario': horario,
            'rangoAsistencia': rangoAsistencia,
            'dias': dias,
            'color': color,
            'activo': true,
            'niveles': [], // Inicializar niveles vacíos
          };

          _dataManager.agregarTurno(
            widget.carrera['id'].toString(),
            nuevoTurno,
          );

          setState(() {
            _turnos = _dataManager.getTurnos(widget.carrera['id'].toString());
          });

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Turno "$nombre" agregado correctamente'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _showEditarTurnoDialog(Map<String, dynamic> turno) {
    showDialog(
      context: context,
      builder: (context) => _TurnoDialog(
        title: 'Modificar Turno',
        nombreInicial: turno['nombre'],
        iconoInicial: turno['icon'],
        horarioInicial: turno['horario'],
        rangoAsistenciaInicial: turno['rangoAsistencia'],
        diasInicial: turno['dias'],
        colorInicial: turno['color'],
        onSave: (nombre, icon, horario, rangoAsistencia, dias, color) {
          final turnoActualizado = Map<String, dynamic>.from(turno);
          turnoActualizado['nombre'] = nombre;
          turnoActualizado['icon'] = icon;
          turnoActualizado['horario'] = horario;
          turnoActualizado['rangoAsistencia'] = rangoAsistencia;
          turnoActualizado['dias'] = dias;
          turnoActualizado['color'] = color;

          _dataManager.actualizarTurno(
            widget.carrera['id'].toString(),
            turno['id'].toString(),
            turnoActualizado,
          );

          setState(() {
            _turnos = _dataManager.getTurnos(widget.carrera['id'].toString());
          });

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Turno "$nombre" modificado correctamente'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _showEliminarTurnoDialog(Map<String, dynamic> turno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Turno'),
        content: Text(
          '¿Estás seguro de eliminar el Turno ${turno['nombre']}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              String nombreTurno = turno['nombre'];

              _dataManager.eliminarTurno(
                widget.carrera['id'].toString(),
                turno['id'].toString(),
              );

              setState(() {
                _turnos = _dataManager.getTurnos(
                  widget.carrera['id'].toString(),
                );
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Turno "$nombreTurno" eliminado'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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

// Diálogo para agregar/modificar turnos
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

  // Opciones predefinidas para turnos
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

  // Íconos adicionales para turnos
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

  // Colores para turnos
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
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TURNOS PREDEFINIDOS
            Text(
              'Turnos predefinidos:',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: _turnosPredefinidos.map((turno) {
                return FilterChip(
                  label: Text(turno['nombre']),
                  selected: _nombreController.text == turno['nombre'],
                  onSelected: (selected) {
                    if (selected) {
                      _seleccionarTurnoPredefinido(turno);
                    }
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: _parseColor(turno['color']).withOpacity(0.2),
                  checkmarkColor: _parseColor(turno['color']),
                  labelStyle: TextStyle(
                    color: _nombreController.text == turno['nombre']
                        ? _parseColor(turno['color'])
                        : Colors.black87,
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: AppSpacing.medium),
            Divider(),
            SizedBox(height: AppSpacing.medium),

            // NOMBRE DEL TURNO
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del turno',
                border: OutlineInputBorder(),
                hintText: 'Ej: Mañana, Tarde, Sábados, etc.',
              ),
            ),
            SizedBox(height: AppSpacing.small),

            // HORARIO
            TextField(
              controller: _horarioController,
              decoration: InputDecoration(
                labelText: 'Horario (Ej: 08:00 - 13:00)',
                border: OutlineInputBorder(),
                hintText: 'Formato: HH:MM - HH:MM',
              ),
            ),
            SizedBox(height: AppSpacing.small),

            // RANGO DE ASISTENCIA
            TextField(
              controller: _rangoAsistenciaController,
              decoration: InputDecoration(
                labelText: 'Rango para registro de asistencia',
                border: OutlineInputBorder(),
                hintText: 'Ej: 07:45 - 08:15',
              ),
            ),
            SizedBox(height: AppSpacing.small),

            // DÍAS
            TextField(
              controller: _diasController,
              decoration: InputDecoration(
                labelText: 'Días de clase',
                border: OutlineInputBorder(),
                hintText: 'Ej: Lunes a Viernes, Sábados, etc.',
              ),
            ),
            SizedBox(height: AppSpacing.medium),

            // SELECTOR DE ICONOS
            Text(
              'Ícono del turno:',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
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
                          : Colors.grey.shade100,
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
                          : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: AppSpacing.medium),

            // SELECTOR DE COLORES
            Text(
              'Color del turno:',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
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
                          ? Border.all(color: Colors.black, width: 3)
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

            // VISTA PREVIA
            Container(
              padding: EdgeInsets.all(AppSpacing.medium),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: Colors.grey.shade300),
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
                          style: AppTextStyles.heading3,
                        ),
                        Text(
                          'Horario: ${_horarioController.text}',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          'Días: ${_diasController.text}',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          'Registro: ${_rangoAsistenciaController.text}',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.success,
                          ),
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
          child: Text('Cancelar'),
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
          child: Text('Guardar'),
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
