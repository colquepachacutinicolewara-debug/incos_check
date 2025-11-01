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
    this.febL = '',
    this.febM = '',
    this.febMi = '',
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
  String febL;
  String febM;
  String febMi;
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
      febL,
      febM,
      febMi,
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

  String get totalDisplay => '$totalAsistencias/15';
}

class PrimerBimestreScreen extends StatefulWidget {
  const PrimerBimestreScreen({super.key});

  @override
  State<PrimerBimestreScreen> createState() => _PrimerBimestreScreenState();
}

class _PrimerBimestreScreenState extends State<PrimerBimestreScreen> {
  final PeriodoAcademico _bimestre = PeriodoAcademico(
    id: 'bim1',
    nombre: 'Primer Bimestre',
    tipo: 'Bimestral',
    numero: 1,
    fechaInicio: DateTime(2024, 2, 1),
    fechaFin: DateTime(2024, 4, 30),
    estado: 'Finalizado',
    fechasClases: [
      '05/02',
      '06/02',
      '07/02',
      '08/02',
      '09/02',
      '12/02',
      '13/02',
      '14/02',
      '15/02',
      '16/02',
      '19/02',
      '20/02',
      '21/02',
      '22/02',
      '23/02',
      '26/02',
      '27/02',
      '28/02',
      '29/02',
      '04/03',
      '05/03',
      '06/03',
      '07/03',
      '08/03',
      '11/03',
      '12/03',
      '13/03',
      '14/03',
      '15/03',
      '18/03',
      '19/03',
      '20/03',
      '21/03',
      '22/03',
      '25/03',
      '26/03',
      '27/03',
      '28/03',
      '29/03',
      '01/04',
      '02/04',
      '03/04',
      '04/04',
      '05/04',
      '08/04',
      '09/04',
      '10/04',
      '11/04',
      '12/04',
      '15/04',
      '16/04',
      '17/04',
      '18/04',
      '19/04',
      '22/04',
      '23/04',
      '24/04',
      '25/04',
      '26/04',
    ],
    descripcion: 'Primer período académico 2024',
    fechaCreacion: DateTime(2024, 1, 15),
  );

  final List<AsistenciaEstudiante> _estudiantes = [];
  final List<String> fechas = [
    'FEB-L',
    'FEB-M',
    'FEB-MI',
    'FEB-J',
    'FEB-V',
    'MAR-L',
    'MAR-M',
    'MAR-MI',
    'MAR-J',
    'MAR-V',
    'ABR-L',
    'ABR-M',
    'ABR-MI',
    'ABR-J',
    'ABR-V',
  ];
  final TextEditingController _searchController = TextEditingController();
  List<AsistenciaEstudiante> _filteredEstudiantes = [];
  int? _estudianteSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarDatosEjemplo();
    _filteredEstudiantes = _estudiantes;
    _searchController.addListener(_filtrarEstudiantes);
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
      // Limpiar selección al filtrar
      _estudianteSeleccionado = null;
    });
  }

  void _seleccionarEstudiante(int item) {
    setState(() {
      _estudianteSeleccionado = _estudianteSeleccionado == item ? null : item;
    });
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
          estudiante.febL,
          estudiante.febM,
          estudiante.febMi,
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
          estudiante.totalDisplay,
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);

      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/asistencia_primer_bimestre.csv';
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
        case 'FEB-L':
          estudiante.febL = valor;
          break;
        case 'FEB-M':
          estudiante.febM = valor;
          break;
        case 'FEB-MI':
          estudiante.febMi = valor;
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
        case 'MAR-MI':
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
        case 'ABR-MI':
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
    double porcentaje = total / 15;
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
        title: const Text('Primer Bimestre'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
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
            color: Colors.orange.shade50,
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
                          labelText: 'Buscar por número o nombre',
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
                Row(
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
                const SizedBox(height: 8),
                if (_estudianteSeleccionado != null)
                  Text(
                    'Estudiante seleccionado: ${_estudianteSeleccionado}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
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
                                            ? Colors.orange
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
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.febL,
                                  estudiante,
                                  'FEB-L',
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.febM,
                                  estudiante,
                                  'FEB-M',
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.febMi,
                                  estudiante,
                                  'FEB-MI',
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
                                  'MAR-MI',
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
                                  'ABR-MI',
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
                                                color: Colors.orange,
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
    super.dispose();
  }
}
