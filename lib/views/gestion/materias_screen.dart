// views/materia_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../models/materia_model.dart';
import '../../viewmodels/materia_viewmodel.dart';

class MateriasScreen extends StatefulWidget {
  const MateriasScreen({super.key});

  @override
  State<MateriasScreen> createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MateriaViewModel(), // ✅ Sin parámetros
      child: Scaffold(
        backgroundColor: _getBackgroundColor(context),
        appBar: AppBar(
          title: const Text(
            'Gestión de Cursos',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Consumer<MateriaViewModel>(
              builder: (context, viewModel, child) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _mostrarFormularioMateria(context, viewModel),
                  tooltip: 'Agregar nueva materia',
                );
              },
            ),
          ],
        ),
        body: Consumer<MateriaViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.materias.isEmpty) {
              return _buildLoadingState();
            }

            if (viewModel.error != null && viewModel.materias.isEmpty) {
              return _buildErrorState(viewModel.error!, viewModel);
            }

            return Stack(
              children: [
                Column(
                  children: [
                    // Filtros mejorados
                    _buildFiltrosSection(viewModel, context),
                    
                    // Indicador de resultados
                    _buildResultadosIndicator(viewModel, context),
                    
                    // Lista de materias
                    Expanded(
                      child: _buildMateriasList(viewModel, context),
                    ),
                  ],
                ),

                // Burbuja de notificación
                if (viewModel.mostrarBurbuja)
                  Positioned(
                    top: 80,
                    left: 16,
                    right: 16,
                    child: _buildBurbujaNotificacion(viewModel),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Cargando materias...',
            style: TextStyle(
              color: _getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, MateriaViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Error al cargar materias',
            style: TextStyle(
              color: _getTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _getSecondaryTextColor(context),
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.clearError(),
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosSection(MateriaViewModel viewModel, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _getFilterBackgroundColor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar cursos:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nivel:',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getSecondaryTextColor(context),
                      ),
                    ),
                    DropdownButton<int>(
                      value: viewModel.anioFiltro,
                      isExpanded: true,
                      dropdownColor: _getDropdownBackgroundColor(context),
                      style: TextStyle(color: _getTextColor(context)),
                      items: [
                        DropdownMenuItem(
                          value: 0,
                          child: Text(
                            'Todos',
                            style: TextStyle(color: _getTextColor(context)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text(
                            '1° Año',
                            style: TextStyle(color: _getTextColor(context)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text(
                            '2° Año',
                            style: TextStyle(color: _getTextColor(context)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text(
                            '3° Año',
                            style: TextStyle(color: _getTextColor(context)),
                          ),
                        ),
                      ],
                      onChanged: (value) => viewModel.setAnioFiltro(value!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carrera:',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getSecondaryTextColor(context),
                      ),
                    ),
                    DropdownButton<String>(
                      value: viewModel.carreraFiltro,
                      isExpanded: true,
                      dropdownColor: _getDropdownBackgroundColor(context),
                      style: TextStyle(color: _getTextColor(context)),
                      items: viewModel.carrerasFiltro.map((carrera) {
                        return DropdownMenuItem(
                          value: carrera,
                          child: Text(
                            carrera,
                            style: TextStyle(color: _getTextColor(context)),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => viewModel.setCarreraFiltro(value!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paralelo:',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getSecondaryTextColor(context),
                      ),
                    ),
                    DropdownButton<String>(
                      value: viewModel.paraleloFiltro,
                      isExpanded: true,
                      dropdownColor: _getDropdownBackgroundColor(context),
                      style: TextStyle(color: _getTextColor(context)),
                      items: viewModel.paralelosFiltro.map((paralelo) {
                        return DropdownMenuItem(
                          value: paralelo,
                          child: Row(
                            children: [
                              if (paralelo != 'Todos')
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: viewModel.getColorParalelo(paralelo),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (paralelo != 'Todos') const SizedBox(width: 8),
                              Text(
                                paralelo == 'Todos' ? 'Todos' : 'Paralelo $paralelo',
                                style: TextStyle(color: _getTextColor(context)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => viewModel.setParaleloFiltro(value!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Turno:',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getSecondaryTextColor(context),
                      ),
                    ),
                    DropdownButton<String>(
                      value: viewModel.turnoFiltro,
                      isExpanded: true,
                      dropdownColor: _getDropdownBackgroundColor(context),
                      style: TextStyle(color: _getTextColor(context)),
                      items: viewModel.turnosFiltro.map((turno) {
                        return DropdownMenuItem(
                          value: turno,
                          child: Row(
                            children: [
                              if (turno != 'Todos')
                                Icon(
                                  viewModel.obtenerIconoTurno(turno),
                                  size: 16,
                                  color: _getTextColor(context),
                                ),
                              if (turno != 'Todos') const SizedBox(width: 8),
                              Text(
                                turno == 'Todos' ? 'Todos' : turno,
                                style: TextStyle(color: _getTextColor(context)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => viewModel.setTurnoFiltro(value!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildFiltrosAplicados(viewModel, context),
        ],
      ),
    );
  }

  Widget _buildFiltrosAplicados(MateriaViewModel viewModel, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.filter_alt, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    viewModel.obtenerTextoFiltros(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (viewModel.anioFiltro != 0 || 
            viewModel.carreraFiltro != 'Todas' || 
            viewModel.paraleloFiltro != 'Todos' || 
            viewModel.turnoFiltro != 'Todos')
          IconButton(
            icon: Icon(Icons.clear, color: AppColors.primary),
            onPressed: viewModel.limpiarFiltros,
            tooltip: 'Limpiar filtros',
          ),
      ],
    );
  }

  Widget _buildResultadosIndicator(MateriaViewModel viewModel, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _getFilterBackgroundColor(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Resultados: ${viewModel.materiasFiltradasGestion.length} materias',
            style: TextStyle(
              color: _getSecondaryTextColor(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (viewModel.materiasFiltradasGestion.isNotEmpty)
            Text(
              _obtenerResumenFiltros(viewModel),
              style: TextStyle(
                color: _getSecondaryTextColor(context),
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  String _obtenerResumenFiltros(MateriaViewModel viewModel) {
    List<String> partes = [];
    if (viewModel.anioFiltro != 0) partes.add('${viewModel.anioFiltro}°');
    if (viewModel.paraleloFiltro != 'Todos') partes.add(viewModel.paraleloFiltro);
    if (viewModel.turnoFiltro != 'Todos') partes.add(viewModel.turnoFiltro);
    return partes.join(' • ');
  }

  Widget _buildMateriasList(MateriaViewModel viewModel, BuildContext context) {
    final materiasFiltradas = viewModel.materiasFiltradasGestion;

    if (materiasFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 64,
              color: _getSecondaryTextColor(context),
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              viewModel.materias.isEmpty 
                  ? 'No hay materias registradas'
                  : 'No hay materias que coincidan con los filtros',
              style: TextStyle(
                color: _getSecondaryTextColor(context),
              ),
            ),
            if (viewModel.materias.isEmpty)
              Text(
                'Presiona el botón + para agregar una materia',
                style: TextStyle(
                  color: _getSecondaryTextColor(context),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: materiasFiltradas.length,
      itemBuilder: (context, index) {
        final materia = materiasFiltradas[index];
        return _buildMateriaCard(materia, context, viewModel);
      },
    );
  }

  Widget _buildBurbujaNotificacion(MateriaViewModel viewModel) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: viewModel.colorBurbuja,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              viewModel.mensajeBurbuja,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: viewModel.ocultarBurbuja,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildMateriaCard(
    Materia materia,
    BuildContext context,
    MateriaViewModel viewModel,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: _getCardColor(context),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: materia.color,
          child: Icon(
            viewModel.obtenerIconoMateria(materia.nombre),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          materia.nombre,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: _getTextColor(context),
            decoration: materia.activo
                ? TextDecoration.none
                : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Código: ${materia.codigo}',
              style: TextStyle(
                color: _getSecondaryTextColor(context),
                decoration: materia.activo
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _buildInfoChip(
                  materia.anioDisplay,
                  Icons.grade,
                  viewModel.getColorAnio(materia.anio),
                  context,
                ),
                _buildInfoChip(
                  materia.paraleloDisplay,
                  Icons.groups,
                  viewModel.getColorParalelo(materia.paralelo),
                  context,
                ),
                _buildInfoChip(
                  materia.turnoDisplay,
                  viewModel.obtenerIconoTurno(materia.turno),
                  Colors.purple,
                  context,
                ),
                _buildInfoChip(
                  materia.activo ? 'Activo' : 'Inactivo',
                  materia.activo ? Icons.check_circle : Icons.cancel,
                  materia.activo ? Colors.green : Colors.red,
                  context,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: _getTextColor(context)),
          onSelected: (value) => _manejarOpcionMenu(value, materia, viewModel),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: materia.activo ? 'desactivar' : 'activar',
              child: Row(
                children: [
                  Icon(
                    materia.activo ? Icons.pause_circle : Icons.play_arrow,
                    color: materia.activo ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(materia.activo ? 'Desactivar' : 'Activar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'eliminar',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _manejarOpcionMenu(
    String value,
    Materia materia,
    MateriaViewModel viewModel,
  ) {
    switch (value) {
      case 'editar':
        viewModel.cargarMateriaParaEditar(materia);
        _mostrarFormularioMateria(context, viewModel);
        break;
      case 'desactivar':
        _mostrarDialogoConfirmacion(
          context,
          'Desactivar Materia',
          '¿Estás seguro de que deseas desactivar ${materia.nombre}?',
          () => viewModel.desactivarMateria(materia.id),
        );
        break;
      case 'activar':
        viewModel.activarMateria(materia.id);
        break;
      case 'eliminar':
        _mostrarDialogoConfirmacion(
          context,
          'Eliminar Materia',
          '¿Estás seguro de que deseas eliminar ${materia.nombre}? Esta acción no se puede deshacer.',
          () => viewModel.eliminarMateria(materia.id),
        );
        break;
    }
  }

  void _mostrarDialogoConfirmacion(
    BuildContext context,
    String titulo,
    String contenido,
    Function onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(contenido),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text('Confirmar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _mostrarFormularioMateria(
    BuildContext context,
    MateriaViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _getCardColor(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      viewModel.materiaEditandoId.isEmpty
                          ? 'Agregar Materia'
                          : 'Editar Materia',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(context),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: _getTextColor(context)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFormField(
                  controller: viewModel.codigoController,
                  label: 'Código de la materia',
                  hint: 'Ej: PROG101',
                  icon: Icons.code,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: viewModel.nombreController,
                  label: 'Nombre de la materia',
                  hint: 'Ej: Programación I',
                  icon: Icons.school,
                ),
                const SizedBox(height: 16),
                Text(
                  'Carrera:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: viewModel.carreraSeleccionadaForm,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: viewModel.carrerasDisponibles.map((carrera) {
                    return DropdownMenuItem<String>(
                      value: carrera,
                      child: Text(carrera),
                    );
                  }).toList(),
                  onChanged: (value) => viewModel.setCarreraSeleccionadaForm(value!),
                ),
                const SizedBox(height: 16),
                Text(
                  'Año:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: viewModel.anioSeleccionadoForm,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: [1, 2, 3].map((anio) {
                    return DropdownMenuItem<int>(
                      value: anio,
                      child: Text('$anio° Año'),
                    );
                  }).toList(),
                  onChanged: (value) => viewModel.setAnioSeleccionadoForm(value!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paralelo:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: viewModel.paraleloSeleccionadoForm,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            items: viewModel.paralelosDisponibles.map((paralelo) {
                              return DropdownMenuItem<String>(
                                value: paralelo,
                                child: Text('Paralelo $paralelo'),
                              );
                            }).toList(),
                            onChanged: (value) => viewModel.setParaleloSeleccionadoForm(value!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Turno:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: viewModel.turnoSeleccionadoForm,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            items: viewModel.turnosDisponibles.map((turno) {
                              return DropdownMenuItem<String>(
                                value: turno,
                                child: Text('Turno $turno'),
                              );
                            }).toList(),
                            onChanged: (value) => viewModel.setTurnoSeleccionadoForm(value!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Color:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildColorOption(MateriaColors.programacion, viewModel),
                    _buildColorOption(MateriaColors.baseDatos, viewModel),
                    _buildColorOption(MateriaColors.redes, viewModel),
                    _buildColorOption(MateriaColors.matematica, viewModel),
                    _buildColorOption(MateriaColors.ingles, viewModel),
                    _buildColorOption(MateriaColors.etica, viewModel),
                    _buildColorOption(MateriaColors.fisica, viewModel),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading ? null : () {
                      if (viewModel.materiaEditandoId.isEmpty) {
                        viewModel.agregarMateria();
                      } else {
                        viewModel.actualizarMateria();
                      }
                      if (!viewModel.isLoading) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: viewModel.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            viewModel.materiaEditandoId.isEmpty
                                ? 'Agregar Materia'
                                : 'Actualizar Materia',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getTextColor(context),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildColorOption(Color color, MateriaViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.setColorSeleccionado(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: viewModel.colorSeleccionado == color
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    String text,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
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

  Color _getFilterBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color _getDropdownBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }
}