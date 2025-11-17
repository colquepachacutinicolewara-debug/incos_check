// views/docentes_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/docente_viewmodel.dart';
import '../../models/docente_model.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class DocentesScreen extends StatelessWidget {
  final Map<String, dynamic> carrera;

  const DocentesScreen({super.key, required this.carrera});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DocentesViewModel()..initialize(carrera),
      child: const _DocentesScreenContent(),
    );
  }
}

class _DocentesScreenContent extends StatelessWidget {
  const _DocentesScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DocentesViewModel>(context);
    final mediaQuery = MediaQuery.of(context);

    // Manejar estados de carga y error
    if (viewModel.isLoading && viewModel.docentes.isEmpty) {
      return _buildLoadingState(context, viewModel);
    }

    if (viewModel.error != null) {
      return _buildErrorState(context, viewModel);
    }

    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Docentes - ${viewModel.selectedCarrera}',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: viewModel.carreraColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDocenteDialog(context, viewModel),
        backgroundColor: viewModel.carreraColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Selector de Carrera
            _buildCarreraSelector(context, viewModel),

            // Tarjetas de Turnos
            _buildTurnosCards(context, viewModel, mediaQuery),

            // Resumen de la selección actual
            _buildResumen(context, viewModel),

            // Barra de búsqueda
            _buildSearchBar(context, viewModel),

            const SizedBox(height: AppSpacing.medium),

