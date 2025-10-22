import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';
import 'widgets/registro_estudiante_widget.dart';

class EstudiantesScreen extends StatefulWidget {
  final String carrera;
  final String turno;
  final String curso;
  final String codigoCurso;

  const EstudiantesScreen({
    super.key,
    required this.carrera,
    required this.turno,
    required this.curso,
    required this.codigoCurso,
  });

  @override
  State<EstudiantesScreen> createState() => _EstudiantesScreenState();
}

class _EstudiantesScreenState extends State<EstudiantesScreen> {
  List<Map<String, dynamic>> _estudiantes = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredEstudiantes = [];

  @override
  void initState() {
    super.initState();
    _cargarEstudiantesIniciales();
    _filteredEstudiantes = _estudiantes;
    _sortEstudiantesAlphabetically();
  }

  void _cargarEstudiantesIniciales() {
    _estudiantes = [
      {
        'id': DateTime.now().millisecondsSinceEpoch + 1,
        'apellidoPaterno': 'ALVAREZ',
        'apellidoMaterno': 'GOMEZ',
        'nombres': 'CARLOS ANDRES',
        'ci': '1234567',
        'huellaRegistrada': true,
        'email': 'carlos.alvarez@incos.edu.bo',
        'telefono': '+59170012345',
        'estado': Estados.activo,
      },
      {
        'id': DateTime.now().millisecondsSinceEpoch + 2,
        'apellidoPaterno': 'BUSTOS',
        'apellidoMaterno': 'FERNANDEZ',
        'nombres': 'MARIA FERNANDA',
        'ci': '1234568',
        'huellaRegistrada': true,
        'email': 'maria.bustos@incos.edu.bo',
        'telefono': '+59170012346',
        'estado': Estados.activo,
      },
    ];
  }

  void _sortEstudiantesAlphabetically() {
    _filteredEstudiantes.sort((a, b) {
      int comparePaterno = a['apellidoPaterno'].compareTo(b['apellidoPaterno']);
      if (comparePaterno != 0) return comparePaterno;
      int compareMaterno = a['apellidoMaterno'].compareTo(b['apellidoMaterno']);
      if (compareMaterno != 0) return compareMaterno;
      return a['nombres'].compareTo(b['nombres']);
    });
  }

