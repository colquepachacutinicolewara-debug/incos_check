import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';

class CursosScreen extends StatefulWidget {
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;

  const CursosScreen({
    super.key,
    required this.carrera,
    required this.turno,
  });

  @override
  State<CursosScreen> createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  final List<Map<String, dynamic>> _cursos = [
    {
      'id': 1,
      'nombre': '3RO B - SISTEMAS',
      'codigo': '3B-SIS',
      'carrera': 'INGENIERÍA DE SISTEMAS',
      'docente': 'LIC. MARIA FERNANDEZ',
      'estudiantes': 25,
      'estado': Estados.activo,
    },
    {
      'id': 2,
      'nombre': '2DO A - ADMINISTRACIÓN',
      'codigo': '2A-ADM',
      'carrera': 'ADMINISTRACIÓN DE EMPRESAS',
      'docente': 'LIC. CARLOS BUSTOS',
      'estudiantes': 30,
      'estado': Estados.activo,
    },
    {
      'id': 3,
      'nombre': '4TO C - CONTADURÍA',
      'codigo': '4C-CON',
      'carrera': 'CONTADURÍA PÚBLICA',
      'docente': 'CPA. ANA LOPEZ',
      'estudiantes': 28,
      'estado': Estados.activo,
    },
    {
      'id': 4,
      'nombre': '1RO B - SISTEMAS',
      'codigo': '1B-SIS',
      'carrera': 'INGENIERÍA DE SISTEMAS',
      'docente': 'ING. JUAN PEREZ',
      'estudiantes': 22,
      'estado': Estados.activo,
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCursos = [];

  @override
  void initState() {
    super.initState();
    _filteredCursos = _cursos;
  }

  void _filterCursos(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCursos = _cursos;
      } else {
        _filteredCursos = _cursos.where((curso) {
          final nombre = curso['nombre'].toString().toLowerCase();
          final docente = curso['docente'].toString().toLowerCase();
          final carrera = curso['carrera'].toString().toLowerCase();
          return nombre.contains(query.toLowerCase()) ||
              docente.contains(query.toLowerCase()) ||
              carrera.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showCursoDetails(Map<String, dynamic> curso) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Detalles del Curso',
          style: AppTextStyles.heading2,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Código:', curso['codigo']),
              _buildDetailRow('Nombre:', curso['nombre']),
              _buildDetailRow('Carrera:', curso['carrera']),
              _buildDetailRow('Docente:', curso['docente']),
              _buildDetailRow('Estudiantes:', '${curso['estudiantes']}'),
              _buildDetailRow('Estado:', curso['estado']),
              _buildDetailRow('Turno:', widget.turno['nombre']),
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
          'Cursos - ${widget.carrera} (${widget.turno})',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar curso...',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              onChanged: _filterCursos,
            ),
          ),

          // Resumen
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Cursos: ${_filteredCursos.length}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Estudiantes: ${_cursos.fold<int>(0, (sum, curso) => sum + (curso['estudiantes'] as int))}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.small),

          // Lista de cursos
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCursos.length,
              itemBuilder: (context, index) {
                final curso = _filteredCursos[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium,
                    vertical: AppSpacing.small,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.success,
                      child: Icon(Icons.book, color: Colors.white),
                    ),
                    title: Text(
                      curso['nombre'],
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Docente: ${curso['docente']}'),
                        Text('${curso['estudiantes']} estudiantes • ${curso['carrera']}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        curso['estado'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: curso['estado'] == Estados.activo
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    onTap: () => _showCursoDetails(curso),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
