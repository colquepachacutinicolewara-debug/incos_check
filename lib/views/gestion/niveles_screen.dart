import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/nivel_viewmodel.dart';
import '../../models/nivel_model.dart';
import '../../utils/constants.dart';
import '../gestion/paralelos_scren.dart';
import '../gestion/materias_screen.dart';

class NivelesScreen extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;

  const NivelesScreen({
    super.key,
    required this.tipo,
    required this.carrera,
    required this.turno,
  });

  @override
  State<NivelesScreen> createState() => _NivelesScreenState();
}

class _NivelesScreenState extends State<NivelesScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NivelViewModel( // ✅ Cambiado a NivelViewModel
        carrera: widget.carrera,
        turno: widget.turno,
        tipo: widget.tipo,
      ), // ✅ SIN databaseHelper
      child: _NivelesScreenContent(
        tipo: widget.tipo,
        carrera: widget.carrera,
        turno: widget.turno,
      ),
    );
  }
}

class _NivelesScreenContent extends StatelessWidget {
  final String tipo;
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;

  const _NivelesScreenContent({
    required this.tipo,
    required this.carrera,
    required this.turno,
  });

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<NivelViewModel>(context); // ✅ Cambiado a NivelViewModel
    final niveles = viewModel.niveles;
    final carreraColor = _parseColor(carrera['color']);

    if (viewModel.isLoading && niveles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${carrera['nombre']} - ${turno['nombre']} - ${tipo == 'Cursos' ? 'Cursos' : 'Niveles'}',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          backgroundColor: carreraColor,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando niveles...'),
            ],
          ),
        ),
      );
    }

    if (niveles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${carrera['nombre']} - ${turno['nombre']} - ${tipo == 'Cursos' ? 'Cursos' : 'Niveles'}',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          backgroundColor: carreraColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.layers,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay niveles configurados',
                style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Presiona el botón + para agregar un nivel',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAgregarNivelDialog(context, viewModel),
          backgroundColor: carreraColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${carrera['nombre']} - ${turno['nombre']} - ${tipo == 'Cursos' ? 'Cursos' : 'Niveles'}',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: carreraColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.medium),
        itemCount: niveles.length,
        itemBuilder: (context, index) {
          final nivel = niveles[index];
          return _buildNivelCard(nivel, context, carreraColor, viewModel);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAgregarNivelDialog(context, viewModel),
        backgroundColor: carreraColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNivelCard(
    NivelModel nivel,
    BuildContext context,
    Color color,
    NivelViewModel viewModel, // ✅ Cambiado a NivelViewModel
  ) {
    int cantidadMaterias = viewModel.obtenerCantidadMaterias(nivel.nombre);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            _obtenerNumeroRomano(nivel.orden),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          tipo == 'Cursos'
              ? '${nivel.nombre} Año'
              : '${nivel.nombre} Nivel',
          style: AppTextStyles.heading3.copyWith(
            color: nivel.activo ? AppColors.textPrimary : Colors.grey,
          ),
        ),
        subtitle: tipo == 'Cursos'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nivel.activo ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: nivel.activo ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$cantidadMaterias materias',
                    style: TextStyle(
                      color: AppColors.textPrimary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : Text(
                nivel.activo ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color: nivel.activo ? Colors.green : Colors.red,
                ),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: nivel.activo,
              onChanged: (value) {
                viewModel.toggleActivarNivel(nivel, value);
              },
              activeColor: color,
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, nivel, viewModel, context),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Modificar'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          if (nivel.activo) {
            if (tipo == 'Estudiantes') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParalelosScreen(
                    tipo: tipo,
                    carrera: carrera,
                    turno: turno,
                    nivel: nivel.toMap(),
                  ),
                ),
              );
            } else if (tipo == 'Cursos') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MateriasScreen()),
              );
            }
          }
        },
      ),
    );
  }

  String _obtenerNumeroRomano(int numero) {
    switch (numero) {
      case 1: return 'I';
      case 2: return 'II';
      case 3: return 'III';
      case 4: return 'IV';
      case 5: return 'V';
      case 6: return 'VI';
      case 7: return 'VII';
      case 8: return 'VIII';
      case 9: return 'IX';
      case 10: return 'X';
      default: return numero.toString();
    }
  }

  void _handleMenuAction(
    String action,
    NivelModel nivel,
    NivelViewModel viewModel, // ✅ Cambiado a NivelViewModel
    BuildContext context,
  ) {
    switch (action) {
      case 'edit':
        _showEditarNivelDialog(context, nivel, viewModel);
        break;
      case 'delete':
        _showEliminarNivelDialog(context, nivel, viewModel);
        break;
    }
  }

  void _showAgregarNivelDialog(
    BuildContext context,
    NivelViewModel viewModel, // ✅ Cambiado a NivelViewModel
  ) {
    viewModel.nombreController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nuevo Nivel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: viewModel.nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Nivel',
                hintText: 'Ej: Primero, Segundo, Cuarto, etc.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Los niveles se ordenarán automáticamente: Primero, Segundo, Tercero, Cuarto, Quinto, etc.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
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
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (viewModel.nombreController.text.trim().isNotEmpty) {
                viewModel.agregarNivel(viewModel.nombreController.text.trim());
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Nivel "${viewModel.nombreController.text.trim()}" agregado correctamente',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _parseColor(carrera['color']),
            ),
            child: const Text(
              'Agregar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditarNivelDialog(
    BuildContext context,
    NivelModel nivel,
    NivelViewModel viewModel, // ✅ Cambiado a NivelViewModel
  ) {
    viewModel.editarNombreController.text = nivel.nombre;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modificar Nivel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: viewModel.editarNombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Nivel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Al cambiar el nombre se reordenará automáticamente',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
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
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (viewModel.editarNombreController.text.trim().isNotEmpty) {
                viewModel.editarNivel(
                  nivel,
                  viewModel.editarNombreController.text.trim(),
                );
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Nivel actualizado a "${viewModel.editarNombreController.text.trim()}"',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _parseColor(carrera['color']),
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEliminarNivelDialog(
    BuildContext context,
    NivelModel nivel,
    NivelViewModel viewModel, // ✅ Cambiado a NivelViewModel
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Nivel'),
        content: Text(
          '¿Estás seguro de eliminar el ${nivel.nombre} Nivel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              String nombreEliminado = nivel.nombre;
              viewModel.eliminarNivel(nivel);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Nivel "$nombreEliminado" eliminado',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}