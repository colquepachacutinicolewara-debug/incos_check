import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../models/materia_model.dart';

class MateriasScreen extends StatefulWidget {
  const MateriasScreen({super.key});

  @override
  State<MateriasScreen> createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  final List<Materia> _materias = [];
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _carreraController = TextEditingController();

  Materia? _materiaEditando;
  Color _colorSeleccionado = MateriaColors.matematica;

  @override
  void initState() {
    super.initState();
    _cargarMateriasEjemplo();
  }

  void _cargarMateriasEjemplo() {
    _materias.addAll([
      Materia(
        id: '1',
        codigo: 'MAT101',
        nombre: 'Matemática I',
        carrera: 'Sistemas Informáticos',
        color: MateriaColors.matematica,
      ),
      Materia(
        id: '2',
        codigo: 'PROG101',
        nombre: 'Programación I',
        carrera: 'Sistemas Informáticos',
        color: MateriaColors.programacion,
      ),
      Materia(
        id: '3',
        codigo: 'FIS101',
        nombre: 'Física I',
        carrera: 'Sistemas Informáticos',
        color: MateriaColors.fisica,
      ),
    ]);
  }

  void _mostrarDialogoMateria([Materia? materia]) {
    _materiaEditando = materia;

    if (materia != null) {
      _codigoController.text = materia.codigo;
      _nombreController.text = materia.nombre;
      _carreraController.text = materia.carrera;
      _colorSeleccionado = materia.color;
    } else {
      _codigoController.clear();
      _nombreController.clear();
      _carreraController.clear();
      _colorSeleccionado = MateriaColors.matematica;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(materia == null ? 'Nueva Materia' : 'Editar Materia'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codigoController,
                  decoration: const InputDecoration(
                    labelText: 'Código de Materia',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Ingrese el código' : null,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de Materia',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Ingrese el nombre' : null,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextFormField(
                  controller: _carreraController,
                  decoration: const InputDecoration(
                    labelText: 'Carrera',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Ingrese la carrera' : null,
                ),
                const SizedBox(height: AppSpacing.medium),
                const Text('Color identificador:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MateriaColors.colors.map((color) {
                    return _buildCirculoColor(color);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _guardarMateria,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCirculoColor(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _colorSeleccionado = color),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: _colorSeleccionado == color
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
      ),
    );
  }

  void _guardarMateria() {
    if (_formKey.currentState!.validate()) {
      final nuevaMateria = Materia(
        id:
            _materiaEditando?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        codigo: _codigoController.text,
        nombre: _nombreController.text,
        carrera: _carreraController.text,
        color: _colorSeleccionado,
      );

      setState(() {
        if (_materiaEditando != null) {
          // Editar materia existente
          final index = _materias.indexWhere(
            (m) => m.id == _materiaEditando!.id,
          );
          if (index != -1) {
            _materias[index] = nuevaMateria;
          }
        } else {
          // Agregar nueva materia
          _materias.add(nuevaMateria);
        }
      });

      Navigator.pop(context);
      _limpiarFormulario();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _materiaEditando != null
                ? '✅ Materia actualizada'
                : '✅ Materia creada',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _eliminarMateria(Materia materia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Materia'),
        content: Text(
          '¿Estás seguro de eliminar la materia "${materia.nombreCompleto}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _materias.removeWhere((m) => m.id == materia.id);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Materia "${materia.codigo}" eliminada'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _limpiarFormulario() {
    _codigoController.clear();
    _nombreController.clear();
    _carreraController.clear();
    _materiaEditando = null;
    _colorSeleccionado = MateriaColors.matematica;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Materias'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarDialogoMateria(),
            tooltip: 'Nueva Materia',
          ),
        ],
      ),
      body: _materias.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: AppSpacing.medium),
                  Text(
                    'No hay materias registradas',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.small),
                  Text(
                    'Presiona el botón + para agregar una',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _materias.length,
              itemBuilder: (context, index) {
                final materia = _materias[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: materia.color,
                      child: Text(
                        materia.codigo.substring(0, 2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      materia.nombreCompleto,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(materia.carrera),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _mostrarDialogoMateria(materia),
                          tooltip: 'Editar materia',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _eliminarMateria(materia),
                          tooltip: 'Eliminar materia',
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _carreraController.dispose();
    super.dispose();
  }
}
