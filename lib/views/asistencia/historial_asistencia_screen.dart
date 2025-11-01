import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/views/gestion/materias_screen.dart';
import 'package:incos_check/views/gestion/bimestres_screen.dart';
import 'package:incos_check/models/materia_model.dart';

class HistorialAsistenciaScreen extends StatefulWidget {
  const HistorialAsistenciaScreen({super.key});

  @override
  State<HistorialAsistenciaScreen> createState() =>
      _HistorialAsistenciaScreenState();
}

class _HistorialAsistenciaScreenState extends State<HistorialAsistenciaScreen> {
  final List<Materia> _materias = [];
  final List<Materia> _materiasFiltradas = [];
  final TextEditingController _searchController = TextEditingController();
  int _anioSeleccionado = 3; // Por defecto TERCER AÑO

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

  Color _getSearchBackgroundColor(BuildContext context) {
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
        : Colors.grey.shade50;
  }

  @override
  void initState() {
    super.initState();
    _cargarMateriasSistemas();
    _filtrarMateriasPorAnio();
    _searchController.addListener(_filtrarMaterias);
  }

  void _filtrarMaterias() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _materiasFiltradas.clear();
      if (query.isEmpty) {
        _materiasFiltradas.addAll(
          _materias.where((materia) => materia.anio == _anioSeleccionado),
        );
      } else {
        _materiasFiltradas.addAll(
          _materias.where(
            (materia) =>
                materia.anio == _anioSeleccionado &&
                (materia.nombre.toLowerCase().contains(query) ||
                    materia.codigo.toLowerCase().contains(query) ||
                    materia.carrera.toLowerCase().contains(query)),
          ),
        );
      }
    });
  }

  void _filtrarMateriasPorAnio() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _materiasFiltradas.clear();
      if (query.isEmpty) {
        _materiasFiltradas.addAll(
          _materias.where((materia) => materia.anio == _anioSeleccionado),
        );
      } else {
        _materiasFiltradas.addAll(
          _materias.where(
            (materia) =>
                materia.anio == _anioSeleccionado &&
                (materia.nombre.toLowerCase().contains(query) ||
                    materia.codigo.toLowerCase().contains(query) ||
                    materia.carrera.toLowerCase().contains(query)),
          ),
        );
      }
    });
  }

  void _cargarMateriasSistemas() {
    // PRIMER ANIO - Sistemas Informaticos
    _materias.addAll([
      Materia(
        id: 'hardware',
        codigo: 'HARD101',
        nombre: 'Hardware de Computadoras',
        carrera: 'Sistemas Informaticos',
        anio: 1,
        color: MateriaColors.redes,
      ),
      Materia(
        id: 'matematica',
        codigo: 'MAT101',
        nombre: 'Matematica para la Informatica',
        carrera: 'Sistemas Informaticos',
        anio: 1,
        color: MateriaColors.matematica,
      ),
      Materia(
        id: 'ingles',
        codigo: 'ING101',
        nombre: 'Ingles Tecnico',
        carrera: 'Sistemas Informaticos',
        anio: 1,
        color: MateriaColors.ingles,
      ),
      Materia(
        id: 'web1',
        codigo: 'WEB101',
        nombre: 'Diseno y Programacion Web I',
        carrera: 'Sistemas Informaticos',
        anio: 1,
        color: MateriaColors.programacion,
      ),
      Materia(
        id: 'ofimatica',
        codigo: 'OFI101',
        nombre: 'Ofimatica y Tecnologia Multimedia',
        carrera: 'Sistemas Informaticos',
        anio: 1,
        color: MateriaColors.etica,
      ),
      Materia(
        id: 'sistemas-op',
        codigo: 'SO101',
        nombre: 'Taller de Sistemas Operativos',
        carrera: 'Sistemas Informaticos',
        anio: 1,
        color: MateriaColors.fisica,
      ),
      Materia(
        id: 'programacion1',
        codigo: 'PROG101',
        nombre: 'Programacion I',
        carrera: 'Sistemas Informaticos',
        anio: 1,
        color: MateriaColors.programacion,
      ),
    ]);

    // SEGUNDO ANIO - Sistemas Informaticos
    _materias.addAll([
      Materia(
        id: 'programacion2',
        codigo: 'PROG201',
        nombre: 'Programacion II',
        carrera: 'Sistemas Informaticos',
        anio: 2,
        color: MateriaColors.programacion,
      ),
      Materia(
        id: 'estructura',
        codigo: 'ED201',
        nombre: 'Estructura de Datos',
        carrera: 'Sistemas Informaticos',
        anio: 2,
        color: MateriaColors.matematica,
      ),
      Materia(
        id: 'estadistica',
        codigo: 'EST201',
        nombre: 'Estadistica',
        carrera: 'Sistemas Informaticos',
        anio: 2,
        color: MateriaColors.matematica,
      ),
      Materia(
        id: 'basedatos1',
        codigo: 'BD201',
        nombre: 'Base de Datos I',
        carrera: 'Sistemas Informaticos',
        anio: 2,
        color: MateriaColors.baseDatos,
      ),
      Materia(
        id: 'redes1',
        codigo: 'RED201',
        nombre: 'Redes de Computadoras I',
        carrera: 'Sistemas Informaticos',
        anio: 2,
        color: MateriaColors.redes,
      ),
      Materia(
        id: 'analisis1',
        codigo: 'ADS201',
        nombre: 'Analisis y Diseno de Sistemas I',
        carrera: 'Sistemas Informaticos',
        anio: 2,
        color: MateriaColors.etica,
      ),
      Materia(
        id: 'moviles1',
        codigo: 'PM201',
        nombre: 'Programacion para Dispositivos Moviles I',
        carrera: 'Sistemas Informaticos',
        anio: 2,
        color: MateriaColors.programacion,
      ),
      Materia(
        id: 'web2',
        codigo: 'WEB201',
        nombre: 'Diseno y Programacion Web II',
        carrera: 'Sistemas Informaticos',
        anio: 2,
        color: MateriaColors.programacion,
      ),
    ]);

    // TERCER ANIO - Sistemas Informaticos
    _materias.addAll([
      Materia(
        id: 'redes2',
        codigo: 'RED301',
        nombre: 'Redes de Computadoras II',
        carrera: 'Sistemas Informaticos',
        anio: 3,
        color: MateriaColors.redes,
      ),
      Materia(
        id: 'web3',
        codigo: 'WEB301',
        nombre: 'Diseno y Programacion Web III',
        carrera: 'Sistemas Informaticos',
        anio: 3,
        color: MateriaColors.programacion,
      ),
      Materia(
        id: 'moviles2',
        codigo: 'PM301',
        nombre: 'Programacion para Dispositivos Moviles II',
        carrera: 'Sistemas Informaticos',
        anio: 3,
        color: MateriaColors.programacion,
      ),
      Materia(
        id: 'analisis2',
        codigo: 'ADS301',
        nombre: 'Analisis y Diseno de Sistemas II',
        carrera: 'Sistemas Informaticos',
        anio: 3,
        color: MateriaColors.etica,
      ),
      Materia(
        id: 'taller-grado',
        codigo: 'TMG301',
        nombre: 'Taller de Modalidad de Graduacion',
        carrera: 'Sistemas Informaticos',
        anio: 3,
        color: MateriaColors.ingles,
      ),
      Materia(
        id: 'gestion-calidad',
        codigo: 'GMC301',
        nombre: 'Gestion y Mejoramiento de la Calidad de Software',
        carrera: 'Sistemas Informaticos',
        anio: 3,
        color: MateriaColors.etica,
      ),
      Materia(
        id: 'basedatos2',
        codigo: 'BD301',
        nombre: 'Base de Datos II',
        carrera: 'Sistemas Informaticos',
        anio: 3,
        color: MateriaColors.baseDatos,
      ),
      Materia(
        id: 'emprendimiento',
        codigo: 'EMP301',
        nombre: 'Emprendimiento Productive',
        carrera: 'Sistemas Informaticos',
        anio: 3,
        color: MateriaColors.ingles,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Historial de Asistencia',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Selector de Año
          Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
              decoration: BoxDecoration(
                color: _getDropdownBackgroundColor(context),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: _getBorderColor(context)),
              ),
              child: DropdownButton<int>(
                value: _anioSeleccionado,
                isExpanded: true,
                underline: SizedBox(),
                dropdownColor: _getDropdownBackgroundColor(context),
                items: [
                  DropdownMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: Colors.yellow, size: 16),
                        SizedBox(width: 8),
                        Text(
                          '🟡 PRIMER AÑO',
                          style: TextStyle(color: _getTextColor(context)),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: Colors.green, size: 16),
                        SizedBox(width: 8),
                        Text(
                          '🟢 SEGUNDO AÑO',
                          style: TextStyle(color: _getTextColor(context)),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Text(
                          '🔵 TERCER AÑO',
                          style: TextStyle(color: _getTextColor(context)),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _anioSeleccionado = value!;
                    _filtrarMateriasPorAnio();
                  });
                },
              ),
            ),
          ),

          // Buscador
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: _getTextColor(context)),
              decoration: InputDecoration(
                hintText: 'Buscar materia...',
                hintStyle: TextStyle(color: _getSecondaryTextColor(context)),
                prefixIcon: Icon(
                  Icons.search,
                  color: _getSecondaryTextColor(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: _getSearchBackgroundColor(context),
              ),
            ),
          ),

          SizedBox(height: AppSpacing.medium),

          // Título del año seleccionado
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _anioSeleccionado == 1
                    ? '🟡 PRIMER AÑO'
                    : _anioSeleccionado == 2
                    ? '🟢 SEGUNDO AÑO'
                    : '🔵 TERCER AÑO',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _anioSeleccionado == 1
                      ? Colors.orange
                      : _anioSeleccionado == 2
                      ? Colors.green
                      : Colors.blue,
                ),
              ),
            ),
          ),

          SizedBox(height: AppSpacing.small),

          Expanded(
            child:
                _materiasFiltradas.isEmpty && _searchController.text.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: _getSecondaryTextColor(context),
                        ),
                        SizedBox(height: AppSpacing.medium),
                        Text(
                          'No se encontraron materias',
                          style: TextStyle(
                            color: _getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.count(
                    crossAxisCount: 2,
                    padding: EdgeInsets.all(AppSpacing.medium),
                    childAspectRatio: 1.0,
                    children: [
                      // Mostrar materias filtradas por año
                      ..._materiasFiltradas
                          .map(
                            (materia) => _buildMenuCard(
                              context,
                              materia.nombre,
                              Icons.school,
                              materia.color,
                              () =>
                                  _navigateToBimestres(context, materia.nombre),
                            ),
                          )
                          .toList(),

                      // Card especial para "Todas las Materias" (gestión)
                      if (_searchController.text.isEmpty)
                        _buildMenuCard(
                          context,
                          'Todas las Materias',
                          Icons.list_alt,
                          AppColors.primary,
                          () => _navigateToMaterias(context),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(AppSpacing.small),
      color: _getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.small),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              SizedBox(height: AppSpacing.small),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.small),
                child: Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToBimestres(BuildContext context, String materia) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BimestresScreen(materiaSeleccionada: materia),
      ),
    );
  }

  void _navigateToMaterias(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MateriasScreen()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
