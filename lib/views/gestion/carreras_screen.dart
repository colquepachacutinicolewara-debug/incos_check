import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'docentes_screen.dart';
import 'turnos_screen.dart';
import '../../views/gestion/programas/programas_screen.dart'; // Importar ProgramasScreen

class CarrerasScreen extends StatefulWidget {
  final String tipo;
  final String carreraSeleccionada;
  final Function(List<String>)? onCarrerasActualizadas;
  final bool mostrarInformacionCarreras; // Nuevo parámetro

  const CarrerasScreen({
    super.key,
    required this.tipo,
    required this.carreraSeleccionada,
    this.onCarrerasActualizadas,
    this.mostrarInformacionCarreras = false, // Por defecto false
  });

  @override
  State<CarrerasScreen> createState() => _CarrerasScreenState();
}

class _CarrerasScreenState extends State<CarrerasScreen> {
  List<Map<String, dynamic>> _carreras = [
    {
      'id': 1,
      'nombre': 'Sistemas Informáticos',
      'color': '#1565C0',
      'icon': Icons.computer,
      'activa': true,
    },
  ];

  // Método para notificar cambios
  void _notificarCambiosCarreras() {
    if (widget.onCarrerasActualizadas != null) {
      List<String> nombresCarreras = _carreras
          .where((carrera) => carrera['activa'] == true)
          .map((carrera) => carrera['nombre'] as String)
          .toList();
      widget.onCarrerasActualizadas!(nombresCarreras);
    }
  }

  @override
  void initState() {
    super.initState();
    _notificarCambiosCarreras(); // Notificar al iniciar
  }

