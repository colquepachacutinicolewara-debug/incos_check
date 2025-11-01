import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../utils/constants.dart';
import '../../../models/materia_model.dart';
import '../../../models/bimestre_model.dart';

class AsistenciaEstudiante {
  AsistenciaEstudiante({
    required this.item,
    required this.nombre,
    this.febM = '',
    this.febJ = '',
    this.febV = '',
    this.marL = '',
    this.marM = '',
    this.marMi = '',
    this.marJ = '',
    this.marV = '',
    this.abrL = '',
    this.abrM = '',
    this.abrMi = '',
    this.abrJ = '',
    this.abrV = '',
  });

  final int item;
  final String nombre;
  String febM;
  String febJ;
  String febV;
  String marL;
  String marM;
  String marMi;
  String marJ;
  String marV;
  String abrL;
  String abrM;
  String abrMi;
  String abrJ;
  String abrV;

  int get totalAsistencias {
    int total = 0;
    List<String> asistencias = [
      febM,
      febJ,
      febV,
      marL,
      marM,
      marMi,
      marJ,
      marV,
      abrL,
      abrM,
      abrMi,
      abrJ,
      abrV,
    ];
    for (String asistencia in asistencias) {
      if (asistencia.trim().isNotEmpty && asistencia.toUpperCase() == 'P') {
        total++;
      }
    }
    return total;
  }

  String get totalDisplay => '$totalAsistencias/13';
}

class HistorialAsistenciaScreen extends StatefulWidget {
  const HistorialAsistenciaScreen({super.key});

  @override
  State<HistorialAsistenciaScreen> createState() =>
      _HistorialAsistenciaScreenState();
}

class _HistorialAsistenciaScreenState extends State<HistorialAsistenciaScreen> {
  // Listas de datos
  final List<Materia> _materias = [];
  final List<PeriodoAcademico> _bimestres = [];
  final List<AsistenciaEstudiante> _estudiantes = [];

  // Estados de navegación
  bool _mostrarMaterias = true;
  bool _mostrarBimestres = false;
  bool _mostrarHistorial = false;

  // Selecciones
  Materia? _materiaSeleccionada;
  PeriodoAcademico? _bimestreSeleccionado;

