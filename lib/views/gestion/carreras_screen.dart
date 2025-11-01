import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'docentes_screen.dart';
import 'turnos_screen.dart';

class CarrerasScreen extends StatefulWidget {
  final String tipo;

  const CarrerasScreen({super.key, required this.tipo});

  @override
  State<CarrerasScreen> createState() => _CarrerasScreenState();
}

class _CarrerasScreenState extends State<CarrerasScreen> {
  // CORRECCIÓN: Cambiar final por List para que sea mutable
  List<Map<String, dynamic>> _carreras = [
    {
      'id': 1,
      'nombre': 'Sistemas Informáticos',
      'color': '#1565C0',
      'icon': Icons.computer,
      'activa': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carreras - ${widget.tipo}',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
      ),
      body: _carreras.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: AppSpacing.medium),
                  Text(
                    'No hay carreras registradas',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Presiona el botón + para agregar una carrera',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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
      color: isActiva ? null : Colors.grey.shade100,
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
                        style: AppTextStyles.heading3.copyWith(
                          color: isActiva ? null : Colors.grey,
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
              PopupMenuItem(value: 'edit', child: Text('Modificar')),
              PopupMenuItem(
                value: 'toggle_active',
                child: Text(carrera['activa'] ? 'Desactivar' : 'Activar'),
              ),
              PopupMenuItem(value: 'delete', child: Text('Eliminar')),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${carrera['nombre']} ${carrera['activa'] ? 'activada' : 'desactivada'}',
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
              'activa':
                  true, // Cambiado a true para que esté activa por defecto
            });
          });

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Carrera "$nombre" agregada correctamente'),
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

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Carrera "$nombre" modificada correctamente'),
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
        title: Text('Eliminar Carrera'),
        content: Text(
          '¿Estás seguro de eliminar la carrera "${carrera['nombre']}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              String nombreCarrera = carrera['nombre'];
              setState(() {
                _carreras.removeWhere((c) => c['id'] == carrera['id']);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Carrera "$nombreCarrera" eliminada'),
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

  // CARRERAS PREDEFINIDAS CON SUS COLORES E ICONOS
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

  // TODOS los colores disponibles
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

  // TODOS los íconos disponibles
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Carreras predefinidas:',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
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
                      ),
                    ),
                    selected: _nombreController.text == carrera['nombre'],
                    onSelected: (selected) {
                      if (selected) {
                        _seleccionarCarreraPredefinida(carrera);
                      }
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: _parseColor(
                      carrera['color'],
                    ).withOpacity(0.2),
                    checkmarkColor: _parseColor(carrera['color']),
                    labelStyle: TextStyle(
                      color: _nombreController.text == carrera['nombre']
                          ? _parseColor(carrera['color'])
                          : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: AppSpacing.medium),
            Divider(),
            SizedBox(height: AppSpacing.medium),

            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre de la carrera',
                border: OutlineInputBorder(),
                hintText: 'O escribe un nombre personalizado',
              ),
              maxLines: 2,
            ),
            SizedBox(height: AppSpacing.medium),

            Row(
              children: [
                Text(
                  'Colores:',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
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

            Row(
              children: [
                Text(
                  'Íconos:',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nombreController.text.isNotEmpty
                              ? _nombreController.text
                              : 'Nombre de la carrera',
                          style: AppTextStyles.heading3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text('Vista previa', style: AppTextStyles.body),
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
            if (_nombreController.text.isNotEmpty) {
              widget.onSave(
                _nombreController.text,
                _colorController.text,
                _iconoSeleccionado,
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
