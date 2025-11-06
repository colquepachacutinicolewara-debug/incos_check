// paralelos_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/viewmodels/paralelos_viewmodel.dart';
import 'package:incos_check/models/paralelo_model.dart';
import 'package:incos_check/views/gestion/estudiantes_screen.dart';

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
  @override
  void initState() {
    super.initState();
    _inicializarViewModel();
  }

  void _inicializarViewModel() {
    final viewModel = Provider.of<ParalelosViewModel>(context, listen: false);
    viewModel.inicializarYcargarParalelos(
      widget.carrera['id'].toString(),
      widget.carrera['nombre'],
      widget.carrera['color'],
      widget.nivel['id'].toString(),
      widget.turno['id'].toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParalelosViewModel>(
      builder: (context, viewModel, child) {
        Color carreraColor = _parseColor(widget.carrera['color']);

        return Scaffold(
          backgroundColor: viewModel.getBackgroundColor(context),
          appBar: AppBar(
            title: Text(
              '${widget.carrera['nombre']} - ${widget.turno['nombre']} - ${widget.nivel['nombre']}',
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
            ),
            backgroundColor: carreraColor,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              if (viewModel.isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: _buildBody(viewModel, context, carreraColor),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAgregarParaleloDialog(viewModel),
            backgroundColor: carreraColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    ParalelosViewModel viewModel,
    BuildContext context,
    Color color,
  ) {
    if (viewModel.isLoading && viewModel.paralelos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error al cargar paralelos',
              style: AppTextStyles.heading3.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: viewModel.getSecondaryTextColor(context)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                viewModel.clearError();
                _inicializarViewModel();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (viewModel.paralelos.isEmpty) {
      return _buildEmptyState(viewModel, context);
    }

    return _buildParalelosList(viewModel, context, color);
  }

  Widget _buildEmptyState(ParalelosViewModel viewModel, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 80,
            color: viewModel.getSecondaryTextColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay paralelos',
            style: AppTextStyles.heading3.copyWith(
              color: viewModel.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para agregar el primer paralelo',
            style: TextStyle(color: viewModel.getSecondaryTextColor(context)),
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
        return _buildParaleloCard(viewModel, paralelo, context, color);
      },
    );
  }

  Widget _buildParaleloCard(
    ParalelosViewModel viewModel,
    Paralelo paralelo,
    BuildContext context,
    Color color,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      color: viewModel.getCardColor(context),
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
        title: Text(
          'Paralelo ${paralelo.nombre}',
          style: AppTextStyles.heading3.copyWith(
            color: paralelo.activo
                ? viewModel.getTextColor(context)
                : Colors.grey,
          ),
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
            if (paralelo.estudiantes.isNotEmpty)
              Text(
                '${paralelo.estudiantes.length} estudiante(s)',
                style: TextStyle(
                  color: viewModel.getSecondaryTextColor(context),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: paralelo.activo,
              onChanged: (value) {
                _cambiarEstadoParalelo(viewModel, paralelo, value);
              },
              activeColor: color,
            ),
            PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleMenuAction(value, paralelo, viewModel),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(
                    'Modificar',
                    style: TextStyle(color: viewModel.getTextColor(context)),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Eliminar',
                    style: TextStyle(color: viewModel.getTextColor(context)),
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
                  tipo: widget.tipo,
                  carrera: widget.carrera,
                  turno: widget.turno,
                  nivel: widget.nivel,
                  paralelo: paralelo.toMap(),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _cambiarEstadoParalelo(
    ParalelosViewModel viewModel,
    Paralelo paralelo,
    bool nuevoEstado,
  ) async {
    final success = await viewModel.cambiarEstadoParalelo(
      paralelo,
      nuevoEstado,
      widget.carrera['id'].toString(),
      widget.turno['id'].toString(),
      widget.nivel['id'].toString(),
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${viewModel.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleMenuAction(
    String action,
    Paralelo paralelo,
    ParalelosViewModel viewModel,
  ) {
    switch (action) {
      case 'edit':
        _showEditarParaleloDialog(paralelo, viewModel);
        break;
      case 'delete':
        _showEliminarParaleloDialog(paralelo, viewModel);
        break;
    }
  }

  void _showAgregarParaleloDialog(ParalelosViewModel viewModel) {
    viewModel.nombreController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: viewModel.getCardColor(context),
        title: Text(
          'Agregar Nuevo Paralelo',
          style: TextStyle(color: viewModel.getTextColor(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: viewModel.nombreController,
              style: TextStyle(color: viewModel.getTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Letra del Paralelo',
                labelStyle: TextStyle(
                  color: viewModel.getSecondaryTextColor(context),
                ),
                hintText: 'Ej: A, C, D, etc.',
                hintStyle: TextStyle(
                  color: viewModel.getSecondaryTextColor(context),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: viewModel.getBorderColor(context),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: viewModel.getBorderColor(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: viewModel.parseColor(widget.carrera['color']),
                  ),
                ),
                counterText: 'Máximo 2 caracteres',
                counterStyle: TextStyle(
                  color: viewModel.getSecondaryTextColor(context),
                ),
              ),
              maxLength: 2,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: viewModel.getInfoBackgroundColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: viewModel.getInfoTextColor(context),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ingresa una letra para el paralelo (A, B, C, etc.)',
                      style: TextStyle(
                        fontSize: 12,
                        color: viewModel.getInfoTextColor(context),
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
              style: TextStyle(color: viewModel.getSecondaryTextColor(context)),
            ),
          ),
          ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    if (viewModel.nombreController.text.trim().isNotEmpty) {
                      final success = await viewModel.agregarParalelo(
                        viewModel.nombreController.text.trim().toUpperCase(),
                        widget.carrera['id'].toString(),
                        widget.turno['id'].toString(),
                        widget.nivel['id'].toString(),
                        context,
                      );

                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Paralelo ${viewModel.nombreController.text} agregado correctamente',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: viewModel.parseColor(widget.carrera['color']),
              disabledBackgroundColor: Colors.grey,
            ),
            child: viewModel.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditarParaleloDialog(
    Paralelo paralelo,
    ParalelosViewModel viewModel,
  ) {
    viewModel.editarNombreController.text = paralelo.nombre;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: viewModel.getCardColor(context),
        title: Text(
          'Modificar Paralelo',
          style: TextStyle(color: viewModel.getTextColor(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: viewModel.editarNombreController,
              style: TextStyle(color: viewModel.getTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Letra del Paralelo',
                labelStyle: TextStyle(
                  color: viewModel.getSecondaryTextColor(context),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: viewModel.getBorderColor(context),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: viewModel.getBorderColor(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: viewModel.parseColor(widget.carrera['color']),
                  ),
                ),
                counterText: 'Máximo 2 caracteres',
                counterStyle: TextStyle(
                  color: viewModel.getSecondaryTextColor(context),
                ),
              ),
              maxLength: 2,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: viewModel.getInfoBackgroundColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: viewModel.getInfoTextColor(context),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Modifica la letra del paralelo',
                      style: TextStyle(
                        fontSize: 12,
                        color: viewModel.getInfoTextColor(context),
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
              style: TextStyle(color: viewModel.getSecondaryTextColor(context)),
            ),
          ),
          ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    if (viewModel.editarNombreController.text
                        .trim()
                        .isNotEmpty) {
                      final success = await viewModel.editarParalelo(
                        paralelo,
                        viewModel.editarNombreController.text
                            .trim()
                            .toUpperCase(),
                        widget.carrera['id'].toString(),
                        widget.turno['id'].toString(),
                        widget.nivel['id'].toString(),
                        context,
                      );

                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Paralelo actualizado a ${viewModel.editarNombreController.text}',
                            ),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: viewModel.parseColor(widget.carrera['color']),
              disabledBackgroundColor: Colors.grey,
            ),
            child: viewModel.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEliminarParaleloDialog(
    Paralelo paralelo,
    ParalelosViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: viewModel.getCardColor(context),
        title: Text(
          'Eliminar Paralelo',
          style: TextStyle(color: viewModel.getTextColor(context)),
        ),
        content: Text(
          '¿Estás seguro de eliminar el Paralelo ${paralelo.nombre}?',
          style: TextStyle(color: viewModel.getTextColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: viewModel.getSecondaryTextColor(context)),
            ),
          ),
          TextButton(
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    final success = await viewModel.eliminarParalelo(
                      paralelo,
                      widget.carrera['id'].toString(),
                      widget.turno['id'].toString(),
                      widget.nivel['id'].toString(),
                      context,
                    );

                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Paralelo ${paralelo.nombre} eliminado',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
            child: viewModel.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Eliminar', style: TextStyle(color: Colors.red)),
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