  @override
  Widget build(BuildContext context) {
    // SI ES PARA MOSTRAR INFORMACIÓN DE CARRERAS, MOSTRAR ProgramasScreen
    if (widget.mostrarInformacionCarreras) {
      return ProgramasScreen(); // Tu pantalla existente con información
    }

    // SI NO, MOSTRAR LA GESTIÓN NORMAL DE CARRERAS (TU FUNCIONALIDAD ORIGINAL)
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carreras - ${widget.tipo}',
          style: AppTextStyles.heading2Dark(
            context,
          ).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
      ),
      body: _carreras.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school,
                    size: 64,
                    color: AppColors.textSecondaryDark(context),
                  ),
                  SizedBox(height: AppSpacing.medium),
                  Text(
                    'No hay carreras registradas',
                    style: AppTextStyles.bodyDark(
                      context,
                    ).copyWith(color: AppColors.textSecondaryDark(context)),
                  ),
                  Text(
                    'Presiona el botón + para agregar una carrera',
                    style: AppTextStyles.bodyDark(context).copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark(context),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacing.medium),
              itemCount: _carreras.length,
              itemBuilder: (context, index) {
                final carrera = _carreras[index];
                return _buildCarreraCard(carrera, context);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAgregarCarreraDialog,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCarreraCard(Map<String, dynamic> carrera, BuildContext context) {
    Color color = _parseColor(carrera['color']);
    bool isActiva = carrera['activa'] ?? false;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      color: isActiva
          ? Theme.of(context).cardColor
          : Colors.grey.shade300.withOpacity(0.5),
      child: Container(
        height: 80,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isActiva ? color : Colors.grey,
            child: Icon(carrera['icon'], color: Colors.white),
          ),
          title: Container(
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        carrera['nombre'],
                        style: AppTextStyles.heading3Dark(context).copyWith(
                          color: isActiva
                              ? _getTextColor(context)
                              : AppColors.textSecondaryDark(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isActiva) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Inactiva',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, carrera),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(
                  'Modificar',
                  style: AppTextStyles.bodyDark(
                    context,
                  ).copyWith(color: _getTextColor(context)),
                ),
              ),
              PopupMenuItem(
                value: 'toggle_active',
                child: Text(
                  carrera['activa'] ? 'Desactivar' : 'Activar',
                  style: AppTextStyles.bodyDark(
                    context,
                  ).copyWith(color: _getTextColor(context)),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Eliminar',
                  style: AppTextStyles.bodyDark(
                    context,
                  ).copyWith(color: _getTextColor(context)),
                ),
              ),
            ],
          ),
          onTap: isActiva
              ? () {
                  if (widget.tipo == 'Docentes') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocentesScreen(carrera: carrera),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TurnosScreen(tipo: widget.tipo, carrera: carrera),
                      ),
                    );
                  }
                }
              : null,
        ),
      ),
    );
  }

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  void _handleMenuAction(String action, Map<String, dynamic> carrera) {
    switch (action) {
      case 'edit':
        _showEditarCarreraDialog(carrera);
        break;
      case 'toggle_active':
        _toggleActivarCarrera(carrera);
        break;
      case 'delete':
        _showEliminarCarreraDialog(carrera);
        break;
    }
  }

  void _toggleActivarCarrera(Map<String, dynamic> carrera) {
    setState(() {
      carrera['activa'] = !(carrera['activa'] ?? false);
    });

    _notificarCambiosCarreras(); // ← NOTIFICAR CAMBIO

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${carrera['nombre']} ${carrera['activa'] ? 'activada' : 'desactivada'}',
          style: AppTextStyles.bodyDark(context).copyWith(color: Colors.white),
        ),
        backgroundColor: carrera['activa']
            ? AppColors.success
            : AppColors.warning,
      ),
    );
  }

  void _showAgregarCarreraDialog() {
    showDialog(
      context: context,
      builder: (context) => _CarreraDialog(
        title: 'Agregar Carrera',
        onSave: (nombre, color, icono) {
          setState(() {
            _carreras.add({
              'id': DateTime.now().millisecondsSinceEpoch,
              'nombre': nombre,
              'color': color,
              'icon': icono,
              'activa': true,
            });
          });

          _notificarCambiosCarreras(); // ← NOTIFICAR CAMBIO

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Carrera "$nombre" agregada correctamente',
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

  void _showEditarCarreraDialog(Map<String, dynamic> carrera) {
    showDialog(
      context: context,
      builder: (context) => _CarreraDialog(
        title: 'Modificar Carrera',
        nombreInicial: carrera['nombre'],
        colorInicial: carrera['color'],
        iconoInicial: carrera['icon'],
        onSave: (nombre, color, icono) {
          setState(() {
            carrera['nombre'] = nombre;
            carrera['color'] = color;
            carrera['icon'] = icono;
          });

          _notificarCambiosCarreras(); // ← NOTIFICAR CAMBIO

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Carrera "$nombre" modificada correctamente',
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

  void _showEliminarCarreraDialog(Map<String, dynamic> carrera) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Eliminar Carrera',
          style: AppTextStyles.heading2Dark(
            context,
          ).copyWith(color: _getTextColor(context)),
        ),
        content: Text(
          '¿Estás seguro de eliminar la carrera "${carrera['nombre']}"? Esta acción no se puede deshacer.',
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
              String nombreCarrera = carrera['nombre'];
              setState(() {
                _carreras.removeWhere((c) => c['id'] == carrera['id']);
              });

              _notificarCambiosCarreras(); // ← NOTIFICAR CAMBIO

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Carrera "$nombreCarrera" eliminada',
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

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}

// Diálogo para agregar/modificar carreras
class _CarreraDialog extends StatefulWidget {
  final String title;
  final String? nombreInicial;
  final String? colorInicial;
  final IconData? iconoInicial;
  final Function(String nombre, String color, IconData icono) onSave;

  const _CarreraDialog({
    required this.title,
    this.nombreInicial,
    this.colorInicial,
    this.iconoInicial,
    required this.onSave,
  });

  @override
  State<_CarreraDialog> createState() => _CarreraDialogState();
}

class _CarreraDialogState extends State<_CarreraDialog> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  IconData _iconoSeleccionado = Icons.school;
  bool _mostrarMasIconos = false;
  bool _mostrarMasColores = false;

  final List<Map<String, dynamic>> _carrerasPredefinidas = [
    {
      'nombre': 'Sistemas Informáticos',
      'color': '#1565C0',
      'icon': Icons.computer,
    },
    {
      'nombre': 'Comercio Internacional y Administración Aduanera',
      'color': '#FF9800',
      'icon': Icons.business,
    },
    {
      'nombre': 'Secretariado Ejecutivo',
      'color': '#4CAF50',
      'icon': Icons.work,
    },
    {
      'nombre': 'Administración de Empresas',
      'color': '#03A9F4',
      'icon': Icons.business_center,
    },
    {
      'nombre': 'Contaduría General',
      'color': '#FFEB3B',
      'icon': Icons.calculate,
    },
    {'nombre': 'Idioma Inglés', 'color': '#F44336', 'icon': Icons.language},
  ];

  final List<Map<String, dynamic>> _coloresDisponibles = [
    {'nombre': 'Azul Sistemas', 'color': '#1565C0'},
    {'nombre': 'Naranja Comercio', 'color': '#FF9800'},
    {'nombre': 'Verde Secretariado', 'color': '#4CAF50'},
    {'nombre': 'Celeste Administración', 'color': '#03A9F4'},
    {'nombre': 'Amarillo Contaduría', 'color': '#FFEB3B'},
    {'nombre': 'Rojo Inglés', 'color': '#F44336'},
  ];

  final List<Map<String, dynamic>> _masColores = [
    {'nombre': 'Morado', 'color': '#9C27B0'},
    {'nombre': 'Rosa', 'color': '#E91E63'},
    {'nombre': 'Café', 'color': '#795548'},
    {'nombre': 'Verde Oscuro', 'color': '#2E7D32'},
    {'nombre': 'Azul Oscuro', 'color': '#0D47A1'},
    {'nombre': 'Verde Lima', 'color': '#CDDC39'},
    {'nombre': 'Azul Claro', 'color': '#29B6F6'},
    {'nombre': 'Verde Esmeralda', 'color': '#009688'},
    {'nombre': 'Naranja Oscuro', 'color': '#E65100'},
    {'nombre': 'Rojo Oscuro', 'color': '#C62828'},
    {'nombre': 'Rosa Fuerte', 'color': '#AD1457'},
    {'nombre': 'Morado Oscuro', 'color': '#6A1B9A'},
    {'nombre': 'Gris Azulado', 'color': '#546E7A'},
    {'nombre': 'Cyan', 'color': '#00BCD4'},
    {'nombre': 'Teal', 'color': '#00695C'},
    {'nombre': 'Deep Orange', 'color': '#FF5722'},
  ];

  final List<Map<String, dynamic>> _iconosDisponibles = [
    {'icon': Icons.computer, 'nombre': 'Sistemas'},
    {'icon': Icons.business, 'nombre': 'Comercio'},
    {'icon': Icons.work, 'nombre': 'Secretariado'},
    {'icon': Icons.business_center, 'nombre': 'Administración'},
    {'icon': Icons.calculate, 'nombre': 'Contaduría'},
    {'icon': Icons.language, 'nombre': 'Idiomas'},
    {'icon': Icons.school, 'nombre': 'General'},
    {'icon': Icons.engineering, 'nombre': 'Ingeniería'},
    {'icon': Icons.medical_services, 'nombre': 'Medicina'},
    {'icon': Icons.gavel, 'nombre': 'Derecho'},
    {'icon': Icons.psychology, 'nombre': 'Psicología'},
    {'icon': Icons.architecture, 'nombre': 'Arquitectura'},
  ];

  final List<Map<String, dynamic>> _masIconos = [
    {'icon': Icons.music_note, 'nombre': 'Música'},
    {'icon': Icons.palette, 'nombre': 'Arte'},
    {'icon': Icons.sports_soccer, 'nombre': 'Deportes'},
    {'icon': Icons.theater_comedy, 'nombre': 'Teatro'},
    {'icon': Icons.camera_alt, 'nombre': 'Fotografía'},
    {'icon': Icons.movie, 'nombre': 'Cine'},
    {'icon': Icons.restaurant, 'nombre': 'Gastronomía'},
    {'icon': Icons.directions_car, 'nombre': 'Automotriz'},
    {'icon': Icons.flight, 'nombre': 'Aviación'},
    {'icon': Icons.local_shipping, 'nombre': 'Logística'},
    {'icon': Icons.agriculture, 'nombre': 'Agronomía'},
    {'icon': Icons.forest, 'nombre': 'Ambiental'},
    {'icon': Icons.biotech, 'nombre': 'Biotecnología'},
    {'icon': Icons.phone_android, 'nombre': 'Móviles'},
    {'icon': Icons.security, 'nombre': 'Seguridad'},
    {'icon': Icons.analytics, 'nombre': 'Analítica'},
    {'icon': Icons.cloud, 'nombre': 'Cloud'},
    {'icon': Icons.router, 'nombre': 'Redes'},
    {'icon': Icons.videogame_asset, 'nombre': 'Videojuegos'},
    {'icon': Icons.design_services, 'nombre': 'Diseño'},
    {'icon': Icons.science, 'nombre': 'Ciencia'},
    {'icon': Icons.biotech, 'nombre': 'Biotecnología'},
    {'icon': Icons.local_hospital, 'nombre': 'Enfermería'},
    {'icon': Icons.healing, 'nombre': 'Farmacia'},
    {'icon': Icons.eco, 'nombre': 'Ambiental'},
    {'icon': Icons.construction, 'nombre': 'Construcción'},
    {'icon': Icons.electrical_services, 'nombre': 'Electricidad'},
    {'icon': Icons.plumbing, 'nombre': 'Plomería'},
    {'icon': Icons.directions_boat, 'nombre': 'Marítima'},
    {'icon': Icons.temple_buddhist, 'nombre': 'Turismo'},
    {'icon': Icons.hotel, 'nombre': 'Hotelería'},
    {'icon': Icons.spa, 'nombre': 'Belleza'},
  ];

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.nombreInicial ?? '';
    _colorController.text = widget.colorInicial ?? '#1565C0';
    _iconoSeleccionado = widget.iconoInicial ?? Icons.school;
  }

  List<Map<String, dynamic>> get _coloresVisibles {
    final coloresBase = _carrerasPredefinidas
        .map((c) => {'nombre': c['nombre'], 'color': c['color']})
        .toList();

    return _mostrarMasColores ? [...coloresBase, ..._masColores] : coloresBase;
  }

  List<Map<String, dynamic>> get _iconosVisibles {
    final iconosBase = _carrerasPredefinidas
        .map((c) => {'icon': c['icon'], 'nombre': c['nombre']})
        .toList();

    return _mostrarMasIconos
        ? [...iconosBase, ..._iconosDisponibles, ..._masIconos]
        : [...iconosBase, ..._iconosDisponibles];
  }

  void _seleccionarCarreraPredefinida(Map<String, dynamic> carrera) {
    setState(() {
      _nombreController.text = carrera['nombre'];
      _colorController.text = carrera['color'];
      _iconoSeleccionado = carrera['icon'];
    });
  }

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
            Text(
              'Carreras predefinidas:',
              style: AppTextStyles.bodyDark(context).copyWith(
                fontWeight: FontWeight.bold,
                color: _getTextColor(context),
              ),
            ),
            SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: _carrerasPredefinidas.map((carrera) {
                return Container(
                  margin: EdgeInsets.only(bottom: 4),
                  child: FilterChip(
                    label: Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: Text(
                        carrera['nombre'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyDark(context).copyWith(
                          color: _nombreController.text == carrera['nombre']
                              ? _parseColor(carrera['color'])
                              : _getTextColor(context),
                        ),
                      ),
                    ),
                    selected: _nombreController.text == carrera['nombre'],
                    onSelected: (selected) {
                      if (selected) {
                        _seleccionarCarreraPredefinida(carrera);
                      }
                    },
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    selectedColor: _parseColor(
                      carrera['color'],
                    ).withOpacity(0.2),
                    checkmarkColor: _parseColor(carrera['color']),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: AppSpacing.medium),
            Divider(color: _getSecondaryTextColor(context)),
            SizedBox(height: AppSpacing.medium),

            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre de la carrera',
                labelStyle: AppTextStyles.bodyDark(
                  context,
                ).copyWith(color: _getTextColor(context)),
                border: OutlineInputBorder(),
                hintText: 'O escribe un nombre personalizado',
                hintStyle: AppTextStyles.bodyDark(
                  context,
                ).copyWith(color: _getSecondaryTextColor(context)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _getSecondaryTextColor(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: _getTextColor(context)),
              maxLines: 2,
            ),
            SizedBox(height: AppSpacing.medium),

            Row(
              children: [
                Text(
                  'Colores:',
                  style: AppTextStyles.bodyDark(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _mostrarMasColores = !_mostrarMasColores;
                    });
                  },
                  child: Text(
                    _mostrarMasColores ? 'Menos colores' : 'Más colores +',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: _coloresVisibles.map((colorInfo) {
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
                          ? Border.all(color: Colors.white, width: 3)
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

            Row(
              children: [
                Text(
                  'Íconos:',
                  style: AppTextStyles.bodyDark(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _mostrarMasIconos = !_mostrarMasIconos;
                    });
                  },
                  child: Text(
                    _mostrarMasIconos ? 'Menos íconos' : 'Más íconos +',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: _iconosVisibles.map((iconInfo) {
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
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
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

            Container(
              padding: EdgeInsets.all(AppSpacing.medium),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade600
                      : Colors.grey.shade300,
                ),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nombreController.text.isNotEmpty
                              ? _nombreController.text
                              : 'Nombre de la carrera',
                          style: AppTextStyles.heading3Dark(
                            context,
                          ).copyWith(color: _getTextColor(context)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Vista previa',
                          style: AppTextStyles.bodyDark(
                            context,
                          ).copyWith(color: _getSecondaryTextColor(context)),
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
            if (_nombreController.text.isNotEmpty) {
              widget.onSave(
                _nombreController.text,
                _colorController.text,
                _iconoSeleccionado,
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
