import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../viewmodels/estudiantes_viewmodel.dart';
import '../../models/estudiante_model.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../biometrico/registro_huella_screen.dart';

class EstudiantesListScreen extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;
  final Map<String, dynamic> nivel;
  final Map<String, dynamic> paralelo;

  const EstudiantesListScreen({
    super.key,
    required this.tipo,
    required this.carrera,
    required this.turno,
    required this.nivel,
    required this.paralelo,
  });

  @override
  State<EstudiantesListScreen> createState() => _EstudiantesListScreenState();
}

class _EstudiantesListScreenState extends State<EstudiantesListScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EstudiantesViewModel(
        tipo: widget.tipo,
        carrera: widget.carrera,
        turno: widget.turno,
        nivel: widget.nivel,
        paralelo: widget.paralelo,
      ),
      child: _EstudiantesListContent(
        tipo: widget.tipo,
        carrera: widget.carrera,
        turno: widget.turno,
        nivel: widget.nivel,
        paralelo: widget.paralelo,
      ),
    );
  }
}

class _EstudiantesListContent extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;
  final Map<String, dynamic> nivel;
  final Map<String, dynamic> paralelo;

  const _EstudiantesListContent({
    required this.tipo,
    required this.carrera,
    required this.turno,
    required this.nivel,
    required this.paralelo,
  });

  @override
  State<_EstudiantesListContent> createState() => _EstudiantesListContentState();
}

class _EstudiantesListContentState extends State<_EstudiantesListContent> {
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EstudiantesViewModel>(context);
    final estudiantes = viewModel.estudiantesFiltrados;
    final searchController = viewModel.searchController;
    Color carreraColor = _parseColor(widget.carrera['color']);

