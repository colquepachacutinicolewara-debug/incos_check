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

  // Datos de horarios para Tercer Año B (ejemplo)
  final Map<String, Map<String, Map<String, dynamic>>> _horariosTercerB = {
    'Lunes': {
      '19:00-20:00': {
        'materia': 'Análisis y Diseño de Sistemas II',
        'docente': 'Marisol Méndez',
        'color': Colors.purple,
      },
      '20:00-21:00': {
        'materia': 'Programación Web II',
        'docente': 'Carlos Saavedra',
        'color': Colors.blue,
      },
      '21:00-22:00': {
        'materia': 'Taller de Modelado 3D',
        'docente': 'Edith Gutiérrez',
        'color': Colors.orange,
      },
    },
    'Martes': {
      '19:00-20:00': {
        'materia': 'Programación Móviles I',
        'docente': 'Miguel Machaca',
        'color': Colors.green,
      },
      '20:00-21:00': {
        'materia': 'Programación Móviles I',
        'docente': 'Miguel Machaca',
        'color': Colors.green,
      },
      '21:00-22:00': {
        'materia': 'Diseño y Programación Web II',
        'docente': 'Carlos Saavedra',
        'color': Colors.blue,
      },
    },
    'Miércoles': {
      '19:00-20:00': {
        'materia': 'Base de Datos II',
        'docente': 'Víctor Ramos',
        'color': Colors.red,
      },
      '20:00-21:00': {
        'materia': 'Base de Datos II',
        'docente': 'Víctor Ramos',
        'color': Colors.red,
      },
      '21:00-22:00': {
        'materia': 'Diseño y Programación Web II',
        'docente': 'Carlos Saavedra',
        'color': Colors.blue,
      },
    },
    'Jueves': {
      '19:00-20:00': {
        'materia': 'Emprendimiento Productivo',
        'docente': 'Fredy Huiza',
        'color': Colors.teal,
      },
      '20:00-21:00': {
        'materia': 'Taller de Modelado 3D',
        'docente': 'Edith Gutiérrez',
        'color': Colors.orange,
      },
      '21:00-22:00': {
        'materia': 'Emprendimiento Productivo',
        'docente': 'Fredy Huiza',
        'color': Colors.teal,
      },
    },
    'Viernes': {
      '19:00-20:00': {
        'materia': 'Redes de Computadoras II',
        'docente': 'Mamerito Alvarado',
        'color': Colors.indigo,
      },
      '20:00-21:00': {
        'materia': 'Programación Web II',
        'docente': 'Carlos Saavedra',
        'color': Colors.blue,
      },
      '21:00-22:00': {
        'materia': 'Emprendimiento Productivo',
        'docente': 'Fredy Huiza',
        'color': Colors.teal,
      },
    },
  };

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.turno == 'Noche' ? Icons.nights_stay : Icons.wb_sunny,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.anio} - Paralelo ${widget.paralelo}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Turno ${widget.turno} • Horario: ${_obtenerHorarioCompleto()}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sistemas Informáticos - INCOS EL ALTO',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'ACTIVO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Celda de horas (más ancha)
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Text(
              'HORA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
          ),
          
          // Días de la semana
          ..._dias.map((dia) => Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.border)),
              ),
              child: Text(
                dia.substring(0, 3).toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )),
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
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          // Celda de hora
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hora.split('-')[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  hora.split('-')[1],
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          // Celdas de materias por día
          ..._dias.map((dia) => Expanded(
            child: _buildCeldaMateria(context, dia, hora),
          )),
        ],
      ),
    );
  }

  Widget _buildCeldaMateria(BuildContext context, String dia, String hora) {
    final materiaInfo = _horariosTercerB[dia]?[hora];
    
    return GestureDetector(
      onTap: () => _mostrarDetalleMateria(context, dia, hora, materiaInfo),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.border.withOpacity(0.5))),
          color: materiaInfo?['color']?.withOpacity(0.1) ?? Colors.transparent,
        ),
        height: 90,
        child: materiaInfo != null 
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
            fontWeight: FontWeight.w600,
            color: materiaInfo['color'],
            fontSize: 10,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Nombre del docente
        Text(
          materiaInfo['docente'] ?? '',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const Spacer(),
        
        // Indicador de edición
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: materiaInfo['color']?.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit,
              size: 10,
              color: materiaInfo['color'],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCeldaVacia() {
    return Center(
      child: Icon(
        Icons.add_circle_outline,
        size: 20,
        color: AppColors.textSecondary.withOpacity(0.3),
      ),
    );
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Horario Completo'),
        content: const Text('¿Deseas editar todo el horario de este paralelo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navegar a pantalla de edición completa
            },
            child: const Text('Editar Horario'),
          ),
        ],
      ),
    );
  }

  void _compartirHorario(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de compartir en desarrollo...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _mostrarDetalleMateria(BuildContext context, String dia, String hora, Map<String, dynamic>? materiaInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$dia - $hora',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (materiaInfo != null) ...[
              _buildDetalleItem('Materia:', materiaInfo['materia']),
              _buildDetalleItem('Docente:', materiaInfo['docente']),
              _buildDetalleItem('Color:', 'Asignado', color: materiaInfo['color']),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editarAsignacion(context, dia, hora, materiaInfo),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _eliminarAsignacion(context, dia, hora),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'Horario disponible',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _agregarAsignacion(context, dia, hora),
                icon: const Icon(Icons.add),
                label: const Text('Agregar Materia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          if (color != null) ...[
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _editarAsignacion(BuildContext context, String dia, String hora, Map<String, dynamic> materiaInfo) {
    Navigator.pop(context); // Cerrar el bottom sheet primero
    // Aquí iría la navegación a la pantalla de edición
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editando: ${materiaInfo['materia']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _eliminarAsignacion(BuildContext context, String dia, String hora) {
    Navigator.pop(context); // Cerrar el bottom sheet primero
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Asignación eliminada correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _agregarAsignacion(BuildContext context, String dia, String hora) {
    Navigator.pop(context); // Cerrar el bottom sheet primero
    // Aquí iría la navegación a la pantalla de agregar asignación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agregando materia para $dia $hora'),
        backgroundColor: Colors.green,
      ),
    );
  }
}