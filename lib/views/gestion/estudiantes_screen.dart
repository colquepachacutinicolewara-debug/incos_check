import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';

class EstudiantesListScreen extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;
  final Map<String, dynamic> nivel;
  final Map<String, dynamic> paralelo;
  
  const EstudiantesListScreen({
    super.key, 
    required this.tipo, 
    required this.carrera,
    required this.turno,
    required this.nivel,
    required this.paralelo
  });

  @override
  State<EstudiantesListScreen> createState() => _EstudiantesListScreenState();
}

class _EstudiantesListScreenState extends State<EstudiantesListScreen> {
  final List<Map<String, dynamic>> _estudiantes = [
    {
      'id': 1,
      'nombres': 'Juan Carlos',
      'apellidoPaterno': 'Pérez',
      'apellidoMaterno': 'Gómez',
      'ci': '1234567',
      'fechaRegistro': '2024-01-15',
    },
    {
      'id': 2,
      'nombres': 'María Elena',
      'apellidoPaterno': 'López',
      'apellidoMaterno': 'Martínez',
      'ci': '7654321',
      'fechaRegistro': '2024-01-16',
    },
  ];

  @override
  Widget build(BuildContext context) {
    Color carreraColor = _parseColor(widget.carrera['color']);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.paralelo['nombre']} - Estudiantes',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: carreraColor,
      ),
      body: _estudiantes.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacing.medium),
              itemCount: _estudiantes.length,
              itemBuilder: (context, index) {
                final estudiante = _estudiantes[index];
                return _buildEstudianteCard(estudiante, index, carreraColor);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAgregarEstudianteDialog,
        backgroundColor: carreraColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEstudianteCard(Map<String, dynamic> estudiante, int index, Color color) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            estudiante['nombres'][0],
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          '${estudiante['nombres']} ${estudiante['apellidoPaterno']} ${estudiante['apellidoMaterno']}',
          style: AppTextStyles.heading3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CI: ${estudiante['ci']}'),
            Text('Registro: ${estudiante['fechaRegistro']}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, estudiante, index),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(value: 'edit', child: Text('Modificar')),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          SizedBox(height: AppSpacing.medium),
          Text(
            'No hay estudiantes registrados',
            style: AppTextStyles.heading3.copyWith(color: Colors.grey),
          ),
          SizedBox(height: AppSpacing.small),
          Text(
            'Presiona el botón + para agregar el primer estudiante',
            style: AppTextStyles.body.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> estudiante, int index) {
    switch (action) {
      case 'edit':
        _showEditarEstudianteDialog(estudiante, index);
        break;
      case 'delete':
        _showEliminarEstudianteDialog(estudiante, index);
        break;
    }
  }

  void _showAgregarEstudianteDialog() {
    showDialog(
      context: context,
      builder: (context) => _EstudianteDialog(
        title: 'Agregar Estudiante',
        onSave: (nombres, paterno, materno, ci) {
          setState(() {
            _estudiantes.add({
              'id': DateTime.now().millisecondsSinceEpoch,
              'nombres': nombres,
              'apellidoPaterno': paterno,
              'apellidoMaterno': materno,
              'ci': ci,
              'fechaRegistro': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            });
          });
        },
      ),
    );
  }

  void _showEditarEstudianteDialog(Map<String, dynamic> estudiante, int index) {
    showDialog(
      context: context,
      builder: (context) => _EstudianteDialog(
        title: 'Modificar Estudiante',
        nombresInicial: estudiante['nombres'],
        paternoInicial: estudiante['apellidoPaterno'],
        maternoInicial: estudiante['apellidoMaterno'],
        ciInicial: estudiante['ci'],
        onSave: (nombres, paterno, materno, ci) {
          setState(() {
            _estudiantes[index] = {
              ...estudiante,
              'nombres': nombres,
              'apellidoPaterno': paterno,
              'apellidoMaterno': materno,
              'ci': ci,
            };
          });
        },
      ),
    );
  }

  void _showEliminarEstudianteDialog(Map<String, dynamic> estudiante, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Estudiante'),
        content: Text('¿Estás seguro de eliminar a ${estudiante['nombres']} ${estudiante['apellidoPaterno']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _estudiantes.removeAt(index);
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

// Diálogo para agregar/modificar estudiantes
class _EstudianteDialog extends StatefulWidget {
  final String title;
  final String? nombresInicial;
  final String? paternoInicial;
  final String? maternoInicial;
  final String? ciInicial;
  final Function(String nombres, String paterno, String materno, String ci) onSave;

  const _EstudianteDialog({
    required this.title,
    this.nombresInicial,
    this.paternoInicial,
    this.maternoInicial,
    this.ciInicial,
    required this.onSave,
  });

  @override
  State<_EstudianteDialog> createState() => _EstudianteDialogState();
}

class _EstudianteDialogState extends State<_EstudianteDialog> {
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _paternoController = TextEditingController();
  final TextEditingController _maternoController = TextEditingController();
  final TextEditingController _ciController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nombresController.text = widget.nombresInicial ?? '';
    _paternoController.text = widget.paternoInicial ?? '';
    _maternoController.text = widget.maternoInicial ?? '';
    _ciController.text = widget.ciInicial ?? '';
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
              controller: _nombresController,
              decoration: InputDecoration(
                labelText: 'Nombres',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.small),
            TextField(
              controller: _paternoController,
              decoration: InputDecoration(
                labelText: 'Apellido Paterno',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.small),
            TextField(
              controller: _maternoController,
              decoration: InputDecoration(
                labelText: 'Apellido Materno',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.small),
            TextField(
              controller: _ciController,
              decoration: InputDecoration(
                labelText: 'Cédula de Identidad',
                border: OutlineInputBorder(),
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
            if (_nombresController.text.isNotEmpty &&
                _paternoController.text.isNotEmpty &&
                _ciController.text.isNotEmpty) {
              widget.onSave(
                _nombresController.text,
                _paternoController.text,
                _maternoController.text,
                _ciController.text,
              );
              Navigator.pop(context);
            }
          },
          child: Text('Guardar'),
        ),
      ],
    );
  }
}