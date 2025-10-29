import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import '../../views/gestion/paralelos_scren.dart';

class NivelesScreen extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic> carrera;
  final Map<String, dynamic> turno;
  
  const NivelesScreen({
    super.key, 
    required this.tipo, 
    required this.carrera,
    required this.turno
  });

  @override
  State<NivelesScreen> createState() => _NivelesScreenState();
}

class _NivelesScreenState extends State<NivelesScreen> {
  final List<Map<String, dynamic>> _niveles = [
    {'id': 1, 'nombre': 'Primero'},
    {'id': 2, 'nombre': 'Segundo'},
    {'id': 3, 'nombre': 'Tercero'},
  ];

  @override
  Widget build(BuildContext context) {
    Color carreraColor = _parseColor(widget.carrera['color']);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.carrera['nombre']} - ${widget.turno['nombre']} - Niveles',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: carreraColor,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.medium),
        itemCount: _niveles.length,
        itemBuilder: (context, index) {
          final nivel = _niveles[index];
          return _buildNivelCard(nivel, context, carreraColor);
        },
      ),
    );
  }

  Widget _buildNivelCard(Map<String, dynamic> nivel, BuildContext context, Color color) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            nivel['nombre'][0],
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${nivel['nombre']} Nivel',
          style: AppTextStyles.heading3,
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParalelosScreen(
                tipo: widget.tipo,
                carrera: widget.carrera,
                turno: widget.turno,
                nivel: nivel,
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