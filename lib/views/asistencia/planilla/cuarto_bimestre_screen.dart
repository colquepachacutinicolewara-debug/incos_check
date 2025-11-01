import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../utils/constants.dart';
import '../../../models/bimestre_model.dart';

class AsistenciaEstudiante {
  AsistenciaEstudiante({
    required this.item,
    required this.nombre,
    this.octL = '',
    this.octM = '',
    this.octMi = '',
    this.octJ = '',
    this.octV = '',
    this.novL = '',
    this.novM = '',
    this.novMi = '',
    this.novJ = '',
    this.novV = '',
    this.dicL = '',
    this.dicM = '',
    this.dicMi = '',
    this.dicJ = '',
    this.dicV = '',
  });

  final int item;
  final String nombre;
  String octL;
  String octM;
  String octMi;
  String octJ;
  String octV;
  String novL;
  String novM;
  String novMi;
  String novJ;
  String novV;
  String dicL;
  String dicM;
  String dicMi;
  String dicJ;
  String dicV;

  int get totalAsistencias {
    int total = 0;
    List<String> asistencias = [
      octL,
      octM,
      octMi,
      octJ,
      octV,
      novL,
      novM,
      novMi,
      novJ,
      novV,
      dicL,
      dicM,
      dicMi,
      dicJ,
      dicV,
    ];
    for (String asistencia in asistencias) {
      if (asistencia.trim().isNotEmpty && asistencia.toUpperCase() == 'P') {
        total++;
      }
    }
    return total;
  }

  String get totalDisplay => '$totalAsistencias/15';
}

class CuartoBimestreScreen extends StatefulWidget {
  const CuartoBimestreScreen({super.key});

  @override
  State<CuartoBimestreScreen> createState() => _CuartoBimestreScreenState();
}

class _CuartoBimestreScreenState extends State<CuartoBimestreScreen> {
  final PeriodoAcademico _bimestre = PeriodoAcademico(
    id: 'bim4',
    nombre: 'Cuarto Bimestre',
    tipo: 'Bimestral',
    numero: 4,
    fechaInicio: DateTime(2024, 10, 1),
    fechaFin: DateTime(2024, 12, 6),
    estado: 'En curso',
    fechasClases: [
      '01/10',
      '02/10',
      '03/10',
      '04/10',
      '07/10',
      '08/10',
      '09/10',
      '10/10',
      '11/10',
      '14/10',
      '15/10',
      '16/10',
      '17/10',
      '18/10',
      '21/10',
      '22/10',
      '23/10',
      '24/10',
      '25/10',
      '28/10',
      '29/10',
      '30/10',
      '31/10',
      '04/11',
      '05/11',
      '06/11',
      '07/11',
      '08/11',
      '11/11',
      '12/11',
      '13/11',
      '14/11',
      '15/11',
      '18/11',
      '19/11',
      '20/11',
      '21/11',
      '22/11',
      '25/11',
      '26/11',
      '27/11',
      '28/11',
      '29/11',
      '02/12',
      '03/12',
      '04/12',
      '05/12',
      '06/12',
    ],
    descripcion: 'Cuarto período académico 2024',
    fechaCreacion: DateTime(2024, 9, 20),
  );

  final List<AsistenciaEstudiante> _estudiantes = [];
  final List<String> fechas = [
    'OCT-L',
    'OCT-M',
    'OCT-MI',
    'OCT-J',
    'OCT-V',
    'NOV-L',
    'NOV-M',
    'NOV-MI',
    'NOV-J',
    'NOV-V',
    'DIC-L',
    'DIC-M',
    'DIC-MI',
    'DIC-J',
    'DIC-V',
  ];

  // Controladores para edición de fechas
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<AsistenciaEstudiante> _filteredEstudiantes = [];
  int? _estudianteSeleccionado;
  bool _mostrarEditorFechas = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosEjemplo();
    _filteredEstudiantes = _estudiantes;
    _searchController.addListener(_filtrarEstudiantes);
    _fechaInicioController.text = _formatDate(_bimestre.fechaInicio);
    _fechaFinController.text = _formatDate(_bimestre.fechaFin);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _cargarDatosEjemplo() {
    for (int i = 1; i <= 60; i++) {
      _estudiantes.add(
        AsistenciaEstudiante(
          item: i,
          nombre: 'Estudiante ${i.toString().padLeft(2, '0')}',
        ),
      );
    }
    _filteredEstudiantes = _estudiantes;
  }

