import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/nivel_viewmodel.dart';
import '../../models/nivel_model.dart';
import 'package:incos_check/utils/constants.dart';
import '../../views/gestion/paralelos_scren.dart';
import '../../views/gestion/materias_screen.dart';

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
  late NivelesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NivelesViewModel(
      carrera: widget.carrera,
      turno: widget.turno,
      tipo: widget.tipo,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
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

  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NivelesViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.carrera['nombre']} - ${widget.turno['nombre']} - ${widget.tipo == 'Cursos' ? 'Cursos' : 'Niveles'}',
            style: AppTextStyles.heading2Dark(
              context,
            ).copyWith(color: Colors.white),
          ),
          backgroundColor: _parseColor(widget.carrera['color']),
        ),
        body: Consumer<NivelesViewModel>(
          builder: (context, viewModel, child) {
            return _buildBody(context, viewModel);
          },
        ),
        floatingActionButton: Consumer<NivelesViewModel>(
          builder: (context, viewModel, child) {
            return FloatingActionButton(
              onPressed: () => _showAgregarNivelDialog(context, viewModel),
              backgroundColor: _parseColor(widget.carrera['color']),
              child: Icon(Icons.add, color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NivelesViewModel viewModel) {
    final niveles = viewModel.niveles;
    final carreraColor = _parseColor(widget.carrera['color']);

    if (niveles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.layers,
              size: 64,
              color: AppColors.textSecondaryDark(context),
            ),
            SizedBox(height: 16),
            Text(
              'No hay niveles configurados',
              style: AppTextStyles.heading3Dark(
                context,
              ).copyWith(color: _getTextColor(context)),
            ),
            SizedBox(height: 8),
            Text(
              'Presiona el botón + para agregar un nivel',
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: _getSecondaryTextColor(context)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.medium),
      itemCount: niveles.length,
      itemBuilder: (context, index) {
        final nivel = niveles[index];
        return _buildNivelCard(nivel, context, carreraColor, viewModel);
      },
    );
  }

  Widget _buildNivelCard(
    NivelModel nivel,
    BuildContext context,
    Color color,
    NivelesViewModel viewModel,
  ) {
    // Para cursos, mostrar información adicional
    int cantidadMaterias = viewModel.obtenerCantidadMaterias(nivel.nombre);

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      color: Theme.of(context).cardColor,
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
          widget.tipo == 'Cursos'
              ? '${nivel.nombre} Año'
              : '${nivel.nombre} Nivel',
          style: AppTextStyles.heading3Dark(context).copyWith(
            color: nivel.activo ? _getTextColor(context) : Colors.grey,
          ),
        ),
        subtitle: widget.tipo == 'Cursos'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nivel.activo ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: nivel.activo ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$cantidadMaterias materias',
                    style: TextStyle(
                      color: _getTextColor(context).withOpacity(0.7),
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
              onSelected: (value) => _handleMenuAction(value, nivel, viewModel),
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
          ],
        ),
        onTap: () {
          if (nivel.activo) {
            if (widget.tipo == 'Estudiantes') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParalelosScreen(
                    tipo: widget.tipo,
                    carrera: widget.carrera,
                    turno: widget.turno,
                    nivel: nivel.toMap(),
                  ),
                ),
              );
            } else if (widget.tipo == 'Cursos') {
              _navegarAMaterias(context);
            }
          }
        },
      ),
    );
  }

  void _navegarAMaterias(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MateriasScreen()),
    );
  }

  String _obtenerNumeroRomano(int numero) {
    switch (numero) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      case 4:
        return 'IV';
      case 5:
        return 'V';
      case 6:
        return 'VI';
      case 7:
        return 'VII';
      case 8:
        return 'VIII';
      case 9:
        return 'IX';
      case 10:
        return 'X';
      default:
        return numero.toString();
    }
  }

  void _handleMenuAction(
    String action,
    NivelModel nivel,
    NivelesViewModel viewModel,
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
    NivelesViewModel viewModel,
  ) {
    viewModel.nombreController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Agregar Nuevo Nivel',
          style: AppTextStyles.heading2Dark(
            context,
          ).copyWith(color: _getTextColor(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: viewModel.nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del Nivel',
                labelStyle: AppTextStyles.bodyDark(context),
                hintText: 'Ej: Primero, Segundo, Cuarto, etc.',
                hintStyle: AppTextStyles.bodyDark(
                  context,
                ).copyWith(color: _getSecondaryTextColor(context)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
              ),
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: _getTextColor(context)),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue.shade900.withOpacity(0.3)
                    : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Los niveles se ordenarán automáticamente: Primero, Segundo, Tercero, Cuarto, Quinto, etc.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue.shade200
                            : Colors.blue[800],
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
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: _getTextColor(context)),
            ),
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
                      style: AppTextStyles.bodyDark(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _parseColor(widget.carrera['color']),
            ),
            child: Text(
              'Agregar',
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditarNivelDialog(
    BuildContext context,
    NivelModel nivel,
    NivelesViewModel viewModel,
  ) {
    viewModel.editarNombreController.text = nivel.nombre;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Modificar Nivel',
          style: AppTextStyles.heading2Dark(
            context,
          ).copyWith(color: _getTextColor(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: viewModel.editarNombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del Nivel',
                labelStyle: AppTextStyles.bodyDark(context),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
              ),
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: _getTextColor(context)),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue.shade900.withOpacity(0.3)
                    : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Al cambiar el nombre se reordenará automáticamente',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue.shade200
                            : Colors.blue[800],
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
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: _getTextColor(context)),
            ),
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
                      style: AppTextStyles.bodyDark(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _parseColor(widget.carrera['color']),
            ),
            child: Text(
              'Guardar',
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEliminarNivelDialog(
    BuildContext context,
    NivelModel nivel,
    NivelesViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Eliminar Nivel',
          style: AppTextStyles.heading2Dark(
            context,
          ).copyWith(color: _getTextColor(context)),
        ),
        content: Text(
          '¿Estás seguro de eliminar el ${nivel.nombre} Nivel?',
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
              String nombreEliminado = nivel.nombre;
              viewModel.eliminarNivel(nivel);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Nivel "$nombreEliminado" eliminado',
                    style: AppTextStyles.bodyDark(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
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
}
