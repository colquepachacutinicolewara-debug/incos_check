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

  // Controladores para el formulario
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _carreraController = TextEditingController();

  // Variables para el formulario
  int _anioSeleccionadoForm = 1;
  Color _colorSeleccionado = MateriaColors.programacion;
  String _materiaEditandoId = '';

  // Efecto de burbuja
  bool _mostrarBurbuja = false;
  String _mensajeBurbuja = '';
  Color _colorBurbuja = Colors.green;

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

  // Getters para el formulario
  TextEditingController get codigoController => _codigoController;
  TextEditingController get nombreController => _nombreController;
  TextEditingController get carreraController => _carreraController;
  int get anioSeleccionadoForm => _anioSeleccionadoForm;
  Color get colorSeleccionado => _colorSeleccionado;
  bool get mostrarBurbuja => _mostrarBurbuja;
  String get mensajeBurbuja => _mensajeBurbuja;
  Color get colorBurbuja => _colorBurbuja;
  String get materiaEditandoId => _materiaEditandoId;

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

  // Setters para el formulario
  void setAnioSeleccionadoForm(int value) {
    _anioSeleccionadoForm = value;
    notifyListeners();
  }

  void setColorSeleccionado(Color color) {
    _colorSeleccionado = color;
    notifyListeners();
  }

  void setMateriaEditandoId(String id) {
    _materiaEditandoId = id;
    notifyListeners();
  }

  // Setters para historial
  void setAnioSeleccionado(int value) {
    _anioSeleccionado = value;
    _filtrarMateriasPorAnio();
  }

  // ========== OPERACIONES CRUD ==========

  // AGREGAR materia
  void agregarMateria() {
    if (_codigoController.text.isEmpty || _nombreController.text.isEmpty) {
      _mostrarMensajeBurbuja('Complete todos los campos', Colors.red);
      return;
    }

    // Verificar si el código ya existe
    if (_materias.any(
      (materia) =>
          materia.codigo == _codigoController.text &&
          materia.id != _materiaEditandoId,
    )) {
      _mostrarMensajeBurbuja('El código ya existe', Colors.red);
      return;
    }

    final nuevaMateria = Materia(
      id: _materiaEditandoId.isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : _materiaEditandoId,
      codigo: _codigoController.text,
      nombre: _nombreController.text,
      carrera: _carreraController.text.isEmpty
          ? 'Sistemas Informáticos'
          : _carreraController.text,
      anio: _anioSeleccionadoForm,
      color: _colorSeleccionado,
      activo: true,
    );

    if (_materiaEditandoId.isEmpty) {
      _materias.add(nuevaMateria);
      _mostrarMensajeBurbuja('Materia agregada exitosamente', Colors.green);
    } else {
      final index = _materias.indexWhere(
        (materia) => materia.id == _materiaEditandoId,
      );
      if (index != -1) {
        _materias[index] = nuevaMateria;
        _mostrarMensajeBurbuja('Materia actualizada exitosamente', Colors.blue);
      }
    }

    _limpiarFormulario();
    notifyListeners();
  }

  // MODIFICAR materia - Cargar datos en el formulario
  void cargarMateriaParaEditar(Materia materia) {
    _materiaEditandoId = materia.id;
    _codigoController.text = materia.codigo;
    _nombreController.text = materia.nombre;
    _carreraController.text = materia.carrera;
    _anioSeleccionadoForm = materia.anio;
    _colorSeleccionado = materia.color;
    notifyListeners();
  }

  // ELIMINAR materia
  void eliminarMateria(String id) {
    _materias.removeWhere((materia) => materia.id == id);
    _mostrarMensajeBurbuja('Materia eliminada exitosamente', Colors.orange);
    notifyListeners();
  }

  // DESACTIVAR materia
  void desactivarMateria(String id) {
    final index = _materias.indexWhere((materia) => materia.id == id);
    if (index != -1) {
      _materias[index] = _materias[index].copyWith(activo: false);
      _mostrarMensajeBurbuja('Materia desactivada', Colors.amber);
      notifyListeners();
    }
  }

  // ACTIVAR materia
  void activarMateria(String id) {
    final index = _materias.indexWhere((materia) => materia.id == id);
    if (index != -1) {
      _materias[index] = _materias[index].copyWith(activo: true);
      _mostrarMensajeBurbuja('Materia activada', Colors.green);
      notifyListeners();
    }
  }

  // Limpiar formulario
  void _limpiarFormulario() {
    _materiaEditandoId = '';
    _codigoController.clear();
    _nombreController.clear();
    _carreraController.clear();
    _anioSeleccionadoForm = 1;
    _colorSeleccionado = MateriaColors.programacion;
    notifyListeners();
  }

  // Mostrar mensaje en burbuja
  void _mostrarMensajeBurbuja(String mensaje, Color color) {
    _mensajeBurbuja = mensaje;
    _colorBurbuja = color;
    _mostrarBurbuja = true;
    notifyListeners();

    // Ocultar después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      _mostrarBurbuja = false;
      notifyListeners();
    });
  }

  // Ocultar burbuja manualmente
  void ocultarBurbuja() {
    _mostrarBurbuja = false;
    notifyListeners();
  }

  // ========== MÉTODOS EXISTENTES ==========

  void _cargarMateriasSistemas() {
    // PRIMER AÑO - Sistemas Informáticos
    _materias.addAll([
      Materia(
        id: 'hardware',
        codigo: 'HARD101',
        nombre: 'Hardware de Computadoras',
        carrera: 'Sistemas Informáticos',
        anio: 1,
        color: MateriaColors.redes, // Usando el color correcto de tus constants
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
    if (_anioFiltro != 0) filtros.add('$_anioFiltro° Año');
    if (_carreraFiltro != 'Todas') filtros.add(_carreraFiltro);
    if (_paraleloFiltro != 'Todos') filtros.add('Paralelo $_paraleloFiltro');
    if (_turnoFiltro != 'Todos') filtros.add('Turno $_turnoFiltro');
    return 'Filtros: ${filtros.join(' • ')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _codigoController.dispose();
    _nombreController.dispose();
    _carreraController.dispose();
    super.dispose();
  }
}
