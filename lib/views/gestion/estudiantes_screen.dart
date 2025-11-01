import 'package:flutter/material.dart';
import 'package:incos_check/utils/export_utils.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/validators.dart';
import 'package:incos_check/utils/helpers.dart';

class EstudiantesListScreen extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;
  final Map<String, dynamic> nivel;
  final Map<String, dynamic> paralelo;

  const EstudiantesListScreen({
    super.key,
    required this.tipo,
    required this.carrera,
    required this.turno,
    required this.nivel,
    required this.paralelo,
  });

  @override
  State<EstudiantesListScreen> createState() => _EstudiantesListScreenState();
}

class _EstudiantesListScreenState extends State<EstudiantesListScreen> {
  List<Map<String, dynamic>> _estudiantes = [
    {
      'id': 1,
      'nombres': 'Juan Carlos',
      'apellidoPaterno': 'Pérez',
      'apellidoMaterno': 'Gómez',
      'ci': '1234567',
      'fechaRegistro': '2024-01-15',
      'huellasRegistradas': 3,
    },
    {
      'id': 2,
      'nombres': 'María Elena',
      'apellidoPaterno': 'López',
      'apellidoMaterno': 'Martínez',
      'ci': '7654321',
      'fechaRegistro': '2024-01-16',
      'huellasRegistradas': 2,
    },
    {
      'id': 3,
      'nombres': 'Ana María',
      'apellidoPaterno': 'García',
      'apellidoMaterno': 'López',
      'ci': '9876543',
      'fechaRegistro': '2024-01-17',
      'huellasRegistradas': 0,
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _estudiantesFiltrados = [];

  @override
  void initState() {
    super.initState();
    _estudiantesFiltrados = _estudiantes;
    _ordenarEstudiantes();
    _searchController.addListener(_filtrarEstudiantes);
  }

  void _ordenarEstudiantes() {
    setState(() {
      _estudiantes.sort((a, b) {
        int comparacion = a['apellidoPaterno'].compareTo(b['apellidoPaterno']);
        if (comparacion != 0) return comparacion;

        comparacion = a['apellidoMaterno'].compareTo(b['apellidoMaterno']);
        if (comparacion != 0) return comparacion;

        return a['nombres'].compareTo(b['nombres']);
      });
      _estudiantesFiltrados = _estudiantes;
    });
  }

  void _filtrarEstudiantes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _estudiantesFiltrados = _estudiantes;
      } else {
        _estudiantesFiltrados = _estudiantes.where((estudiante) {
          return estudiante['nombres'].toLowerCase().contains(query) ||
              estudiante['apellidoPaterno'].toLowerCase().contains(query) ||
              estudiante['apellidoMaterno'].toLowerCase().contains(query) ||
              estudiante['ci'].contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color carreraColor = _parseColor(widget.carrera['color']);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paralelo ${widget.paralelo['nombre']} - Estudiantes',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: carreraColor,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleExportAction(value),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'excel_simple',
                child: Text('Exportar Lista Simple (Excel)'),
              ),
              PopupMenuItem(
                value: 'excel_completo',
                child: Text('Exportar Lista Completa (Excel)'),
              ),
              PopupMenuItem(
                value: 'pdf_simple',
                child: Text('Exportar Lista Simple (PDF)'),
              ),
              PopupMenuItem(
                value: 'pdf_completo',
                child: Text('Exportar Lista Completa (PDF)'),
              ),
            ],
            icon: Icon(Icons.download),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar estudiante...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Contador de resultados
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_estudiantesFiltrados.length} estudiante${_estudiantesFiltrados.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  Text(
                    'Búsqueda: "${_searchController.text}"',
                    style: TextStyle(color: Colors.blue[600], fontSize: 12),
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.small),
          // Lista de estudiantes
          Expanded(
            child: _estudiantesFiltrados.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(AppSpacing.medium),
                    itemCount: _estudiantesFiltrados.length,
                    itemBuilder: (context, index) {
                      final estudiante = _estudiantesFiltrados[index];
                      return _buildEstudianteCard(
                        estudiante,
                        index,
                        carreraColor,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAgregarEstudianteDialog,
        backgroundColor: carreraColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEstudianteCard(
    Map<String, dynamic> estudiante,
    int index,
    Color color,
  ) {
    int huellasRegistradas = estudiante['huellasRegistradas'] ?? 0;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            estudiante['nombres'][0],
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          '${estudiante['apellidoPaterno']} ${estudiante['apellidoMaterno']} ${estudiante['nombres']}',
          style: AppTextStyles.heading3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CI: ${estudiante['ci']}'),
            Text('Registro: ${estudiante['fechaRegistro']}'),
            Row(
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 14,
                  color: huellasRegistradas == 3 ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 4),
                Text(
                  'Huellas: $huellasRegistradas/3',
                  style: TextStyle(
                    color: huellasRegistradas == 3
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (huellasRegistradas < 3)
              IconButton(
                icon: Icon(Icons.fingerprint, color: Colors.blue),
                onPressed: () => _registrarHuellas(estudiante, index),
                tooltip: 'Registrar Huellas',
              ),
            PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleMenuAction(value, estudiante, index),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(value: 'edit', child: Text('Modificar')),
                PopupMenuItem(
                  value: 'huellas',
                  child: Text('Gestionar Huellas'),
                ),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          SizedBox(height: AppSpacing.medium),
          Text(
            _searchController.text.isEmpty
                ? 'No hay estudiantes registrados'
                : 'No se encontraron resultados',
            style: AppTextStyles.heading3.copyWith(color: Colors.grey),
          ),
          SizedBox(height: AppSpacing.small),
          Text(
            _searchController.text.isEmpty
                ? 'Presiona el botón + para agregar el primer estudiante'
                : 'Intenta con otros términos de búsqueda',
            style: AppTextStyles.body.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
              },
              child: Text('Limpiar búsqueda'),
            ),
        ],
      ),
    );
  }

  void _handleMenuAction(
    String action,
    Map<String, dynamic> estudiante,
    int index,
  ) {
    switch (action) {
      case 'edit':
        _showEditarEstudianteDialog(estudiante, index);
        break;
      case 'huellas':
        _registrarHuellas(estudiante, index);
        break;
      case 'delete':
        _showEliminarEstudianteDialog(estudiante, index);
        break;
    }
  }

  void _handleExportAction(String action) {
    switch (action) {
      case 'excel_simple':
        _exportarExcel(simple: true);
        break;
      case 'excel_completo':
        _exportarExcel(simple: false);
        break;
      case 'pdf_simple':
        _exportarPDF(simple: true);
        break;
      case 'pdf_completo':
        _exportarPDF(simple: false);
        break;
    }
  }

  void _showAgregarEstudianteDialog() {
    showDialog(
      context: context,
      builder: (context) => _EstudianteDialog(
        title: 'Agregar Estudiante',
        onSave: (nombres, paterno, materno, ci) {
          setState(() {
            _estudiantes.add({
              'id': DateTime.now().millisecondsSinceEpoch,
              'nombres': nombres,
              'apellidoPaterno': paterno,
              'apellidoMaterno': materno,
              'ci': ci,
              'fechaRegistro': Helpers.formatDate(DateTime.now()),
              'huellasRegistradas': 0,
            });
            _ordenarEstudiantes();
          });
          Helpers.showSnackBar(
            context,
            'Estudiante agregado exitosamente',
            type: 'success',
          );
        },
      ),
    );
  }

  void _showEditarEstudianteDialog(Map<String, dynamic> estudiante, int index) {
    showDialog(
      context: context,
      builder: (context) => _EstudianteDialog(
        title: 'Modificar Estudiante',
        nombresInicial: estudiante['nombres'],
        paternoInicial: estudiante['apellidoPaterno'],
        maternoInicial: estudiante['apellidoMaterno'],
        ciInicial: estudiante['ci'],
        onSave: (nombres, paterno, materno, ci) {
          setState(() {
            _estudiantes[index] = {
              ...estudiante,
              'nombres': nombres,
              'apellidoPaterno': paterno,
              'apellidoMaterno': materno,
              'ci': ci,
            };
            _ordenarEstudiantes();
          });
          Helpers.showSnackBar(
            context,
            'Estudiante actualizado exitosamente',
            type: 'success',
          );
        },
      ),
    );
  }

  void _showEliminarEstudianteDialog(
    Map<String, dynamic> estudiante,
    int index,
  ) {
    Helpers.showConfirmationDialog(
      context,
      title: 'Eliminar Estudiante',
      content:
          '¿Estás seguro de eliminar a ${estudiante['nombres']} ${estudiante['apellidoPaterno']}?',
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          _estudiantes.removeAt(index);
          _filtrarEstudiantes();
        });
        Helpers.showSnackBar(
          context,
          'Estudiante eliminado exitosamente',
          type: 'success',
        );
      }
    });
  }

  void _registrarHuellas(Map<String, dynamic> estudiante, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroHuellasScreen(
          estudiante: estudiante,
          onHuellasRegistradas: (int huellasRegistradas) {
            setState(() {
              _estudiantes[index]['huellasRegistradas'] = huellasRegistradas;
            });
          },
        ),
      ),
    );
  }

  void _exportarExcel({bool simple = true}) {
    final estudiantesExportar = _estudiantesFiltrados;
    final tipo = simple ? 'simple' : 'completa';

    Helpers.showConfirmationDialog(
      context,
      title: 'Exportar a Excel',
      content:
          '¿Exportar lista $tipo con ${estudiantesExportar.length} estudiante${estudiantesExportar.length != 1 ? 's' : ''} a Excel?',
    ).then((confirmed) {
      if (confirmed) {
        // Simular exportación real a Excel
        _realExportacionExcel(estudiantesExportar, simple);
        Helpers.showSnackBar(
          context,
          'Lista $tipo exportada a Excel exitosamente',
          type: 'success',
        );
      }
    });
  }

  void _exportarPDF({bool simple = true}) {
    final estudiantesExportar = _estudiantesFiltrados;
    final tipo = simple ? 'simple' : 'completa';

    Helpers.showConfirmationDialog(
      context,
      title: 'Exportar a PDF',
      content:
          '¿Exportar lista $tipo con ${estudiantesExportar.length} estudiante${estudiantesExportar.length != 1 ? 's' : ''} a PDF?',
    ).then((confirmed) {
      if (confirmed) {
        // Simular exportación real a PDF
        _realExportacionPDF(estudiantesExportar, simple);
        Helpers.showSnackBar(
          context,
          'Lista $tipo exportada a PDF exitosamente',
          type: 'success',
        );
      }
    });
  }

  void _realExportacionExcel(
    List<Map<String, dynamic>> estudiantes,
    bool simple,
  ) {
    // Aquí iría la lógica real de exportación a Excel
    // Por ejemplo usando excel: ^5.1.1 o syncfusion_flutter_xlsio: ^23.1.44

    print('=== EXPORTACIÓN REAL EXCEL ${simple ? 'SIMPLE' : 'COMPLETA'} ===');
    print('Institución: ${widget.carrera['nombre']}');
    print('Turno: ${widget.turno['nombre']}');
    print('Nivel: ${widget.nivel['nombre']}');
    print('Paralelo: ${widget.paralelo['nombre']}');
    print('Fecha: ${Helpers.formatDateTime(DateTime.now())}');
    print('Total estudiantes: ${estudiantes.length}');

    if (simple) {
      print('--- LISTA SIMPLE ---');
      for (var estudiante in estudiantes) {
        print(
          '${estudiante['apellidoPaterno']} ${estudiante['apellidoMaterno']} ${estudiante['nombres']}',
        );
      }
    } else {
      print('--- LISTA COMPLETA ---');
      for (var estudiante in estudiantes) {
        print(
          '${estudiante['apellidoPaterno']} | ${estudiante['apellidoMaterno']} | ${estudiante['nombres']} | CI: ${estudiante['ci']} | Registro: ${estudiante['fechaRegistro']} | Huellas: ${estudiante['huellasRegistradas']}/3',
        );
      }
    }

    // En una implementación real, aquí se generaría el archivo Excel
    // y se descargaría o compartiría
  }

  void _realExportacionPDF(
    List<Map<String, dynamic>> estudiantes,
    bool simple,
  ) {
    // Aquí iría la lógica real de exportación a PDF
    // Por ejemplo usando pdf: ^3.10.4 o syncfusion_flutter_pdf: ^23.1.44

    print('=== EXPORTACIÓN REAL PDF ${simple ? 'SIMPLE' : 'COMPLETA'} ===');
    print('Institución: ${widget.carrera['nombre']}');
    print('Turno: ${widget.turno['nombre']}');
    print('Nivel: ${widget.nivel['nombre']}');
    print('Paralelo: ${widget.paralelo['nombre']}');
    print('Fecha: ${Helpers.formatDateTime(DateTime.now())}');
    print('Total estudiantes: ${estudiantes.length}');

    if (simple) {
      print('--- LISTA SIMPLE ---');
      for (var estudiante in estudiantes) {
        print(
          '• ${estudiante['apellidoPaterno']} ${estudiante['apellidoMaterno']} ${estudiante['nombres']}',
        );
      }
    } else {
      print('--- LISTA COMPLETA ---');
      for (var estudiante in estudiantes) {
        print(
          '• ${estudiante['apellidoPaterno']} ${estudiante['apellidoMaterno']} ${estudiante['nombres']}',
        );
        print(
          '  CI: ${estudiante['ci']} | Fecha Registro: ${estudiante['fechaRegistro']} | Huellas: ${estudiante['huellasRegistradas']}/3',
        );
      }
    }

    // En una implementación real, aquí se generaría el archivo PDF
    // y se descargaría o compartiría
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}