  void _filterEstudiantes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEstudiantes = _estudiantes;
      } else {
        _filteredEstudiantes = _estudiantes.where((estudiante) {
          final nombreCompleto = '${estudiante['apellidoPaterno']} ${estudiante['apellidoMaterno']} ${estudiante['nombres']}'.toLowerCase();
          final ci = estudiante['ci'].toString().toLowerCase();
          return nombreCompleto.contains(query.toLowerCase()) || ci.contains(query.toLowerCase());
        }).toList();
      }
      _sortEstudiantesAlphabetically();
    });
  }

  void _agregarEstudiante(Map<String, dynamic> nuevoEstudiante) {
    setState(() {
      _estudiantes.add(nuevoEstudiante);
      _filteredEstudiantes = _estudiantes;
      _sortEstudiantesAlphabetically();
    });
    Helpers.showSnackBar(context, 'Estudiante agregado exitosamente', type: 'success');
  }

  void _editarEstudiante(int index, Map<String, dynamic> estudianteActualizado) {
    setState(() {
      _estudiantes[index] = estudianteActualizado;
      _filteredEstudiantes = _estudiantes;
      _sortEstudiantesAlphabetically();
    });
    Helpers.showSnackBar(context, 'Estudiante actualizado exitosamente', type: 'success');
  }

  void _eliminarEstudiante(int index) {
    final estudiante = _filteredEstudiantes[index];
    Helpers.showConfirmationDialog(
      context,
      title: 'Eliminar Estudiante',
      content: '¿Estás seguro de eliminar a ${estudiante['nombres']} ${estudiante['apellidoPaterno']}?',
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          _estudiantes.removeWhere((e) => e['id'] == estudiante['id']);
          _filteredEstudiantes = _estudiantes;
          _sortEstudiantesAlphabetically();
        });
        Helpers.showSnackBar(context, 'Estudiante eliminado exitosamente', type: 'success');
      }
    });
  }

  void _showEstudianteDetails(int index) {
    final estudiante = _filteredEstudiantes[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del Estudiante', style: AppTextStyles.heading2),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('CI:', estudiante['ci']),
              _buildDetailRow('Apellido Paterno:', estudiante['apellidoPaterno']),
              _buildDetailRow('Apellido Materno:', estudiante['apellidoMaterno']),
              _buildDetailRow('Nombres:', estudiante['nombres']),
              _buildDetailRow('Email:', estudiante['email']),
              _buildDetailRow('Teléfono:', estudiante['telefono']),
              _buildDetailRow('Huella Registrada:', estudiante['huellaRegistrada'] ? 'SÍ' : 'NO'),
              _buildDetailRow('Estado:', estudiante['estado']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }

  void _navigateToRegistro({Map<String, dynamic>? estudiante, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroEstudianteWidget(
          estudianteExistente: estudiante,
          onEstudianteGuardado: (nuevoEstudiante) {
            if (index != null) {
              _editarEstudiante(index, nuevoEstudiante);
            } else {
              _agregarEstudiante(nuevoEstudiante);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(width: 8),
          Expanded(child: Text(value, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.curso} - ${widget.turno}', style: AppTextStyles.heading2.copyWith(color: Colors.white)),
        backgroundColor: UserThemeColors.estudiante,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.white),
            onPressed: () => _navigateToRegistro(),
            tooltip: 'Registrar nuevo estudiante',
          ),
        ],
      ),
      body: Column(
        children: [
          // Información del curso
          Card(
            margin: EdgeInsets.all(AppSpacing.medium),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.carrera, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  SizedBox(height: AppSpacing.small),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Curso: ${widget.curso}', style: AppTextStyles.body),
                      Text('Código: ${widget.codigoCurso}', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  SizedBox(height: AppSpacing.small),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Turno: ${widget.turno}', style: AppTextStyles.body),
                      Text('Estudiantes: ${_filteredEstudiantes.length}', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
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
              decoration: InputDecoration(
                labelText: 'Buscar estudiante...',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.small)),
                filled: true,
                fillColor: AppColors.background,
              ),
              onChanged: _filterEstudiantes,
            ),
          ),
          
          SizedBox(height: AppSpacing.small),
          
          // Lista de estudiantes
          Expanded(
            child: ListView.builder(
              itemCount: _filteredEstudiantes.length,
              itemBuilder: (context, index) {
                final estudiante = _filteredEstudiantes[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.medium, vertical: AppSpacing.small),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: estudiante['estado'] == Estados.activo ? AppColors.success : AppColors.error,
                      child: Icon(estudiante['huellaRegistrada'] ? Icons.fingerprint : Icons.person, color: Colors.white, size: 20),
                    ),
                    title: Text('${estudiante['apellidoPaterno']} ${estudiante['apellidoMaterno']}', 
                         style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(estudiante['nombres']),
                        Row(
                          children: [
                            Icon(Icons.badge, size: 12, color: AppColors.textSecondary),
                            SizedBox(width: 4),
                            Text('CI: ${estudiante['ci']}', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 8),
                            Icon(Icons.fingerprint, size: 12, color: estudiante['huellaRegistrada'] ? AppColors.success : AppColors.error),
                            SizedBox(width: 4),
                            Text(estudiante['huellaRegistrada'] ? 'Huella OK' : 'Sin huella',
                                style: TextStyle(fontSize: 12, color: estudiante['huellaRegistrada'] ? AppColors.success : AppColors.error)),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'ver', child: Row(children: [Icon(Icons.visibility, color: AppColors.primary), SizedBox(width: 8), Text('Ver Detalles')])),
                        PopupMenuItem(value: 'editar', child: Row(children: [Icon(Icons.edit, color: AppColors.warning), SizedBox(width: 8), Text('Editar')])),
                        PopupMenuItem(value: 'eliminar', child: Row(children: [Icon(Icons.delete, color: AppColors.error), SizedBox(width: 8), Text('Eliminar')])),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'ver': _showEstudianteDetails(index); break;
                          case 'editar': _navigateToRegistro(estudiante: estudiante, index: index); break;
                          case 'eliminar': _eliminarEstudiante(index); break;
                        }
                      },
                    ),
                    onTap: () => _showEstudianteDetails(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToRegistro(),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.person_add, color: Colors.white, size: 28),
        tooltip: 'Registrar nuevo estudiante',
      ),
    );
  }
}