import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/viewmodels/paralelos_viewmodel.dart';
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
  late ParalelosViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ParalelosViewModel();
    _inicializarViewModel();
  }

  void _inicializarViewModel() {
    _viewModel.inicializarYcargarParalelos(
      widget.carrera['id'].toString(),
      widget.carrera['nombre'],
      widget.carrera['color'],
      widget.nivel['id'].toString(),
      widget.turno['id'].toString(),
    );

    // Escuchar los cambios del ViewModel
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color carreraColor = _parseColor(widget.carrera['color']);

    return Scaffold(
      backgroundColor: _viewModel.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          '${widget.carrera['nombre']} - ${widget.turno['nombre']} - ${widget.nivel['nombre']}',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: carreraColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _viewModel.paralelos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 80,
                    color: _viewModel.getSecondaryTextColor(context),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay paralelos',
                    style: AppTextStyles.heading3.copyWith(
                      color: _viewModel.getSecondaryTextColor(context),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Presiona el botón + para agregar el primer paralelo',
                    style: TextStyle(
                      color: _viewModel.getSecondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacing.medium),
              itemCount: _viewModel.paralelos.length,
              itemBuilder: (context, index) {
                final paralelo = _viewModel.paralelos[index];
                return _buildParaleloCard(paralelo, context, carreraColor);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAgregarParaleloDialog(),
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
      color: _viewModel.getCardColor(context),
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
            color: isActive ? _viewModel.getTextColor(context) : Colors.grey,
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
                _viewModel.cambiarEstadoParalelo(
                  paralelo,
                  value,
                  widget.carrera['id'].toString(),
                  widget.turno['id'].toString(),
                  widget.nivel['id'].toString(),
                );
              },
              activeColor: color,
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, paralelo),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(
                    'Modificar',
                    style: TextStyle(color: _viewModel.getTextColor(context)),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Eliminar',
                    style: TextStyle(color: _viewModel.getTextColor(context)),
                  ),
                ),
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
    _viewModel.nombreController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _viewModel.getCardColor(context),
        title: Text(
          'Agregar Nuevo Paralelo',
          style: TextStyle(color: _viewModel.getTextColor(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _viewModel.nombreController,
              style: TextStyle(color: _viewModel.getTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Letra del Paralelo',
                labelStyle: TextStyle(
                  color: _viewModel.getSecondaryTextColor(context),
                ),
                hintText: 'Ej: A, C, D, etc.',
                hintStyle: TextStyle(
                  color: _viewModel.getSecondaryTextColor(context),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _viewModel.getBorderColor(context),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _viewModel.getBorderColor(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _viewModel.parseColor(widget.carrera['color']),
                  ),
                ),
                counterText: 'Máximo 2 caracteres',
                counterStyle: TextStyle(
                  color: _viewModel.getSecondaryTextColor(context),
                ),
              ),
              maxLength: 2,
              textCapitalization: TextCapitalization.characters,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _viewModel.getInfoBackgroundColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: _viewModel.getInfoTextColor(context),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ingresa una letra para el paralelo (A, B, C, etc.)',
                      style: TextStyle(
                        fontSize: 12,
                        color: _viewModel.getInfoTextColor(context),
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
              style: TextStyle(
                color: _viewModel.getSecondaryTextColor(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_viewModel.nombreController.text.trim().isNotEmpty) {
                _viewModel.agregarParalelo(
                  _viewModel.nombreController.text.trim().toUpperCase(),
                  widget.carrera['id'].toString(),
                  widget.turno['id'].toString(),
                  widget.nivel['id'].toString(),
                  context,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _viewModel.parseColor(widget.carrera['color']),
            ),
            child: Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditarParaleloDialog(Map<String, dynamic> paralelo) {
    _viewModel.editarNombreController.text = paralelo['nombre'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _viewModel.getCardColor(context),
        title: Text(
          'Modificar Paralelo',
          style: TextStyle(color: _viewModel.getTextColor(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _viewModel.editarNombreController,
              style: TextStyle(color: _viewModel.getTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Letra del Paralelo',
                labelStyle: TextStyle(
                  color: _viewModel.getSecondaryTextColor(context),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _viewModel.getBorderColor(context),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _viewModel.getBorderColor(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _viewModel.parseColor(widget.carrera['color']),
                  ),
                ),
                counterText: 'Máximo 2 caracteres',
                counterStyle: TextStyle(
                  color: _viewModel.getSecondaryTextColor(context),
                ),
              ),
              maxLength: 2,
              textCapitalization: TextCapitalization.characters,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _viewModel.getInfoBackgroundColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: _viewModel.getInfoTextColor(context),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Modifica la letra del paralelo',
                      style: TextStyle(
                        fontSize: 12,
                        color: _viewModel.getInfoTextColor(context),
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
              style: TextStyle(
                color: _viewModel.getSecondaryTextColor(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_viewModel.editarNombreController.text.trim().isNotEmpty) {
                _viewModel.editarParalelo(
                  paralelo,
                  _viewModel.editarNombreController.text.trim().toUpperCase(),
                  widget.carrera['id'].toString(),
                  widget.turno['id'].toString(),
                  widget.nivel['id'].toString(),
                  context,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _viewModel.parseColor(widget.carrera['color']),
            ),
            child: Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEliminarParaleloDialog(Map<String, dynamic> paralelo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _viewModel.getCardColor(context),
        title: Text(
          'Eliminar Paralelo',
          style: TextStyle(color: _viewModel.getTextColor(context)),
        ),
        content: Text(
          '¿Estás seguro de eliminar el Paralelo ${paralelo['nombre']}?',
          style: TextStyle(color: _viewModel.getTextColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: _viewModel.getSecondaryTextColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _viewModel.eliminarParalelo(
                paralelo,
                widget.carrera['id'].toString(),
                widget.turno['id'].toString(),
                widget.nivel['id'].toString(),
                context,
              );
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