    // Mostrar loading state
    if (viewModel.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Paralelo ${widget.paralelo['nombre']} - Estudiantes',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          backgroundColor: carreraColor,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando estudiantes...'),
            ],
          ),
        ),
      );
    }

    // Mostrar error state
    if (viewModel.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Paralelo ${widget.paralelo['nombre']} - Estudiantes',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          backgroundColor: carreraColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Error al cargar estudiantes',
                style: AppTextStyles.heading2.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.small),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  viewModel.error!,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              ElevatedButton(
                onPressed: () => viewModel.reintentarCarga(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paralelo ${widget.paralelo['nombre']} - Estudiantes',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: carreraColor,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleExportAction(context, value),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'excel_simple',
                child: Text('Exportar Lista Simple (Excel)'),
              ),
              const PopupMenuItem(
                value: 'excel_completo',
                child: Text('Exportar Lista Completa (Excel)'),
              ),
              const PopupMenuItem(
                value: 'pdf_simple',
                child: Text('Exportar Lista Simple (PDF)'),
              ),
              const PopupMenuItem(
                value: 'pdf_completo',
                child: Text('Exportar Lista Completa (PDF)'),
              ),
            ],
            icon: const Icon(Icons.download, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar estudiante...',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.clear, color: AppColors.primary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${estudiantes.length} estudiante${estudiantes.length != 1 ? 's' : ''}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (searchController.text.isNotEmpty)
                  Text(
                    'Búsqueda: "${searchController.text}"',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.blue[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Expanded(
            child: estudiantes.isEmpty
                ? _buildEmptyState(viewModel)
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    itemCount: estudiantes.length,
                    itemBuilder: (context, index) {
                      final estudiante = estudiantes[index];
                      return _buildEstudianteCard(
                        context,
                        estudiante,
                        carreraColor,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAgregarEstudianteDialog(context, viewModel),
        backgroundColor: carreraColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEstudianteCard(
    BuildContext context,
    Estudiante estudiante,
    Color color,
  ) {
    final viewModel = Provider.of<EstudiantesViewModel>(context, listen: false);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            estudiante.nombres.isNotEmpty ? estudiante.nombres[0] : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          '${estudiante.apellidoPaterno} ${estudiante.apellidoMaterno} ${estudiante.nombres}',
          style: AppTextStyles.heading3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CI: ${estudiante.ci}', style: AppTextStyles.body),
            Text('Registro: ${estudiante.fechaRegistro}', style: AppTextStyles.body),
            Row(
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 14,
                  color: estudiante.tieneTodasLasHuellas
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  'Huellas: ${estudiante.huellasRegistradas}/3',
                  style: AppTextStyles.body.copyWith(
                    color: estudiante.tieneTodasLasHuellas
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!estudiante.tieneTodasLasHuellas)
              IconButton(
                icon: const Icon(Icons.fingerprint, color: Colors.blue),
                onPressed: () =>
                    _registrarHuellas(context, estudiante, viewModel),
                tooltip: 'Registrar Huellas',
              ),
            PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleMenuAction(context, value, estudiante, viewModel),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Modificar'),
                ),
                const PopupMenuItem(
                  value: 'huellas',
                  child: Text('Gestionar Huellas'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(EstudiantesViewModel viewModel) {
    final searchController = viewModel.searchController;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.medium),
          Text(
            searchController.text.isEmpty
                ? 'No hay estudiantes registrados'
                : 'No se encontraron resultados',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            searchController.text.isEmpty
                ? 'Presiona el botón + para agregar el primer estudiante'
                : 'Intenta con otros términos de búsqueda',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                searchController.clear();
              },
              child: const Text('Limpiar búsqueda'),
            ),
        ],
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    Estudiante estudiante,
    EstudiantesViewModel viewModel,
  ) {
    switch (action) {
      case 'edit':
        _showEditarEstudianteDialog(context, estudiante, viewModel);
        break;
      case 'huellas':
        _registrarHuellas(context, estudiante, viewModel);
        break;
      case 'delete':
        _showEliminarEstudianteDialog(context, estudiante, viewModel);
        break;
    }
  }

  void _handleExportAction(BuildContext context, String action) {
    final viewModel = Provider.of<EstudiantesViewModel>(context, listen: false);
    switch (action) {
      case 'excel_simple':
        _showExportPreviewDialog(
          context,
          viewModel,
          isPdf: false,
          simple: true,
        );
        break;
      case 'excel_completo':
        _showExportPreviewDialog(
          context,
          viewModel,
          isPdf: false,
          simple: false,
        );
        break;
      case 'pdf_simple':
        _showExportPreviewDialog(context, viewModel, isPdf: true, simple: true);
        break;
      case 'pdf_completo':
        _showExportPreviewDialog(
          context,
          viewModel,
          isPdf: true,
          simple: false,
        );
        break;
    }
  }

  void _showAgregarEstudianteDialog(
    BuildContext context,
    EstudiantesViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => _EstudianteDialog(
        title: 'Agregar Estudiante',
        onSave: (nombres, paterno, materno, ci) async {
          final success = await viewModel.agregarEstudiante(
            nombres: nombres,
            paterno: paterno,
            materno: materno,
            ci: ci,
          );

          if (success && context.mounted) {
            Navigator.pop(context);
            Helpers.showSnackBar(
              context,
              'Estudiante agregado exitosamente',
              type: 'success',
            );
          } else if (context.mounted && viewModel.error != null) {
            Helpers.showSnackBar(
              context,
              viewModel.error!,
              type: 'error',
            );
          }
        },
      ),
    );
  }

  void _showEditarEstudianteDialog(
    BuildContext context,
    Estudiante estudiante,
    EstudiantesViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => _EstudianteDialog(
        title: 'Modificar Estudiante',
        nombresInicial: estudiante.nombres,
        paternoInicial: estudiante.apellidoPaterno,
        maternoInicial: estudiante.apellidoMaterno,
        ciInicial: estudiante.ci,
        onSave: (nombres, paterno, materno, ci) async {
          final success = await viewModel.editarEstudiante(
            id: estudiante.id,
            nombres: nombres,
            paterno: paterno,
            materno: materno,
            ci: ci,
          );

          if (success && context.mounted) {
            Navigator.pop(context);
            Helpers.showSnackBar(
              context,
              'Estudiante actualizado exitosamente',
              type: 'success',
            );
          } else if (context.mounted && viewModel.error != null) {
            Helpers.showSnackBar(
              context,
              viewModel.error!,
              type: 'error',
            );
          }
        },
      ),
    );
  }

  void _showEliminarEstudianteDialog(
    BuildContext context,
    Estudiante estudiante,
    EstudiantesViewModel viewModel,
  ) {
    Helpers.showConfirmationDialog(
      context,
      title: 'Eliminar Estudiante',
      content:
          '¿Estás seguro de eliminar a ${estudiante.nombres} ${estudiante.apellidoPaterno}?',
    ).then((confirmed) async {
      if (confirmed && context.mounted) {
        final success = await viewModel.eliminarEstudiante(estudiante.id);
        if (success) {
          Helpers.showSnackBar(
            context,
            'Estudiante eliminado exitosamente',
            type: 'success',
          );
        } else if (context.mounted && viewModel.error != null) {
          Helpers.showSnackBar(
            context,
            viewModel.error!,
            type: 'error',
          );
        }
      }
    });
  }

  void _registrarHuellas(
    BuildContext context,
    Estudiante estudiante,
    EstudiantesViewModel viewModel,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroHuellasScreen(
          estudiante: estudiante.toMap(),
          onHuellasRegistradas: (int huellasRegistradas) async {
            final success = await viewModel.actualizarHuellasEstudiante(
              estudiante.id,
              huellasRegistradas,
            );

            if (success && context.mounted) {
              Helpers.showSnackBar(
                context,
                'Huellas actualizadas exitosamente',
                type: 'success',
              );
            } else if (context.mounted && viewModel.error != null) {
              Helpers.showSnackBar(
                context,
                viewModel.error!,
                type: 'error',
              );
            }
          },
        ),
      ),
    );
  }

  void _showExportPreviewDialog(
    BuildContext context,
    EstudiantesViewModel viewModel, {
    required bool isPdf,
    required bool simple,
  }) {
    final TextEditingController asignaturaController = TextEditingController(
      text: 'BASE DE DATOS II',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exportar - Opciones'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: asignaturaController,
                decoration: const InputDecoration(labelText: 'Asignatura'),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                '${viewModel.estudiantesFiltrados.length} estudiante${viewModel.estudiantesFiltrados.length != 1 ? 's' : ''}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final asignatura = asignaturaController.text.trim().isEmpty
                    ? 'BASE DE DATOS II'
                    : asignaturaController.text.trim();
                if (isPdf) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('Vista previa PDF')),
                        body: PdfPreview(
                          build: (format) async => viewModel
                              .buildPdfDocument(
                                viewModel.estudiantesFiltrados,
                                simple,
                                asignatura,
                              )
                              .save(),
                        ),
                      ),
                    ),
                  );
                } else {
                  final csv = viewModel.buildCsvString(simple, asignatura);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('Vista previa CSV')),
                        body: Padding(
                          padding: const EdgeInsets.all(AppSpacing.medium),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              csv,
                              style: AppTextStyles.body,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Vista previa'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final asignatura = asignaturaController.text.trim().isEmpty
                    ? 'BASE DE DATOS II'
                    : asignaturaController.text.trim();
                try {
                  if (isPdf) {
                    await viewModel.exportarPDF(
                      simple: simple,
                      asignatura: asignatura,
                    );
                  } else {
                    await viewModel.exportarExcel(
                      simple: simple,
                      asignatura: asignatura,
                    );
                  }
                  if (context.mounted) {
                    Helpers.showSnackBar(
                      context,
                      'Exportación completada',
                      type: 'success',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Helpers.showSnackBar(
                      context,
                      'Error en exportación: ${e.toString()}',
                      type: 'error',
                    );
                  }
                }
              },
              child: const Text('Descargar'),
            ),
          ],
        );
      },
    );
  }
}