  void _filtrarEstudiantes() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredEstudiantes = _estudiantes;
      } else {
        _filteredEstudiantes = _estudiantes.where((estudiante) {
          final nombreMatch = estudiante.nombre.toLowerCase().contains(query);
          final itemMatch = estudiante.item.toString() == query;
          final itemPartialMatch = estudiante.item.toString().contains(query);

          // Búsqueda más precisa: coincidencia exacta del número o búsqueda en el nombre
          return itemMatch ||
              nombreMatch ||
              (query.length > 1 && itemPartialMatch);
        }).toList();
      }
      // Limpiar selección al filtrar
      _estudianteSeleccionado = null;
    });
  }

  void _seleccionarEstudiante(int item) {
    setState(() {
      _estudianteSeleccionado = _estudianteSeleccionado == item ? null : item;
    });
  }

  void _editarFechasBimestre() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Fechas del Bimestre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _fechaInicioController,
              decoration: const InputDecoration(
                labelText: 'Fecha de inicio (DD/MM/AAAA)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fechaFinController,
              decoration: const InputDecoration(
                labelText: 'Fecha de fin (DD/MM/AAAA)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí puedes agregar la lógica para validar y guardar las fechas
              setState(() {
                // Actualizar el bimestre con las nuevas fechas
                // _bimestre.fechaInicio = ...;
                // _bimestre.fechaFin = ...;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fechas actualizadas correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportarACSV() async {
    try {
      List<List<dynamic>> csvData = [];

      // Encabezados
      csvData.add(['ÍTEM', 'ESTUDIANTE', ...fechas, 'TOTAL']);

      // Datos
      for (var estudiante in _filteredEstudiantes) {
        csvData.add([
          estudiante.item.toString().padLeft(2, '0'),
          estudiante.nombre,
          estudiante.octL,
          estudiante.octM,
          estudiante.octMi,
          estudiante.octJ,
          estudiante.octV,
          estudiante.novL,
          estudiante.novM,
          estudiante.novMi,
          estudiante.novJ,
          estudiante.novV,
          estudiante.dicL,
          estudiante.dicM,
          estudiante.dicMi,
          estudiante.dicJ,
          estudiante.dicV,
          estudiante.totalDisplay,
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);

      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/asistencia_cuarto_bimestre.csv';
      final File file = File(path);
      await file.writeAsString(csv, flush: true);

      await OpenFile.open(path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Archivo exportado: $path'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editarAsistencia(AsistenciaEstudiante estudiante, String fecha) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar asistencia - $fecha'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Estudiante: ${estudiante.nombre}'),
              const SizedBox(height: 20),
              const Text(
                'Seleccione el estado:',
                style: TextStyle(fontWeight: FontWeight.bold),
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
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
        case 'OCT-L':
          estudiante.octL = valor;
          break;
        case 'OCT-M':
          estudiante.octM = valor;
          break;
        case 'OCT-MI':
          estudiante.octMi = valor;
          break;
        case 'OCT-J':
          estudiante.octJ = valor;
          break;
        case 'OCT-V':
          estudiante.octV = valor;
          break;
        case 'NOV-L':
          estudiante.novL = valor;
          break;
        case 'NOV-M':
          estudiante.novM = valor;
          break;
        case 'NOV-MI':
          estudiante.novMi = valor;
          break;
        case 'NOV-J':
          estudiante.novJ = valor;
          break;
        case 'NOV-V':
          estudiante.novV = valor;
          break;
        case 'DIC-L':
          estudiante.dicL = valor;
          break;
        case 'DIC-M':
          estudiante.dicM = valor;
          break;
        case 'DIC-MI':
          estudiante.dicMi = valor;
          break;
        case 'DIC-J':
          estudiante.dicJ = valor;
          break;
        case 'DIC-V':
          estudiante.dicV = valor;
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
    double porcentaje = total / 15;
    if (porcentaje >= 0.9) return Colors.green;
    if (porcentaje >= 0.7) return Colors.orange;
    return Colors.red;
  }

  Widget _buildItemLeyenda(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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

  Color _getColorFila(int item) {
    if (_estudianteSeleccionado == item) {
      return Colors.yellow.withOpacity(0.3);
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuarto Bimestre'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _editarFechasBimestre,
            tooltip: 'Editar fechas',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportarACSV,
            tooltip: 'Exportar a CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          // Información del bimestre
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Row(
              children: [
                Container(width: 4, height: 40, color: _bimestre.colorEstado),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_bimestre.nombre, style: AppTextStyles.heading2),
                      Text(_bimestre.rangoFechas),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _bimestre.colorEstado.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _bimestre.colorEstado),
                  ),
                  child: Text(
                    _bimestre.estado,
                    style: TextStyle(
                      color: _bimestre.colorEstado,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barra de búsqueda y controles
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
                          labelText: 'Buscar por número exacto o nombre',
                          hintText: 'Ej: 05 o "Estudiante 05"',
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => _searchController.clear(),
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
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal.shade200),
                      ),
                      child: Text(
                        'Total: ${_filteredEstudiantes.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.teal,
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
                      _buildItemLeyenda(Colors.green, 'Presente (P)'),
                      const SizedBox(width: 16),
                      _buildItemLeyenda(Colors.red, 'Falta (F)'),
                      const SizedBox(width: 16),
                      _buildItemLeyenda(Colors.orange, 'Justificado (J)'),
                      const SizedBox(width: 16),
                      _buildItemLeyenda(Colors.yellow, 'Seleccionado'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (_estudianteSeleccionado != null)
                  Text(
                    'Estudiante seleccionado: ${_estudianteSeleccionado}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
              ],
            ),
          ),

          // Tabla de asistencias
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
                          (states) => Colors.teal.shade50,
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
                          final bool estaSeleccionado =
                              _estudianteSeleccionado == estudiante.item;

                          return DataRow(
                            color: MaterialStateProperty.resolveWith<Color?>((
                              Set<MaterialState> states,
                            ) {
                              return _getColorFila(estudiante.item);
                            }),
                            cells: [
                              DataCell(
                                GestureDetector(
                                  onTap: () =>
                                      _seleccionarEstudiante(estudiante.item),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: estaSeleccionado
                                            ? Colors.teal
                                            : null,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        estudiante.item.toString().padLeft(
                                          2,
                                          '0',
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: estaSeleccionado
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () =>
                                      _seleccionarEstudiante(estudiante.item),
                                  child: SizedBox(
                                    width: 120,
                                    child: Text(
                                      estudiante.nombre,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        backgroundColor: estaSeleccionado
                                            ? Colors.yellow
                                            : Colors.transparent,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              // Octubre
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.octL,
                                  estudiante,
                                  'OCT-L',
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.octM,
                                  estudiante,
                                  'OCT-M',
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.octMi,
                                  estudiante,
                                  'OCT-MI',
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.octJ,
                                  estudiante,
                                  'OCT-J',
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.octV,
                                  estudiante,
                                  'OCT-V',
                                ),
                              ),
                              // Noviembre
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.novL,
                                  estudiante,
                                  'NOV-L',
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.novM,
                                  estudiante,
                                  'NOV-M',
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.novMi,
                                  estudiante,
                                  'NOV-MI',
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.novJ,
                                  estudiante,
                                  'NOV-J',
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.novV,
                                  estudiante,
                                  'NOV-V',
                                ),
                              ),
                              // Diciembre
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.dicL,
                                  estudiante,
                                  'DIC-L',
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.dicM,
                                  estudiante,
                                  'DIC-M',
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.dicMi,
                                  estudiante,
                                  'DIC-MI',
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.dicJ,
                                  estudiante,
                                  'DIC-J',
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.dicV,
                                  estudiante,
                                  'DIC-V',
                                ),
                              ),
                              // Total
                              DataCell(
                                GestureDetector(
                                  onTap: () =>
                                      _seleccionarEstudiante(estudiante.item),
                                  child: Center(
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
                                        border: estaSeleccionado
                                            ? Border.all(
                                                color: Colors.teal,
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }
}
