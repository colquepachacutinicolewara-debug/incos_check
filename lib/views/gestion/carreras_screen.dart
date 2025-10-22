import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';

class CarreraScreen extends StatefulWidget {
  const CarreraScreen({super.key});

  @override
  State<CarreraScreen> createState() => _CarreraScreenState();
}

class _CarreraScreenState extends State<CarreraScreen> {
  final List<Map<String, dynamic>> _carreras = [
    {
      'id': 1,
      'nombre': 'INGENIERÍA DE SISTEMAS',
      'codigo': 'SIS-001',
      'duracion': '5 Años',
      'estudiantes': 45,
      'estado': Estados.activo,
    },
    {
      'id': 2,
      'nombre': 'ADMINISTRACIÓN DE EMPRESAS',
      'codigo': 'ADM-001',
      'duracion': '4 Años',
      'estudiantes': 38,
      'estado': Estados.activo,
    },
    {
      'id': 3,
      'nombre': 'CONTADURÍA PÚBLICA',
      'codigo': 'CON-001',
      'duracion': '4 Años',
      'estudiantes': 42,
      'estado': Estados.activo,
    },
    {
      'id': 4,
      'nombre': 'INGENIERÍA COMERCIAL',
      'codigo': 'ICO-001',
      'duracion': '5 Años',
      'estudiantes': 28,
      'estado': Estados.inactivo,
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCarreras = [];

  @override
  void initState() {
    super.initState();
    _filteredCarreras = _carreras;
  }

  void _filterCarreras(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCarreras = _carreras;
      } else {
        _filteredCarreras = _carreras.where((carrera) {
          final nombre = carrera['nombre'].toString().toLowerCase();
          final codigo = carrera['codigo'].toString().toLowerCase();
          return nombre.contains(query.toLowerCase()) || codigo.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showCarreraDetails(Map<String, dynamic> carrera) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Detalles de la Carrera',
          style: AppTextStyles.heading2,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Código:', carrera['codigo']),
              _buildDetailRow('Nombre:', carrera['nombre']),
              _buildDetailRow('Duración:', carrera['duracion']),
              _buildDetailRow('Estudiantes:', '${carrera['estudiantes']}'),
              _buildDetailRow('Estado:', carrera['estado']),
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
          'Gestión de Carreras',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.warning,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar carrera...',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              onChanged: _filterCarreras,
            ),
          ),
          
          // Resumen
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Carreras: ${_filteredCarreras.length}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Estudiantes: ${_carreras.fold<int>(0, (sum, carrera) => sum + (carrera['estudiantes'] as int))}',

                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: AppSpacing.small),
          
          // Lista de carreras
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCarreras.length,
              itemBuilder: (context, index) {
                final carrera = _filteredCarreras[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium,
                    vertical: AppSpacing.small,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.warning,
                      child: Icon(Icons.school, color: Colors.white),
                    ),
                    title: Text(
                      carrera['nombre'],
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Código: ${carrera['codigo']}'),
                        Text('${carrera['estudiantes']} estudiantes • ${carrera['duracion']}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        carrera['estado'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: carrera['estado'] == Estados.activo 
                          ? AppColors.success 
                          : AppColors.error,
                    ),
                    onTap: () => _showCarreraDetails(carrera),
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