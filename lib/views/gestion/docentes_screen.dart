import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';
import 'package:incos_check/utils/validators.dart';

class DocentesScreen extends StatefulWidget {
  final Map<String, dynamic> carrera;

  const DocentesScreen({super.key, required this.carrera});

  @override
  State<DocentesScreen> createState() => _DocentesScreenState();
}

class _DocentesScreenState extends State<DocentesScreen> {
  // Lista de turnos disponibles
  final List<String> _turnos = ['MAÑANA', 'NOCHE', 'AMBOS'];

  // Datos de ejemplo
  final List<Map<String, dynamic>> _docentes = [
    {
      'id': 1,
      'apellidoPaterno': 'FERNANDEZ',
      'apellidoMaterno': 'GARCIA',
      'nombres': 'MARIA ELENA',
      'ci': '6543210',
      'carrera': 'SISTEMAS INFORMÁTICOS',
      'turno': 'MAÑANA',
      'email': 'mfernandez@gmail.com',
      'telefono': '+59170012345',
      'estado': Estados.activo,
    },
    {
      'id': 2,
      'apellidoPaterno': 'BUSTOS',
      'apellidoMaterno': 'MARTINEZ',
      'nombres': 'CARLOS ALBERTO',
      'ci': '6543211',
      'carrera': 'SISTEMAS INFORMÁTICOS',
      'turno': 'NOCHE',
      'email': 'cbustos@gmail.com',
      'telefono': '+59170012346',
      'estado': Estados.activo,
    },
  ];

  // Lista de carreras disponibles - se cargará desde el almacenamiento
  List<String> _carreras = ['SISTEMAS INFORMÁTICOS'];

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredDocentes = [];
  String _selectedCarrera = '';
  String _selectedTurno = 'MAÑANA';
  Color _carreraColor = AppColors.primary;

  // Métodos para adaptación al modo oscuro
  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.white;
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

