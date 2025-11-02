// viewmodels/materia_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../models/materia_model.dart';

class MateriaViewModel extends ChangeNotifier {
  final List<Materia> _materias = [];
  final List<Materia> _materiasFiltradas = [];
  final TextEditingController _searchController = TextEditingController();

  // Filtros para gestión de cursos
  int _anioFiltro = 0;
  String _carreraFiltro = 'Todas';
  String _paraleloFiltro = 'Todos';
  String _turnoFiltro = 'Todos';

  // Filtros para historial
  int _anioSeleccionado = 3;

  // Opciones para filtros
  final List<String> _paralelos = ['Todos', 'A', 'B', 'C', 'D'];
  final List<String> _turnos = ['Todos', 'Mañana', 'Tarde', 'Noche'];

  // Getters
  List<Materia> get materias => _materias;
  List<Materia> get materiasFiltradas => _materiasFiltradas;
  List<Materia> get materiasFiltradasGestion => _getMateriasFiltradasGestion();
  int get anioFiltro => _anioFiltro;
  String get carreraFiltro => _carreraFiltro;
  String get paraleloFiltro => _paraleloFiltro;
  String get turnoFiltro => _turnoFiltro;
  int get anioSeleccionado => _anioSeleccionado;
  TextEditingController get searchController => _searchController;
  List<String> get paralelos => _paralelos;
  List<String> get turnos => _turnos;

  MateriaViewModel() {
    _cargarMateriasSistemas();
    _searchController.addListener(_filtrarMateriasHistorial);
  }

  // Setters para gestión de cursos
  void setAnioFiltro(int value) {
    _anioFiltro = value;
    notifyListeners();
  }

  void setCarreraFiltro(String value) {
    _carreraFiltro = value;
    notifyListeners();
  }

  void setParaleloFiltro(String value) {
    _paraleloFiltro = value;
    notifyListeners();
  }

  void setTurnoFiltro(String value) {
    _turnoFiltro = value;
    notifyListeners();
  }

  // Setters para historial
  void setAnioSeleccionado(int value) {
    _anioSeleccionado = value;
    _filtrarMateriasPorAnio();
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

  // Filtrado para gestión de cursos
  List<Materia> _getMateriasFiltradasGestion() {
    return _materias.where((materia) {
      bool anioOk = _anioFiltro == 0 || materia.anio == _anioFiltro;
      bool carreraOk =
          _carreraFiltro == 'Todas' || materia.carrera == _carreraFiltro;
      return anioOk && carreraOk;
    }).toList();
  }

  // Filtrado para historial
  void _filtrarMateriasHistorial() {
    final query = _searchController.text.toLowerCase();
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
    notifyListeners();
  }

  void _filtrarMateriasPorAnio() {
    _filtrarMateriasHistorial();
  }

  // Métodos de utilidad para colores
  Color getColorAnio(int anio) {
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

  Color getColorParalelo(String paralelo) {
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

  IconData obtenerIconoTurno(String turno) {
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

  IconData obtenerIconoMateria(String nombreMateria) {
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

  String obtenerTextoFiltros() {
    List<String> filtros = [];
    if (_anioFiltro != 0) filtros.add('${_anioFiltro}° Año');
    if (_carreraFiltro != 'Todas') filtros.add(_carreraFiltro);
    if (_paraleloFiltro != 'Todos') filtros.add('Paralelo $_paraleloFiltro');
    if (_turnoFiltro != 'Todos') filtros.add('Turno $_turnoFiltro');
    return 'Filtros: ${filtros.join(' • ')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
