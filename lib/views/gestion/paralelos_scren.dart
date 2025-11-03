import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:incos_check/utils/constants.dart';
import '../../views/gestion/estudiantes_screen.dart';
import '../../viewmodels/paralelos_viewmodel.dart';
import '../../models/paralelo_model.dart';

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
  late ParalelosViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ParalelosViewModel();
    _viewModel.inicializarDatos(
      tipo: widget.tipo,
      carrera: widget.carrera,
      turno: widget.turno,
      nivel: widget.nivel,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // Funciones para obtener colores según el tema
  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : AppColors.background;
  }

  Color _getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
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

  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  Color _getInfoBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blue.shade900.withOpacity(0.3)
        : Colors.blue.shade50;
  }

  Color _getInfoTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blue.shade200
        : Colors.blue.shade800;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ParalelosViewModel>(
        builder: (context, viewModel, child) {
          Color carreraColor = _parseColor(viewModel.carrera['color']);

          return Scaffold(
            backgroundColor: _getBackgroundColor(context),
            appBar: AppBar(
              title: Text(
                '${viewModel.carrera['nombre']} - ${viewModel.turno['nombre']} - ${viewModel.nivel['nombre']}',
                style: AppTextStyles.heading2.copyWith(color: Colors.white),
              ),
              backgroundColor: carreraColor,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: viewModel.paralelos.isEmpty
                ? _buildEmptyState(viewModel, context)
                : _buildParalelosList(viewModel, context, carreraColor),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAgregarParaleloDialog(context, viewModel),
              backgroundColor: carreraColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ParalelosViewModel viewModel, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 80,
            color: _getSecondaryTextColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay paralelos',
            style: AppTextStyles.heading3.copyWith(
              color: _getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.esCarreraDeEjemplo
                ? 'Esta es una vista de ejemplo con datos demostrativos'
                : 'Presiona el botón + para agregar el primer paralelo',
            style: TextStyle(color: _getSecondaryTextColor(context)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildParalelosList(
    ParalelosViewModel viewModel,
    BuildContext context,
    Color color,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.medium),
      itemCount: viewModel.paralelos.length,
      itemBuilder: (context, index) {
        final paralelo = viewModel.paralelos[index];
        return _buildParaleloCard(paralelo, context, color, viewModel);
      },
    );
  }

  Widget _buildParaleloCard(
    Paralelo paralelo,
    BuildContext context,
    Color color,
    ParalelosViewModel viewModel,
  ) {
    bool esEjemplo = viewModel.esParaleloEjemplo(paralelo);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      color: _getCardColor(context),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            paralelo.nombre,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              'Paralelo ${paralelo.nombre}',
              style: AppTextStyles.heading3.copyWith(
                color: paralelo.activo ? _getTextColor(context) : Colors.grey,
              ),
            ),
            if (esEjemplo) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Ejemplo',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              paralelo.activo ? 'Activo' : 'Inactivo',
              style: TextStyle(
                color: paralelo.activo ? Colors.green : Colors.red,
              ),
            ),
            if (esEjemplo)
              Text(
                'Datos de demostración',
                style: TextStyle(
                  fontSize: 12,
                  color: _getSecondaryTextColor(context),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // keep a small gap and limit width so the popup icon always shows
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Switch(
                value: paralelo.activo,
                onChanged: esEjemplo
                    ? null
                    : (value) {
                        viewModel.cambiarEstadoParalelo(paralelo, value);
                      },
                activeColor: color,
              ),
            ),
            if (!esEjemplo)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: _getTextColor(context)),
                tooltip: 'Más opciones',
                onSelected: (value) =>
                    _handleMenuAction(value, paralelo, viewModel, context),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(
                      'Modificar',
                      style: TextStyle(color: _getTextColor(context)),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Eliminar',
                      style: TextStyle(color: _getTextColor(context)),
                    ),
                  ),
                ],
              ),
          ],
        ),
        onTap: () {
          if (paralelo.activo) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EstudiantesListScreen(
                  tipo: viewModel.tipo,
                  carrera: viewModel.carrera,
                  turno: viewModel.turno,
                  nivel: viewModel.nivel,
                  paralelo: paralelo.toMap(),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _handleMenuAction(
    String action,
    Paralelo paralelo,
    ParalelosViewModel viewModel,
    BuildContext context,
  ) {
    switch (action) {
      case 'edit':
        _showEditarParaleloDialog(context, paralelo, viewModel);
        break;
      case 'delete':
        _showEliminarParaleloDialog(context, paralelo, viewModel);
        break;
    }
  }

  void _showAgregarParaleloDialog(
    BuildContext context,
    ParalelosViewModel viewModel,
  ) {
    viewModel.nombreController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(context),
        title: Text(
          'Agregar Nuevo Paralelo',
          style: TextStyle(color: _getTextColor(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: viewModel.nombreController,
              style: TextStyle(color: _getTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Letra del Paralelo',
                labelStyle: TextStyle(color: _getSecondaryTextColor(context)),
                hintText: 'Ej: A, C, D, etc.',
                hintStyle: TextStyle(color: _getSecondaryTextColor(context)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _parseColor(viewModel.carrera['color']),
                  ),
                ),
                counterText: 'Máximo 2 caracteres',
                counterStyle: TextStyle(color: _getSecondaryTextColor(context)),
              ),
              maxLength: 2,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getInfoBackgroundColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: _getInfoTextColor(context), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ingresa una letra para el paralelo (A, B, C, etc.)',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getInfoTextColor(context),
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
            child: Text(
              'Cancelar',
              style: TextStyle(color: _getSecondaryTextColor(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (viewModel.nombreController.text.trim().isNotEmpty) {
                try {
                  viewModel.agregarParalelo(
                    viewModel.nombreController.text.trim().toUpperCase(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Paralelo ${viewModel.nombreController.text.trim().toUpperCase()} agregado correctamente',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _parseColor(viewModel.carrera['color']),
            ),
            child: const Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditarParaleloDialog(
    BuildContext context,
    Paralelo paralelo,
    ParalelosViewModel viewModel,
  ) {
    viewModel.editarNombreController.text = paralelo.nombre;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(context),
        title: Text(
          'Modificar Paralelo',
          style: TextStyle(color: _getTextColor(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: viewModel.editarNombreController,
              style: TextStyle(color: _getTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Letra del Paralelo',
                labelStyle: TextStyle(color: _getSecondaryTextColor(context)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _parseColor(viewModel.carrera['color']),
                  ),
                ),
                counterText: 'Máximo 2 caracteres',
                counterStyle: TextStyle(color: _getSecondaryTextColor(context)),
              ),
              maxLength: 2,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getInfoBackgroundColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: _getInfoTextColor(context), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Modifica la letra del paralelo',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getInfoTextColor(context),
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
            child: Text(
              'Cancelar',
              style: TextStyle(color: _getSecondaryTextColor(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (viewModel.editarNombreController.text.trim().isNotEmpty) {
                try {
                  viewModel.editarParalelo(
                    paralelo,
                    viewModel.editarNombreController.text.trim().toUpperCase(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Paralelo actualizado a ${viewModel.editarNombreController.text.trim().toUpperCase()}',
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _parseColor(viewModel.carrera['color']),
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEliminarParaleloDialog(
    BuildContext context,
    Paralelo paralelo,
    ParalelosViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(context),
        title: Text(
          'Eliminar Paralelo',
          style: TextStyle(color: _getTextColor(context)),
        ),
        content: Text(
          '¿Estás seguro de eliminar el Paralelo ${paralelo.nombre}?',
          style: TextStyle(color: _getTextColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: _getSecondaryTextColor(context)),
            ),
          ),
          TextButton(
            onPressed: () {
              viewModel.eliminarParalelo(paralelo);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Paralelo ${paralelo.nombre} eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
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
