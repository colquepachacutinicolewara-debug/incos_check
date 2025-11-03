// views/estudiantes/estudiantes_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/estudiantes_viewmodel.dart';
import '../../models/estudiante_model.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../utils/export_helpers.dart'; // NUEVO IMPORT
import '../../views/biometrico/registro_huella_screen.dart';

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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<EstudiantesViewModel>(
        context,
        listen: false,
      );
      viewModel.cargarDatosEjemplo();
    });
  }

  void _onSearchChanged() {
    final viewModel = Provider.of<EstudiantesViewModel>(context, listen: false);
    viewModel.actualizarBusqueda(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color carreraColor = _parseColor(widget.carrera['color']);

    return ChangeNotifierProvider(
      create: (context) => EstudiantesViewModel(),
      child: Consumer<EstudiantesViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Paralelo ${widget.paralelo['nombre']} - Estudiantes',
                style: AppTextStyles.heading2Dark(
                  context,
                ).copyWith(color: Colors.white),
              ),
              backgroundColor: carreraColor,
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) => _handleExportAction(value, viewModel),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'excel_simple',
                      child: Text(
                        'Exportar Lista Simple (Excel)',
                        style: AppTextStyles.bodyDark(context),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'excel_completo',
                      child: Text(
                        'Exportar Lista Completa (Excel)',
                        style: AppTextStyles.bodyDark(context),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'pdf_simple',
                      child: Text(
                        'Exportar Lista Simple (PDF)',
                        style: AppTextStyles.bodyDark(context),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'pdf_completo',
                      child: Text(
                        'Exportar Lista Completa (PDF)',
                        style: AppTextStyles.bodyDark(context),
                      ),
                    ),
                  ],
                  icon: Icon(Icons.download, color: Colors.white),
                ),
              ],
            ),
            body: Column(
              children: [
                // Barra de búsqueda
                Padding(
                  padding: EdgeInsets.all(AppSpacing.medium),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar estudiante...',
                      labelStyle: AppTextStyles.bodyDark(context),
                      prefixIcon: Icon(Icons.search, color: AppColors.primary),
                      border: OutlineInputBorder(),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: AppColors.primary),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                    ),
                    style: AppTextStyles.bodyDark(context),
                  ),
                ),

                // Contador de resultados
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${viewModel.estudiantesFiltrados.length} estudiante${viewModel.estudiantesFiltrados.length != 1 ? 's' : ''}',
                        style: AppTextStyles.bodyDark(context).copyWith(
                          color: AppColors.textSecondaryDark(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        Text(
                          'Búsqueda: "${_searchController.text}"',
                          style: AppTextStyles.bodyDark(
                            context,
                          ).copyWith(color: Colors.blue[600], fontSize: 12),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.small),

                // Loading indicator
                if (viewModel.isLoading)
                  LinearProgressIndicator(
                    backgroundColor: AppColors.primary.withOpacity(0.3),
                    color: AppColors.primary,
                  ),

                // Mensaje de error
                if (viewModel.errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.medium),
                    color: Colors.red[50],
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: Text(
                            viewModel.errorMessage,
                            style: AppTextStyles.bodyDark(
                              context,
                            ).copyWith(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => viewModel.limpiarError(),
                        ),
                      ],
                    ),
                  ),

                // Lista de estudiantes
                Expanded(
                  child: viewModel.estudiantesFiltrados.isEmpty
                      ? _buildEmptyState(viewModel)
                      : ListView.builder(
                          padding: EdgeInsets.all(AppSpacing.medium),
                          itemCount: viewModel.estudiantesFiltrados.length,
                          itemBuilder: (context, index) {
                            final estudiante =
                                viewModel.estudiantesFiltrados[index];
                            return _buildEstudianteCard(
                              estudiante,
                              index,
                              carreraColor,
                              viewModel,
                            );
                          },
                        ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAgregarEstudianteDialog(viewModel),
              backgroundColor: carreraColor,
              child: Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEstudianteCard(
    Estudiante estudiante,
    int index,
    Color color,
    EstudiantesViewModel viewModel,
  ) {
    bool tieneHuella = estudiante.huellaId != null;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            estudiante.nombres[0],
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          estudiante.nombreCompleto,
          style: AppTextStyles.heading3Dark(context),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CI: ${estudiante.ci}',
              style: AppTextStyles.bodyDark(context),
            ),
            Text(
              'Registro: ${Helpers.formatDate(estudiante.fechaRegistro)}',
              style: AppTextStyles.bodyDark(context),
            ),
            Row(
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 14,
                  color: tieneHuella ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 4),
                Text(
                  'Huella: ${tieneHuella ? 'Registrada' : 'No registrada'}',
                  style: AppTextStyles.bodyDark(context).copyWith(
                    color: tieneHuella ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (!estudiante.activo)
              Text(
                'INACTIVO',
                style: AppTextStyles.bodyDark(
                  context,
                ).copyWith(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!tieneHuella)
              IconButton(
                icon: Icon(Icons.fingerprint, color: Colors.blue),
                onPressed: () => _registrarHuellas(estudiante, viewModel),
                tooltip: 'Registrar Huellas',
              ),
            PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleMenuAction(value, estudiante, viewModel),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(
                    'Modificar',
                    style: AppTextStyles.bodyDark(context),
                  ),
                ),
                PopupMenuItem(
                  value: 'huellas',
                  child: Text(
                    'Gestionar Huellas',
                    style: AppTextStyles.bodyDark(context),
                  ),
                ),
                if (estudiante.activo)
                  PopupMenuItem(
                    value: 'deactivate',
                    child: Text(
                      'Desactivar',
                      style: AppTextStyles.bodyDark(context),
                    ),
                  )
                else
                  PopupMenuItem(
                    value: 'activate',
                    child: Text(
                      'Activar',
                      style: AppTextStyles.bodyDark(context),
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Eliminar',
                    style: AppTextStyles.bodyDark(
                      context,
                    ).copyWith(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(EstudiantesViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.textSecondaryDark(context),
          ),
          SizedBox(height: AppSpacing.medium),
          Text(
            _searchController.text.isEmpty
                ? 'No hay estudiantes registrados'
                : 'No se encontraron resultados',
            style: AppTextStyles.heading3Dark(
              context,
            ).copyWith(color: AppColors.textSecondaryDark(context)),
          ),
          SizedBox(height: AppSpacing.small),
          Text(
            _searchController.text.isEmpty
                ? 'Presiona el botón + para agregar el primer estudiante'
                : 'Intenta con otros términos de búsqueda',
            style: AppTextStyles.bodyDark(
              context,
            ).copyWith(color: AppColors.textSecondaryDark(context)),
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
              },
              child: Text(
                'Limpiar búsqueda',
                style: AppTextStyles.bodyDark(context),
              ),
            ),
          if (_searchController.text.isEmpty)
            ElevatedButton(
              onPressed: () => viewModel.cargarDatosEjemplo(),
              child: Text('Cargar datos de ejemplo'),
            ),
        ],
      ),
    );
  }

  void _handleMenuAction(
    String action,
    Estudiante estudiante,
    EstudiantesViewModel viewModel,
  ) {
    switch (action) {
      case 'edit':
        _showEditarEstudianteDialog(estudiante, viewModel);
        break;
      case 'huellas':
        _registrarHuellas(estudiante, viewModel);
        break;
      case 'deactivate':
        _desactivarEstudiante(estudiante, viewModel);
        break;
      case 'activate':
        _activarEstudiante(estudiante, viewModel);
        break;
      case 'delete':
        _showEliminarEstudianteDialog(estudiante, viewModel);
        break;
    }
  }

  void _handleExportAction(String action, EstudiantesViewModel viewModel) {
    switch (action) {
      case 'excel_simple':
        _exportarExcel(viewModel, simple: true);
        break;
      case 'excel_completo':
        _exportarExcel(viewModel, simple: false);
        break;
      case 'pdf_simple':
        _exportarPDF(viewModel, simple: true);
        break;
      case 'pdf_completo':
        _exportarPDF(viewModel, simple: false);
        break;
    }
  }

  void _showAgregarEstudianteDialog(EstudiantesViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => _EstudianteDialog(
        title: 'Agregar Estudiante',
        onSave: (nombres, paterno, materno, ci) async {
          final success = await viewModel.agregarEstudiante(
            nombres: nombres,
            apellidoPaterno: paterno,
            apellidoMaterno: materno,
            ci: ci,
            carrera: widget.carrera['nombre'],
            curso: widget.paralelo['nombre'],
          );

          if (success) {
            Helpers.showSnackBar(
              context,
              'Estudiante agregado exitosamente',
              type: 'success',
            );
          } else {
            Helpers.showSnackBar(
              context,
              viewModel.errorMessage,
              type: 'error',
            );
          }
        },
      ),
    );
  }

  void _showEditarEstudianteDialog(
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
            apellidoPaterno: paterno,
            apellidoMaterno: materno,
            ci: ci,
            carrera: estudiante.carrera,
            curso: estudiante.curso,
          );

          if (success) {
            Helpers.showSnackBar(
              context,
              'Estudiante actualizado exitosamente',
              type: 'success',
            );
          } else {
            Helpers.showSnackBar(
              context,
              viewModel.errorMessage,
              type: 'error',
            );
          }
        },
      ),
    );
  }

  void _showEliminarEstudianteDialog(
    Estudiante estudiante,
    EstudiantesViewModel viewModel,
  ) {
    Helpers.showConfirmationDialog(
      context,
      title: 'Eliminar Estudiante',
      content: '¿Estás seguro de eliminar a ${estudiante.nombreCompleto}?',
    ).then((confirmed) async {
      if (confirmed) {
        final success = await viewModel.eliminarEstudiante(estudiante.id);
        if (success) {
          Helpers.showSnackBar(
            context,
            'Estudiante eliminado exitosamente',
            type: 'success',
          );
        } else {
          Helpers.showSnackBar(context, viewModel.errorMessage, type: 'error');
        }
      }
    });
  }

  void _desactivarEstudiante(
    Estudiante estudiante,
    EstudiantesViewModel viewModel,
  ) {
    Helpers.showConfirmationDialog(
      context,
      title: 'Desactivar Estudiante',
      content: '¿Estás seguro de desactivar a ${estudiante.nombreCompleto}?',
    ).then((confirmed) async {
      if (confirmed) {
        final success = await viewModel.desactivarEstudiante(estudiante.id);
        if (success) {
          Helpers.showSnackBar(
            context,
            'Estudiante desactivado exitosamente',
            type: 'success',
          );
        }
      }
    });
  }

  void _activarEstudiante(
    Estudiante estudiante,
    EstudiantesViewModel viewModel,
  ) {
    Helpers.showConfirmationDialog(
      context,
      title: 'Activar Estudiante',
      content: '¿Estás seguro de activar a ${estudiante.nombreCompleto}?',
    ).then((confirmed) async {
      if (confirmed) {
        final success = await viewModel.activarEstudiante(estudiante.id);
        if (success) {
          Helpers.showSnackBar(
            context,
            'Estudiante activado exitosamente',
            type: 'success',
          );
        }
      }
    });
  }

  void _registrarHuellas(
    Estudiante estudiante,
    EstudiantesViewModel viewModel,
  ) {
    // Convertir Estudiante a Map para compatibilidad con tu pantalla de huellas
    Map<String, dynamic> estudianteMap = {
      'id': estudiante.id,
      'nombres': estudiante.nombres,
      'apellidoPaterno': estudiante.apellidoPaterno,
      'apellidoMaterno': estudiante.apellidoMaterno,
      'ci': estudiante.ci,
      'carrera': estudiante.carrera,
      'curso': estudiante.curso,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroHuellasScreen(
          estudiante: estudianteMap,
          onHuellasRegistradas: (int huellasRegistradas) async {
            // Solo asociar huella si se registraron las 3 huellas
            if (huellasRegistradas == 3) {
              String huellaId =
                  'huella_${estudiante.id}_${DateTime.now().millisecondsSinceEpoch}';
              final success = await viewModel.asociarHuella(
                estudiante.id,
                huellaId,
              );

              if (success) {
                Helpers.showSnackBar(
                  context,
                  '¡3 huellas registradas exitosamente!',
                  type: 'success',
                );
              } else {
                Helpers.showSnackBar(
                  context,
                  'Error al guardar huellas: ${viewModel.errorMessage}',
                  type: 'error',
                );
              }
            } else {
              Helpers.showSnackBar(
                context,
                'Se registraron $huellasRegistradas/3 huellas. Se requieren las 3 huellas para completar el registro.',
                type: 'warning',
              );
            }
          },
        ),
      ),
    );
  }

  // NUEVO MÉTODO ACTUALIZADO PARA EXPORTAR EXCEL
  void _exportarExcel(
    EstudiantesViewModel viewModel, {
    bool simple = true,
  }) async {
    final estudiantesExportar = viewModel.estudiantesFiltrados;
    final tipo = simple ? 'simple' : 'completa';

    Helpers.showConfirmationDialog(
      context,
      title: 'Exportar a Excel',
      content:
          '¿Exportar lista $tipo con ${estudiantesExportar.length} estudiante${estudiantesExportar.length != 1 ? 's' : ''} a Excel?',
    ).then((confirmed) async {
      if (confirmed) {
        try {
          // Convertir estudiantes a formato Map para exportación
          List<Map<String, dynamic>> estudiantesMap = estudiantesExportar.map((
            e,
          ) {
            return {
              'nombres': e.nombres,
              'apellidoPaterno': e.apellidoPaterno,
              'apellidoMaterno': e.apellidoMaterno,
              'ci': e.ci,
              'fechaRegistro': Helpers.formatDate(e.fechaRegistro),
              'huellaId': e.huellaId,
            };
          }).toList();

          // Exportar usando el nuevo helper
          String filePath = await ExportHelpers.exportToExcel(
            estudiantes: estudiantesMap,
            institucion: widget.carrera['nombre'],
            turno: widget.turno['nombre'],
            nivel: widget.nivel['nombre'],
            paralelo: widget.paralelo['nombre'],
            simple: simple,
          );

          Helpers.showSnackBar(
            context,
            '✅ Lista $tipo exportada exitosamente\nArchivo: ${filePath.split('/').last}',
            type: 'success',
          );
        } catch (e) {
          Helpers.showSnackBar(
            context,
            '❌ Error al exportar: $e',
            type: 'error',
          );
        }
      }
    });
  }

  // NUEVO MÉTODO ACTUALIZADO PARA EXPORTAR PDF
  void _exportarPDF(
    EstudiantesViewModel viewModel, {
    bool simple = true,
  }) async {
    final estudiantesExportar = viewModel.estudiantesFiltrados;
    final tipo = simple ? 'simple' : 'completa';

    Helpers.showConfirmationDialog(
      context,
      title: 'Exportar a PDF',
      content:
          '¿Exportar lista $tipo con ${estudiantesExportar.length} estudiante${estudiantesExportar.length != 1 ? 's' : ''} a PDF?',
    ).then((confirmed) async {
      if (confirmed) {
        try {
          // Convertir estudiantes a formato Map para exportación
          List<Map<String, dynamic>> estudiantesMap = estudiantesExportar.map((
            e,
          ) {
            return {
              'nombres': e.nombres,
              'apellidoPaterno': e.apellidoPaterno,
              'apellidoMaterno': e.apellidoMaterno,
              'ci': e.ci,
              'fechaRegistro': Helpers.formatDate(e.fechaRegistro),
              'huellaId': e.huellaId,
            };
          }).toList();

          // Exportar usando el nuevo helper
          String filePath = await ExportHelpers.exportToPDF(
            estudiantes: estudiantesMap,
            institucion: widget.carrera['nombre'],
            turno: widget.turno['nombre'],
            nivel: widget.nivel['nombre'],
            paralelo: widget.paralelo['nombre'],
            simple: simple,
          );

          Helpers.showSnackBar(
            context,
            '✅ Lista $tipo exportada exitosamente\nArchivo: ${filePath.split('/').last}',
            type: 'success',
          );
        } catch (e) {
          Helpers.showSnackBar(
            context,
            '❌ Error al exportar: $e',
            type: 'error',
          );
        }
      }
    });
  }

  // ELIMINAR estos métodos antiguos (ya no se necesitan)
  /*
  void _realExportacionExcel(List<Estudiante> estudiantes, bool simple) {
    print('=== EXPORTACIÓN REAL EXCEL ${simple ? 'SIMPLE' : 'COMPLETA'} ===');
    print('Institución: ${widget.carrera['nombre']}');
    print('Turno: ${widget.turno['nombre']}');
    print('Nivel: ${widget.nivel['nombre']}');
    print('Paralelo: ${widget.paralelo['nombre']}');
    print('Fecha: ${Helpers.formatDateTime(DateTime.now())}');
    print('Total estudiantes: ${estudiantes.length}');

    if (simple) {
      print('--- LISTA SIMPLE ---');
      for (var estudiante in estudiantes) {
        print(estudiante.nombreCompleto);
      }
    } else {
      print('--- LISTA COMPLETA ---');
      for (var estudiante in estudiantes) {
        print(
          '${estudiante.apellidoPaterno} | ${estudiante.apellidoMaterno} | ${estudiante.nombres} | CI: ${estudiante.ci} | Registro: ${Helpers.formatDate(estudiante.fechaRegistro)} | Huella: ${estudiante.huellaId != null ? 'Sí' : 'No'}',
        );
      }
    }
  }

  void _realExportacionPDF(List<Estudiante> estudiantes, bool simple) {
    print('=== EXPORTACIÓN REAL PDF ${simple ? 'SIMPLE' : 'COMPLETA'} ===');
    print('Institución: ${widget.carrera['nombre']}');
    print('Turno: ${widget.turno['nombre']}');
    print('Nivel: ${widget.nivel['nombre']}');
    print('Paralelo: ${widget.paralelo['nombre']}');
    print('Fecha: ${Helpers.formatDateTime(DateTime.now())}');
    print('Total estudiantes: ${estudiantes.length}');

    if (simple) {
      print('--- LISTA SIMPLE ---');
      for (var estudiante in estudiantes) {
        print('• ${estudiante.nombreCompleto}');
      }
    } else {
      print('--- LISTA COMPLETA ---');
      for (var estudiante in estudiantes) {
        print('• ${estudiante.nombreCompleto}');
        print(
          '  CI: ${estudiante.ci} | Fecha Registro: ${Helpers.formatDate(estudiante.fechaRegistro)} | Huella: ${estudiante.huellaId != null ? 'Registrada' : 'No registrada'}',
        );
      }
    }
  }
  */

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}

