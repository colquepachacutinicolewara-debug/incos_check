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
  final DataManager _dataManager = DataManager();
  List<Map<String, dynamic>> _paralelos = [];

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _editarNombreController = TextEditingController();

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
  void initState() {
    super.initState();
    _inicializarYcargarParalelos();
  }

  void _inicializarYcargarParalelos() {
    // INICIALIZAR SIEMPRE la carrera en DataManager
    _dataManager.inicializarCarrera(
      widget.carrera['id'].toString(),
      widget.carrera['nombre'],
      widget.carrera['color'],
    );

    // SOLO cargar datos de ejemplo para Sistemas Informáticos - Tercero - Noche
    final bool esSistemasTerceroNoche =
        widget.carrera['nombre'].toUpperCase().contains('SISTEMAS') &&
        widget.nivel['nombre'] == 'Tercero' &&
        widget.turno['nombre'] == 'Noche';

    if (esSistemasTerceroNoche) {
      _cargarParaleloEjemploSistemas();
    } else {
      _cargarParalelosDataManager();
    }
  }

  void _cargarParaleloEjemploSistemas() {
    // Datos de ejemplo SOLO para mostrar
    setState(() {
      _paralelos = [
        {
          'id': 'sistemas_noche_tercero_B',
          'nombre': 'B',
          'activo': true,
          'estudiantes': [
            {
              'id': 1,
              'nombres': 'Juan Carlos',
              'apellidoPaterno': 'Pérez',
              'apellidoMaterno': 'Gómez',
              'ci': '1234567',
              'fechaRegistro': '2024-01-15',
              'huellasRegistradas': 3,
            },
            {
              'id': 2,
              'nombres': 'María Elena',
              'apellidoPaterno': 'López',
              'apellidoMaterno': 'Martínez',
              'ci': '7654321',
              'fechaRegistro': '2024-01-16',
              'huellasRegistradas': 2,
            },
          ],
        },
      ];
    });
  }

  void _cargarParalelosDataManager() {
    // Para TODAS las demás carreras, usar DataManager
    final paralelosDataManager = _dataManager.getParalelos(
      widget.carrera['id'].toString(),
      widget.turno['id'].toString(),
      widget.nivel['id'].toString(),
    );

    setState(() {
      _paralelos = paralelosDataManager;
    });
  }

  bool get _esCarreraDeEjemplo {
    return widget.carrera['nombre'].toUpperCase().contains('SISTEMAS') &&
        widget.nivel['nombre'] == 'Tercero' &&
        widget.turno['nombre'] == 'Noche';
  }

  @override
  Widget build(BuildContext context) {
    Color carreraColor = _parseColor(widget.carrera['color']);

    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          '${widget.carrera['nombre']} - ${widget.turno['nombre']} - ${widget.nivel['nombre']}',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: carreraColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _paralelos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 80,
                    color: _getSecondaryTextColor(context),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay paralelos',
                    style: AppTextStyles.heading3.copyWith(
                      color: _getSecondaryTextColor(context),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _esCarreraDeEjemplo
                        ? 'Esta es una vista de ejemplo con datos demostrativos'
                        : 'Presiona el botón + para agregar el primer paralelo',
                    style: TextStyle(color: _getSecondaryTextColor(context)),
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
    bool esEjemplo =
        _esCarreraDeEjemplo && paralelo['id'] == 'sistemas_noche_tercero_B';

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      color: _getCardColor(context),
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
        title: Row(
          children: [
            Text(
              'Paralelo ${paralelo['nombre']}',
              style: AppTextStyles.heading3.copyWith(
                color: isActive ? _getTextColor(context) : Colors.grey,
              ),
            ),
            if (esEjemplo) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
              isActive ? 'Activo' : 'Inactivo',
              style: TextStyle(color: isActive ? Colors.green : Colors.red),
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
            Switch(
              value: isActive,
              onChanged: esEjemplo
                  ? null
                  : (value) {
                      _cambiarEstadoParalelo(paralelo, value);
                    },
              activeColor: color,
            ),
            if (!esEjemplo)
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, paralelo),
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
        backgroundColor: _getCardColor(context),
        title: Text(
          'Agregar Nuevo Paralelo',
          style: TextStyle(color: _getTextColor(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
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
                    color: _parseColor(widget.carrera['color']),
                  ),
                ),
                counterText: 'Máximo 2 caracteres',
                counterStyle: TextStyle(color: _getSecondaryTextColor(context)),
              ),
              maxLength: 2,
              textCapitalization: TextCapitalization.characters,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getInfoBackgroundColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: _getInfoTextColor(context), size: 16),
                  SizedBox(width: 8),
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

    // Crear nuevo paralelo con ID único
    Map<String, dynamic> nuevoParalelo = {
      'id':
          '${widget.carrera['id']}_${widget.turno['id']}_${widget.nivel['id']}_$nombre',
      'nombre': nombre,
      'activo': true,
      'estudiantes': [],
    };

    // Guardar en DataManager
    _dataManager.agregarParalelo(
      widget.carrera['id'].toString(),
      widget.turno['id'].toString(),
      widget.nivel['id'].toString(),
      nuevoParalelo,
    );

    setState(() {
      _paralelos.add(nuevoParalelo);
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

  void _cambiarEstadoParalelo(Map<String, dynamic> paralelo, bool nuevoEstado) {
    setState(() {
      paralelo['activo'] = nuevoEstado;
    });

    // Actualizar en DataManager
    _dataManager.actualizarParalelo(
      widget.carrera['id'].toString(),
      widget.turno['id'].toString(),
      widget.nivel['id'].toString(),
      paralelo['id'].toString(),
      paralelo,
    );
  }

  void _showEditarParaleloDialog(Map<String, dynamic> paralelo) {
    _editarNombreController.text = paralelo['nombre'];

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
              controller: _editarNombreController,
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
                    color: _parseColor(widget.carrera['color']),
                  ),
                ),
                counterText: 'Máximo 2 caracteres',
                counterStyle: TextStyle(color: _getSecondaryTextColor(context)),
              ),
              maxLength: 2,
              textCapitalization: TextCapitalization.characters,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getInfoBackgroundColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: _getInfoTextColor(context), size: 16),
                  SizedBox(width: 8),
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

    String nombreAnterior = paralelo['nombre'];

    setState(() {
      paralelo['nombre'] = nuevoNombre;
      // Reordenar después de editar
      _paralelos.sort((a, b) => a['nombre'].compareTo(b['nombre']));
    });

    // Actualizar en DataManager
    _dataManager.actualizarParalelo(
      widget.carrera['id'].toString(),
      widget.turno['id'].toString(),
      widget.nivel['id'].toString(),
      paralelo['id'].toString(),
      paralelo,
    );

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
        backgroundColor: _getCardColor(context),
        title: Text(
          'Eliminar Paralelo',
          style: TextStyle(color: _getTextColor(context)),
        ),
        content: Text(
          '¿Estás seguro de eliminar el Paralelo ${paralelo['nombre']}?',
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
              _eliminarParalelo(paralelo);
              Navigator.pop(context);
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _eliminarParalelo(Map<String, dynamic> paralelo) {
    String nombreEliminado = paralelo['nombre'];

    // Eliminar del DataManager
    _dataManager.eliminarParalelo(
      widget.carrera['id'].toString(),
      widget.turno['id'].toString(),
      widget.nivel['id'].toString(),
      paralelo['id'].toString(),
    );

    setState(() {
      _paralelos.removeWhere((p) => p['id'] == paralelo['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paralelo $nombreEliminado eliminado'),
        backgroundColor: Colors.red,
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