  // Controladores para el historial
  final List<String> fechas = [
    'FEB-M',
    'FEB-J',
    'FEB-V',
    'MAR-L',
    'MAR-M',
    'MAR-M',
    'MAR-J',
    'MAR-V',
    'ABR-L',
    'ABR-M',
    'ABR-M',
    'ABR-J',
    'ABR-V',
  ];
  final TextEditingController _searchController = TextEditingController();
  List<AsistenciaEstudiante> _filteredEstudiantes = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosEjemplo();
    _searchController.addListener(_filtrarEstudiantes);
  }

  void _cargarDatosEjemplo() {
    // Cargar materias de ejemplo
    _materias.addAll([
      Materia(
        id: 'bd2',
        codigo: 'BD2',
        nombre: 'Base de Datos II',
        carrera: 'Sistemas Informáticos',
        color: MateriaColors.baseDatos,
      ),
      Materia(
        id: 'prog3',
        codigo: 'PROG3',
        nombre: 'Programación III',
        carrera: 'Sistemas Informáticos',
        color: MateriaColors.programacion,
      ),
      Materia(
        id: 'taller',
        codigo: 'TALLER',
        nombre: 'Taller de Grado',
        carrera: 'Sistemas Informáticos',
        color: MateriaColors.ingles,
      ),
      Materia(
        id: 'redes2',
        codigo: 'RED2',
        nombre: 'Redes II',
        carrera: 'Sistemas Informáticos',
        color: MateriaColors.redes,
      ),
    ]);

    // Cargar bimestres de ejemplo
    _bimestres.addAll([
      PeriodoAcademico(
        id: 'bim1',
        nombre: 'Primer Bimestre',
        tipo: 'Bimestral',
        numero: 1,
        fechaInicio: DateTime(2024, 2, 1),
        fechaFin: DateTime(2024, 3, 31),
        estado: 'Finalizado',
        fechasClases: ['07/05', '08/05', '14/05', '15/05', '21/05', '22/05'],
        descripcion: 'Primer período académico 2024',
        fechaCreacion: DateTime(2024, 1, 15),
      ),
      PeriodoAcademico(
        id: 'bim2',
        nombre: 'Segundo Bimestre',
        tipo: 'Bimestral',
        numero: 2,
        fechaInicio: DateTime(2024, 4, 1),
        fechaFin: DateTime(2024, 5, 31),
        estado: 'En Curso',
        fechasClases: ['04/06', '05/06', '11/06', '12/06', '18/06', '19/06'],
        descripcion: 'Segundo período académico 2024',
        fechaCreacion: DateTime(2024, 3, 15),
      ),
      PeriodoAcademico(
        id: 'bim3',
        nombre: 'Tercer Bimestre',
        tipo: 'Bimestral',
        numero: 3,
        fechaInicio: DateTime(2024, 6, 1),
        fechaFin: DateTime(2024, 7, 31),
        estado: 'Planificado',
        fechasClases: [],
        descripcion: 'Tercer período académico 2024',
        fechaCreacion: DateTime(2024, 5, 15),
      ),
      PeriodoAcademico(
        id: 'bim4',
        nombre: 'Cuarto Bimestre',
        tipo: 'Bimestral',
        numero: 4,
        fechaInicio: DateTime(2024, 8, 1),
        fechaFin: DateTime(2024, 9, 30),
        estado: 'Planificado',
        fechasClases: [],
        descripcion: 'Cuarto período académico 2024',
        fechaCreacion: DateTime(2024, 7, 15),
      ),
    ]);

    // Cargar estudiantes de ejemplo (igual que tu código original)
    _cargarEstudiantesEjemplo();
  }

  void _cargarEstudiantesEjemplo() {
    for (int i = 1; i <= 60; i++) {
      _estudiantes.add(
        AsistenciaEstudiante(
          item: i,
          nombre: 'Estudiante ${i.toString().padLeft(2, '0')}',
        ),
      );
    }

    // Agregar algunos datos de ejemplo (igual que tu código)
    _estudiantes[0].febM = 'P';
    _estudiantes[0].febJ = 'P';
    _estudiantes[0].marL = 'P';
    _estudiantes[0].marM = 'F';

    _estudiantes[1].febM = 'P';
    _estudiantes[1].marL = 'P';
    _estudiantes[1].abrL = 'P';

    _estudiantes[2].febV = 'J';
    _estudiantes[2].marJ = 'P';

    _filteredEstudiantes = _estudiantes;
  }

  void _filtrarEstudiantes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredEstudiantes = _estudiantes;
      } else {
        _filteredEstudiantes = _estudiantes.where((estudiante) {
          return estudiante.nombre.toLowerCase().contains(query) ||
              estudiante.item.toString().contains(query);
        }).toList();
      }
    });
  }

  // Navegación entre pantallas
  void _seleccionarMateria(Materia materia) {
    setState(() {
      _materiaSeleccionada = materia;
      _mostrarMaterias = false;
      _mostrarBimestres = true;
      _mostrarHistorial = false;
    });
  }

  void _seleccionarBimestre(PeriodoAcademico bimestre) {
    setState(() {
      _bimestreSeleccionado = bimestre;
      _mostrarMaterias = false;
      _mostrarBimestres = false;
      _mostrarHistorial = true;
    });
  }

  void _volverAMaterias() {
    setState(() {
      _materiaSeleccionada = null;
      _mostrarMaterias = true;
      _mostrarBimestres = false;
      _mostrarHistorial = false;
    });
  }

  void _volverABimestres() {
    setState(() {
      _bimestreSeleccionado = null;
      _mostrarMaterias = false;
      _mostrarBimestres = true;
      _mostrarHistorial = false;
    });
  }

  // Método de exportación mejorado con formato INCOS
  Future<void> _exportarACSV() async {
    try {
      List<List<dynamic>> csvData = [];

      // Encabezado institucional (formato INCOS)
      csvData.add(['INSTITUTO TÉCNICO COMERCIAL "INCOS - EL ALTO"']);
      csvData.add([_materiaSeleccionada?.nombreCompleto ?? 'MATERIA']);
      csvData.add([
        'CARRERA: ${_materiaSeleccionada?.carrera ?? "Sistemas Informáticos"}',
      ]);
      csvData.add([
        'TURNO: Noche (${_bimestreSeleccionado?.nombre ?? "Bimestre"})',
      ]);
      csvData.add(['CURSO: Tercero "B"']);
      csvData.add([]);

      // Encabezados de la tabla
      List<dynamic> encabezados = ['NRO', 'ESTUDIANTES'];
      encabezados.addAll(fechas);
      encabezados.add('TOTAL');
      csvData.add(encabezados);

      // Datos de estudiantes
      for (var i = 0; i < _filteredEstudiantes.length; i++) {
        var estudiante = _filteredEstudiantes[i];
        List<dynamic> fila = [(i + 1).toString(), estudiante.nombre];

        // Agregar asistencias por fecha
        List<String> asistencias = [
          estudiante.febM,
          estudiante.febJ,
          estudiante.febV,
          estudiante.marL,
          estudiante.marM,
          estudiante.marMi,
          estudiante.marJ,
          estudiante.marV,
          estudiante.abrL,
          estudiante.abrM,
          estudiante.abrMi,
          estudiante.abrJ,
          estudiante.abrV,
        ];

        for (String asistencia in asistencias) {
          String simbolo = asistencia == 'P'
              ? '●'
              : asistencia == 'F'
              ? '-'
              : asistencia == 'J'
              ? 'J'
              : '';
          fila.add(simbolo);
        }

        // Agregar total
        fila.add(estudiante.totalDisplay);

        csvData.add(fila);
      }

      String csv = const ListToCsvConverter().convert(csvData);

      final Directory directory = await getApplicationDocumentsDirectory();
      final String nombreArchivo =
          'asistencia_${_materiaSeleccionada?.codigo ?? "general"}_${_bimestreSeleccionado?.nombre.replaceAll(' ', '_') ?? "bimestre"}.csv';
      final String path = '${directory.path}/$nombreArchivo';
      final File file = File(path);
      await file.writeAsString(csv, flush: true);

      // Abrir el archivo
      await OpenFile.open(path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Archivo exportado: $nombreArchivo'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al exportar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // MANTENGO TODOS TUS MÉTODOS ORIGINALES DE EDICIÓN
  void _editarAsistencia(AsistenciaEstudiante estudiante, String fecha) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar asistencia - $fecha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Estudiante: ${estudiante.nombre}'),
            const SizedBox(height: 20),
            const Text(
              'Seleccione el estado:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBotonAsistencia(
                  'P',
                  'Presente',
                  Colors.green,
                  estudiante,
                  fecha,
                ),
                _buildBotonAsistencia(
                  'F',
                  'Falta',
                  Colors.red,
                  estudiante,
                  fecha,
                ),
                _buildBotonAsistencia(
                  'J',
                  'Justificado',
                  Colors.orange,
                  estudiante,
                  fecha,
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _actualizarAsistencia(estudiante, fecha, '');
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                side: const BorderSide(color: Colors.grey),
              ),
              child: const Text('Limpiar'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonAsistencia(
    String valor,
    String label,
    Color color,
    AsistenciaEstudiante estudiante,
    String fecha,
  ) {
    return GestureDetector(
      onTap: () {
        _actualizarAsistencia(estudiante, fecha, valor);
        Navigator.pop(context);
      },
      child: Column(
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _actualizarAsistencia(
    AsistenciaEstudiante estudiante,
    String fecha,
    String valor,
  ) {
    setState(() {
      switch (fecha) {
        case 'FEB-M':
          estudiante.febM = valor;
          break;
        case 'FEB-J':
          estudiante.febJ = valor;
          break;
        case 'FEB-V':
          estudiante.febV = valor;
          break;
        case 'MAR-L':
          estudiante.marL = valor;
          break;
        case 'MAR-M':
          estudiante.marM = valor;
          break;
        case 'MAR-M':
          estudiante.marMi = valor;
          break;
        case 'MAR-J':
          estudiante.marJ = valor;
          break;
        case 'MAR-V':
          estudiante.marV = valor;
          break;
        case 'ABR-L':
          estudiante.abrL = valor;
          break;
        case 'ABR-M':
          estudiante.abrM = valor;
          break;
        case 'ABR-M':
          estudiante.abrMi = valor;
          break;
        case 'ABR-J':
          estudiante.abrJ = valor;
          break;
        case 'ABR-V':
          estudiante.abrV = valor;
          break;
      }
    });
  }

  Color _getColorAsistencia(String valor) {
    switch (valor.toUpperCase()) {
      case 'P':
        return Colors.green;
      case 'F':
        return Colors.red;
      case 'J':
        return Colors.orange;
      default:
        return Colors.grey.shade200;
    }
  }

  String _getTooltipAsistencia(String valor) {
    switch (valor.toUpperCase()) {
      case 'P':
        return 'Presente';
      case 'F':
        return 'Falta';
      case 'J':
        return 'Justificado';
      default:
        return 'Sin registrar';
    }
  }

  Color _getColorTotal(int total) {
    double porcentaje = total / 13;
    if (porcentaje >= 0.9) return Colors.green;
    if (porcentaje >= 0.7) return Colors.orange;
    return Colors.red;
  }

  Widget _buildItemLeyenda(Color color, String texto) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildCeldaAsistencia(
    String valor,
    AsistenciaEstudiante estudiante,
    String fecha,
  ) {
    return Tooltip(
      message: '${_getTooltipAsistencia(valor)} - $fecha\nClic para editar',
      child: GestureDetector(
        onTap: () => _editarAsistencia(estudiante, fecha),
        child: Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _getColorAsistencia(valor),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade400, width: 1),
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
                color: valor.isEmpty ? Colors.grey.shade600 : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildContenido());
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _buildAppBarTitle(),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      leading: _buildBackButton(),
      actions: _buildAppBarActions(),
    );
  }

  Widget _buildAppBarTitle() {
    if (_mostrarMaterias) {
      return const Text('Seleccionar Materia');
    } else if (_mostrarBimestres) {
      return Text('Bimestres - ${_materiaSeleccionada?.nombre ?? ""}');
    } else {
      return Text('Asistencia - ${_materiaSeleccionada?.nombre ?? ""}');
    }
  }

  Widget? _buildBackButton() {
    if (_mostrarBimestres) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _volverAMaterias,
      );
    } else if (_mostrarHistorial) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _volverABimestres,
      );
    }
    return null;
  }

  List<Widget> _buildAppBarActions() {
    if (_mostrarHistorial) {
      return [
        IconButton(
          icon: const Icon(Icons.file_download),
          onPressed: _exportarACSV,
          tooltip: 'Exportar a CSV',
        ),
      ];
    }
    return [];
  }

  Widget _buildContenido() {
    if (_mostrarMaterias) {
      return _buildListaMaterias();
    } else if (_mostrarBimestres) {
      return _buildListaBimestres();
    } else {
      return _buildHistorialOriginal();
    }
  }

  // PANTALLA 1: LISTA DE MATERIAS CON CARDS (igual a tu patrón)
  Widget _buildListaMaterias() {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(AppSpacing.medium),
      childAspectRatio: 1.0,
      children: _materias.map((materia) {
        return _buildMenuCard(
          materia.nombre,
          Icons.school,
          materia.color,
          () => _seleccionarMateria(materia),
          subtitulo: materia.carrera,
        );
      }).toList(),
    );
  }

  // PANTALLA 2: LISTA DE BIMESTRES CON CARDS
  Widget _buildListaBimestres() {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(AppSpacing.medium),
      childAspectRatio: 1.2,
      children: _bimestres.map((bimestre) {
        return _buildMenuCard(
          bimestre.nombre,
          _getIconPorEstado(bimestre.estado),
          bimestre.colorEstado,
          () => _seleccionarBimestre(bimestre),
          subtitulo: '${bimestre.totalClases} clases',
        );
      }).toList(),
    );
  }

  IconData _getIconPorEstado(String estado) {
    switch (estado) {
      case 'En Curso':
        return Icons.play_arrow;
      case 'Finalizado':
        return Icons.check_circle;
      case 'Planificado':
        return Icons.schedule;
      default:
        return Icons.calendar_today;
    }
  }

  // CARD CON TU PATRÓN EXACTO
  Widget _buildMenuCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    String? subtitulo,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(AppSpacing.small),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(height: AppSpacing.small),
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitulo != null) ...[
              SizedBox(height: AppSpacing.small / 2),
              Text(
                subtitulo,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // PANTALLA 3: TU HISTORIAL ORIGINAL (EXACTO)
  Widget _buildHistorialOriginal() {
    return Column(
      children: [
        // Barra de búsqueda y controles (igual a tu código)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar por número o nombre',
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
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
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      'Total: ${_filteredEstudiantes.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Leyenda de colores
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildItemLeyenda(Colors.green, 'Presente (P)'),
                  const SizedBox(width: 16),
                  _buildItemLeyenda(Colors.red, 'Falta (F)'),
                  const SizedBox(width: 16),
                  _buildItemLeyenda(Colors.orange, 'Justificado (J)'),
                ],
              ),
            ],
          ),
        ),

        // Tabla de asistencias (igual a tu código)
        Expanded(
          child: _filteredEstudiantes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No se encontraron estudiantes',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.orange.shade50,
                      ),
                      columnSpacing: 8,
                      dataRowMinHeight: 55,
                      dataRowMaxHeight: 55,
                      horizontalMargin: 8,
                      columns: [
                        DataColumn(
                          label: const Text(
                            'ÍTEM',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          numeric: true,
                        ),
                        const DataColumn(
                          label: Text(
                            'ESTUDIANTE',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...fechas
                            .map(
                              (fecha) => DataColumn(
                                label: SizedBox(
                                  width: 48,
                                  child: Text(
                                    fecha,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        DataColumn(
                          label: const Text(
                            'TOTAL',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          numeric: true,
                        ),
                      ],
                      rows: _filteredEstudiantes.map((estudiante) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Center(
                                child: Text(
                                  estudiante.item.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 120,
                                child: Text(
                                  estudiante.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            // Celdas de asistencia (igual a tu código)
                            DataCell(
                              _buildCeldaAsistencia(
                                estudiante.febM,
                                estudiante,
                                'FEB-M',
                              ),
                            ),
                            DataCell(
                              _buildCeldaAsistencia(
                                estudiante.febJ,
                                estudiante,
                                'FEB-J',
                              ),
                            ),
                            DataCell(
                              _buildCeldaAsistencia(
                                estudiante.febV,
                                estudiante,
                                'FEB-V',
                              ),
                            ),
                            DataCell(
                              _buildCeldaAsistencia(
                                estudiante.marL,
                                estudiante,
                                'MAR-L',
                              ),
                            ),
                            DataCell(
                              _buildCeldaAsistencia(
                                estudiante.marM,
                                estudiante,
                                'MAR-M',
                              ),
                            ),
                            DataCell(
                              _buildCeldaAsistencia(
                                estudiante.marMi,
                                estudiante,
                                'MAR-M',
                              ),
                            ),
                            DataCell(
                              _buildCeldaAsistencia(
                                estudiante.marJ,
                                estudiante,
                                'MAR-J',
                              ),
                            ),
                            DataCell(
                              _buildCeldaAsistencia(
                                estudiante.marV,
                                estudiante,
                                'MAR-V',
                              ),
                            ),
                            DataCell(
                              _buildCeldaAsistencia(
                                estudiante.abrL,
                                estudiante,
                                'ABR-L',
                              ),
                            ),
                            DataCell(
                              _buildCeldaAsistencia(
                                estudiante.abrM,
                                estudiante,
                                'ABR-M',
                              ),
                            ),
                            DataCell(
                              _buildCeldaAsistencia(
                                estudiante.abrMi,
                                estudiante,
                                'ABR-M',
                              ),
                            ),
                            DataCell(
                              _buildCeldaAsistencia(
                                estudiante.abrJ,
                                estudiante,
                                'ABR-J',
                              ),
                            ),
                            DataCell(
                              _buildCeldaAsistencia(
                                estudiante.abrV,
                                estudiante,
                                'ABR-V',
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getColorTotal(
                                      estudiante.totalAsistencias,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
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
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
