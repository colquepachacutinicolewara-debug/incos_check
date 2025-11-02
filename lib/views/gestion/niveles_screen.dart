import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/data_manager.dart';
import '../../views/gestion/paralelos_scren.dart';
import '../../views/gestion/materias_screen.dart'; // Cambiar a MateriasScreen

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

  // Mapeo de años a materias para Sistemas Informáticos
  final Map<int, List<Map<String, dynamic>>> _materiasPorAnio = {
    1: [
      {
        'id': 'hardware',
        'codigo': 'HARD101',
        'nombre': 'Hardware de Computadoras',
        'color': '#FF6B6B',
      },
      {
        'id': 'matematica',
        'codigo': 'MAT101',
        'nombre': 'Matemática para la Informática',
        'color': '#4ECDC4',
      },
      {
        'id': 'ingles',
        'codigo': 'ING101',
        'nombre': 'Inglés Técnico',
        'color': '#45B7D1',
      },
      {
        'id': 'web1',
        'codigo': 'WEB101',
        'nombre': 'Diseño y Programación Web I',
        'color': '#96CEB4',
      },
      {
        'id': 'ofimatica',
        'codigo': 'OFI101',
        'nombre': 'Ofimática y Tecnología Multimedia',
        'color': '#FECA57',
      },
      {
        'id': 'sistemas-op',
        'codigo': 'SO101',
        'nombre': 'Taller de Sistemas Operativos',
        'color': '#FF9FF3',
      },
      {
        'id': 'programacion1',
        'codigo': 'PROG101',
        'nombre': 'Programación I',
        'color': '#54A0FF',
      },
    ],
    2: [
      {
        'id': 'programacion2',
        'codigo': 'PROG201',
        'nombre': 'Programación II',
        'color': '#54A0FF',
      },
      {
        'id': 'estructura',
        'codigo': 'ED201',
        'nombre': 'Estructura de Datos',
        'color': '#4ECDC4',
      },
      {
        'id': 'estadistica',
        'codigo': 'EST201',
        'nombre': 'Estadística',
        'color': '#4ECDC4',
      },
      {
        'id': 'basedatos1',
        'codigo': 'BD201',
        'nombre': 'Base de Datos I',
        'color': '#A55EEA',
      },
      {
        'id': 'redes1',
        'codigo': 'RED201',
        'nombre': 'Redes de Computadoras I',
        'color': '#FF6B6B',
      },
      {
        'id': 'analisis1',
        'codigo': 'ADS201',
        'nombre': 'Análisis y Diseño de Sistemas I',
        'color': '#F78FB3',
      },
      {
        'id': 'moviles1',
        'codigo': 'PM201',
        'nombre': 'Programación para Dispositivos Móviles I',
        'color': '#54A0FF',
      },
      {
        'id': 'web2',
        'codigo': 'WEB201',
        'nombre': 'Diseño y Programación Web II',
        'color': '#96CEB4',
      },
    ],
    3: [
      {
        'id': 'redes2',
        'codigo': 'RED301',
        'nombre': 'Redes de Computadoras II',
        'color': '#FF6B6B',
      },
      {
        'id': 'web3',
        'codigo': 'WEB301',
        'nombre': 'Diseño y Programación Web III',
        'color': '#96CEB4',
      },
      {
        'id': 'moviles2',
        'codigo': 'PM301',
        'nombre': 'Programación para Dispositivos Móviles II',
        'color': '#54A0FF',
      },
      {
        'id': 'analisis2',
        'codigo': 'ADS301',
        'nombre': 'Análisis y Diseño de Sistemas II',
        'color': '#F78FB3',
      },
      {
        'id': 'taller-grado',
        'codigo': 'TMG301',
        'nombre': 'Taller de Modalidad de Graduación',
        'color': '#45B7D1',
      },
      {
        'id': 'gestion-calidad',
        'codigo': 'GMC301',
        'nombre': 'Gestión y Mejoramiento de la Calidad de Software',
        'color': '#F78FB3',
      },
      {
        'id': 'basedatos2',
        'codigo': 'BD301',
        'nombre': 'Base de Datos II',
        'color': '#A55EEA',
      },
      {
        'id': 'emprendimiento',
        'codigo': 'EMP301',
        'nombre': 'Emprendimiento Productivo',
        'color': '#45B7D1',
      },
    ],
  };

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

  @override
  void initState() {
    super.initState();
    // Obtener niveles específicos de este turno y carrera
    _niveles = _dataManager.getNiveles(
      widget.carrera['id'].toString(),
      widget.turno['id'].toString(),
    );

    // SOLO para "Sistemas Informáticos" agregar nivel por defecto
    // Las nuevas carreras (como "Idioma Inglés") empiezan VACÍAS
    if (_niveles.isEmpty && _esSistemasInformaticos()) {
      _agregarNivelPorDefectoSistemas();
    }
  }

  // Verificar si es la carrera "Sistemas Informáticos"
  bool _esSistemasInformaticos() {
    return widget.carrera['nombre'] == 'Sistemas Informáticos';
  }

  void _agregarNivelPorDefectoSistemas() {
    final nivelPorDefecto = {
      'id': '${widget.turno['id']}_tercero',
      'nombre': 'Tercero',
      'activo': true,
      'orden': 3,
      'paralelos': [], // Inicializar paralelos vacíos
    };

    _dataManager.agregarNivel(
      widget.carrera['id'].toString(),
      widget.turno['id'].toString(),
      nivelPorDefecto,
    );

    setState(() {
      _niveles = _dataManager.getNiveles(
        widget.carrera['id'].toString(),
        widget.turno['id'].toString(),
      );
    });
  }

  // Mapeo de nombres de nivel a año numérico
  int _obtenerAnioDesdeNivel(String nombreNivel) {
    switch (nombreNivel.toLowerCase()) {
      case 'primero':
        return 1;
      case 'segundo':
        return 2;
      case 'tercero':
        return 3;
      case 'cuarto':
        return 4;
      case 'quinto':
        return 5;
      default:
        return 1; // Por defecto
    }
  }

  @override
  Widget build(BuildContext context) {
    Color carreraColor = _parseColor(widget.carrera['color']);

    // Ordenar niveles antes de construir la lista
    _niveles.sort((a, b) => (a['orden'] ?? 99).compareTo(b['orden'] ?? 99));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.carrera['nombre']} - ${widget.turno['nombre']} - ${widget.tipo == 'Cursos' ? 'Cursos' : 'Niveles'}',
          style: AppTextStyles.heading2Dark(
            context,
          ).copyWith(color: Colors.white),
        ),
        backgroundColor: carreraColor,
      ),
      body: _niveles.isEmpty
          ? Center(
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

    // Para cursos, mostrar información adicional
    int anio = _obtenerAnioDesdeNivel(nivel['nombre']);
    int cantidadMaterias = _materiasPorAnio[anio]?.length ?? 0;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      color: Theme.of(context).cardColor,
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
          widget.tipo == 'Cursos'
              ? '${nivel['nombre']} Año'
              : '${nivel['nombre']} Nivel',
          style: AppTextStyles.heading3Dark(
            context,
          ).copyWith(color: isActive ? _getTextColor(context) : Colors.grey),
        ),
        subtitle: widget.tipo == 'Cursos'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: isActive ? Colors.green : Colors.red,
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
          if (isActive) {
            if (widget.tipo == 'Estudiantes') {
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
            } else if (widget.tipo == 'Cursos') {
              // Navegar directamente a MateriasScreen para cursos
              _navegarAMaterias(context);
            }
          }
        },
      ),
    );
  }

  void _navegarAMaterias(BuildContext context) {
    // Navegar directamente a MateriasScreen
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
              controller: _nombreController,
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
              if (_nombreController.text.trim().isNotEmpty) {
                _agregarNivel(_nombreController.text.trim());
                Navigator.pop(context);
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

  void _agregarNivel(String nombre) {
    String nombreLower = nombre.toLowerCase().trim();
    int orden = _ordenNiveles[nombreLower] ?? 99;

    final nuevoNivel = {
      'id': '${widget.turno['id']}_${DateTime.now().millisecondsSinceEpoch}',
      'nombre': _capitalizarPrimeraLetra(nombre),
      'activo': true,
      'orden': orden,
      'paralelos': [], // Inicializar paralelos VACÍOS
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
        content: Text(
          'Nivel "$nombre" agregado correctamente',
          style: AppTextStyles.bodyDark(context).copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showEditarNivelDialog(Map<String, dynamic> nivel) {
    _editarNombreController.text = nivel['nombre'];

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
              controller: _editarNombreController,
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
              if (_editarNombreController.text.trim().isNotEmpty) {
                _editarNivel(nivel, _editarNombreController.text.trim());
                Navigator.pop(context);
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
        content: Text(
          'Nivel actualizado a "$nuevoNombre"',
          style: AppTextStyles.bodyDark(context).copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showEliminarNivelDialog(Map<String, dynamic> nivel) {
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
          '¿Estás seguro de eliminar el ${nivel['nombre']} Nivel?',
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
              _eliminarNivel(nivel);
              Navigator.pop(context);
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
        content: Text(
          'Nivel "$nombreEliminado" eliminado',
          style: AppTextStyles.bodyDark(context).copyWith(color: Colors.white),
        ),
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
