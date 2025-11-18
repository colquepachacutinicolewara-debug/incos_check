// views/horarios/horario_detalle_screen.dart
import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';

class HorarioDetalleScreen extends StatefulWidget {
  final String turno;
  final String anio;
  final String paralelo;

  const HorarioDetalleScreen({
    super.key,
    required this.turno,
    required this.anio,
    required this.paralelo,
  });

  @override
  State<HorarioDetalleScreen> createState() => _HorarioDetalleScreenState();
}

class _HorarioDetalleScreenState extends State<HorarioDetalleScreen> {
  final List<String> _dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];
  final List<String> _horas = ['19:00-20:00', '20:00-21:00', '21:00-22:00'];

  @override
  Widget build(BuildContext context) {
    final colorAnio = _obtenerColorAnio(widget.anio);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${widget.anio} ${widget.paralelo}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorAnio,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editarHorario(context),
            tooltip: 'Editar horario',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _compartirHorario(context),
            tooltip: 'Compartir horario',
          ),
        ],
      ),
      body: Column(
        children: [
          // Información del horario
          _buildInfoHeader(colorAnio),
          
          // Tabla de horarios
          Expanded(
            child: _buildTablaHorarios(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoHeader(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.turno == 'Noche' ? Icons.nights_stay : Icons.wb_sunny,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.anio} - Paralelo ${widget.paralelo}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Turno ${widget.turno} • ${_obtenerHorarioCompleto()}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Chip(
            label: const Text(
              'ACTIVO',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            backgroundColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildTablaHorarios(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header de la tabla
              _buildTablaHeader(),
              const SizedBox(height: 8),
              
              // Contenido de la tabla
              Expanded(
                child: _buildTablaContenido(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTablaHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Celda de horas (más ancha)
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Text(
              'HORA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
          
          // Días de la semana
          ..._dias.map((dia) => Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.border)),
              ),
              child: Text(
                dia.substring(0, 3).toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTablaContenido(BuildContext context) {
    return ListView.builder(
      itemCount: _horas.length,
      itemBuilder: (context, indexHora) {
        final hora = _horas[indexHora];
        return _buildFilaHorario(context, hora, indexHora);
      },
    );
  }

  Widget _buildFilaHorario(BuildContext context, String hora, int indexHora) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Celda de hora
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hora.split('-')[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  hora.split('-')[1],
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          
          // Celdas de materias por día
          ..._dias.map((dia) => Expanded(
            child: _buildCeldaMateria(context, dia, hora, indexHora),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildCeldaMateria(BuildContext context, String dia, String hora, int indexHora) {
    final materiaInfo = _obtenerMateriaInfo(widget.anio, widget.paralelo, dia, hora);
    
    return GestureDetector(
      onTap: () => _editarCeldaHorario(context, dia, hora, materiaInfo),
      onLongPress: () => _mostrarOpcionesCelda(context, dia, hora, materiaInfo),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.border)),
          color: materiaInfo['color']?.withOpacity(0.1) ?? Colors.transparent,
        ),
        height: 80,
        child: materiaInfo['materia'] != null 
            ? _buildCeldaConMateria(materiaInfo)
            : _buildCeldaVacia(),
      ),
    );
  }

  Widget _buildCeldaConMateria(Map<String, dynamic> materiaInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nombre de la materia
        Text(
          materiaInfo['materia'] ?? '',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: materiaInfo['color'],
            fontSize: 10,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 2),
        
        // Nombre del docente
        Text(
          materiaInfo['docente'] ?? '',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 8,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCeldaVacia() {
    return Center(
      child: Icon(
        Icons.add,
        size: 20,
        color: AppColors.textSecondary.withOpacity(0.5),
      ),
    );
  }

  Map<String, dynamic> _obtenerMateriaInfo(String anio, String paralelo, String dia, String hora) {
    // Aquí iría la lógica para obtener la información real de la base de datos
    // Por ahora retornamos datos de ejemplo
    final materiasEjemplo = {
      'Primer Año': {
        'A': {
          'Lunes': {
            '19:00-20:00': {
              'materia': 'Hardware de Computadoras',
              'docente': 'Omar Condori',
              'color': Colors.blue,
            },
          },
        },
      },
      // ... más datos de ejemplo
    };
    
    return materiasEjemplo[anio]?[paralelo]?[dia]?[hora] ?? {};
  }

  Color _obtenerColorAnio(String anio) {
    switch (anio) {
      case 'Primer Año': return Colors.blue;
      case 'Segundo Año': return Colors.green;
      case 'Tercer Año': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _obtenerHorarioCompleto() {
    return widget.turno == 'Noche' ? '19:00 - 22:00' : '7:00 - 12:00';
  }

  void _editarHorario(BuildContext context) {
    // Navegar a pantalla de edición completa
  }

  void _compartirHorario(BuildContext context) {
    // Implementar compartir horario
  }

  void _editarCeldaHorario(BuildContext context, String dia, String hora, Map<String, dynamic> materiaInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Horario - $dia $hora'),
        content: SizedBox(
          width: double.maxFinite,
          child: _buildFormularioEdicion(materiaInfo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Guardar cambios
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioEdicion(Map<String, dynamic> materiaInfo) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField(
          decoration: const InputDecoration(labelText: 'Materia'),
          items: [], // Lista de materias disponibles
          onChanged: (value) {},
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField(
          decoration: const InputDecoration(labelText: 'Docente'),
          items: [], // Lista de docentes disponibles
          onChanged: (value) {},
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField(
          decoration: const InputDecoration(labelText: 'Color'),
          items: [], // Lista de colores
          onChanged: (value) {},
        ),
      ],
    );
  }

  void _mostrarOpcionesCelda(BuildContext context, String dia, String hora, Map<String, dynamic> materiaInfo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Editar asignación'),
              onTap: () {
                Navigator.pop(context);
                _editarCeldaHorario(context, dia, hora, materiaInfo);
              },
            ),
            if (materiaInfo['materia'] != null) ...[
              ListTile(
                leading: const Icon(Icons.person, color: Colors.green),
                title: const Text('Cambiar docente'),
                onTap: () {
                  Navigator.pop(context);
                  _cambiarDocente(context, dia, hora, materiaInfo);
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.orange),
                title: const Text('Mover horario'),
                onTap: () {
                  Navigator.pop(context);
                  _moverHorario(context, dia, hora, materiaInfo);
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: Icon(
                materiaInfo['materia'] != null ? Icons.clear : Icons.add,
                color: materiaInfo['materia'] != null ? Colors.red : Colors.green,
              ),
              title: Text(
                materiaInfo['materia'] != null ? 'Eliminar asignación' : 'Agregar materia',
              ),
              onTap: () {
                Navigator.pop(context);
                if (materiaInfo['materia'] != null) {
                  _eliminarAsignacion(context, dia, hora);
                } else {
                  _editarCeldaHorario(context, dia, hora, materiaInfo);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _cambiarDocente(BuildContext context, String dia, String hora, Map<String, dynamic> materiaInfo) {
    // Implementar cambio de docente
  }

  void _moverHorario(BuildContext context, String dia, String hora, Map<String, dynamic> materiaInfo) {
    // Implementar mover horario
  }

  void _eliminarAsignacion(BuildContext context, String dia, String hora) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Asignación'),
        content: const Text('¿Estás seguro de eliminar esta asignación de horario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Eliminar asignación
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}