// =============================================
// PANTALLA DE REGISTRO DE HUELLAS
// =============================================
class RegistroHuellasScreen extends StatefulWidget {
  final Map<String, dynamic> estudiante;
  final Function(int) onHuellasRegistradas;

  const RegistroHuellasScreen({
    super.key,
    required this.estudiante,
    required this.onHuellasRegistradas,
  });

  @override
  State<RegistroHuellasScreen> createState() => _RegistroHuellasScreenState();
}

class _RegistroHuellasScreenState extends State<RegistroHuellasScreen> {
  List<bool> _huellasRegistradas = [false, false, false];
  int _huellaActual = 0;

  final List<String> _nombresDedos = [
    'Pulgar - Mano Derecha',
    'Índice - Mano Derecha',
    'Medio - Mano Derecha',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Huellas'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del estudiante
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    widget.estudiante['nombres'][0],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  '${widget.estudiante['apellidoPaterno']} ${widget.estudiante['apellidoMaterno']} ${widget.estudiante['nombres']}',
                  style: AppTextStyles.heading3,
                ),
                subtitle: Text('CI: ${widget.estudiante['ci']}'),
              ),
            ),
            SizedBox(height: AppSpacing.large),

            // Progreso
            Text(
              'Progreso: ${_huellasRegistradas.where((h) => h).length}/3 huellas registradas',
              style: AppTextStyles.heading2,
            ),
            SizedBox(height: AppSpacing.small),
            LinearProgressIndicator(
              value: _huellasRegistradas.where((h) => h).length / 3,
              backgroundColor: Colors.grey[300],
              color: AppColors.primary,
            ),
            SizedBox(height: AppSpacing.large),

            // Huella actual
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: 120,
                    color: _huellasRegistradas[_huellaActual]
                        ? Colors.green
                        : AppColors.primary,
                  ),
                  SizedBox(height: AppSpacing.medium),
                  Text(
                    _nombresDedos[_huellaActual],
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.small),
                  Text(
                    _huellasRegistradas[_huellaActual]
                        ? '✅ Huella registrada'
                        : 'Presiona el botón para registrar esta huella',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xlarge),

            // Controles de navegación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _huellaActual > 0 ? _anteriorHuella : null,
                  child: Text('Anterior'),
                ),
                ElevatedButton(
                  onPressed: _huellasRegistradas[_huellaActual]
                      ? _siguienteHuella
                      : _registrarHuellaActual,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    _huellasRegistradas[_huellaActual]
                        ? 'Siguiente'
                        : 'Registrar Huella',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            // Lista de huellas
            SizedBox(height: AppSpacing.large),
            Text('Huellas registradas:', style: AppTextStyles.heading3),
            SizedBox(height: AppSpacing.small),
            ..._nombresDedos.asMap().entries.map((entry) {
              int index = entry.key;
              String nombre = entry.value;
              return ListTile(
                leading: Icon(
                  _huellasRegistradas[index]
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: _huellasRegistradas[index]
                      ? Colors.green
                      : Colors.grey,
                ),
                title: Text(nombre),
                trailing: _huellasRegistradas[index]
                    ? Icon(Icons.check, color: Colors.green)
                    : null,
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: _huellasRegistradas.every((h) => h)
          ? FloatingActionButton.extended(
              onPressed: _finalizarRegistro,
              backgroundColor: Colors.green,
              icon: Icon(Icons.done_all),
              label: Text('Finalizar Registro'),
            )
          : null,
    );
  }

  void _registrarHuellaActual() {
    // Aquí iría la lógica real de registro de huella con el dispositivo
    // Por ahora simulamos el registro

    setState(() {
      _huellasRegistradas[_huellaActual] = true;
    });

    Helpers.showSnackBar(
      context,
      'Huella ${_nombresDedos[_huellaActual]} registrada exitosamente',
      type: 'success',
    );

    // Si es la última huella, finalizar
    if (_huellaActual == 2) {
      _finalizarRegistro();
    }
  }

  void _siguienteHuella() {
    if (_huellaActual < 2) {
      setState(() {
        _huellaActual++;
      });
    }
  }

  void _anteriorHuella() {
    if (_huellaActual > 0) {
      setState(() {
        _huellaActual--;
      });
    }
  }

  void _finalizarRegistro() {
    int totalRegistradas = _huellasRegistradas.where((h) => h).length;
    widget.onHuellasRegistradas(totalRegistradas);
    Navigator.pop(context);
    Helpers.showSnackBar(
      context,
      'Registro de huellas completado: $totalRegistradas/3',
      type: 'success',
    );
  }
}

// =============================================
// DIÁLOGO PARA AGREGAR/MODIFICAR ESTUDIANTES
// =============================================
class _EstudianteDialog extends StatefulWidget {
  final String title;
  final String? nombresInicial;
  final String? paternoInicial;
  final String? maternoInicial;
  final String? ciInicial;
  final Function(String nombres, String paterno, String materno, String ci)
  onSave;

  const _EstudianteDialog({
    required this.title,
    this.nombresInicial,
    this.paternoInicial,
    this.maternoInicial,
    this.ciInicial,
    required this.onSave,
  });

  @override
  State<_EstudianteDialog> createState() => _EstudianteDialogState();
}

class _EstudianteDialogState extends State<_EstudianteDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _paternoController = TextEditingController();
  final TextEditingController _maternoController = TextEditingController();
  final TextEditingController _ciController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nombresController.text = widget.nombresInicial ?? '';
    _paternoController.text = widget.paternoInicial ?? '';
    _maternoController.text = widget.maternoInicial ?? '';
    _ciController.text = widget.ciInicial ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(AppSpacing.medium),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: AppTextStyles.heading2),
            SizedBox(height: AppSpacing.medium),
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nombresController,
                    decoration: InputDecoration(
                      labelText: 'Nombres *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => Validators.validateName(value),
                  ),
                  SizedBox(height: AppSpacing.small),
                  TextFormField(
                    controller: _paternoController,
                    decoration: InputDecoration(
                      labelText: 'Apellido Paterno *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => Validators.validateName(value),
                  ),
                  SizedBox(height: AppSpacing.small),
                  TextFormField(
                    controller: _maternoController,
                    decoration: InputDecoration(
                      labelText: 'Apellido Materno',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        return Validators.validateName(value);
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppSpacing.small),
                  TextFormField(
                    controller: _ciController,
                    decoration: InputDecoration(
                      labelText: 'Cédula de Identidad *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.validateCI(value),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.large),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
                SizedBox(width: AppSpacing.small),
                ElevatedButton(
                  onPressed: _guardarEstudiante,
                  child: Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _guardarEstudiante() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        Validators.formatName(_nombresController.text),
        Validators.formatName(_paternoController.text),
        Validators.formatName(_maternoController.text),
        _ciController.text.trim(),
      );
      Navigator.pop(context);
    }
  }
}
