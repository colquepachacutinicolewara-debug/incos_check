import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../models/periodo_academico_model.dart';
import '../../viewmodels/periodo_academico_viewmodel.dart';
import '../../views/asistencia/planilla/primer_bimestre_screen.dart';
import '../../views/asistencia/planilla/segundo_bimestre_screen.dart';
import '../../views/asistencia/planilla/tercer_bimestre_screen.dart';
import '../../views/asistencia/planilla/cuarto_bimestre_screen.dart';

class BimestresScreen extends StatefulWidget {
  final String materiaSeleccionada;

  const BimestresScreen({super.key, required this.materiaSeleccionada});

  @override
  State<BimestresScreen> createState() => _BimestresScreenState();
}

class _BimestresScreenState extends State<BimestresScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PeriodoAcademicoViewModel(),
      child: Scaffold(
        backgroundColor: _getBackgroundColor(context),
        appBar: AppBar(
          title: Text(
            'Periodos Académicos - ${widget.materiaSeleccionada}',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Consumer<PeriodoAcademicoViewModel>(
              builder: (context, viewModel, child) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    viewModel.cargarPeriodos();
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<PeriodoAcademicoViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (viewModel.error != null && viewModel.error!.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar periodos',
                      style: TextStyle(
                        color: _getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _getSecondaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.cargarPeriodos();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.periodos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay periodos académicos',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.cargarPeriodos();
                      },
                      child: const Text('Cargar Periodos'),
                    ),
                  ],
                ),
              );
            }

            return GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(AppSpacing.medium),
              childAspectRatio: 1.0,
              children: viewModel.periodos.map((bimestre) {
                return _buildBimestreCard(bimestre, context, viewModel);
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBimestreCard(
    PeriodoAcademico bimestre, 
    BuildContext context, 
    PeriodoAcademicoViewModel viewModel
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(AppSpacing.small),
      color: _getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () => _navigateToBimestreDetalle(bimestre, context),
            onLongPress: () => _mostrarOpcionesPeriodo(bimestre, context, viewModel),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.small),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono del bimestre
                  Icon(
                    Icons.calendar_month,
                    size: 40,
                    color: viewModel.getColorPorNumero(bimestre.numero),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  // Nombre del bimestre
                  Text(
                    bimestre.nombre,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(context),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Rango de fechas
                  Text(
                    bimestre.rangoFechas,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 10,
                      color: _getSecondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Estado del bimestre
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: viewModel.getEstadoColor(bimestre.estado).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: viewModel.getEstadoColor(bimestre.estado)),
                    ),
                    child: Text(
                      viewModel.getEstadoDisplay(bimestre.estado),
                      style: TextStyle(
                        color: viewModel.getEstadoColor(bimestre.estado),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Información adicional
                  Text(
                    '${bimestre.totalClasesComputed} clases',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 9,
                      color: _getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ✅ ICONO DE CALENDARIO PARA EDITAR
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                Icons.edit_calendar,
                size: 18,
                color: Colors.grey.shade600,
              ),
              onPressed: () => _mostrarDialogoEditarFechas(bimestre, context, viewModel),
              tooltip: 'Editar fechas',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ DIÁLOGO PARA EDITAR FECHAS
  void _mostrarDialogoEditarFechas(
    PeriodoAcademico periodo, 
    BuildContext context, 
    PeriodoAcademicoViewModel viewModel
  ) {
    // Crear controladores temporales para el diálogo
    final nombreController = TextEditingController(text: periodo.nombre);
    final fechaInicioController = TextEditingController(
      text: '${periodo.fechaInicio.year}-${periodo.fechaInicio.month.toString().padLeft(2, '0')}-${periodo.fechaInicio.day.toString().padLeft(2, '0')}'
    );
    final fechaFinController = TextEditingController(
      text: '${periodo.fechaFin.year}-${periodo.fechaFin.month.toString().padLeft(2, '0')}-${periodo.fechaFin.day.toString().padLeft(2, '0')}'
    );
    final descripcionController = TextEditingController(text: periodo.descripcion);
    
    String estadoSeleccionado = periodo.estado;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Editar ${periodo.nombre}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del período',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: fechaInicioController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha inicio (YYYY-MM-DD)',
                      hintText: 'Ej: 2024-02-01',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: fechaFinController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha fin (YYYY-MM-DD)',
                      hintText: 'Ej: 2024-03-31',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: estadoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: viewModel.opcionesEstado
                        .map((estado) => DropdownMenuItem(
                              value: estado,
                              child: Text(estado),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        estadoSeleccionado = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nombreController.text.isEmpty ||
                      fechaInicioController.text.isEmpty ||
                      fechaFinController.text.isEmpty) {
                    _mostrarSnackBar(context, 'Nombre y fechas son requeridos', Colors.red);
                    return;
                  }

                  final fechaInicio = _parseDate(fechaInicioController.text);
                  final fechaFin = _parseDate(fechaFinController.text);

                  if (fechaInicio == null || fechaFin == null) {
                    _mostrarSnackBar(context, 'Formato de fecha inválido. Use YYYY-MM-DD', Colors.red);
                    return;
                  }

                  if (fechaFin.isBefore(fechaInicio)) {
                    _mostrarSnackBar(context, 'La fecha fin no puede ser anterior a la fecha inicio', Colors.red);
                    return;
                  }

                  // ✅ GUARDAR EN SQLITE Y ACTUALIZAR CARDS
                  final success = await viewModel.editarPeriodoCompleto(
                    periodo.id,
                    nombreController.text,
                    periodo.tipo,
                    periodo.numero,
                    fechaInicio,
                    fechaFin,
                    estadoSeleccionado,
                    descripcionController.text,
                  );

                  if (success && context.mounted) {
                    Navigator.pop(context);
                    _mostrarSnackBar(context, '✅ Período actualizado correctamente', Colors.green);
                  } else if (context.mounted) {
                    _mostrarSnackBar(context, '❌ Error: ${viewModel.error}', Colors.red);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToBimestreDetalle(PeriodoAcademico bimestre, BuildContext context) {
    switch (bimestre.numero) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PrimerBimestreScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SegundoBimestreScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TercerBimestreScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CuartoBimestreScreen()),
        );
        break;
    }
  }

  DateTime? _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  void _mostrarSnackBar(BuildContext context, String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarOpcionesPeriodo(
    PeriodoAcademico periodo, 
    BuildContext context, 
    PeriodoAcademicoViewModel viewModel
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar Periodo'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDialogoEditarFechas(periodo, context, viewModel);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar Periodo'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDialogoEliminarPeriodo(periodo, context, viewModel);
                },
              ),
              if (periodo.estado != 'En Curso')
                ListTile(
                  leading: const Icon(Icons.play_arrow),
                  title: const Text('Marcar como En Curso'),
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.cambiarEstadoPeriodo(periodo.id, 'En Curso');
                    _mostrarSnackBar(context, '✅ Estado actualizado', Colors.green);
                  },
                ),
              if (periodo.estado != 'Finalizado')
                ListTile(
                  leading: const Icon(Icons.done_all),
                  title: const Text('Marcar como Finalizado'),
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.cambiarEstadoPeriodo(periodo.id, 'Finalizado');
                    _mostrarSnackBar(context, '✅ Estado actualizado', Colors.green);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogoEliminarPeriodo(
    PeriodoAcademico periodo, 
    BuildContext context, 
    PeriodoAcademicoViewModel viewModel
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Periodo'),
        content: Text('¿Estás seguro de eliminar el ${periodo.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await viewModel.eliminarPeriodo(periodo.id);
              if (success && context.mounted) {
                Navigator.pop(context);
                _mostrarSnackBar(context, '✅ Período eliminado', Colors.green);
              } else if (context.mounted) {
                _mostrarSnackBar(context, '❌ Error al eliminar', Colors.red);
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
}