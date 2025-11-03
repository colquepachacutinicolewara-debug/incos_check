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

  // Controladores para edición de fechas
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<AsistenciaEstudiante> _filteredEstudiantes = [];
  int? _estudianteSeleccionado;

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

  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  Color _getHeaderBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.orange.shade50;
  }

  Color _getSearchBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color _getOrangeAccentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.orange.shade700
        : Colors.orange;
  }

  Color _getOrangeLightColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.orange.shade900.withOpacity(0.3)
        : Colors.orange.shade50;
  }

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
        backgroundColor: _getCardColor(context),
        title: Text(
          'Editar Fechas del Bimestre',
          style: TextStyle(color: _getTextColor(context)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fechaInicioController,
                style: TextStyle(color: _getTextColor(context)),
                decoration: InputDecoration(
                  labelText: 'Fecha de inicio (DD/MM/AAAA)',
                  labelStyle: TextStyle(color: _getSecondaryTextColor(context)),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: _getSearchBackgroundColor(context),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaFinController,
                style: TextStyle(color: _getTextColor(context)),
                decoration: InputDecoration(
                  labelText: 'Fecha de fin (DD/MM/AAAA)',
                  labelStyle: TextStyle(color: _getSecondaryTextColor(context)),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: _getSearchBackgroundColor(context),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: _getSecondaryTextColor(context)),
            ),
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
                SnackBar(
                  content: const Text('Fechas actualizadas correctamente'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getOrangeAccentColor(context),
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
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
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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

  void _editarAsistencia(AsistenciaEstudiante estudiante, String fecha) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(context),
        title: Text(
          'Editar asistencia - $fecha',
          style: TextStyle(color: _getTextColor(context)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Estudiante: ${estudiante.nombre}',
                style: TextStyle(color: _getTextColor(context)),
              ),
              const SizedBox(height: 20),
              Text(
                'Seleccione el estado:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(context),
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
                  ),
                  _buildBotonAsistencia(
                    'F',
                    'Falta',
                    Colors.red,
                    estudiante,
                    fecha,
                    context,
                  ),
                  _buildBotonAsistencia(
                    'J',
                    'Justificado',
                    Colors.orange,
                    estudiante,
                    fecha,
                    context,
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
                  foregroundColor: _getSecondaryTextColor(context),
                  side: BorderSide(color: _getBorderColor(context)),
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
              style: TextStyle(color: _getOrangeAccentColor(context)),
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
    AsistenciaEstudiante estudiante,
    String fecha,
    BuildContext context,
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
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getTextColor(context),
            ),
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

  Color _getColorAsistencia(String valor, BuildContext context) {
    switch (valor.toUpperCase()) {
      case 'P':
        return Colors.green;
      case 'F':
        return Colors.red;
      case 'J':
        return Colors.orange;
      default:
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade200;
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

  Widget _buildItemLeyenda(Color color, String texto, BuildContext context) {
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
          style: TextStyle(fontSize: 12, color: _getTextColor(context)),
        ),
      ],
    );
  }

  Widget _buildCeldaAsistencia(
    String valor,
    AsistenciaEstudiante estudiante,
    String fecha,
    BuildContext context,
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
            color: _getColorAsistencia(valor, context),
            shape: BoxShape.circle,
            border: Border.all(color: _getBorderColor(context), width: 1),
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
                    ? _getSecondaryTextColor(context)
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

  Color _getColorFila(int item, BuildContext context) {
    if (_estudianteSeleccionado == item) {
      return Theme.of(context).brightness == Brightness.dark
          ? Colors.yellow.withOpacity(0.2)
          : Colors.yellow.withOpacity(0.3);
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Primer Bimestre',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: _getOrangeAccentColor(context),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
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
            color: _getOrangeLightColor(context),
            child: Row(
              children: [
                Container(width: 4, height: 40, color: _bimestre.colorEstado),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _bimestre.nombre,
                        style: AppTextStyles.heading2.copyWith(
                          color: _getTextColor(context),
                        ),
                      ),
                      Text(
                        _bimestre.rangoFechas,
                        style: TextStyle(
                          color: _getSecondaryTextColor(context),
                        ),
                      ),
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
                        style: TextStyle(color: _getTextColor(context)),
                        decoration: InputDecoration(
                          labelText: 'Buscar por número exacto o nombre',
                          hintText: 'Ej: 05 o "Estudiante 05"',
                          labelStyle: TextStyle(
                            color: _getSecondaryTextColor(context),
                          ),
                          hintStyle: TextStyle(
                            color: _getSecondaryTextColor(context),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: _getSecondaryTextColor(context),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _getBorderColor(context),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _getBorderColor(context),
                            ),
                          ),
                          filled: true,
                          fillColor: _getSearchBackgroundColor(context),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: _getSecondaryTextColor(context),
                                  ),
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
                        color: _getOrangeLightColor(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getOrangeAccentColor(
                            context,
                          ).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Total: ${_filteredEstudiantes.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _getOrangeAccentColor(context),
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
                      _buildItemLeyenda(Colors.green, 'Presente (P)', context),
                      const SizedBox(width: 16),
                      _buildItemLeyenda(Colors.red, 'Falta (F)', context),
                      const SizedBox(width: 16),
                      _buildItemLeyenda(
                        Colors.orange,
                        'Justificado (J)',
                        context,
                      ),
                      const SizedBox(width: 16),
                      _buildItemLeyenda(Colors.yellow, 'Seleccionado', context),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (_estudianteSeleccionado != null)
                  Text(
                    'Estudiante seleccionado: $_estudianteSeleccionado',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getOrangeAccentColor(context),
                    ),
                  ),
              ],
            ),
          ),

          // Tabla de asistencias
          Expanded(
            child: _filteredEstudiantes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: _getSecondaryTextColor(context),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron estudiantes',
                          style: TextStyle(
                            fontSize: 16,
                            color: _getSecondaryTextColor(context),
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
                          (states) => _getHeaderBackgroundColor(context),
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
                                color: _getTextColor(context),
                              ),
                            ),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text(
                              'ESTUDIANTE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getTextColor(context),
                              ),
                            ),
                          ),
                          ...fechas
                              .map(
                                (fecha) => DataColumn(
                                  label: SizedBox(
                                    width: 48,
                                    child: Text(
                                      fecha,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: _getTextColor(context),
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              )
                              ,
                          DataColumn(
                            label: Text(
                              'TOTAL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getTextColor(context),
                              ),
                            ),
                            numeric: true,
                          ),
                        ],
                        rows: _filteredEstudiantes.map((estudiante) {
                          final bool estaSeleccionado =
                              _estudianteSeleccionado == estudiante.item;

                          return DataRow(
                            color: WidgetStateProperty.resolveWith<Color?>((
                              Set<WidgetState> states,
                            ) {
                              return _getColorFila(estudiante.item, context);
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
                                            ? _getOrangeAccentColor(context)
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
                                              : _getTextColor(context),
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
                                        color: _getTextColor(context),
                                        backgroundColor: estaSeleccionado
                                            ? Colors.yellow.withOpacity(0.3)
                                            : Colors.transparent,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              // Febrero
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.febL,
                                  estudiante,
                                  'FEB-L',
                                  context,
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.febM,
                                  estudiante,
                                  'FEB-M',
                                  context,
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.febMi,
                                  estudiante,
                                  'FEB-MI',
                                  context,
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.febJ,
                                  estudiante,
                                  'FEB-J',
                                  context,
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.febV,
                                  estudiante,
                                  'FEB-V',
                                  context,
                                ),
                              ),
                              // Marzo
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.marL,
                                  estudiante,
                                  'MAR-L',
                                  context,
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.marM,
                                  estudiante,
                                  'MAR-M',
                                  context,
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.marMi,
                                  estudiante,
                                  'MAR-MI',
                                  context,
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.marJ,
                                  estudiante,
                                  'MAR-J',
                                  context,
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.marV,
                                  estudiante,
                                  'MAR-V',
                                  context,
                                ),
                              ),
                              // Abril
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.abrL,
                                  estudiante,
                                  'ABR-L',
                                  context,
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.abrM,
                                  estudiante,
                                  'ABR-M',
                                  context,
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.abrMi,
                                  estudiante,
                                  'ABR-MI',
                                  context,
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.abrJ,
                                  estudiante,
                                  'ABR-J',
                                  context,
                                ),
                              ),
                              DataCell(
                                _buildCeldaAsistencia(
                                  estudiante.abrV,
                                  estudiante,
                                  'ABR-V',
                                  context,
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
                                                color: _getOrangeAccentColor(
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
