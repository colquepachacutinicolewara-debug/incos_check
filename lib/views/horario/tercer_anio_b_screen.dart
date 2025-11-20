import 'package:flutter/material.dart';

class TercerAnioBScreen extends StatefulWidget {
  const TercerAnioBScreen({super.key});

  @override
  State<TercerAnioBScreen> createState() => _TercerAnioBScreenState();
}

class _TercerAnioBScreenState extends State<TercerAnioBScreen> {
  @override
  void initState() {
    super.initState();
    _inicializarHorariosEspecificos();
  }

  void _inicializarHorariosEspecificos() {
    // Puedes inicializar los horarios específicos aquí si es necesario
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Tercer Año B - Turno Noche',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _mostrarHorarioCompleto(context),
            tooltip: 'Ver horario completo',
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pantalla de Horarios - Tercer Año B',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Esta pantalla mostrará los horarios específicos de Tercer Año B.'),
            SizedBox(height: 8),
            Text('• Análisis y Diseño de Sistemas II'),
            Text('• Programación Móviles II'),
            Text('• Base de Datos II'),
            Text('• Emprendimiento Productivo'),
            Text('• Redes de Computadoras II'),
            Text('• Diseño y Programación Web III'),
            Text('• Taller de Modalidad de Graduación'),
          ],
        ),
      ),
    );
  }

  void _mostrarHorarioCompleto(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Horario Completo - Tercer Año B'),
        content: const Text('Aquí irá la tabla completa de horarios.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}