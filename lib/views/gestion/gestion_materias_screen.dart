import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../models/materia_model.dart';

class GestionMateriasScreen extends StatefulWidget {
  const GestionMateriasScreen({super.key});

  @override
  State<GestionMateriasScreen> createState() => _GestionMateriasScreenState();
}

class _GestionMateriasScreenState extends State<GestionMateriasScreen> {
  final List<Materia> _materias = [];
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();

  Materia? _materiaEditando;
  Color _colorSeleccionado = MateriaColors.matematica;
  int _anioSeleccionado = 1;
  String _carreraSeleccionada = 'Sistemas Informaticos';

  @override
  void initState() {
    super.initState();
    _cargarMateriasSistemas();
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
        nombre: 'Emprendimiento Productivo',
        carrera: 'Sistemas Informaticos',
        anio: 3,
        color: MateriaColors.ingles,
      ),
    ]);
  }

  void _mostrarDialogoMateria([Materia? materia]) {
    _materiaEditando = materia;

    if (materia != null) {
      _codigoController.text = materia.codigo;
      _nombreController.text = materia.nombre;
      _colorSeleccionado = materia.color;
      _anioSeleccionado = materia.anio;
      _carreraSeleccionada = materia.carrera;
    } else {
      _codigoController.clear();
      _nombreController.clear();
      _colorSeleccionado = MateriaColors.matematica;
      _anioSeleccionado = 1;
      _carreraSeleccionada = 'Sistemas Informaticos';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(materia == null ? 'Nueva Materia' : 'Editar Materia'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _codigoController,
                    decoration: const InputDecoration(
                      labelText: 'Codigo de Materia',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Ingrese el codigo' : null,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de Materia',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Ingrese el nombre' : null,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  DropdownButtonFormField<String>(
                    value: _carreraSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Carrera',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                          'Sistemas Informaticos',
                          'Redes y Telecomunicaciones',
                        ].map((carrera) {
                          return DropdownMenuItem(
                            value: carrera,
                            child: Text(carrera),
                          );
                        }).toList(),
                    onChanged: (value) =>
                        setState(() => _carreraSeleccionada = value!),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  DropdownButtonFormField<int>(
                    value: _anioSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Anio',
                      border: OutlineInputBorder(),
                    ),
                    items: [1, 2, 3].map((anio) {
                      return DropdownMenuItem(
                        value: anio,
                        child: Text('$anio° Anio'),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _anioSeleccionado = value!),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  const Text('Color identificador:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MateriaColors.colors.map((color) {
                      return _buildCirculoColor(color, setState);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _guardarMateria,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCirculoColor(Color color, StateSetter setState) {
    return GestureDetector(
      onTap: () => setState(() => _colorSeleccionado = color),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: _colorSeleccionado == color
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
      ),
    );
  }

  void _guardarMateria() {
    if (_formKey.currentState!.validate()) {
      final nuevaMateria = Materia(
        id:
            _materiaEditando?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        codigo: _codigoController.text,
        nombre: _nombreController.text,
        carrera: _carreraSeleccionada,
        anio: _anioSeleccionado,
        color: _colorSeleccionado,
      );

      setState(() {
        if (_materiaEditando != null) {
          final index = _materias.indexWhere(
            (m) => m.id == _materiaEditando!.id,
          );
          if (index != -1) {
            _materias[index] = nuevaMateria;
          }
        } else {
          _materias.add(nuevaMateria);
        }
      });

      Navigator.pop(context);
      _limpiarFormulario();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _materiaEditando != null
                ? '✅ Materia actualizada'
                : '✅ Materia creada',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _eliminarMateria(Materia materia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Materia'),
        content: Text(
          '¿Estas seguro de eliminar la materia "${materia.nombreCompleto}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _materias.removeWhere((m) => m.id == materia.id);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Materia "${materia.codigo}" eliminada'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _limpiarFormulario() {
    _codigoController.clear();
    _nombreController.clear();
    _materiaEditando = null;
    _colorSeleccionado = MateriaColors.matematica;
    _anioSeleccionado = 1;
    _carreraSeleccionada = 'Sistemas Informaticos';
  }

  // Filtros
  int _anioFiltro = 0; // 0 = Todos
  String _carreraFiltro = 'Todas';

  List<Materia> get _materiasFiltradas {
    return _materias.where((materia) {
      bool anioOk = _anioFiltro == 0 || materia.anio == _anioFiltro;
      bool carreraOk =
          _carreraFiltro == 'Todas' || materia.carrera == _carreraFiltro;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de Materias'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarDialogoMateria(),
            tooltip: 'Nueva Materia',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                const Text(
                  'Filtrar:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: _anioFiltro,
                  items: [
                    const DropdownMenuItem(
                      value: 0,
                      child: Text('Todos los anios'),
                    ),
                    const DropdownMenuItem(value: 1, child: Text('1° Anio')),
                    const DropdownMenuItem(value: 2, child: Text('2° Anio')),
                    const DropdownMenuItem(value: 3, child: Text('3° Anio')),
                  ],
                  onChanged: (value) => setState(() => _anioFiltro = value!),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _carreraFiltro,
                  items: [
                    const DropdownMenuItem(
                      value: 'Todas',
                      child: Text('Todas las carreras'),
                    ),
                    const DropdownMenuItem(
                      value: 'Sistemas Informaticos',
                      child: Text('Sistemas'),
                    ),
                    const DropdownMenuItem(
                      value: 'Redes y Telecomunicaciones',
                      child: Text('Redes'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _carreraFiltro = value!),
                ),
              ],
            ),
          ),
          Expanded(
            child: _materiasFiltradas.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: AppSpacing.medium),
                        Text(
                          'No hay materias registradas',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _materiasFiltradas.length,
                    itemBuilder: (context, index) {
                      final materia = _materiasFiltradas[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: materia.color,
                            child: Text(
                              materia.codigo.substring(0, 2),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            materia.nombreCompleto,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(materia.carrera),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getColorAnio(
                                        materia.anio,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getColorAnio(materia.anio),
                                      ),
                                    ),
                                    child: Text(
                                      materia.anioDisplay,
                                      style: TextStyle(
                                        color: _getColorAnio(materia.anio),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () =>
                                    _mostrarDialogoMateria(materia),
                                tooltip: 'Editar materia',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _eliminarMateria(materia),
                                tooltip: 'Eliminar materia',
                                color: AppColors.error,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    super.dispose();
  }
}
