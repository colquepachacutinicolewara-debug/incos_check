// views/horarios/horarios_turno_screen.dart (ACTUALIZADO)
import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'horario_detalle_screen.dart';
import '../../views/horario/agregar_horario_screen.dart';

class HorariosTurnoScreen extends StatefulWidget {
  final String turno;

  const HorariosTurnoScreen({super.key, required this.turno});

  @override
  State<HorariosTurnoScreen> createState() => _HorariosTurnoScreenState();
}

class _HorariosTurnoScreenState extends State<HorariosTurnoScreen> {
  String _anioSeleccionado = 'Todos';

  // ✅ CAMBIO: Solo nombres de paralelos, sin descripciones largas
  final Map<String, List<String>> _horariosNoche = {
    'Primer Año': ['A', 'B'],
    'Segundo Año': ['A', 'B'],
    'Tercer Año': ['A', 'B'],
  };

  @override
  Widget build(BuildContext context) {
    final isNoche = widget.turno == 'Noche';
    final colorTurno = isNoche ? Colors.indigo : Colors.orange;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Horarios - Turno ${widget.turno}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorTurno,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _buscarHorario(context),
            tooltip: 'Buscar horario',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _agregarHorario(context),
            tooltip: 'Agregar horario',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header informativo
          _buildHeader(colorTurno),
          
          // Filtros
          _buildFiltrosSection(),
          
          // Lista de años
          Expanded(
            child: _buildAniosSection(colorTurno),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: color.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.turno == 'Noche' ? Icons.nights_stay : Icons.wb_sunny,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Turno ${widget.turno}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.turno == 'Noche' ? 'Horario: 19:00 - 22:00' : 'Horario: 7:00 - 12:00',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_horariosNoche.length} años',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            'Filtrar:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _anioSeleccionado,
                  isExpanded: true,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  items: ['Todos', 'Primer Año', 'Segundo Año', 'Tercer Año']
                      .map((anio) => DropdownMenuItem(
                            value: anio,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(anio),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _anioSeleccionado = value!;
                    });
                  },
                  icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAniosSection(Color colorTurno) {
    final anios = _horariosNoche.keys.toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: anios.length,
      itemBuilder: (context, index) {
        final anio = anios[index];
        
        // Si hay filtro aplicado, mostrar solo el año seleccionado
        if (_anioSeleccionado != 'Todos' && _anioSeleccionado != anio) {
          return const SizedBox();
        }
        
        return _buildAnioCard(context, anio, colorTurno);
      },
    );
  }

  Widget _buildAnioCard(BuildContext context, String anio, Color colorTurno) {
    final colorAnio = _obtenerColorAnio(anio);
    final paralelos = _horariosNoche[anio]!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header del año
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorAnio.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorAnio,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anio,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorAnio,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${paralelos.length} paralelos disponibles',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorAnio.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Turno ${widget.turno}',
                    style: TextStyle(
                      color: colorAnio,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Cards de paralelos
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2, // ✅ AJUSTADO: Más compacto
              ),
              itemCount: paralelos.length,
              itemBuilder: (context, index) {
                final paralelo = paralelos[index];
                return _buildParaleloCard(
                  context, 
                  anio, 
                  paralelo, 
                  colorAnio
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ CAMBIO: Card simplificado sin descripción larga
  Widget _buildParaleloCard(
    BuildContext context, 
    String anio, 
    String paralelo, 
    Color color
  ) {
    return GestureDetector(
      onTap: () => _navigateToHorarioDetalle(context, anio, paralelo),
      onLongPress: () => _mostrarOpcionesParalelo(context, anio, paralelo),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.05),
              color.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Stack(
          children: [
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Letra del paralelo grande
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        paralelo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Texto "Paralelo"
                  Text(
                    'Paralelo',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  // Letra del paralelo de nuevo
                  Text(
                    paralelo,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Indicador de acción en esquina
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  size: 12,
                  color: color,
                ),
              ),
            ),
          ],
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

  void _buscarHorario(BuildContext context) {
    // Implementar búsqueda
  }

  void _agregarHorario(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarHorarioScreen(),
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
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar horario'),
              onTap: () {
                Navigator.pop(context);
                _eliminarHorarioCompleto(context, anio, paralelo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editarHorarioCompleto(BuildContext context, String anio, String paralelo) {
    // Navegar a pantalla de edición completa
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editando horario de $anio Paralelo $paralelo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _eliminarHorarioCompleto(BuildContext context, String anio, String paralelo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Horario'),
        content: Text('¿Estás seguro de eliminar el horario completo de $anio Paralelo $paralelo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Horario de $anio Paralelo $paralelo eliminado'),
                  backgroundColor: Colors.red,
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
}