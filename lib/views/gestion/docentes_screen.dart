import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';

class DocentesScreen extends StatefulWidget {
  const DocentesScreen({super.key});

  @override
  State<DocentesScreen> createState() => _DocentesScreenState();
}

class _DocentesScreenState extends State<DocentesScreen> {
  final List<Map<String, dynamic>> _docentes = [
    {
      'id': 1,
      'apellidoPaterno': 'FERNANDEZ',
      'apellidoMaterno': 'GARCIA',
      'nombres': 'MARIA ELENA',
      'ci': '6543210',
      'especialidad': 'SISTEMAS INFORMÁTICOS',
      'email': 'mfernandez@incos.edu.bo',
      'telefono': '+591 70012345',
      'estado': Estados.activo,
    },
    {
      'id': 2,
      'apellidoPaterno': 'BUSTOS',
      'apellidoMaterno': 'MARTINEZ',
      'nombres': 'CARLOS ALBERTO',
      'ci': '6543211',
      'especialidad': 'ADMINISTRACIÓN',
      'email': 'cbustos@incos.edu.bo',
      'telefono': '+591 70012346',
      'estado': Estados.activo,
    },
    {
      'id': 3,
      'apellidoPaterno': 'LOPEZ',
      'apellidoMaterno': 'ROJAS',
      'nombres': 'ANA MARIA',
      'ci': '6543212',
      'especialidad': 'CONTADURÍA',
      'email': 'alopez@incos.edu.bo',
      'telefono': '+591 70012347',
      'estado': Estados.activo,
    },
    {
      'id': 4,
      'apellidoPaterno': 'PEREZ',
      'apellidoMaterno': 'CASTRO',
      'nombres': 'JUAN CARLOS',
      'ci': '6543213',
      'especialidad': 'MATEMÁTICAS',
      'email': 'jperez@incos.edu.bo',
      'telefono': '+591 70012348',
      'estado': Estados.inactivo,
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredDocentes = [];

  @override
  void initState() {
    super.initState();
    _filteredDocentes = _docentes;
    _sortDocentesAlphabetically();
  }

  void _sortDocentesAlphabetically() {
    _filteredDocentes.sort((a, b) {
      int comparePaterno = a['apellidoPaterno'].compareTo(b['apellidoPaterno']);
      if (comparePaterno != 0) return comparePaterno;
      
      int compareMaterno = a['apellidoMaterno'].compareTo(b['apellidoMaterno']);
      if (compareMaterno != 0) return compareMaterno;
      
      return a['nombres'].compareTo(b['nombres']);
    });
  }

  void _filterDocentes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDocentes = _docentes;
      } else {
        _filteredDocentes = _docentes.where((docente) {
          final nombreCompleto = '${docente['apellidoPaterno']} ${docente['apellidoMaterno']} ${docente['nombres']}'.toLowerCase();
          final especialidad = docente['especialidad'].toString().toLowerCase();
          final ci = docente['ci'].toString().toLowerCase();
          return nombreCompleto.contains(query.toLowerCase()) || 
                 especialidad.contains(query.toLowerCase()) ||
                 ci.contains(query.toLowerCase());
        }).toList();
      }
      _sortDocentesAlphabetically();
    });
  }

  void _showDocenteDetails(Map<String, dynamic> docente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Detalles del Docente',
          style: AppTextStyles.heading2,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('CI:', docente['ci']),
              _buildDetailRow('Apellido Paterno:', docente['apellidoPaterno']),
              _buildDetailRow('Apellido Materno:', docente['apellidoMaterno']),
              _buildDetailRow('Nombres:', docente['nombres']),
              _buildDetailRow('Especialidad:', docente['especialidad']),
              _buildDetailRow('Email:', docente['email']),
              _buildDetailRow('Teléfono:', docente['telefono']),
              _buildDetailRow('Estado:', docente['estado']),
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
          'Gestión de Docentes',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: UserThemeColors.docente,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar docente...',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              onChanged: _filterDocentes,
            ),
          ),
          
          // Resumen
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Docentes: ${_filteredDocentes.length}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Activos: ${_docentes.where((d) => d['estado'] == Estados.activo).length}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: AppSpacing.small),
          
          // Lista de docentes
          Expanded(
            child: ListView.builder(
              itemCount: _filteredDocentes.length,
              itemBuilder: (context, index) {
                final docente = _filteredDocentes[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium,
                    vertical: AppSpacing.small,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: UserThemeColors.docente,
                      child: Text(
                        '${docente['apellidoPaterno'][0]}${docente['apellidoMaterno'][0]}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${docente['apellidoPaterno']} ${docente['apellidoMaterno']}',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(docente['nombres']),
                        Text('Especialidad: ${docente['especialidad']}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        docente['estado'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: docente['estado'] == Estados.activo 
                          ? AppColors.success 
                          : AppColors.error,
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
}