// =============================================
// DIÁLOGO PARA AGREGAR/MODIFICAR ESTUDIANTES
// =============================================
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
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _paternoController = TextEditingController();
  final TextEditingController _maternoController = TextEditingController();
  final TextEditingController _ciController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nombresController.text = widget.nombresInicial ?? '';
    _paternoController.text = widget.paternoInicial ?? '';
    _maternoController.text = widget.maternoInicial ?? '';
    _ciController.text = widget.ciInicial ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(AppSpacing.medium),
      child: SingleChildScrollView(
        padding: MediaQuery.of(context).viewInsets,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.95,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.title, style: AppTextStyles.heading2Dark(context)),
                SizedBox(height: AppSpacing.medium),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nombresController,
                        decoration: InputDecoration(
                          labelText: 'Nombres *',
                          labelStyle: AppTextStyles.bodyDark(context),
                          border: OutlineInputBorder(),
                        ),
                        style: AppTextStyles.bodyDark(context),
                        validator: (value) => Validators.validateName(value),
                      ),
                      SizedBox(height: AppSpacing.small),
                      TextFormField(
                        controller: _paternoController,
                        decoration: InputDecoration(
                          labelText: 'Apellido Paterno *',
                          labelStyle: AppTextStyles.bodyDark(context),
                          border: OutlineInputBorder(),
                        ),
                        style: AppTextStyles.bodyDark(context),
                        validator: (value) => Validators.validateName(value),
                      ),
                      SizedBox(height: AppSpacing.small),
                      TextFormField(
                        controller: _maternoController,
                        decoration: InputDecoration(
                          labelText: 'Apellido Materno',
                          labelStyle: AppTextStyles.bodyDark(context),
                          border: OutlineInputBorder(),
                        ),
                        style: AppTextStyles.bodyDark(context),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            return Validators.validateName(value);
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.small),
                      TextFormField(
                        controller: _ciController,
                        decoration: InputDecoration(
                          labelText: 'Cédula de Identidad *',
                          labelStyle: AppTextStyles.bodyDark(context),
                          border: OutlineInputBorder(),
                        ),
                        style: AppTextStyles.bodyDark(context),
                        keyboardType: TextInputType.number,
                        validator: (value) => Validators.validateCI(value),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.large),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: AppTextStyles.bodyDark(context),
                      ),
                    ),
                    SizedBox(width: AppSpacing.small),
                    ElevatedButton(
                      onPressed: _guardarEstudiante,
                      child: Text(
                        'Guardar',
                        style: AppTextStyles.bodyDark(context),
                      ),
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
      Navigator.pop(context);
    }
  }
}