            // Lista de docentes
            _buildDocentesList(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, DocentesViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Docentes - ${viewModel.selectedCarrera}',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: viewModel.carreraColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.medium),
            Text('Cargando docentes...', style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, DocentesViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Docentes - ${viewModel.selectedCarrera}',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: viewModel.carreraColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.medium),
              Text('Error al cargar docentes', style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.small),
              Text(
                viewModel.error!,
                style: AppTextStyles.body.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.medium),
              ElevatedButton(
                onPressed: () => viewModel.reintentarCarga(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarreraSelector(
    BuildContext context,
    DocentesViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: DropdownButtonFormField<String>(
        value: viewModel.selectedCarrera,
        isExpanded: true,
        dropdownColor: _getCardColor(context),
        style: TextStyle(color: _getTextColor(context)),
        decoration: InputDecoration(
          labelText: 'Carrera',
          labelStyle: TextStyle(color: _getTextColor(context)),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _getBorderColor(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: viewModel.carreraColor),
          ),
          prefixIcon: Icon(Icons.school, color: viewModel.carreraColor),
          filled: true,
          fillColor: _getInputFillColor(context),
        ),
        items: viewModel.carreras.map((carrera) {
          return DropdownMenuItem(
            value: carrera,
            child: Text(
              carrera,
              style: TextStyle(color: _getTextColor(context)),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            viewModel.selectedCarrera = value;
            viewModel.selectedTurno = 'MAÑANA';
          }
        },
      ),
    );
  }

  Widget _buildTurnosCards(
    BuildContext context,
    DocentesViewModel viewModel,
    MediaQueryData mediaQuery,
  ) {
    final estadisticas = viewModel.getEstadisticasPorTurno();
    final isSmallScreen = mediaQuery.size.width < 400;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seleccione un turno:',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: _getTextColor(context),
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          SizedBox(
            height: isSmallScreen ? 100 : 120,
            child: Row(
              children: [
                _buildTurnoCard(
                  context,
                  viewModel,
                  'MAÑANA',
                  estadisticas['MAÑANA']!,
                  Icons.wb_sunny,
                  Colors.orange,
                  isSmallScreen,
                ),
                const SizedBox(width: AppSpacing.small),
                _buildTurnoCard(
                  context,
                  viewModel,
                  'NOCHE',
                  estadisticas['NOCHE']!,
                  Icons.nights_stay,
                  Colors.blue,
                  isSmallScreen,
                ),
                const SizedBox(width: AppSpacing.small),
                _buildTurnoCard(
                  context,
                  viewModel,
                  'AMBOS',
                  estadisticas['AMBOS']!,
                  Icons.all_inclusive,
                  Colors.purple,
                  isSmallScreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnoCard(
    BuildContext context,
    DocentesViewModel viewModel,
    String turno,
    int cantidad,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
    final isSelected = viewModel.selectedTurno == turno;

    return Expanded(
      child: Card(
        color: isSelected ? color.withOpacity(0.2) : _getCardColor(context),
        elevation: 2,
        child: InkWell(
          onTap: () => viewModel.selectedTurno = turno,
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : AppSpacing.medium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: isSmallScreen ? 20 : 24,
                  color: isSelected ? color : _getSecondaryTextColor(context),
                ),
                const SizedBox(height: 4),
                Text(
                  turno,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 12 : 14,
                    color: isSelected ? color : _getTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '$cantidad',
                  style: AppTextStyles.body.copyWith(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResumen(BuildContext context, DocentesViewModel viewModel) {
    final estadisticas = viewModel.getEstadisticasPorTurno();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.medium),
        decoration: BoxDecoration(
          color: viewModel.carreraColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: viewModel.carreraColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.selectedCarrera,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: viewModel.carreraColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Turno: ${viewModel.selectedTurno}',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color: _getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total: ${estadisticas['TOTAL']}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                ),
                Text(
                  'Mostrando: ${viewModel.filteredDocentes.length}',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, DocentesViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
      child: TextFormField(
        controller: viewModel.searchController,
        style: TextStyle(color: _getTextColor(context)),
        decoration: InputDecoration(
          labelText: 'Buscar docente...',
          labelStyle: TextStyle(color: _getTextColor(context)),
          prefixIcon: Icon(Icons.search, color: viewModel.carreraColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
            borderSide: BorderSide(color: _getBorderColor(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
            borderSide: BorderSide(color: viewModel.carreraColor),
          ),
          filled: true,
          fillColor: _getInputFillColor(context),
        ),
      ),
    );
  }

  Widget _buildDocentesList(BuildContext context, DocentesViewModel viewModel) {
    return Expanded(
      child: viewModel.filteredDocentes.isEmpty
          ? _buildEmptyState(context, viewModel)
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: viewModel.filteredDocentes.length,
              itemBuilder: (context, index) {
                final docente = viewModel.filteredDocentes[index];
                return _buildDocenteCard(context, viewModel, docente);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DocentesViewModel viewModel) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: _getSecondaryTextColor(context),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'No hay docentes en ${viewModel.selectedCarrera}',
                style: AppTextStyles.body.copyWith(
                  color: _getSecondaryTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Turno: ${viewModel.selectedTurno}',
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  color: _getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              ElevatedButton(
                onPressed: () => _showAddEditDocenteDialog(context, viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: viewModel.carreraColor,
                ),
                child: const Text(
                  'Agregar Primer Docente',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocenteCard(
    BuildContext context,
    DocentesViewModel viewModel,
    Docente docente,
  ) {
    return Card(
      color: _getCardColor(context),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: viewModel.carreraColor,
          child: Text(
            '${docente.apellidoPaterno[0]}${docente.apellidoMaterno[0]}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          docente.nombres,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            color: _getTextColor(context),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${docente.apellidoPaterno} ${docente.apellidoMaterno}',
              style: AppTextStyles.body.copyWith(color: _getTextColor(context)),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.credit_card,
                      size: 12,
                      color: _getSecondaryTextColor(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'CI: ${docente.ci}',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: _getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getTurnoColor(docente.turno).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    docente.turno,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 10,
                      color: _getTurnoColor(docente.turno),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: viewModel.carreraColor),
          onSelected: (value) {
            switch (value) {
              case 'ver':
                _showDocenteDetails(context, docente);
                break;
              case 'editar':
                _showAddEditDocenteDialog(context, viewModel, docente: docente);
                break;
              case 'eliminar':
                _confirmDeleteDocente(context, viewModel, docente.id);
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'ver',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: viewModel.carreraColor),
                  const SizedBox(width: 8),
                  Text(
                    'Ver Información',
                    style: TextStyle(color: _getTextColor(context)),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit, color: viewModel.carreraColor),
                  const SizedBox(width: 8),
                  Text(
                    'Modificar',
                    style: TextStyle(color: _getTextColor(context)),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'eliminar',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showDocenteDetails(context, docente),
      ),
    );
  }

  // DIÁLOGO DE DETALLES DEL DOCENTE
  void _showDocenteDetails(BuildContext context, Docente docente) {
    final viewModel = Provider.of<DocentesViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _getCardColor(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 500,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detalles del Docente',
                      style: AppTextStyles.heading2.copyWith(
                        color: viewModel.carreraColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: _getTextColor(context)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('CI:', docente.ci, context),
                        _buildDetailRow(
                          'Apellido Paterno:',
                          docente.apellidoPaterno,
                          context,
                        ),
                        _buildDetailRow(
                          'Apellido Materno:',
                          docente.apellidoMaterno,
                          context,
                        ),
                        _buildDetailRow('Nombres:', docente.nombres, context),
                        _buildDetailRow('Carrera:', docente.carrera, context),
                        _buildDetailRow('Turno:', docente.turno, context),
                        _buildDetailRow('Email:', docente.email, context),
                        _buildDetailRow('Teléfono:', docente.telefono, context),
                        _buildDetailRow('Estado:', docente.estado, context),
                        if (docente.fechaCreacion != null)
                          _buildDetailRow(
                            'Fecha de Registro:',
                            _formatDate(docente.fechaCreacion!),
                            context,
                          ),
                        if (docente.fechaActualizacion != null)
                          _buildDetailRow(
                            'Última Actualización:',
                            _formatDate(docente.fechaActualizacion!),
                            context,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cerrar',
                        style: AppTextStyles.body.copyWith(
                          color: _getTextColor(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddEditDocenteDialog(
                          context,
                          viewModel,
                          docente: docente,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: viewModel.carreraColor,
                      ),
                      child: const Text(
                        'Editar',
                        style: TextStyle(color: Colors.white),
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

  // DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR
  void _confirmDeleteDocente(
    BuildContext context,
    DocentesViewModel viewModel,
    String id,
  ) {
    final docente = viewModel.getDocenteById(id);
    if (docente == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(context),
        title: Text(
          'Confirmar Eliminación',
          style: TextStyle(
            color: _getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Está seguro de eliminar este docente?',
              style: TextStyle(color: _getTextColor(context)),
            ),
            const SizedBox(height: AppSpacing.small),
            Container(
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${docente.nombres} ${docente.apellidoPaterno}',
                      style: TextStyle(
                        color: _getTextColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'CI: ${docente.ci}',
              style: TextStyle(
                color: _getSecondaryTextColor(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: _getTextColor(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final success = await viewModel.deleteDocente(id);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Docente eliminado correctamente',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error al eliminar docente: ${viewModel.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // DIÁLOGO PRINCIPAL PARA AGREGAR/EDITAR DOCENTE
  void _showAddEditDocenteDialog(
    BuildContext context,
    DocentesViewModel viewModel, {
    Docente? docente,
  }) {
    final bool isEditing = docente != null;

    TextEditingController ciController = TextEditingController(
      text: docente?.ci ?? '',
    );
    TextEditingController apellidoPaternoController = TextEditingController(
      text: docente?.apellidoPaterno ?? '',
    );
    TextEditingController apellidoMaternoController = TextEditingController(
      text: docente?.apellidoMaterno ?? '',
    );
    TextEditingController nombresController = TextEditingController(
      text: docente?.nombres ?? '',
    );
    TextEditingController emailController = TextEditingController(
      text: docente?.email ?? '',
    );
    TextEditingController telefonoController = TextEditingController(
      text: docente?.telefono ?? '',
    );

    String selectedCarrera = docente?.carrera ?? viewModel.selectedCarrera;
    String selectedTurno = docente?.turno ?? 'MAÑANA';
    String selectedEstado = docente?.estado ?? 'ACTIVO';

    final formKey = GlobalKey<FormState>();

    void autoCompletarEmail() {
      if (apellidoPaternoController.text.isNotEmpty &&
          nombresController.text.isNotEmpty &&
          emailController.text.isEmpty) {
        final nombre = nombresController.text.split(' ')[0].toLowerCase();
        final apellido = apellidoPaternoController.text.toLowerCase();
        emailController.text = '$nombre.$apellido@gmail.com';
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: _getCardColor(context),
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              maxWidth: 500,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditing ? 'Modificar Docente' : 'Agregar Docente',
                    style: AppTextStyles.heading2.copyWith(
                      color: viewModel.carreraColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // CI con validación
                            TextFormField(
                              controller: ciController,
                              style: TextStyle(color: _getTextColor(context)),
                              decoration: InputDecoration(
                                labelText: 'CI *',
                                labelStyle: TextStyle(
                                  color: _getTextColor(context),
                                ),
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: _getInputFillColor(context),
                              ),
                              keyboardType: TextInputType.number,
                              validator: Validators.validateCI,
                            ),
                            const SizedBox(height: AppSpacing.small),

                            // Apellido Paterno
                            TextFormField(
                              controller: apellidoPaternoController,
                              style: TextStyle(color: _getTextColor(context)),
                              decoration: InputDecoration(
                                labelText: 'Apellido Paterno *',
                                labelStyle: TextStyle(
                                  color: _getTextColor(context),
                                ),
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: _getInputFillColor(context),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) =>
                                  Validators.validateName(value),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  apellidoPaternoController.value =
                                      TextEditingValue(
                                        text: value.toUpperCase(),
                                        selection:
                                            apellidoPaternoController.selection,
                                      );
                                  autoCompletarEmail();
                                }
                              },
                            ),
                            const SizedBox(height: AppSpacing.small),

                            // Apellido Materno
                            TextFormField(
                              controller: apellidoMaternoController,
                              style: TextStyle(color: _getTextColor(context)),
                              decoration: InputDecoration(
                                labelText: 'Apellido Materno *',
                                labelStyle: TextStyle(
                                  color: _getTextColor(context),
                                ),
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: _getInputFillColor(context),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) =>
                                  Validators.validateName(value),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  apellidoMaternoController.value =
                                      TextEditingValue(
                                        text: value.toUpperCase(),
                                        selection:
                                            apellidoMaternoController.selection,
                                      );
                                }
                              },
                            ),
                            const SizedBox(height: AppSpacing.small),

                            // Nombres
                            TextFormField(
                              controller: nombresController,
                              style: TextStyle(color: _getTextColor(context)),
                              decoration: InputDecoration(
                                labelText: 'Nombres *',
                                labelStyle: TextStyle(
                                  color: _getTextColor(context),
                                ),
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: _getInputFillColor(context),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) =>
                                  Validators.validateName(value),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  nombresController.value = TextEditingValue(
                                    text: value.toUpperCase(),
                                    selection: nombresController.selection,
                                  );
                                  autoCompletarEmail();
                                }
                              },
                            ),
                            const SizedBox(height: AppSpacing.small),

                            // Selector de Carrera
                            DropdownButtonFormField<String>(
                              value: selectedCarrera,
                              isExpanded: true,
                              dropdownColor: _getCardColor(context),
                              style: TextStyle(color: _getTextColor(context)),
                              decoration: InputDecoration(
                                labelText: 'Carrera *',
                                labelStyle: TextStyle(
                                  color: _getTextColor(context),
                                ),
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: _getInputFillColor(context),
                              ),
                              items: viewModel.carreras.map((carrera) {
                                return DropdownMenuItem(
                                  value: carrera,
                                  child: Text(
                                    carrera,
                                    style: TextStyle(
                                      color: _getTextColor(context),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedCarrera = value!;
                                });
                              },
                              validator: (value) => value == null
                                  ? 'Seleccione una carrera'
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.small),

                            // Selector de Turno
                            DropdownButtonFormField<String>(
                              value: selectedTurno,
                              isExpanded: true,
                              dropdownColor: _getCardColor(context),
                              style: TextStyle(color: _getTextColor(context)),
                              decoration: InputDecoration(
                                labelText: 'Turno *',
                                labelStyle: TextStyle(
                                  color: _getTextColor(context),
                                ),
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: _getInputFillColor(context),
                              ),
                              items: viewModel.turnos.map((turno) {
                                return DropdownMenuItem(
                                  value: turno,
                                  child: Text(
                                    turno,
                                    style: TextStyle(
                                      color: _getTextColor(context),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedTurno = value!;
                                });
                              },
                              validator: (value) =>
                                  value == null ? 'Seleccione un turno' : null,
                            ),
                            const SizedBox(height: AppSpacing.small),

                            // Email
                            TextFormField(
                              controller: emailController,
                              style: TextStyle(color: _getTextColor(context)),
                              decoration: InputDecoration(
                                labelText: 'Email *',
                                labelStyle: TextStyle(
                                  color: _getTextColor(context),
                                ),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.email,
                                    color: viewModel.carreraColor,
                                  ),
                                  onPressed: autoCompletarEmail,
                                ),
                                filled: true,
                                fillColor: _getInputFillColor(context),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: AppSpacing.small),

                            // Teléfono
                            TextFormField(
                              controller: telefonoController,
                              style: TextStyle(color: _getTextColor(context)),
                              decoration: InputDecoration(
                                labelText: 'Teléfono *',
                                labelStyle: TextStyle(
                                  color: _getTextColor(context),
                                ),
                                border: const OutlineInputBorder(),
                                prefixText: '+591 ',
                                prefixStyle: TextStyle(
                                  color: _getTextColor(context),
                                ),
                                filled: true,
                                fillColor: _getInputFillColor(context),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) =>
                                  Validators.validatePhone(value),
                            ),
                            const SizedBox(height: AppSpacing.small),

                            // Estado
                            DropdownButtonFormField<String>(
                              value: selectedEstado,
                              isExpanded: true,
                              dropdownColor: _getCardColor(context),
                              style: TextStyle(color: _getTextColor(context)),
                              decoration: InputDecoration(
                                labelText: 'Estado *',
                                labelStyle: TextStyle(
                                  color: _getTextColor(context),
                                ),
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: _getInputFillColor(context),
                              ),
                              items: ['ACTIVO', 'INACTIVO'].map((estado) {
                                return DropdownMenuItem(
                                  value: estado,
                                  child: Text(
                                    estado,
                                    style: TextStyle(
                                      color: _getTextColor(context),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedEstado = value!;
                                });
                              },
                              validator: (value) =>
                                  value == null ? 'Seleccione un estado' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  if (viewModel.guardando)
                    const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.medium),
                      child: CircularProgressIndicator(),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancelar',
                            style: AppTextStyles.body.copyWith(
                              color: _getTextColor(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.small),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              String telefonoFormateado =
                                  telefonoController.text;
                              if (!telefonoFormateado.startsWith('+591')) {
                                if (RegExp(
                                  r'^\d+$',
                                ).hasMatch(telefonoFormateado)) {
                                  telefonoFormateado =
                                      '+591$telefonoFormateado';
                                }
                              }

                              final nuevoDocente = Docente(
                                id: isEditing ? docente!.id : '',
                                ci: ciController.text,
                                apellidoPaterno: apellidoPaternoController.text
                                    .trim()
                                    .toUpperCase(),
                                apellidoMaterno: apellidoMaternoController.text
                                    .trim()
                                    .toUpperCase(),
                                nombres: nombresController.text
                                    .trim()
                                    .toUpperCase(),
                                carrera: selectedCarrera,
                                turno: selectedTurno,
                                email: emailController.text.trim(),
                                telefono: telefonoFormateado,
                                estado: selectedEstado,
                              );

                              final success = isEditing
                                  ? await viewModel.updateDocente(nuevoDocente)
                                  : await viewModel.addDocente(nuevoDocente);

                              if (success && context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEditing
                                          ? 'Docente actualizado correctamente'
                                          : 'Docente agregado correctamente',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: AppColors.success,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } else if (context.mounted &&
                                  viewModel.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error: ${viewModel.error}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: AppColors.error,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: viewModel.carreraColor,
                          ),
                          child: Text(
                            isEditing ? 'Actualizar' : 'Guardar',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // MÉTODOS AUXILIARES
  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: _getTextColor(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: _getSecondaryTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getTurnoColor(String turno) {
    switch (turno) {
      case 'MAÑANA':
        return Colors.orange;
      case 'NOCHE':
        return Colors.blue;
      case 'AMBOS':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.white;
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

  Color _getInputFillColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : AppColors.background;
  }
}