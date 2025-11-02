import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../../models/materia_model.dart';
import '../../../viewmodels/materia_viewmodel.dart';

class CursosScreen extends StatefulWidget {
  const CursosScreen({super.key});

  @override
  State<CursosScreen> createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  // Filtros mejorados
  int _anioFiltro = 0; // 0 = Todos
  String _carreraFiltro = 'Todas';
  String _paraleloFiltro = 'Todos';
  String _turnoFiltro = 'Todos';

  // Opciones para filtros
  final List<String> _paralelos = ['Todos', 'A', 'B', 'C', 'D'];
  final List<String> _turnos = ['Todos', 'Mañana', 'Tarde', 'Noche'];

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

  Color _getFilterBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  Color _getDropdownBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MateriaViewModel>(context);

    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Gestión de Cursos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filtros mejorados
          Container(
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
                // Primera fila de filtros
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
                            value: _anioFiltro,
                            isExpanded: true,
                            dropdownColor: _getDropdownBackgroundColor(context),
                            style: TextStyle(color: _getTextColor(context)),
                            items: [
                              DropdownMenuItem(
                                value: 0,
                                child: Text(
                                  'Todos',
                                  style: TextStyle(
                                    color: _getTextColor(context),
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Text(
                                  '1° Año',
                                  style: TextStyle(
                                    color: _getTextColor(context),
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text(
                                  '2° Año',
                                  style: TextStyle(
                                    color: _getTextColor(context),
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 3,
                                child: Text(
                                  '3° Año',
                                  style: TextStyle(
                                    color: _getTextColor(context),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _anioFiltro = value!),
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
                            value: _carreraFiltro,
                            isExpanded: true,
                            dropdownColor: _getDropdownBackgroundColor(context),
                            style: TextStyle(color: _getTextColor(context)),
                            items: [
                              DropdownMenuItem(
                                value: 'Todas',
                                child: Text(
                                  'Todas',
                                  style: TextStyle(
                                    color: _getTextColor(context),
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Sistemas Informáticos',
                                child: Text(
                                  'Sistemas',
                                  style: TextStyle(
                                    color: _getTextColor(context),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _carreraFiltro = value!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Segunda fila de filtros
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
                            value: _paraleloFiltro,
                            isExpanded: true,
                            dropdownColor: _getDropdownBackgroundColor(context),
                            style: TextStyle(color: _getTextColor(context)),
                            items: _paralelos.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    if (value != 'Todos')
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: viewModel.getColorParalelo(
                                            value,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    if (value != 'Todos')
                                      const SizedBox(width: 8),
                                    Text(
                                      value == 'Todos'
                                          ? 'Todos'
                                          : 'Paralelo $value',
                                      style: TextStyle(
                                        color: _getTextColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _paraleloFiltro = value!),
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
                            value: _turnoFiltro,
                            isExpanded: true,
                            dropdownColor: _getDropdownBackgroundColor(context),
                            style: TextStyle(color: _getTextColor(context)),
                            items: _turnos.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    if (value != 'Todos')
                                      Icon(
                                        viewModel.obtenerIconoTurno(value),
                                        size: 16,
                                        color: _getTextColor(context),
                                      ),
                                    if (value != 'Todos')
                                      const SizedBox(width: 8),
                                    Text(
                                      value == 'Todos' ? 'Todos' : value,
                                      style: TextStyle(
                                        color: _getTextColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _turnoFiltro = value!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Información de filtros aplicados
                if (_anioFiltro != 0 ||
                    _carreraFiltro != 'Todas' ||
                    _paraleloFiltro != 'Todos' ||
                    _turnoFiltro != 'Todos')
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_alt,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _obtenerTextoFiltros(),
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
              ],
            ),
          ),
          Expanded(
            child: _getMateriasFiltradas(viewModel).isEmpty
                ? Center(
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
                          'No hay materias registradas',
                          style: TextStyle(
                            color: _getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _getMateriasFiltradas(viewModel).length,
                    itemBuilder: (context, index) {
                      final materia = _getMateriasFiltradas(viewModel)[index];
                      return _buildMateriaCard(materia, context, viewModel);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Materia> _getMateriasFiltradas(MateriaViewModel viewModel) {
    return viewModel.materias.where((materia) {
      bool anioOk = _anioFiltro == 0 || materia.anio == _anioFiltro;
      bool carreraOk =
          _carreraFiltro == 'Todas' || materia.carrera == _carreraFiltro;

      // Los filtros de paralelo y turno son informativos, no filtran datos reales
      // ya que las materias no tienen esta información en el modelo
      return anioOk && carreraOk;
    }).toList();
  }

  String _obtenerTextoFiltros() {
    List<String> filtros = [];

    if (_anioFiltro != 0) filtros.add('${_anioFiltro}° Año');
    if (_carreraFiltro != 'Todas') filtros.add(_carreraFiltro);
    if (_paraleloFiltro != 'Todos') filtros.add('Paralelo $_paraleloFiltro');
    if (_turnoFiltro != 'Todos') filtros.add('Turno $_turnoFiltro');

    return 'Filtros: ${filtros.join(' • ')}';
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
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Código: ${materia.codigo}',
              style: TextStyle(color: _getSecondaryTextColor(context)),
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
                if (_paraleloFiltro != 'Todos')
                  _buildInfoChip(
                    'Paralelo $_paraleloFiltro',
                    Icons.groups,
                    viewModel.getColorParalelo(_paraleloFiltro),
                    context,
                  ),
                if (_turnoFiltro != 'Todos')
                  _buildInfoChip(
                    'Turno $_turnoFiltro',
                    viewModel.obtenerIconoTurno(_turnoFiltro),
                    Colors.orange,
                    context,
                  ),
              ],
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
}