// Diálogo para agregar/modificar estudiantes
class _EstudianteDialog extends StatefulWidget {
  final String title;
  final String? nombresInicial;
  final String? paternoInicial;
  final String? maternoInicial;
  final String? ciInicial;
  final Function(String nombres, String paterno, String materno, String ci)
  onSave;

  const _EstudianteDialog({
    required this.title,
    this.nombresInicial,
    this.paternoInicial,
    this.maternoInicial,
    this.ciInicial,
    required this.onSave,
  });

  @override
  State<_EstudianteDialog> createState() => _EstudianteDialogState();
}

class _EstudianteDialogState extends State<_EstudianteDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombresController;
  late TextEditingController _paternoController;
  late TextEditingController _maternoController;
  late TextEditingController _ciController;

  @override
  void initState() {
    super.initState();
    _nombresController = TextEditingController(
      text: widget.nombresInicial ?? '',
    );
    _paternoController = TextEditingController(
      text: widget.paternoInicial ?? '',
    );
    _maternoController = TextEditingController(
      text: widget.maternoInicial ?? '',
    );
    _ciController = TextEditingController(text: widget.ciInicial ?? '');
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _paternoController.dispose();
    _maternoController.dispose();
    _ciController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.medium),
      child: SingleChildScrollView(
        padding: MediaQuery.of(context).viewInsets,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.95,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.title, style: AppTextStyles.heading2),
                const SizedBox(height: AppSpacing.medium),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nombresController,
                        decoration: const InputDecoration(
                          labelText: 'Nombres *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => Validators.validateName(value),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      TextFormField(
                        controller: _paternoController,
                        decoration: const InputDecoration(
                          labelText: 'Apellido Paterno *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => Validators.validateName(value),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      TextFormField(
                        controller: _maternoController,
                        decoration: const InputDecoration(
                          labelText: 'Apellido Materno',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            return Validators.validateName(value);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.small),
                      TextFormField(
                        controller: _ciController,
                        decoration: const InputDecoration(
                          labelText: 'Cédula de Identidad *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => Validators.validateCI(value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    ElevatedButton(
                      onPressed: _guardarEstudiante,
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _guardarEstudiante() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        Validators.formatName(_nombresController.text),
        Validators.formatName(_paternoController.text),
        Validators.formatName(_maternoController.text),
        _ciController.text.trim(),
      );
    }
  }
}