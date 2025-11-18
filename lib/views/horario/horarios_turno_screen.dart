// views/horarios/horarios_turno_screen.dart
import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import '../../views/horario/horario_detalle_screen.dart';

class HorariosTurnoScreen extends StatefulWidget {
  final String turno;

  const HorariosTurnoScreen({super.key, required this.turno});

  @override
  State<HorariosTurnoScreen> createState() => _HorariosTurnoScreenState();
}

class _HorariosTurnoScreenState extends State<HorariosTurnoScreen> {
  String _anioSeleccionado = 'Todos';

  @override
  Widget build(BuildContext context) {
    final isNoche = widget.turno == 'Noche';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Horarios - Turno ${widget.turno}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isNoche ? Colors.indigo : Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarDialogoAgregarHorario(context),
            tooltip: 'Agregar horario',
          ),
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            onPressed: () => _mostrarOpcionesAvanzadas(context),
            tooltip: 'Opciones avanzadas',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          _buildFiltrosSection(),
          
          // Cards de años
          Expanded(
            child: _buildAniosSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosSection() {
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
          Icon(
            widget.turno == 'Noche' ? Icons.nights_stay : Icons.wb_sunny,
            color: widget.turno == 'Noche' ? Colors.indigo : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            'Filtrar por año:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: _anioSeleccionado,
              isExpanded: true,
              style: TextStyle(color: AppColors.textPrimary),
              items: ['Todos', 'Primer Año', 'Segundo Año', 'Tercer Año']
                  .map((anio) => DropdownMenuItem(
                        value: anio,
                        child: Text(anio),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _anioSeleccionado = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAniosSection(BuildContext context) {
    final anios = ['Primer Año', 'Segundo Año', 'Tercer Año'];
    final paralelos = ['A', 'B'];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: anios.length,
      itemBuilder: (context, indexAnio) {
        final anio = anios[indexAnio];
        
        // Si hay filtro aplicado, mostrar solo el año seleccionado
        if (_anioSeleccionado != 'Todos' && _anioSeleccionado != anio) {
          return const SizedBox();
        }
        
        return _buildAnioCard(context, anio, paralelos);
      },
    );
  }

  Widget _buildAnioCard(BuildContext context, String anio, List<String> paralelos) {
    final colorAnio = _obtenerColorAnio(anio);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del año
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorAnio.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school,
                    color: colorAnio,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  anio,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorAnio,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    '${_obtenerCantidadParalelos(anio)} paralelos',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: colorAnio,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Cards de paralelos
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: paralelos.length,
              itemBuilder: (context, index) {
                final paralelo = paralelos[index];
                return _buildParaleloCard(context, anio, paralelo, colorAnio);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParaleloCard(BuildContext context, String anio, String paralelo, Color color) {
    final horarioCompleto = _obtenerHorarioCompleto(anio, paralelo);
    
    return GestureDetector(
      onTap: () => _navigateToHorarioDetalle(context, anio, paralelo),
      onLongPress: () => _mostrarOpcionesParalelo(context, anio, paralelo),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      paralelo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Paralelo $paralelo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                horarioCompleto,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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

  int _obtenerCantidadParalelos(String anio) {
    return 2; // A y B para todos los años
  }

  String _obtenerHorarioCompleto(String anio, String paralelo) {
    // Aquí iría la lógica para obtener el horario específico
    return 'Lun-Vie ${widget.turno == 'Noche' ? '19:00-22:00' : '7:00-12:00'}';
  }

  void _navigateToHorarioDetalle(BuildContext context, String anio, String paralelo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HorarioDetalleScreen(
          turno: widget.turno,
          anio: anio,
          paralelo: paralelo,
        ),
      ),
    );
  }

  void _mostrarOpcionesParalelo(BuildContext context, String anio, String paralelo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.blue),
              title: const Text('Ver horario completo'),
              onTap: () {
                Navigator.pop(context);
                _navigateToHorarioDetalle(context, anio, paralelo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.orange),
              title: const Text('Editar horario'),
              onTap: () {
                Navigator.pop(context);
                _editarHorarioCompleto(context, anio, paralelo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: Colors.green),
              title: const Text('Asignar docentes'),
              onTap: () {
                Navigator.pop(context);
                _asignarDocentes(context, anio, paralelo);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar horario'),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminarHorario(context, anio, paralelo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoAgregarHorario(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nuevo Horario'),
        content: const Text('¿Deseas crear un nuevo horario para este turno?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navegar a pantalla de creación de horario
            },
            child: const Text('Crear Horario'),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionesAvanzadas(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.download, color: Colors.blue),
              title: Text('Exportar horarios'),
              subtitle: Text('Descargar en PDF o Excel'),
            ),
            const ListTile(
              leading: Icon(Icons.print, color: Colors.green),
              title: Text('Imprimir horarios'),
            ),
            const ListTile(
              leading: Icon(Icons.sync, color: Colors.orange),
              title: Text('Sincronizar con sistema'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Configuración de horarios'),
              onTap: () {
                Navigator.pop(context);
                // Navegar a configuración
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editarHorarioCompleto(BuildContext context, String anio, String paralelo) {
    // Implementar edición completa del horario
  }

  void _asignarDocentes(BuildContext context, String anio, String paralelo) {
    // Implementar asignación de docentes
  }

  void _confirmarEliminarHorario(BuildContext context, String anio, String paralelo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Horario'),
        content: Text('¿Estás seguro de eliminar el horario de $anio Paralelo $paralelo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar eliminación
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}