//bimestre_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../../models/bimestre_model.dart';
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
  void initState() {
    super.initState();
    // Los periodos se cargan automáticamente en el ViewModel
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
          MaterialPageRoute(
            builder: (context) => const SegundoBimestreScreen(),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Periodos Académicos - ${widget.materiaSeleccionada}',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PeriodoAcademicoViewModel>().cargarPeriodos();
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
      child: InkWell(
        onTap: () => _navigateToBimestreDetalle(bimestre, context),
        onLongPress: () => _mostrarOpcionesPeriodo(bimestre, context, viewModel),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.small),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono
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
                '${bimestre.fechasClases.length} clases',
                style: AppTextStyles.body.copyWith(
                  fontSize: 9,
                  color: _getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
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
                  _mostrarDialogoEditarPeriodo(periodo, context, viewModel);
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
                  },
                ),
              if (periodo.estado != 'Finalizado')
                ListTile(
                  leading: const Icon(Icons.done_all),
                  title: const Text('Marcar como Finalizado'),
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.cambiarEstadoPeriodo(periodo.id, 'Finalizado');
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogoEditarPeriodo(
    PeriodoAcademico periodo, 
    BuildContext context, 
    PeriodoAcademicoViewModel viewModel
  ) {
    viewModel.cargarPeriodoParaEditar(periodo);
    
    // Aquí puedes implementar un diálogo de edición completo
    // con formularios para modificar nombre, fechas, etc.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Periodo'),
        content: const Text('Funcionalidad de edición en desarrollo...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
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
            onPressed: () {
              viewModel.eliminarPeriodo(periodo.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}