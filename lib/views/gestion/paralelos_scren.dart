import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import '../../views/gestion/estudiantes_screen.dart';

class ParalelosScreen extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;
  final Map<String, dynamic> nivel;
  
  const ParalelosScreen({
    super.key, 
    required this.tipo, 
    required this.carrera,
    required this.turno,
    required this.nivel
  });

  @override
  State<ParalelosScreen> createState() => _ParalelosScreenState();
}

class _ParalelosScreenState extends State<ParalelosScreen> {
  final List<Map<String, dynamic>> _paralelos = [
    {'id': 1, 'nombre': 'A'},
    {'id': 2, 'nombre': 'B'},
    {'id': 3, 'nombre': 'C'},
  ];

  @override
  Widget build(BuildContext context) {
    Color carreraColor = _parseColor(widget.carrera['color']);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.carrera['nombre']} - ${widget.turno['nombre']} - ${widget.nivel['nombre']}',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: carreraColor,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.medium),
        itemCount: _paralelos.length,
        itemBuilder: (context, index) {
          final paralelo = _paralelos[index];
          return _buildParaleloCard(paralelo, context, carreraColor);
        },
      ),
    );
  }

  Widget _buildParaleloCard(Map<String, dynamic> paralelo, BuildContext context, Color color) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            paralelo['nombre'],
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          'Paralelo ${paralelo['nombre']}',
          style: AppTextStyles.heading3,
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EstudiantesListScreen(
                tipo: widget.tipo,
                carrera: widget.carrera,
                turno: widget.turno,
                nivel: widget.nivel,
                paralelo: paralelo,
              ),
            ),
          );
        },
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}