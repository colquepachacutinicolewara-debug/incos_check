// views/carreras_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import 'docentes_screen.dart';
import 'turnos_screen.dart';
import '../../views/gestion/programas/programas_screen.dart';
import '../../viewmodels/carreras_viewmodel.dart';
import '../../models/carrera_model.dart';

class CarrerasScreen extends StatefulWidget {
  final String tipo;
  final String carreraSeleccionada;
  final Function(List<String>)? onCarrerasActualizadas;
  final bool mostrarInformacionCarreras;

  const CarrerasScreen({
    super.key,
    required this.tipo,
    required this.carreraSeleccionada,
    this.onCarrerasActualizadas,
    this.mostrarInformacionCarreras = false,
  });

  @override
  State<CarrerasScreen> createState() => _CarrerasScreenState();
}

class _CarrerasScreenState extends State<CarrerasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarYNotificar();
    });
  }

  void _cargarYNotificar() {
    final viewModel = context.read<CarrerasViewModel>();
    
    // Esperar a que se carguen las carreras y luego notificar
    if (!viewModel.isLoading) {
      _notificarCambiosCarreras();
    }
  }

  void _notificarCambiosCarreras() {
    if (widget.onCarrerasActualizadas != null) {
      final viewModel = context.read<CarrerasViewModel>();
      final carrerasActivas = viewModel.nombresCarrerasActivas;
      
      print('Notificando cambios en carreras: $carrerasActivas');
      widget.onCarrerasActualizadas!(carrerasActivas);
    }
  }

  @override
  void didUpdateWidget(CarrerasScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tipo != widget.tipo || 
        oldWidget.mostrarInformacionCarreras != widget.mostrarInformacionCarreras) {
      _notificarCambiosCarreras();
    }
  }

  void _navegarADocentes(CarreraModel carrera) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocentesScreen(carrera: carrera.toMap()),
      ),
    );
  }

  void _navegarATurnos(CarreraModel carrera) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TurnosScreen(
          tipo: widget.tipo,
          carrera: carrera.toMap(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CarrerasViewModel(),
      child: Consumer<CarrerasViewModel>(
        builder: (context, viewModel, child) {
          // Manejar navegación a ProgramasScreen
          if (widget.mostrarInformacionCarreras) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProgramasScreen()),
              );
            });
            return _buildLoadingState();
          }

          // Manejar estados de carga y error
          if (viewModel.isLoading && viewModel.carreras.isEmpty) {
            return _buildLoadingState();
          }

          if (viewModel.error != null) {
            return _buildErrorState(viewModel.error!, viewModel);
          }

          // Notificar cambios cuando se actualice el ViewModel
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _notificarCambiosCarreras();
          });

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Carreras - ${widget.tipo}',
                style: AppTextStyles.heading2Dark(
                  context,
                ).copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.secondary,
            ),
            body: viewModel.carreras.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(AppSpacing.medium),
                    itemCount: viewModel.carreras.length + 1,
                    itemBuilder: (context, index) {
                      if (index == viewModel.carreras.length) {
                        return _buildProgramasCard(context);
                      }
                      final carrera = viewModel.carreras[index];
                      return _buildCarreraCard(carrera, context, viewModel);
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAgregarCarreraDialog(context, viewModel),
              backgroundColor: AppColors.primary,
              child: Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carreras - ${widget.tipo}',
          style: AppTextStyles.heading2Dark(
            context,
          ).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.medium),
            Text(
              'Cargando carreras...',
              style: AppTextStyles.bodyDark(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, CarrerasViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carreras - ${widget.tipo}',
          style: AppTextStyles.heading2Dark(
            context,
          ).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppSpacing.medium),
            Text(
              'Error al cargar carreras',
              style: AppTextStyles.bodyDark(context),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.large),
              child: Text(
                error,
                style: AppTextStyles.bodyDark(context).copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSpacing.medium),
            ElevatedButton(
              onPressed: () {
                viewModel.reintentarCarga();
              },
              child: Text('Reintentar'),
            ),
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
          Icon(
            Icons.school,
            size: 64,
            color: AppColors.textSecondaryDark(context),
          ),
          SizedBox(height: AppSpacing.medium),
          Text(
            'No hay carreras registradas',
            style: AppTextStyles.bodyDark(
              context,
            ).copyWith(color: AppColors.textSecondaryDark(context)),
          ),
          Text(
            'Presiona el botón + para agregar una carrera',
            style: AppTextStyles.bodyDark(context).copyWith(
              fontSize: 12,
              color: AppColors.textSecondaryDark(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramasCard(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(
        bottom: AppSpacing.medium,
        top: AppSpacing.medium,
      ),
      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
      child: Container(
        height: 100,
        child: ListTile(
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(isDarkMode ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(Icons.info, color: AppColors.info, size: 30),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Programas de Estudio',
                style: AppTextStyles.heading3Dark(context).copyWith(
                  color: _getTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Información completa de todas las carreras del INCOs El Alto',
                style: AppTextStyles.bodyDark(context).copyWith(
                  color: _getSecondaryTextColor(context),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.info,
            size: 20,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProgramasScreen()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCarreraCard(
    CarreraModel carrera,
    BuildContext context,
    CarrerasViewModel viewModel,
  ) {
    Color color = CarrerasViewModel.parseColor(carrera.color);
    bool isActiva = carrera.activa;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      color: isActiva
          ? Theme.of(context).cardColor
          : Colors.grey.shade300.withOpacity(0.5),
      child: Container(
        height: 80,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isActiva ? color : Colors.grey,
            child: Icon(carrera.icon, color: Colors.white),
          ),
          title: Container(
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        carrera.nombre,
                        style: AppTextStyles.heading3Dark(context).copyWith(
                          color: isActiva
                              ? _getTextColor(context)
                              : AppColors.textSecondaryDark(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isActiva) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Inactiva',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) =>
                _handleMenuAction(value, carrera, viewModel, context),
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
                value: 'toggle_active',
                child: Text(
                  carrera.activa ? 'Desactivar' : 'Activar',
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
          onTap: isActiva
              ? () {
                  if (widget.tipo == 'Docentes') {
                    _navegarADocentes(carrera);
                  } else {
                    _navegarATurnos(carrera);
                  }
                }
              : null,
        ),
      ),
    );
  }

  void _handleMenuAction(
    String action,
    CarreraModel carrera,
    CarrerasViewModel viewModel,
    BuildContext context,
  ) {
    switch (action) {
      case 'edit':
        _showEditarCarreraDialog(carrera, context, viewModel);
        break;
      case 'toggle_active':
        _toggleActivarCarrera(carrera, viewModel, context);
        break;
      case 'delete':
        _showEliminarCarreraDialog(carrera, viewModel, context);
        break;
    }
  }

  void _toggleActivarCarrera(
    CarreraModel carrera,
    CarrerasViewModel viewModel,
    BuildContext context,
  ) {
    viewModel.toggleActivarCarrera(carrera.id);

    // Notificar cambios después de modificar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificarCambiosCarreras();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${carrera.nombre} ${!carrera.activa ? 'activada' : 'desactivada'}',
          style: AppTextStyles.bodyDark(context).copyWith(color: Colors.white),
        ),
        backgroundColor: !carrera.activa
            ? AppColors.success
            : AppColors.warning,
      ),
    );
  }

  void _showAgregarCarreraDialog(
    BuildContext context,
    CarrerasViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => _CarreraDialog(
        title: 'Agregar Carrera',
        onSave: (nombre, color, icono) {
          _agregarCarreraYNotificar(nombre, color, icono, viewModel, context);
        },
      ),
    );
  }

  void _agregarCarreraYNotificar(
    String nombre,
    String color,
    IconData icono,
    CarrerasViewModel viewModel,
    BuildContext context,
  ) {
    viewModel.agregarCarrera(nombre, color, icono);
    
    // Notificar cambios después de agregar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificarCambiosCarreras();
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Carrera "$nombre" agregada correctamente'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showEditarCarreraDialog(
    CarreraModel carrera,
    BuildContext context,
    CarrerasViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => _CarreraDialog(
        title: 'Modificar Carrera',
        nombreInicial: carrera.nombre,
        colorInicial: carrera.color,
        iconoInicial: carrera.icon,
        onSave: (nombre, color, icono) {
          _editarCarreraYNotificar(carrera.id, nombre, color, icono, viewModel, context);
        },
      ),
    );
  }

  void _editarCarreraYNotificar(
    String id,
    String nombre,
    String color,
    IconData icono,
    CarrerasViewModel viewModel,
    BuildContext context,
  ) {
    viewModel.editarCarrera(id, nombre, color, icono);
    
    // Notificar cambios después de editar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificarCambiosCarreras();
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Carrera "$nombre" modificada correctamente'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showEliminarCarreraDialog(
    CarreraModel carrera,
    CarrerasViewModel viewModel,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Eliminar Carrera',
          style: AppTextStyles.heading2Dark(
            context,
          ).copyWith(color: _getTextColor(context)),
        ),
        content: Text(
          '¿Estás seguro de eliminar la carrera "${carrera.nombre}"? Esta acción no se puede deshacer.',
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
              _eliminarCarreraYNotificar(carrera, viewModel, context);
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

  void _eliminarCarreraYNotificar(
    CarreraModel carrera,
    CarrerasViewModel viewModel,
    BuildContext context,
  ) {
    final nombreCarrera = carrera.nombre;
    viewModel.eliminarCarrera(carrera.id);
    
    // Notificar cambios después de eliminar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificarCambiosCarreras();
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Carrera "$nombreCarrera" eliminada',
          style: AppTextStyles.bodyDark(
            context,
          ).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.error,
      ),
    );
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
}

// Diálogo para agregar/modificar carreras (MANTENIDO IGUAL)
class _CarreraDialog extends StatefulWidget {
  final String title;
  final String? nombreInicial;
  final String? colorInicial;
  final IconData? iconoInicial;
  final Function(String nombre, String color, IconData icono) onSave;

  const _CarreraDialog({
    required this.title,
    this.nombreInicial,
    this.colorInicial,
    this.iconoInicial,
    required this.onSave,
  });

  @override
  State<_CarreraDialog> createState() => _CarreraDialogState();
}

class _CarreraDialogState extends State<_CarreraDialog> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  IconData _iconoSeleccionado = Icons.school;
  bool _mostrarMasIconos = false;
  bool _mostrarMasColores = false;

  final List<Map<String, dynamic>> _carrerasPredefinidas = [
    {
      'nombre': 'Sistemas Informáticos',
      'color': '#1565C0',
      'icon': Icons.computer,
    },
    {
      'nombre': 'Comercio Internacional y Administración Aduanera',
      'color': '#FF9800',
      'icon': Icons.business,
    },
    {
      'nombre': 'Secretariado Ejecutivo',
      'color': '#4CAF50',
      'icon': Icons.work,
    },
    {
      'nombre': 'Administración de Empresas',
      'color': '#03A9F4',
      'icon': Icons.business_center,
    },
    {
      'nombre': 'Contaduría General',
      'color': '#FFEB3B',
      'icon': Icons.calculate,
    },
    {'nombre': 'Idioma Inglés', 'color': '#F44336', 'icon': Icons.language},
  ];

  final List<Map<String, dynamic>> _coloresDisponibles = [
    {'nombre': 'Azul Sistemas', 'color': '#1565C0'},
    {'nombre': 'Naranja Comercio', 'color': '#FF9800'},
    {'nombre': 'Verde Secretariado', 'color': '#4CAF50'},
    {'nombre': 'Celeste Administración', 'color': '#03A9F4'},
    {'nombre': 'Amarillo Contaduría', 'color': '#FFEB3B'},
    {'nombre': 'Rojo Inglés', 'color': '#F44336'},
  ];

  final List<Map<String, dynamic>> _masColores = [
    {'nombre': 'Morado', 'color': '#9C27B0'},
    {'nombre': 'Rosa', 'color': '#E91E63'},
    {'nombre': 'Café', 'color': '#795548'},
    {'nombre': 'Verde Oscuro', 'color': '#2E7D32'},
    {'nombre': 'Azul Oscuro', 'color': '#0D47A1'},
    {'nombre': 'Verde Lima', 'color': '#CDDC39'},
    {'nombre': 'Azul Claro', 'color': '#29B6F6'},
    {'nombre': 'Verde Esmeralda', 'color': '#009688'},
    {'nombre': 'Naranja Oscuro', 'color': '#E65100'},
    {'nombre': 'Rojo Oscuro', 'color': '#C62828'},
    {'nombre': 'Rosa Fuerte', 'color': '#AD1457'},
    {'nombre': 'Morado Oscuro', 'color': '#6A1B9A'},
    {'nombre': 'Gris Azulado', 'color': '#546E7A'},
    {'nombre': 'Cyan', 'color': '#00BCD4'},
    {'nombre': 'Teal', 'color': '#00695C'},
    {'nombre': 'Deep Orange', 'color': '#FF5722'},
  ];

  final List<Map<String, dynamic>> _iconosDisponibles = [
    {'icon': Icons.computer, 'nombre': 'Sistemas'},
    {'icon': Icons.business, 'nombre': 'Comercio'},
    {'icon': Icons.work, 'nombre': 'Secretariado'},
    {'icon': Icons.business_center, 'nombre': 'Administración'},
    {'icon': Icons.calculate, 'nombre': 'Contaduría'},
    {'icon': Icons.language, 'nombre': 'Idiomas'},
    {'icon': Icons.school, 'nombre': 'General'},
    {'icon': Icons.engineering, 'nombre': 'Ingeniería'},
    {'icon': Icons.medical_services, 'nombre': 'Medicina'},
    {'icon': Icons.gavel, 'nombre': 'Derecho'},
    {'icon': Icons.psychology, 'nombre': 'Psicología'},
    {'icon': Icons.architecture, 'nombre': 'Arquitectura'},
  ];

  final List<Map<String, dynamic>> _masIconos = [
    {'icon': Icons.music_note, 'nombre': 'Música'},
    {'icon': Icons.palette, 'nombre': 'Arte'},
    {'icon': Icons.sports_soccer, 'nombre': 'Deportes'},
    {'icon': Icons.theater_comedy, 'nombre': 'Teatro'},
    {'icon': Icons.camera_alt, 'nombre': 'Fotografía'},
    {'icon': Icons.movie, 'nombre': 'Cine'},
    {'icon': Icons.restaurant, 'nombre': 'Gastronomía'},
    {'icon': Icons.directions_car, 'nombre': 'Automotriz'},
    {'icon': Icons.flight, 'nombre': 'Aviación'},
    {'icon': Icons.local_shipping, 'nombre': 'Logística'},
    {'icon': Icons.agriculture, 'nombre': 'Agronomía'},
    {'icon': Icons.forest, 'nombre': 'Ambiental'},
    {'icon': Icons.biotech, 'nombre': 'Biotecnología'},
    {'icon': Icons.phone_android, 'nombre': 'Móviles'},
    {'icon': Icons.security, 'nombre': 'Seguridad'},
    {'icon': Icons.analytics, 'nombre': 'Analítica'},
    {'icon': Icons.cloud, 'nombre': 'Cloud'},
    {'icon': Icons.router, 'nombre': 'Redes'},
    {'icon': Icons.videogame_asset, 'nombre': 'Videojuegos'},
    {'icon': Icons.design_services, 'nombre': 'Diseño'},
    {'icon': Icons.science, 'nombre': 'Ciencia'},
    {'icon': Icons.biotech, 'nombre': 'Biotecnología'},
    {'icon': Icons.local_hospital, 'nombre': 'Enfermería'},
    {'icon': Icons.healing, 'nombre': 'Farmacia'},
    {'icon': Icons.eco, 'nombre': 'Ambiental'},
    {'icon': Icons.construction, 'nombre': 'Construcción'},
    {'icon': Icons.electrical_services, 'nombre': 'Electricidad'},
    {'icon': Icons.plumbing, 'nombre': 'Plomería'},
    {'icon': Icons.directions_boat, 'nombre': 'Marítima'},
    {'icon': Icons.temple_buddhist, 'nombre': 'Turismo'},
    {'icon': Icons.hotel, 'nombre': 'Hotelería'},
    {'icon': Icons.spa, 'nombre': 'Belleza'},
  ];

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.nombreInicial ?? '';
    _colorController.text = widget.colorInicial ?? '#1565C0';
    _iconoSeleccionado = widget.iconoInicial ?? Icons.school;
  }

  List<Map<String, dynamic>> get _coloresVisibles {
    final coloresBase = _carrerasPredefinidas
        .map((c) => {'nombre': c['nombre'], 'color': c['color']})
        .toList();
    return _mostrarMasColores ? [...coloresBase, ..._masColores] : coloresBase;
  }

  List<Map<String, dynamic>> get _iconosVisibles {
    final iconosBase = _carrerasPredefinidas
        .map((c) => {'icon': c['icon'], 'nombre': c['nombre']})
        .toList();
    return _mostrarMasIconos
        ? [...iconosBase, ..._iconosDisponibles, ..._masIconos]
        : [...iconosBase, ..._iconosDisponibles];
  }

  void _seleccionarCarreraPredefinida(Map<String, dynamic> carrera) {
    setState(() {
      _nombreController.text = carrera['nombre'];
      _colorController.text = carrera['color'];
      _iconoSeleccionado = carrera['icon'];
    });
  }

  void _guardarCarrera() {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El nombre de la carrera es requerido'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (nombre.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El nombre debe tener al menos 3 caracteres'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    widget.onSave(nombre, _colorController.text, _iconoSeleccionado);
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

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      title: Text(
        widget.title,
        style: AppTextStyles.heading2Dark(
          context,
        ).copyWith(color: _getTextColor(context)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Carreras predefinidas:',
              style: AppTextStyles.bodyDark(context).copyWith(
                fontWeight: FontWeight.bold,
                color: _getTextColor(context),
              ),
            ),
            SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: _carrerasPredefinidas.map((carrera) {
                return Container(
                  margin: EdgeInsets.only(bottom: 4),
                  child: FilterChip(
                    label: Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: Text(
                        carrera['nombre'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyDark(context).copyWith(
                          color: _nombreController.text == carrera['nombre']
                              ? _parseColor(carrera['color'])
                              : _getTextColor(context),
                        ),
                      ),
                    ),
                    selected: _nombreController.text == carrera['nombre'],
                    onSelected: (selected) {
                      if (selected) {
                        _seleccionarCarreraPredefinida(carrera);
                      }
                    },
                    backgroundColor: isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    selectedColor: _parseColor(
                      carrera['color'],
                    ).withOpacity(0.2),
                    checkmarkColor: _parseColor(carrera['color']),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: AppSpacing.medium),
            Divider(color: _getSecondaryTextColor(context)),
            SizedBox(height: AppSpacing.medium),

            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre de la carrera',
                labelStyle: AppTextStyles.bodyDark(
                  context,
                ).copyWith(color: _getTextColor(context)),
                border: OutlineInputBorder(),
                hintText: 'O escribe un nombre personalizado',
                hintStyle: AppTextStyles.bodyDark(
                  context,
                ).copyWith(color: _getSecondaryTextColor(context)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _getSecondaryTextColor(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: _getTextColor(context)),
              maxLines: 2,
            ),
            SizedBox(height: AppSpacing.medium),

            Row(
              children: [
                Text(
                  'Colores:',
                  style: AppTextStyles.bodyDark(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _mostrarMasColores = !_mostrarMasColores;
                    });
                  },
                  child: Text(
                    _mostrarMasColores ? 'Menos colores' : 'Más colores +',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: _coloresVisibles.map((colorInfo) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _colorController.text = colorInfo['color'];
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _parseColor(colorInfo['color']),
                      borderRadius: BorderRadius.circular(18),
                      border: _colorController.text == colorInfo['color']
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                    child: _colorController.text == colorInfo['color']
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: AppSpacing.medium),

            Row(
              children: [
                Text(
                  'Íconos:',
                  style: AppTextStyles.bodyDark(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _mostrarMasIconos = !_mostrarMasIconos;
                    });
                  },
                  child: Text(
                    _mostrarMasIconos ? 'Menos íconos' : 'Más íconos +',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: _iconosVisibles.map((iconInfo) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _iconoSeleccionado = iconInfo['icon'];
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _iconoSeleccionado == iconInfo['icon']
                          ? _parseColor(_colorController.text).withOpacity(0.2)
                          : isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                      border: _iconoSeleccionado == iconInfo['icon']
                          ? Border.all(
                              color: _parseColor(_colorController.text),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Icon(
                      iconInfo['icon'],
                      color: _iconoSeleccionado == iconInfo['icon']
                          ? _parseColor(_colorController.text)
                          : isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: AppSpacing.medium),

            Container(
              padding: EdgeInsets.all(AppSpacing.medium),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.grey.shade600
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _parseColor(_colorController.text),
                    child: Icon(_iconoSeleccionado, color: Colors.white),
                  ),
                  SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nombreController.text.isNotEmpty
                              ? _nombreController.text
                              : 'Nombre de la carrera',
                          style: AppTextStyles.heading3Dark(
                            context,
                          ).copyWith(color: _getTextColor(context)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Vista previa',
                          style: AppTextStyles.bodyDark(
                            context,
                          ).copyWith(color: _getSecondaryTextColor(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          onPressed: _guardarCarrera,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Guardar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}