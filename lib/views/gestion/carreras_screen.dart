import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'turnos_screen.dart';

class CarrerasScreen extends StatefulWidget {
  final String tipo;
  
  const CarrerasScreen({super.key, required this.tipo});

  @override
  State<CarrerasScreen> createState() => _CarrerasScreenState();
}

class _CarrerasScreenState extends State<CarrerasScreen> {
  // Lista de carreras con sus colores
  final List<Map<String, dynamic>> _carreras = [
    {
      'id': 1,
      'nombre': 'Sistemas Informáticos',
      'color': '#1565C0', // Azul
      'icon': Icons.computer,
    },
    {
      'id': 2,
      'nombre': 'Comercio Internacional',
      'color': '#FF9800', // Naranja
      'icon': Icons.business,
    },
    {
      'id': 3,
      'nombre': 'Secretariado Ejecutivo',
      'color': '#4CAF50', // Verde
      'icon': Icons.work,
    },
    {
      'id': 4,
      'nombre': 'Administración de Empresas',
      'color': '#03A9F4', // Celeste claro
      'icon': Icons.business_center,
    },
    {
      'id': 5,
      'nombre': 'Contaduría General',
      'color': '#FFEB3B', // Amarillo
      'icon': Icons.calculate,
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
      body: ListView.builder(
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
    
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(carrera['icon'], color: Colors.white),
        ),
        title: Text(
          carrera['nombre'],
          style: AppTextStyles.heading3,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, carrera),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(value: 'edit', child: Text('Modificar')),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TurnosScreen(
                tipo: widget.tipo,
                carrera: carrera,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> carrera) {
    switch (action) {
      case 'edit':
        _showEditarCarreraDialog(carrera);
        break;
      case 'delete':
        _showEliminarCarreraDialog(carrera);
        break;
    }
  }

  void _showAgregarCarreraDialog() {
    showDialog(
      context: context,
      builder: (context) => _CarreraDialog(
        title: 'Agregar Carrera',
        onSave: (nombre, color) {
          // Aquí agregarías la nueva carrera
          setState(() {
            _carreras.add({
              'id': DateTime.now().millisecondsSinceEpoch,
              'nombre': nombre,
              'color': color,
              'icon': Icons.school,
            });
          });
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
        onSave: (nombre, color) {
          setState(() {
            carrera['nombre'] = nombre;
            carrera['color'] = color;
          });
        },
      ),
    );
  }

  void _showEliminarCarreraDialog(Map<String, dynamic> carrera) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Carrera'),
        content: Text('¿Estás seguro de eliminar ${carrera['nombre']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _carreras.removeWhere((c) => c['id'] == carrera['id']);
              });
              Navigator.pop(context);
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
  final Function(String nombre, String color) onSave;

  const _CarreraDialog({
    required this.title,
    this.nombreInicial,
    this.colorInicial,
    required this.onSave,
  });

  @override
  State<_CarreraDialog> createState() => _CarreraDialogState();
}

class _CarreraDialogState extends State<_CarreraDialog> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  // Colores predefinidos para las carreras
  final List<Map<String, dynamic>> _coloresDisponibles = [
    {'nombre': 'Azul Sistemas', 'color': '#1565C0'},
    {'nombre': 'Naranja Comercio', 'color': '#FF9800'},
    {'nombre': 'Verde Secretariado', 'color': '#4CAF50'},
    {'nombre': 'Celeste Administración', 'color': '#03A9F4'},
    {'nombre': 'Amarillo Contaduría', 'color': '#FFEB3B'},
    {'nombre': 'Rojo Inglés', 'color': '#F44336'},
    {'nombre': 'Morado Derecho', 'color': '#9C27B0'},
  ];

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.nombreInicial ?? '';
    _colorController.text = widget.colorInicial ?? '#1565C0';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre de la carrera',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.medium),
            Text('Seleccionar color:'),
            SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              children: _coloresDisponibles.map((colorInfo) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _colorController.text = colorInfo['color'];
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _parseColor(colorInfo['color']),
                      borderRadius: BorderRadius.circular(20),
                      border: _colorController.text == colorInfo['color']
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
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
              widget.onSave(_nombreController.text, _colorController.text);
              Navigator.pop(context);
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