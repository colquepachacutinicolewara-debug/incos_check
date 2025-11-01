import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/data_manager.dart';
import '../../views/gestion/paralelos_scren.dart';

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
  final DataManager _dataManager = DataManager();
  late List<Map<String, dynamic>> _niveles;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _editarNombreController = TextEditingController();

  // Mapeo de nombres a valores de orden
  final Map<String, int> _ordenNiveles = {
    'primero': 1,
    'segundo': 2,
    'tercero': 3,
    'cuarto': 4,
    'quinto': 5,
    'sexto': 6,
    'séptimo': 7,
    'octavo': 8,
    'noveno': 9,
    'décimo': 10,
  };

  @override
  void initState() {
    super.initState();
    // Obtener niveles específicos de este turno y carrera
    _niveles = _dataManager.getNiveles(
      widget.carrera['id'].toString(),
      widget.turno['id'].toString(),
    );

    // Si no hay niveles, agregar algunos por defecto
    if (_niveles.isEmpty) {
      _agregarNivelesPorDefecto();
    }
  }

  void _agregarNivelesPorDefecto() {
    final nivelesPorDefecto = [
      {
        'id': '${widget.turno['id']}_tercero',
        'nombre': 'Tercero',
        'activo': true,
        'orden': 3,
        'paralelos': [], // Inicializar paralelos vacíos
      },
    ];

    for (var nivel in nivelesPorDefecto) {
      _dataManager.agregarNivel(
        widget.carrera['id'].toString(),
        widget.turno['id'].toString(),
        nivel,
      );
    }

    setState(() {
      _niveles = _dataManager.getNiveles(
        widget.carrera['id'].toString(),
        widget.turno['id'].toString(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Color carreraColor = _parseColor(widget.carrera['color']);

    // Ordenar niveles antes de construir la lista
    _niveles.sort((a, b) => (a['orden'] ?? 99).compareTo(b['orden'] ?? 99));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.carrera['nombre']} - ${widget.turno['nombre']} - Niveles',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: carreraColor,
      ),
      body: _niveles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.layers, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay niveles configurados',
                    style: AppTextStyles.heading3,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Presiona el botón + para agregar un nivel',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacing.medium),
              itemCount: _niveles.length,
              itemBuilder: (context, index) {
                final nivel = _niveles[index];
                return _buildNivelCard(nivel, context, carreraColor);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAgregarNivelDialog,
        backgroundColor: carreraColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNivelCard(
    Map<String, dynamic> nivel,
    BuildContext context,
    Color color,
  ) {
    bool isActive = nivel['activo'] ?? true;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            _obtenerNumeroRomano(nivel['orden']),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          '${nivel['nombre']} Nivel',
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
                _toggleActivarNivel(nivel, value);
              },
              activeColor: color,
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, nivel),
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
                builder: (context) => ParalelosScreen(
                  tipo: widget.tipo,
                  carrera: widget.carrera,
                  turno: widget.turno,
                  nivel: nivel,
                ),
              ),
            );
          }
        },
      ),
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

  void _handleMenuAction(String action, Map<String, dynamic> nivel) {
    switch (action) {
      case 'edit':
        _showEditarNivelDialog(nivel);
        break;
      case 'delete':
        _showEliminarNivelDialog(nivel);
        break;
    }
  }

  void _toggleActivarNivel(Map<String, dynamic> nivel, bool value) {
    final nivelActualizado = Map<String, dynamic>.from(nivel);
    nivelActualizado['activo'] = value;

    _dataManager.actualizarNivel(
      widget.carrera['id'].toString(),
      widget.turno['id'].toString(),
      nivel['id'].toString(),
      nivelActualizado,
    );

    setState(() {
      _niveles = _dataManager.getNiveles(
        widget.carrera['id'].toString(),
        widget.turno['id'].toString(),
      );
    });
  }

  void _showAgregarNivelDialog() {
    _nombreController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Nuevo Nivel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del Nivel',
                hintText: 'Ej: Primero, Segundo, Cuarto, etc.',
                border: OutlineInputBorder(),
              ),
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
                      'Los niveles se ordenarán automáticamente: Primero, Segundo, Tercero, Cuarto, Quinto, etc.',
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
                _agregarNivel(_nombreController.text.trim());
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

  void _agregarNivel(String nombre) {
    String nombreLower = nombre.toLowerCase().trim();
    int orden = _ordenNiveles[nombreLower] ?? 99;

    final nuevoNivel = {
      'id': '${widget.turno['id']}_${DateTime.now().millisecondsSinceEpoch}',
      'nombre': _capitalizarPrimeraLetra(nombre),
      'activo': true,
      'orden': orden,
      'paralelos': [], // Inicializar paralelos vacíos
    };

    _dataManager.agregarNivel(
      widget.carrera['id'].toString(),
      widget.turno['id'].toString(),
      nuevoNivel,
    );

    setState(() {
      _niveles = _dataManager.getNiveles(
        widget.carrera['id'].toString(),
        widget.turno['id'].toString(),
      );
      // Ordenar después de agregar
      _niveles.sort((a, b) => (a['orden'] ?? 99).compareTo(b['orden'] ?? 99));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nivel "$nombre" agregado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showEditarNivelDialog(Map<String, dynamic> nivel) {
    _editarNombreController.text = nivel['nombre'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modificar Nivel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _editarNombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del Nivel',
                border: OutlineInputBorder(),
              ),
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
                      'Al cambiar el nombre se reordenará automáticamente',
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
                _editarNivel(nivel, _editarNombreController.text.trim());
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

  void _editarNivel(Map<String, dynamic> nivel, String nuevoNombre) {
    String nombreLower = nuevoNombre.toLowerCase().trim();
    int nuevoOrden = _ordenNiveles[nombreLower] ?? nivel['orden'] ?? 99;

    final nivelActualizado = Map<String, dynamic>.from(nivel);
    nivelActualizado['nombre'] = _capitalizarPrimeraLetra(nuevoNombre);
    nivelActualizado['orden'] = nuevoOrden;

    _dataManager.actualizarNivel(
      widget.carrera['id'].toString(),
      widget.turno['id'].toString(),
      nivel['id'].toString(),
      nivelActualizado,
    );

    setState(() {
      _niveles = _dataManager.getNiveles(
        widget.carrera['id'].toString(),
        widget.turno['id'].toString(),
      );
      // Reordenar después de editar
      _niveles.sort((a, b) => (a['orden'] ?? 99).compareTo(b['orden'] ?? 99));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nivel actualizado a "$nuevoNombre"'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showEliminarNivelDialog(Map<String, dynamic> nivel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Nivel'),
        content: Text('¿Estás seguro de eliminar el ${nivel['nombre']} Nivel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _eliminarNivel(nivel);
              Navigator.pop(context);
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _eliminarNivel(Map<String, dynamic> nivel) {
    String nombreEliminado = nivel['nombre'];

    _dataManager.eliminarNivel(
      widget.carrera['id'].toString(),
      widget.turno['id'].toString(),
      nivel['id'].toString(),
    );

    setState(() {
      _niveles = _dataManager.getNiveles(
        widget.carrera['id'].toString(),
        widget.turno['id'].toString(),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nivel "$nombreEliminado" eliminado'),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _capitalizarPrimeraLetra(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}