  Color _getInputFillColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : AppColors.background;
  }

  @override
  void initState() {
    super.initState();
    _carreraColor = _parseColor(widget.carrera['color']);

    // Inicializar con la carrera actual
    _selectedCarrera = widget.carrera['nombre'] as String;

    // Si la carrera actual no está en la lista, agregarla
    if (!_carreras.contains(_selectedCarrera)) {
      _carreras.add(_selectedCarrera);
    }

    _filteredDocentes = _docentes;
    _filterDocentesByCarreraAndTurno();
  }

  // Método para cargar carreras desde almacenamiento (simulado)
  void _cargarCarreras() {
    // En una app real, esto vendría de una base de datos o SharedPreferences
    setState(() {
      _carreras = [
        'SISTEMAS INFORMÁTICOS',
        'ADMINISTRACIÓN DE EMPRESAS',
        'CONTADURÍA GENERAL',
      ];
    });
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  void _filterDocentesByCarreraAndTurno() {
    setState(() {
      _filteredDocentes = _docentes.where((docente) {
        return docente['carrera'] == _selectedCarrera &&
            docente['turno'] == _selectedTurno;
      }).toList();
      _sortDocentesAlphabetically();
    });
  }

  void _sortDocentesAlphabetically() {
    _filteredDocentes.sort((a, b) {
      int comparePaterno = (a['apellidoPaterno'] as String).compareTo(
        b['apellidoPaterno'] as String,
      );
      if (comparePaterno != 0) return comparePaterno;

      int compareMaterno = (a['apellidoMaterno'] as String).compareTo(
        b['apellidoMaterno'] as String,
      );
      if (compareMaterno != 0) return compareMaterno;

      return (a['nombres'] as String).compareTo(b['nombres'] as String);
    });
  }

  void _filterDocentes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterDocentesByCarreraAndTurno();
      } else {
        _filteredDocentes = _docentes.where((docente) {
          final nombreCompleto =
              '${docente['apellidoPaterno']} ${docente['apellidoMaterno']} ${docente['nombres']}'
                  .toLowerCase();
          final ci = docente['ci'].toString().toLowerCase();
          final matchesSearch =
              nombreCompleto.contains(query.toLowerCase()) ||
              ci.contains(query.toLowerCase());

          final matchesCarreraTurno =
              docente['carrera'] == _selectedCarrera &&
              docente['turno'] == _selectedTurno;

          return matchesSearch && matchesCarreraTurno;
        }).toList();
      }
      _sortDocentesAlphabetically();
    });
  }

  // Método para obtener estadísticas por turno
  Map<String, int> _getEstadisticasPorTurno() {
    final docentesCarrera = _docentes
        .where((d) => d['carrera'] == _selectedCarrera)
        .toList();

    return {
      'MAÑANA': docentesCarrera.where((d) => d['turno'] == 'MAÑANA').length,
      'NOCHE': docentesCarrera.where((d) => d['turno'] == 'NOCHE').length,
      'AMBOS': docentesCarrera.where((d) => d['turno'] == 'AMBOS').length,
      'TOTAL': docentesCarrera.length,
    };
  }

  void _showDocenteDetails(Map<String, dynamic> docente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(context),
        title: Text(
          'Detalles del Docente',
          style: AppTextStyles.heading2.copyWith(color: _carreraColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('CI:', docente['ci'] as String, context),
              _buildDetailRow(
                'Apellido Paterno:',
                docente['apellidoPaterno'] as String,
                context,
              ),
              _buildDetailRow(
                'Apellido Materno:',
                docente['apellidoMaterno'] as String,
                context,
              ),
              _buildDetailRow(
                'Nombres:',
                docente['nombres'] as String,
                context,
              ),
              _buildDetailRow(
                'Carrera:',
                docente['carrera'] as String,
                context,
              ),
              _buildDetailRow('Turno:', docente['turno'] as String, context),
              _buildDetailRow('Email:', docente['email'] as String, context),
              _buildDetailRow(
                'Teléfono:',
                docente['telefono'] as String,
                context,
              ),
              _buildDetailRow('Estado:', docente['estado'] as String, context),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: AppTextStyles.body.copyWith(color: _getTextColor(context)),
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuOptions(Map<String, dynamic> docente) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _getCardColor(context),
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility, color: _carreraColor),
              title: Text(
                'Ver Información',
                style: TextStyle(color: _getTextColor(context)),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDocenteDetails(docente);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: _carreraColor),
              title: Text(
                'Modificar',
                style: TextStyle(color: _getTextColor(context)),
              ),
              onTap: () {
                Navigator.pop(context);
                _showAddEditDocenteDialog(docente: docente);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('Eliminar', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteDocente(docente['id'] as int);
              },
            ),
            SizedBox(height: AppSpacing.small),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: _getTextColor(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditDocenteDialog({Map<String, dynamic>? docente}) {
    final bool isEditing = docente != null;

    TextEditingController ciController = TextEditingController(
      text: docente?['ci'] ?? '',
    );
    TextEditingController apellidoPaternoController = TextEditingController(
      text: docente?['apellidoPaterno'] ?? '',
    );
    TextEditingController apellidoMaternoController = TextEditingController(
      text: docente?['apellidoMaterno'] ?? '',
    );
    TextEditingController nombresController = TextEditingController(
      text: docente?['nombres'] ?? '',
    );
    TextEditingController emailController = TextEditingController(
      text: docente?['email'] ?? '',
    );
    TextEditingController telefonoController = TextEditingController(
      text: docente?['telefono'] ?? '',
    );

    String selectedCarrera = docente?['carrera'] ?? _selectedCarrera;
    String selectedTurno = docente?['turno'] ?? 'MAÑANA';
    String selectedEstado = docente?['estado'] ?? Estados.activo;

    final _formKey = GlobalKey<FormState>();

    // Auto-completar email cuando se llenen los nombres
    void _autoCompletarEmail() {
      if (apellidoPaternoController.text.isNotEmpty &&
          nombresController.text.isNotEmpty &&
          emailController.text.isEmpty) {
        final nombre = nombresController.text.split(' ')[0].toLowerCase();
        final apellido = apellidoPaternoController.text.toLowerCase();
        emailController.text = '$nombre.$apellido@gmail.com';
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _getCardColor(context),
          title: Text(
            isEditing ? 'Modificar Docente' : 'Agregar Docente',
            style: AppTextStyles.heading2.copyWith(color: _carreraColor),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // CI con validación
                  TextFormField(
                    controller: ciController,
                    style: TextStyle(color: _getTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'CI *',
                      labelStyle: TextStyle(color: _getTextColor(context)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _carreraColor),
                      ),
                      hintText: 'Solo números (6-10 dígitos)',
                      hintStyle: TextStyle(
                        color: _getSecondaryTextColor(context),
                      ),
                      errorStyle: TextStyle(color: AppColors.error),
                      filled: true,
                      fillColor: _getInputFillColor(context),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.validateCI,
                  ),
                  SizedBox(height: AppSpacing.small),

                  // Apellido Paterno con validación
                  TextFormField(
                    controller: apellidoPaternoController,
                    style: TextStyle(color: _getTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Apellido Paterno *',
                      labelStyle: TextStyle(color: _getTextColor(context)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _carreraColor),
                      ),
                      hintText: 'Solo letras',
                      hintStyle: TextStyle(
                        color: _getSecondaryTextColor(context),
                      ),
                      errorStyle: TextStyle(color: AppColors.error),
                      filled: true,
                      fillColor: _getInputFillColor(context),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => Validators.validateName(value),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        apellidoPaternoController.value = TextEditingValue(
                          text: value.toUpperCase(),
                          selection: apellidoPaternoController.selection,
                        );
                        _autoCompletarEmail();
                      }
                    },
                  ),
                  SizedBox(height: AppSpacing.small),

                  // Apellido Materno con validación
                  TextFormField(
                    controller: apellidoMaternoController,
                    style: TextStyle(color: _getTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Apellido Materno *',
                      labelStyle: TextStyle(color: _getTextColor(context)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _carreraColor),
                      ),
                      hintText: 'Solo letras',
                      hintStyle: TextStyle(
                        color: _getSecondaryTextColor(context),
                      ),
                      errorStyle: TextStyle(color: AppColors.error),
                      filled: true,
                      fillColor: _getInputFillColor(context),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => Validators.validateName(value),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        apellidoMaternoController.value = TextEditingValue(
                          text: value.toUpperCase(),
                          selection: apellidoMaternoController.selection,
                        );
                      }
                    },
                  ),
                  SizedBox(height: AppSpacing.small),

                  // Nombres con validación
                  TextFormField(
                    controller: nombresController,
                    style: TextStyle(color: _getTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Nombres *',
                      labelStyle: TextStyle(color: _getTextColor(context)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _carreraColor),
                      ),
                      hintText: 'Solo letras',
                      hintStyle: TextStyle(
                        color: _getSecondaryTextColor(context),
                      ),
                      errorStyle: TextStyle(color: AppColors.error),
                      filled: true,
                      fillColor: _getInputFillColor(context),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => Validators.validateName(value),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        nombresController.value = TextEditingValue(
                          text: value.toUpperCase(),
                          selection: nombresController.selection,
                        );
                        _autoCompletarEmail();
                      }
                    },
                  ),
                  SizedBox(height: AppSpacing.small),

                  // Selector de Carrera
                  DropdownButtonFormField<String>(
                    value: selectedCarrera,
                    dropdownColor: _getCardColor(context),
                    style: TextStyle(color: _getTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Carrera *',
                      labelStyle: TextStyle(color: _getTextColor(context)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _carreraColor),
                      ),
                      errorStyle: TextStyle(color: AppColors.error),
                      filled: true,
                      fillColor: _getInputFillColor(context),
                    ),
                    items: _carreras.map((carrera) {
                      return DropdownMenuItem(
                        value: carrera,
                        child: Text(
                          carrera,
                          style: TextStyle(color: _getTextColor(context)),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCarrera = value!;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Seleccione una carrera' : null,
                  ),
                  SizedBox(height: AppSpacing.small),

                  // Selector de Turno
                  DropdownButtonFormField<String>(
                    value: selectedTurno,
                    dropdownColor: _getCardColor(context),
                    style: TextStyle(color: _getTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Turno *',
                      labelStyle: TextStyle(color: _getTextColor(context)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _carreraColor),
                      ),
                      errorStyle: TextStyle(color: AppColors.error),
                      filled: true,
                      fillColor: _getInputFillColor(context),
                    ),
                    items: _turnos.map((turno) {
                      return DropdownMenuItem(
                        value: turno,
                        child: Text(
                          turno,
                          style: TextStyle(color: _getTextColor(context)),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedTurno = value!;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Seleccione un turno' : null,
                  ),
                  SizedBox(height: AppSpacing.small),

                  // Email con validación
                  TextFormField(
                    controller: emailController,
                    style: TextStyle(color: _getTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Email *',
                      labelStyle: TextStyle(color: _getTextColor(context)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _carreraColor),
                      ),
                      hintText: 'ejemplo@gmail.com',
                      hintStyle: TextStyle(
                        color: _getSecondaryTextColor(context),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.email, color: _carreraColor),
                        onPressed: () {
                          _autoCompletarEmail();
                        },
                      ),
                      errorStyle: TextStyle(color: AppColors.error),
                      filled: true,
                      fillColor: _getInputFillColor(context),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  SizedBox(height: AppSpacing.small),

                  // Teléfono con validación
                  TextFormField(
                    controller: telefonoController,
                    style: TextStyle(color: _getTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Teléfono *',
                      labelStyle: TextStyle(color: _getTextColor(context)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _carreraColor),
                      ),
                      hintText: '70012345',
                      prefixText: '+591 ',
                      prefixStyle: TextStyle(color: _getTextColor(context)),
                      hintStyle: TextStyle(
                        color: _getSecondaryTextColor(context),
                      ),
                      errorStyle: TextStyle(color: AppColors.error),
                      filled: true,
                      fillColor: _getInputFillColor(context),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => Validators.validatePhone(value),
                  ),
                  SizedBox(height: AppSpacing.small),

                  // Estado
                  DropdownButtonFormField<String>(
                    value: selectedEstado,
                    dropdownColor: _getCardColor(context),
                    style: TextStyle(color: _getTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Estado *',
                      labelStyle: TextStyle(color: _getTextColor(context)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _getBorderColor(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _carreraColor),
                      ),
                      errorStyle: TextStyle(color: AppColors.error),
                      filled: true,
                      fillColor: _getInputFillColor(context),
                    ),
                    items: [Estados.activo, Estados.inactivo].map((estado) {
                      return DropdownMenuItem(
                        value: estado,
                        child: Text(
                          estado,
                          style: TextStyle(color: _getTextColor(context)),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedEstado = value!;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Seleccione un estado' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: AppTextStyles.body.copyWith(
                  color: _getTextColor(context),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Formatear teléfono si es necesario
                  String telefonoFormateado = telefonoController.text;
                  if (!telefonoFormateado.startsWith('+591')) {
                    if (RegExp(r'^\d+$').hasMatch(telefonoFormateado)) {
                      telefonoFormateado = '+591$telefonoFormateado';
                    }
                  }

                  _saveDocente(
                    isEditing: isEditing,
                    id: docente?['id'] as int?,
                    ci: ciController.text,
                    apellidoPaterno: apellidoPaternoController.text
                        .trim()
                        .toUpperCase(),
                    apellidoMaterno: apellidoMaternoController.text
                        .trim()
                        .toUpperCase(),
                    nombres: nombresController.text.trim().toUpperCase(),
                    carrera: selectedCarrera,
                    turno: selectedTurno,
                    email: emailController.text.trim(),
                    telefono: telefonoFormateado,
                    estado: selectedEstado,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _carreraColor),
              child: Text(
                isEditing ? 'Actualizar' : 'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveDocente({
    required bool isEditing,
    required int? id,
    required String ci,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String nombres,
    required String carrera,
    required String turno,
    required String email,
    required String telefono,
    required String estado,
  }) {
    setState(() {
      if (isEditing) {
        final index = _docentes.indexWhere((d) => d['id'] == id);
        if (index != -1) {
          _docentes[index] = {
            'id': id,
            'ci': ci,
            'apellidoPaterno': apellidoPaterno,
            'apellidoMaterno': apellidoMaterno,
            'nombres': nombres,
            'carrera': carrera,
            'turno': turno,
            'email': email,
            'telefono': telefono,
            'estado': estado,
          };
        }
      } else {
        final newId = _docentes.isNotEmpty
            ? (_docentes.last['id'] as int) + 1
            : 1;
        _docentes.add({
          'id': newId,
          'ci': ci,
          'apellidoPaterno': apellidoPaterno,
          'apellidoMaterno': apellidoMaterno,
          'nombres': nombres,
          'carrera': carrera,
          'turno': turno,
          'email': email,
          'telefono': telefono,
          'estado': estado,
        });

        // Agregar la carrera a la lista si es nueva
        if (!_carreras.contains(carrera)) {
          _carreras.add(carrera);
        }
      }
      _filterDocentesByCarreraAndTurno();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Docente actualizado' : 'Docente agregado'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _confirmDeleteDocente(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(context),
        title: Text(
          'Confirmar Eliminación',
          style: TextStyle(color: _getTextColor(context)),
        ),
        content: Text(
          '¿Está seguro de eliminar este docente?',
          style: TextStyle(color: _getTextColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: _getTextColor(context)),
            ),
          ),
          TextButton(
            onPressed: () {
              _deleteDocente(id);
              Navigator.pop(context);
            },
            child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _deleteDocente(int id) {
    setState(() {
      _docentes.removeWhere((d) => d['id'] == id);
      _filterDocentesByCarreraAndTurno();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Docente eliminado'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: _getTextColor(context),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: _getSecondaryTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar las tarjetas de turnos
  Widget _buildTurnosCards() {
    final estadisticas = _getEstadisticasPorTurno();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seleccione un turno:',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: _getTextColor(context),
            ),
          ),
          SizedBox(height: AppSpacing.small),
          Row(
            children: [
              _buildTurnoCard(
                'MAÑANA',
                estadisticas['MAÑANA']!,
                Icons.wb_sunny,
                Colors.orange,
              ),
              SizedBox(width: AppSpacing.small),
              _buildTurnoCard(
                'NOCHE',
                estadisticas['NOCHE']!,
                Icons.nights_stay,
                Colors.blue,
              ),
              SizedBox(width: AppSpacing.small),
              _buildTurnoCard(
                'AMBOS',
                estadisticas['AMBOS']!,
                Icons.all_inclusive,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTurnoCard(
    String turno,
    int cantidad,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedTurno == turno;

    return Expanded(
      child: Card(
        color: isSelected ? color.withOpacity(0.2) : _getCardColor(context),
        elevation: 2,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTurno = turno;
              _filterDocentesByCarreraAndTurno();
            });
          },
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? color : _getSecondaryTextColor(context),
                ),
                SizedBox(height: AppSpacing.small),
                Text(
                  turno,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? color : _getTextColor(context),
                  ),
                ),
                Text(
                  '$cantidad docentes',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estadisticas = _getEstadisticasPorTurno();

    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Docentes - $_selectedCarrera',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: _carreraColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDocenteDialog(),
        backgroundColor: _carreraColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Selector de Carrera
          Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: DropdownButtonFormField<String>(
              value: _selectedCarrera,
              dropdownColor: _getCardColor(context),
              style: TextStyle(color: _getTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Carrera',
                labelStyle: TextStyle(color: _getTextColor(context)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _carreraColor),
                ),
                prefixIcon: Icon(Icons.school, color: _carreraColor),
                filled: true,
                fillColor: _getInputFillColor(context),
              ),
              items: _carreras.map((carrera) {
                return DropdownMenuItem(
                  value: carrera,
                  child: Text(
                    carrera,
                    style: TextStyle(color: _getTextColor(context)),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCarrera = value!;
                  _selectedTurno = 'MAÑANA';
                  _filterDocentesByCarreraAndTurno();
                });
              },
            ),
          ),

          // Tarjetas de Turnos
          _buildTurnosCards(),

          // Resumen de la selección actual
          Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.medium),
              decoration: BoxDecoration(
                color: _carreraColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: _carreraColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedCarrera',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _carreraColor,
                        ),
                      ),
                      Text(
                        'Turno: $_selectedTurno',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          color: _getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total: ${estadisticas['TOTAL']} docentes',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getTextColor(context),
                        ),
                      ),
                      Text(
                        'Mostrando: ${_filteredDocentes.length}',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          color: _getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: TextFormField(
              controller: _searchController,
              style: TextStyle(color: _getTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Buscar docente...',
                labelStyle: TextStyle(color: _getTextColor(context)),
                prefixIcon: Icon(Icons.search, color: _carreraColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: BorderSide(color: _getBorderColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: BorderSide(color: _carreraColor),
                ),
                filled: true,
                fillColor: _getInputFillColor(context),
              ),
              onChanged: _filterDocentes,
            ),
          ),

          SizedBox(height: AppSpacing.medium),

          // Lista de docentes
          Expanded(
            child: _filteredDocentes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: _getSecondaryTextColor(context),
                        ),
                        SizedBox(height: AppSpacing.medium),
                        Text(
                          'No hay docentes en $_selectedCarrera',
                          style: AppTextStyles.body.copyWith(
                            color: _getSecondaryTextColor(context),
                          ),
                        ),
                        Text(
                          'Turno: $_selectedTurno',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            color: _getSecondaryTextColor(context),
                          ),
                        ),
                        SizedBox(height: AppSpacing.medium),
                        ElevatedButton(
                          onPressed: () => _showAddEditDocenteDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _carreraColor,
                          ),
                          child: Text(
                            'Agregar Primer Docente',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredDocentes.length,
                    itemBuilder: (context, index) {
                      final docente = _filteredDocentes[index];
                      return Card(
                        color: _getCardColor(context),
                        margin: EdgeInsets.symmetric(
                          horizontal: AppSpacing.medium,
                          vertical: AppSpacing.small,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _carreraColor,
                            child: Text(
                              '${(docente['apellidoPaterno'] as String)[0]}${(docente['apellidoMaterno'] as String)[0]}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            '${docente['nombres']}',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(context),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${docente['apellidoPaterno']} ${docente['apellidoMaterno']}',
                                style: AppTextStyles.body.copyWith(
                                  color: _getTextColor(context),
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    size: 12,
                                    color: _getSecondaryTextColor(context),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'CI: ${docente['ci']}',
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 12,
                                      color: _getSecondaryTextColor(context),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getTurnoColor(
                                        docente['turno'] as String,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      docente['turno'] as String,
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 10,
                                        color: _getTurnoColor(
                                          docente['turno'] as String,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: _carreraColor),
                            onSelected: (value) {
                              switch (value) {
                                case 'ver':
                                  _showDocenteDetails(docente);
                                  break;
                                case 'editar':
                                  _showAddEditDocenteDialog(docente: docente);
                                  break;
                                case 'eliminar':
                                  _confirmDeleteDocente(docente['id'] as int);
                                  break;
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                value: 'ver',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.visibility,
                                      color: _carreraColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Ver Información',
                                      style: TextStyle(
                                        color: _getTextColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'editar',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: _carreraColor),
                                    SizedBox(width: 8),
                                    Text(
                                      'Modificar',
                                      style: TextStyle(
                                        color: _getTextColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'eliminar',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: AppColors.error),
                                    SizedBox(width: 8),
                                    Text(
                                      'Eliminar',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showDocenteDetails(docente),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getTurnoColor(String turno) {
    switch (turno) {
      case 'MAÑANA':
        return Colors.orange;
      case 'NOCHE':
        return Colors.blue;
      case 'AMBOS':
        return Colors.purple;
      default:
        return _carreraColor;
    }
  }
}
