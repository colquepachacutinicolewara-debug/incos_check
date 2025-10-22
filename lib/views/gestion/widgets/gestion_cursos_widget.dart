import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';

class GestionCursosScreen extends StatefulWidget {
  const GestionCursosScreen({super.key});

  @override
  State<GestionCursosScreen> createState() => _GestionCursosScreenState();
}

class _GestionCursosScreenState extends State<GestionCursosScreen> {
  List<Map<String, dynamic>> _cursos = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCursos = [];

  @override
  void initState() {
    super.initState();
    _cargarCursosIniciales();
    _filteredCursos = _cursos;
  }

  void _cargarCursosIniciales() {
    _cursos = [
      {
        'id': DateTime.now().millisecondsSinceEpoch + 1,
        'nombre': '3RO B - SISTEMAS',
        'codigo': '3B-SIS',
        'carrera': 'INGENIERÍA DE SISTEMAS',
        'docente': 'LIC. MARIA FERNANDEZ',
        'estudiantes': 25,
        'estado': Estados.activo,
      },
      {
        'id': DateTime.now().millisecondsSinceEpoch + 2,
        'nombre': '2DO A - ADMINISTRACIÓN',
        'codigo': '2A-ADM',
        'carrera': 'ADMINISTRACIÓN DE EMPRESAS',
        'docente': 'LIC. CARLOS BUSTOS',
        'estudiantes': 30,
        'estado': Estados.activo,
      },
    ];
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

  void _agregarCurso() {
    _mostrarFormularioCurso();
  }

  void _editarCurso(int index) {
    final curso = _filteredCursos[index];
    _mostrarFormularioCurso(cursoExistente: curso, index: index);
  }

  void _eliminarCurso(int index) {
    final curso = _filteredCursos[index];
    Helpers.showConfirmationDialog(
      context,
      title: 'Eliminar Curso',
      content: '¿Estás seguro de eliminar el curso ${curso['nombre']}?',
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          _cursos.removeWhere((c) => c['id'] == curso['id']);
          _filteredCursos = _cursos;
        });
        Helpers.showSnackBar(context, 'Curso eliminado exitosamente', type: 'success');
      }
    });
  }

  void _mostrarFormularioCurso({Map<String, dynamic>? cursoExistente, int? index}) {
    final nombreController = TextEditingController(text: cursoExistente?['nombre'] ?? '');
    final codigoController = TextEditingController(text: cursoExistente?['codigo'] ?? '');
    final carreraController = TextEditingController(text: cursoExistente?['carrera'] ?? '');
    final docenteController = TextEditingController(text: cursoExistente?['docente'] ?? '');
    final estudiantesController = TextEditingController(text: cursoExistente?['estudiantes']?.toString() ?? '');
    
    String estado = cursoExistente?['estado'] ?? Estados.activo;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cursoExistente != null ? 'Editar Curso' : 'Agregar Curso', style: AppTextStyles.heading2),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre del Curso', border: OutlineInputBorder()),
              ),
              SizedBox(height: AppSpacing.small),
              TextFormField(
                controller: codigoController,
                decoration: InputDecoration(labelText: 'Código', border: OutlineInputBorder()),
              ),
              SizedBox(height: AppSpacing.small),
              TextFormField(
                controller: carreraController,
                decoration: InputDecoration(labelText: 'Carrera', border: OutlineInputBorder()),
              ),
              SizedBox(height: AppSpacing.small),
              TextFormField(
                controller: docenteController,
                decoration: InputDecoration(labelText: 'Docente', border: OutlineInputBorder()),
              ),
              SizedBox(height: AppSpacing.small),
              TextFormField(
                controller: estudiantesController,
                decoration: InputDecoration(labelText: 'Número de Estudiantes', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: AppSpacing.small),
              DropdownButtonFormField(
                value: estado,
                decoration: InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                items: [Estados.activo, Estados.inactivo].map((estado) {
                  return DropdownMenuItem(value: estado, child: Text(estado));
                }).toList(),
                onChanged: (value) => estado = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final nuevoCurso = {
                'id': cursoExistente?['id'] ?? DateTime.now().millisecondsSinceEpoch,
                'nombre': nombreController.text,
                'codigo': codigoController.text,
                'carrera': carreraController.text,
                'docente': docenteController.text,
                'estudiantes': int.tryParse(estudiantesController.text) ?? 0,
                'estado': estado,
              };

              setState(() {
                if (index != null) {
                  _cursos[index] = nuevoCurso;
                } else {
                  _cursos.add(nuevoCurso);
                }
                _filteredCursos = _cursos;
              });

              Helpers.showSnackBar(
                context, 
                cursoExistente != null ? 'Curso actualizado exitosamente' : 'Curso agregado exitosamente',
                type: 'success'
              );
              Navigator.pop(context);
            },
            child: Text(cursoExistente != null ? 'Actualizar' : 'Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Cursos', style: AppTextStyles.heading2.copyWith(color: Colors.white)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.small)),
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
                Text('Total Cursos: ${_filteredCursos.length}', 
                     style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                Text('Estudiantes: ${_cursos.fold<int>(0, (sum, curso) => sum + (curso['estudiantes'] as int))}',
                     style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),),
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
                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.medium, vertical: AppSpacing.small),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.success,
                      child: Icon(Icons.book, color: Colors.white),
                    ),
                    title: Text(curso['nombre'], style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Docente: ${curso['docente']}'),
                        Text('${curso['estudiantes']} estudiantes • ${curso['carrera']}'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'editar', child: Row(children: [Icon(Icons.edit, color: AppColors.warning), SizedBox(width: 8), Text('Editar')])),
                        PopupMenuItem(value: 'eliminar', child: Row(children: [Icon(Icons.delete, color: AppColors.error), SizedBox(width: 8), Text('Eliminar')])),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'editar': _editarCurso(index); break;
                          case 'eliminar': _eliminarCurso(index); break;
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarCurso,
        backgroundColor: AppColors.success,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Agregar nuevo curso',
      ),
    );
  }
}