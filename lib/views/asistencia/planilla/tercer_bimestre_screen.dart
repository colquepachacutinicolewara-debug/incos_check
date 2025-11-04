import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../../viewmodels/tercer_bimestre_viewmodel.dart';
import '../../../models/tercer_bimestre_model.dart';

class TercerBimestreScreen extends StatelessWidget {
  const TercerBimestreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TercerBimestreViewModel(),
      child: const _TercerBimestreScreenContent(),
    );
  }
}

class _TercerBimestreScreenContent extends StatelessWidget {
  const _TercerBimestreScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TercerBimestreViewModel>();

    return Scaffold(
      backgroundColor: viewModel.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Tercer Bimestre',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: viewModel.getPurpleAccentColor(context),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: viewModel.editarFechasBimestre,
            tooltip: 'Editar fechas',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportarCSV(context, viewModel),
            tooltip: 'Exportar a CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          // Información del bimestre
          _buildBimestreInfo(context, viewModel),

          // Barra de búsqueda y controles
          _buildSearchBar(context, viewModel),

          // Tabla de asistencias
          _buildAsistenciaTable(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildBimestreInfo(
    BuildContext context,
    TercerBimestreViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: viewModel.getPurpleLightColor(context),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            color: viewModel.bimestre.colorEstado,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.bimestre.nombre,
                  style: AppTextStyles.heading2.copyWith(
                    color: viewModel.getTextColor(context),
                  ),
                ),
                Text(
                  viewModel.bimestre.rangoFechas,
                  style: TextStyle(
                    color: viewModel.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: viewModel.bimestre.colorEstado.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: viewModel.bimestre.colorEstado),
            ),
            child: Text(
              viewModel.bimestre.estado,
              style: TextStyle(
                color: viewModel.bimestre.colorEstado,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    TercerBimestreViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: viewModel.searchController,
                  style: TextStyle(color: viewModel.getTextColor(context)),
                  decoration: InputDecoration(
                    labelText: 'Buscar por número exacto o nombre',
                    hintText: 'Ej: 05 o "Estudiante 05"',
                    labelStyle: TextStyle(
                      color: viewModel.getSecondaryTextColor(context),
                    ),
                    hintStyle: TextStyle(
                      color: viewModel.getSecondaryTextColor(context),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: viewModel.getSecondaryTextColor(context),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: viewModel.getBorderColor(context),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: viewModel.getBorderColor(context),
                      ),
                    ),
                    filled: true,
                    fillColor: viewModel.getSearchBackgroundColor(context),
                    suffixIcon: viewModel.searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: viewModel.getSecondaryTextColor(context),
                            ),
                            onPressed: () => viewModel.searchController.clear(),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: viewModel.getPurpleLightColor(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: viewModel
                        .getPurpleAccentColor(context)
                        .withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Total: ${viewModel.filteredEstudiantes.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: viewModel.getPurpleAccentColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildItemLeyenda(
                  Colors.green,
                  'Presente (P)',
                  context,
                  viewModel,
                ),
                const SizedBox(width: 16),
                _buildItemLeyenda(Colors.red, 'Falta (F)', context, viewModel),
                const SizedBox(width: 16),
                _buildItemLeyenda(
                  Colors.orange,
                  'Justificado (J)',
                  context,
                  viewModel,
                ),
                const SizedBox(width: 16),
                _buildItemLeyenda(
                  Colors.yellow,
                  'Seleccionado',
                  context,
                  viewModel,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (viewModel.estudianteSeleccionado != null)
            Text(
              'Estudiante seleccionado: ${viewModel.estudianteSeleccionado}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: viewModel.getPurpleAccentColor(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAsistenciaTable(
    BuildContext context,
    TercerBimestreViewModel viewModel,
  ) {
    return Expanded(
      child: viewModel.filteredEstudiantes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: viewModel.getSecondaryTextColor(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron estudiantes',
                    style: TextStyle(
                      fontSize: 16,
                      color: viewModel.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith(
                    (states) => viewModel.getHeaderBackgroundColor(context),
                  ),
                  columnSpacing: 8,
                  dataRowMinHeight: 55,
                  dataRowMaxHeight: 55,
                  horizontalMargin: 8,
                  columns: [
                    DataColumn(
                      label: Text(
                        'ÍTEM',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: viewModel.getTextColor(context),
                        ),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'ESTUDIANTE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: viewModel.getTextColor(context),
                        ),
                      ),
                    ),
                    ...viewModel.fechas.map(
                      (fecha) => DataColumn(
                        label: SizedBox(
                          width: 48,
                          child: Text(
                            fecha,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: viewModel.getTextColor(context),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'TOTAL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: viewModel.getTextColor(context),
                        ),
                      ),
                      numeric: true,
                    ),
                  ],
                  rows: viewModel.filteredEstudiantes.map((estudiante) {
                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>((states) {
                        return viewModel.getColorFila(estudiante.item, context);
                      }),
                      cells: [
                        DataCell(
                          GestureDetector(
                            onTap: () => viewModel.seleccionarEstudiante(
                              estudiante.item,
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      viewModel.estudianteSeleccionado ==
                                          estudiante.item
                                      ? viewModel.getPurpleAccentColor(context)
                                      : null,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  estudiante.item.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        viewModel.estudianteSeleccionado ==
                                            estudiante.item
                                        ? Colors.white
                                        : viewModel.getTextColor(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          GestureDetector(
                            onTap: () => viewModel.seleccionarEstudiante(
                              estudiante.item,
                            ),
                            child: SizedBox(
                              width: 120,
                              child: Text(
                                estudiante.nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: viewModel.getTextColor(context),
                                  backgroundColor:
                                      viewModel.estudianteSeleccionado ==
                                          estudiante.item
                                      ? Colors.yellow.withOpacity(0.3)
                                      : Colors.transparent,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        // Celdas de asistencia
                        ...viewModel.fechas.map(
                          (fecha) => DataCell(
                            _buildCeldaAsistencia(
                              estudiante,
                              fecha,
                              context,
                              viewModel,
                            ),
                          ),
                        ),
                        DataCell(
                          GestureDetector(
                            onTap: () => viewModel.seleccionarEstudiante(
                              estudiante.item,
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: viewModel.getColorTotal(
                                    estudiante.totalAsistencias,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      viewModel.estudianteSeleccionado ==
                                          estudiante.item
                                      ? Border.all(
                                          color: viewModel.getPurpleAccentColor(
                                            context,
                                          ),
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Text(
                                  estudiante.totalDisplay,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }

  Widget _buildCeldaAsistencia(
    AsistenciaEstudianteTercer estudiante,
    String fecha,
    BuildContext context,
    TercerBimestreViewModel viewModel,
  ) {
    String valor = '';
    switch (fecha) {
      case 'JUL-L':
        valor = estudiante.julL;
        break;
      case 'JUL-M':
        valor = estudiante.julM;
        break;
      case 'JUL-MI':
        valor = estudiante.julMi;
        break;
      case 'JUL-J':
        valor = estudiante.julJ;
        break;
      case 'JUL-V':
        valor = estudiante.julV;
        break;
      case 'AGO-L':
        valor = estudiante.agoL;
        break;
      case 'AGO-M':
        valor = estudiante.agoM;
        break;
      case 'AGO-MI':
        valor = estudiante.agoMi;
        break;
      case 'AGO-J':
        valor = estudiante.agoJ;
        break;
      case 'AGO-V':
        valor = estudiante.agoV;
        break;
      case 'SEP-L':
        valor = estudiante.sepL;
        break;
      case 'SEP-M':
        valor = estudiante.sepM;
        break;
      case 'SEP-MI':
        valor = estudiante.sepMi;
        break;
      case 'SEP-J':
        valor = estudiante.sepJ;
        break;
      case 'SEP-V':
        valor = estudiante.sepV;
        break;
    }

    return Tooltip(
      message:
          '${viewModel.getTooltipAsistencia(valor)} - $fecha\nClic para editar',
      child: GestureDetector(
        onTap: () => _editarAsistencia(estudiante, fecha, context, viewModel),
        child: Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: viewModel.getColorAsistencia(valor, context),
            shape: BoxShape.circle,
            border: Border.all(
              color: viewModel.getBorderColor(context),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              valor.isEmpty ? '' : valor,
              style: TextStyle(
                color: valor.isEmpty
                    ? viewModel.getSecondaryTextColor(context)
                    : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemLeyenda(
    Color color,
    String texto,
    BuildContext context,
    TercerBimestreViewModel viewModel,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            color: viewModel.getTextColor(context),
          ),
        ),
      ],
    );
  }

  Future<void> _exportarCSV(
    BuildContext context,
    TercerBimestreViewModel viewModel,
  ) async {
    try {
      await viewModel.exportarACSV();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Archivo exportado correctamente'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al exportar: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _editarAsistencia(
    AsistenciaEstudianteTercer estudiante,
    String fecha,
    BuildContext context,
    TercerBimestreViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: viewModel.getCardColor(context),
        title: Text(
          'Editar asistencia - $fecha',
          style: TextStyle(color: viewModel.getTextColor(context)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Estudiante: ${estudiante.nombre}',
                style: TextStyle(color: viewModel.getTextColor(context)),
              ),
              const SizedBox(height: 20),
              Text(
                'Seleccione el estado:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: viewModel.getTextColor(context),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  _buildBotonAsistencia(
                    'P',
                    'Presente',
                    Colors.green,
                    estudiante,
                    fecha,
                    context,
                    viewModel,
                  ),
                  _buildBotonAsistencia(
                    'F',
                    'Falta',
                    Colors.red,
                    estudiante,
                    fecha,
                    context,
                    viewModel,
                  ),
                  _buildBotonAsistencia(
                    'J',
                    'Justificado',
                    Colors.orange,
                    estudiante,
                    fecha,
                    context,
                    viewModel,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  viewModel.actualizarAsistencia(estudiante, fecha, '');
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: viewModel.getSecondaryTextColor(context),
                  side: BorderSide(color: viewModel.getBorderColor(context)),
                ),
                child: const Text('Limpiar'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: TextStyle(color: viewModel.getPurpleAccentColor(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonAsistencia(
    String valor,
    String label,
    Color color,
    AsistenciaEstudianteTercer estudiante,
    String fecha,
    BuildContext context,
    TercerBimestreViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () {
        viewModel.actualizarAsistencia(estudiante, fecha, valor);
        Navigator.pop(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                valor,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: viewModel.getTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
