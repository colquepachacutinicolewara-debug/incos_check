import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';
import '../../views/gestion/widgets/registro_estudiante_widget.dart'; // IMPORTAR EL WIDGET DE REGISTRO

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
  final List<Map<String, dynamic>> _estudiantes = [
    {
      'id': 1,
      'apellidoPaterno': 'ALVAREZ',
      'apellidoMaterno': 'GOMEZ',
      'nombres': 'CARLOS ANDRES',
      'curso': '3RO B',
      'ci': '1234567',
      'estado': Estados.activo,
    },
    // ... el resto de estudiantes (mantener como ya lo tienes)
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredEstudiantes = [];

  @override
  void initState() {
    super.initState();
    _filteredEstudiantes = _estudiantes;
    _sortEstudiantesAlphabetically();
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

  void _showEstudianteDetails(Map<String, dynamic> estudiante) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Detalles del Estudiante',
          style: AppTextStyles.heading2,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('CI:', estudiante['ci']),
              _buildDetailRow('Apellido Paterno:', estudiante['apellidoPaterno']),
              _buildDetailRow('Apellido Materno:', estudiante['apellidoMaterno']),
              _buildDetailRow('Nombres:', estudiante['nombres']),
              _buildDetailRow('Curso:', estudiante['curso']),
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

  void _navigateToRegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistroEstudianteWidget()),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Estudiantes - ${widget.curso}',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: UserThemeColors.estudiante,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.white),
            onPressed: _navigateToRegistro,
            tooltip: 'Registrar nuevo estudiante',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar estudiante...',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              onChanged: _filterEstudiantes,
            ),
          ),

          // Información del curso y la carrera pasada desde CursosScreen
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Carrera: ${widget.carrera}',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Turno: ${widget.turno}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.small),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Curso: ${widget.curso} (${widget.codigoCurso})',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Total: ${_filteredEstudiantes.length} estudiantes',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
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
                  margin: EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium,
                    vertical: AppSpacing.small,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: estudiante['estado'] == Estados.activo
                          ? AppColors.success
                          : AppColors.error,
                      child: Text(
                        '${estudiante['apellidoPaterno'][0]}${estudiante['apellidoMaterno'][0]}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${estudiante['apellidoPaterno']} ${estudiante['apellidoMaterno']}',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      estudiante['nombres'],
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Chip(
                      label: Text(
                        estudiante['estado'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: estudiante['estado'] == Estados.activo
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    onTap: () => _showEstudianteDetails(estudiante),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToRegistro,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.person_add, color: Colors.white, size: 28),
        tooltip: 'Registrar nuevo estudiante',
      ),
    );
  }
}
