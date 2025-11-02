import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../models/materia_model.dart';

class MateriasScreen extends StatefulWidget {
  const MateriasScreen({super.key});

  @override
  State<MateriasScreen> createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  final List<Materia> _materias = [];

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
  void initState() {
    super.initState();
    _cargarMateriasSistemas();
  }

  void _cargarMateriasSistemas() {
    // PRIMER AÑO - Sistemas Informáticos
    _materias.addAll([
      Materia(
        id: 'hardware',
        codigo: 'HARD101',
        nombre: 'Hardware de Computadoras',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.redes,
      ),
      Materia(
        id: 'matematica',
        codigo: 'MAT101',
        nombre: 'Matemática para la Informática',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.matematica,
      ),
      Materia(
        id: 'ingles',
        codigo: 'ING101',
        nombre: 'Inglés Técnico',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.ingles,
      ),
      Materia(
        id: 'web1',
        codigo: 'WEB101',
        nombre: 'Diseño y Programación Web I',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.programacion,
      ),
      Materia(
        id: 'ofimatica',
        codigo: 'OFI101',
        nombre: 'Ofimática y Tecnología Multimedia',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.etica,
      ),
      Materia(
        id: 'sistemas-op',
        codigo: 'SO101',
        nombre: 'Taller de Sistemas Operativos',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.fisica,
      ),
      Materia(
        id: 'programacion1',
        codigo: 'PROG101',
        nombre: 'Programación I',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.programacion,
      ),
    ]);

    // SEGUNDO AÑO - Sistemas Informáticos
    _materias.addAll([
      Materia(
        id: 'programacion2',
        codigo: 'PROG201',
        nombre: 'Programación II',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
      ),
      Materia(
        id: 'estructura',
        codigo: 'ED201',
        nombre: 'Estructura de Datos',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.matematica,
      ),
      Materia(
        id: 'estadistica',
        codigo: 'EST201',
        nombre: 'Estadística',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.matematica,
      ),
      Materia(
        id: 'basedatos1',
        codigo: 'BD201',
        nombre: 'Base de Datos I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.baseDatos,
      ),
      Materia(
        id: 'redes1',
        codigo: 'RED201',
        nombre: 'Redes de Computadoras I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.redes,
      ),
      Materia(
        id: 'analisis1',
        codigo: 'ADS201',
        nombre: 'Análisis y Diseño de Sistemas I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.etica,
      ),
      Materia(
        id: 'moviles1',
        codigo: 'PM201',
        nombre: 'Programación para Dispositivos Móviles I',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
      ),
      Materia(
        id: 'web2',
        codigo: 'WEB201',
        nombre: 'Diseño y Programación Web II',
        carrera: 'Sistemas Informáticos',
        anio: 2,
        color: MateriaColors.programacion,
      ),
    ]);

    // TERCER AÑO - Sistemas Informáticos
    _materias.addAll([
      Materia(
        id: 'redes2',
        codigo: 'RED301',
        nombre: 'Redes de Computadoras II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.redes,
      ),
      Materia(
        id: 'web3',
        codigo: 'WEB301',
        nombre: 'Diseño y Programación Web III',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.programacion,
      ),
      Materia(
        id: 'moviles2',
        codigo: 'PM301',
        nombre: 'Programación para Dispositivos Móviles II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.programacion,
      ),
      Materia(
        id: 'analisis2',
        codigo: 'ADS301',
        nombre: 'Análisis y Diseño de Sistemas II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.etica,
      ),
      Materia(
        id: 'taller-grado',
        codigo: 'TMG301',
        nombre: 'Taller de Modalidad de Graduación',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.ingles,
      ),
      Materia(
        id: 'gestion-calidad',
        codigo: 'GMC301',
        nombre: 'Gestión y Mejoramiento de la Calidad de Software',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.etica,
      ),
      Materia(
        id: 'basedatos2',
        codigo: 'BD301',
        nombre: 'Base de Datos II',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.baseDatos,
      ),
      Materia(
        id: 'emprendimiento',
        codigo: 'EMP301',
        nombre: 'Emprendimiento Productivo',
        carrera: 'Sistemas Informáticos',
        anio: 3,
        color: MateriaColors.ingles,
      ),
    ]);
  }

  List<Materia> get _materiasFiltradas {
    return _materias.where((materia) {
      bool anioOk = _anioFiltro == 0 || materia.anio == _anioFiltro;
      bool carreraOk =
          _carreraFiltro == 'Todas' || materia.carrera == _carreraFiltro;

      // Los filtros de paralelo y turno son informativos, no filtran datos reales
      // ya que las materias no tienen esta información en el modelo
      return anioOk && carreraOk;
    }).toList();
  }

  Color _getColorAnio(int anio) {
    switch (anio) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.green;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getColorParalelo(String paralelo) {
    switch (paralelo) {
      case 'A':
        return Colors.red;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.green;
      case 'D':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _obtenerIconoTurno(String turno) {
    switch (turno.toLowerCase()) {
      case 'mañana':
        return Icons.wb_sunny;
      case 'tarde':
        return Icons.brightness_6;
      case 'noche':
        return Icons.nights_stay;
      default:
        return Icons.schedule;
    }
  }

  IconData _obtenerIconoMateria(String nombreMateria) {
    if (nombreMateria.toLowerCase().contains('programación') ||
        nombreMateria.toLowerCase().contains('web')) {
      return Icons.code;
    } else if (nombreMateria.toLowerCase().contains('base de datos')) {
      return Icons.storage;
    } else if (nombreMateria.toLowerCase().contains('redes')) {
      return Icons.lan;
    } else if (nombreMateria.toLowerCase().contains('matemática') ||
        nombreMateria.toLowerCase().contains('estadística')) {
      return Icons.calculate;
    } else if (nombreMateria.toLowerCase().contains('inglés')) {
      return Icons.language;
    } else if (nombreMateria.toLowerCase().contains('hardware')) {
      return Icons.computer;
    } else if (nombreMateria.toLowerCase().contains('sistemas operativos')) {
      return Icons.settings;
    } else {
      return Icons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                          color: _getColorParalelo(value),
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
                                        _obtenerIconoTurno(value),
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
            child: _materiasFiltradas.isEmpty
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
                    itemCount: _materiasFiltradas.length,
                    itemBuilder: (context, index) {
                      final materia = _materiasFiltradas[index];
                      return _buildMateriaCard(materia, context);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _obtenerTextoFiltros() {
    List<String> filtros = [];

    if (_anioFiltro != 0) filtros.add('${_anioFiltro}° Año');
    if (_carreraFiltro != 'Todas') filtros.add(_carreraFiltro);
    if (_paraleloFiltro != 'Todos') filtros.add('Paralelo $_paraleloFiltro');
    if (_turnoFiltro != 'Todos') filtros.add('Turno $_turnoFiltro');

    return 'Filtros: ${filtros.join(' • ')}';
  }

  Widget _buildMateriaCard(Materia materia, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: _getCardColor(context),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: materia.color,
          child: Icon(
            _obtenerIconoMateria(materia.nombre),
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
                  _getColorAnio(materia.anio),
                  context,
                ),
                if (_paraleloFiltro != 'Todos')
                  _buildInfoChip(
                    'Paralelo $_paraleloFiltro',
                    Icons.groups,
                    _getColorParalelo(_paraleloFiltro),
                    context,
                  ),
                if (_turnoFiltro != 'Todos')
                  _buildInfoChip(
                    'Turno $_turnoFiltro',
                    _obtenerIconoTurno(_turnoFiltro),
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
