import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/data_manager.dart';
import '../../views/gestion/estudiantes_screen.dart';

class ParalelosScreen extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;
  final Map<String, dynamic> nivel;

  const ParalelosScreen({
    super.key,
    required this.tipo,
    required this.carrera,
    required this.turno,
    required this.nivel,
  });

  @override
  State<ParalelosScreen> createState() => _ParalelosScreenState();
}

class _ParalelosScreenState extends State<ParalelosScreen> {
  List<Map<String, dynamic>> _paralelos = [
    {'id': 2, 'nombre': 'B', 'activo': true},
  ];

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _editarNombreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Color carreraColor = _parseColor(widget.carrera['color']);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.carrera['nombre']} - ${widget.turno['nombre']} - ${widget.nivel['nombre']}',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: carreraColor,
      ),
      body: _paralelos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_outlined, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No hay paralelos',
                    style: AppTextStyles.heading3.copyWith(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Presiona el botón + para agregar el primer paralelo',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacing.medium),
              itemCount: _paralelos.length,
              itemBuilder: (context, index) {
                final paralelo = _paralelos[index];
                return _buildParaleloCard(paralelo, context, carreraColor);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAgregarParaleloDialog,
        backgroundColor: carreraColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildParaleloCard(
    Map<String, dynamic> paralelo,
    BuildContext context,
    Color color,
  ) {
    bool isActive = paralelo['activo'] ?? true;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            paralelo['nombre'],
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          'Paralelo ${paralelo['nombre']}',
          style: AppTextStyles.heading3.copyWith(
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Text(
          isActive ? 'Activo' : 'Inactivo',
          style: TextStyle(color: isActive ? Colors.green : Colors.red),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: isActive,
              onChanged: (value) {
                setState(() {
                  paralelo['activo'] = value;
                });
              },
              activeColor: color,
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, paralelo),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(value: 'edit', child: Text('Modificar')),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
        onTap: () {
          if (isActive) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EstudiantesListScreen(
                  tipo: widget.tipo,
                  carrera: widget.carrera,
                  turno: widget.turno,
                  nivel: widget.nivel,
                  paralelo: paralelo,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> paralelo) {
    switch (action) {
      case 'edit':
        _showEditarParaleloDialog(paralelo);
        break;
      case 'delete':
        _showEliminarParaleloDialog(paralelo);
        break;
    }
  }

  void _showAgregarParaleloDialog() {
    _nombreController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Nuevo Paralelo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Letra del Paralelo',
                hintText: 'Ej: A, C, D, etc.',
                border: OutlineInputBorder(),
                counterText: 'Máximo 2 caracteres',
              ),
              maxLength: 2,
              textCapitalization: TextCapitalization.characters,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ingresa una letra para el paralelo (A, B, C, etc.)',
                      style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nombreController.text.trim().isNotEmpty) {
                _agregarParalelo(_nombreController.text.trim().toUpperCase());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _parseColor(widget.carrera['color']),
            ),
            child: Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _agregarParalelo(String nombre) {
    // Verificar si ya existe un paralelo con ese nombre
    bool existe = _paralelos.any((p) => p['nombre'] == nombre);

    if (existe) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ya existe un paralelo con la letra $nombre'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      int nuevoId = _paralelos.isNotEmpty
          ? _paralelos
                    .map((p) => p['id'] as int)
                    .reduce((a, b) => a > b ? a : b) +
                1
          : 1;

      _paralelos.add({'id': nuevoId, 'nombre': nombre, 'activo': true});

      // Ordenar paralelos alfabéticamente
      _paralelos.sort((a, b) => a['nombre'].compareTo(b['nombre']));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paralelo $nombre agregado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showEditarParaleloDialog(Map<String, dynamic> paralelo) {
    _editarNombreController.text = paralelo['nombre'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modificar Paralelo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _editarNombreController,
              decoration: InputDecoration(
                labelText: 'Letra del Paralelo',
                border: OutlineInputBorder(),
                counterText: 'Máximo 2 caracteres',
              ),
              maxLength: 2,
              textCapitalization: TextCapitalization.characters,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Modifica la letra del paralelo',
                      style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_editarNombreController.text.trim().isNotEmpty) {
                _editarParalelo(
                  paralelo,
                  _editarNombreController.text.trim().toUpperCase(),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _parseColor(widget.carrera['color']),
            ),
            child: Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editarParalelo(Map<String, dynamic> paralelo, String nuevoNombre) {
    // Verificar si ya existe otro paralelo con ese nombre (excluyendo el actual)
    bool existe = _paralelos.any(
      (p) => p['nombre'] == nuevoNombre && p['id'] != paralelo['id'],
    );

    if (existe) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ya existe un paralelo con la letra $nuevoNombre'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      paralelo['nombre'] = nuevoNombre;

      // Reordenar después de editar
      _paralelos.sort((a, b) => a['nombre'].compareTo(b['nombre']));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paralelo actualizado a $nuevoNombre'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showEliminarParaleloDialog(Map<String, dynamic> paralelo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Paralelo'),
        content: Text(
          '¿Estás seguro de eliminar el Paralelo ${paralelo['nombre']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              String nombreEliminado = paralelo['nombre'];
              setState(() {
                _paralelos.removeWhere((p) => p['id'] == paralelo['id']);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Paralelo $nombreEliminado eliminado'),
                  backgroundColor: Colors.red,
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
