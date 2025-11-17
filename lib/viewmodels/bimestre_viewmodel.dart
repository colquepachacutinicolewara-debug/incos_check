// viewmodels/bimestre_viewmodel.dart
import 'package:flutter/material.dart';

class BimestreViewModel with ChangeNotifier {
  final List<Bimestre> _bimestres = [
    Bimestre(
      id: 'bim1',
      nombre: 'Primer Bimestre',
      numero: 1,
      color: Colors.orange,
      fechaInicio: '01/02/2024',
      fechaFin: '31/03/2024',
      estado: 'Finalizado',
    ),
    Bimestre(
      id: 'bim2',
      nombre: 'Segundo Bimestre',
      numero: 2,
      color: Colors.green,
      fechaInicio: '01/04/2024',
      fechaFin: '31/05/2024',
      estado: 'En Curso',
    ),
    Bimestre(
      id: 'bim3',
      nombre: 'Tercer Bimestre',
      numero: 3,
      color: Colors.blue,
      fechaInicio: '01/06/2024',
      fechaFin: '31/07/2024',
      estado: 'Planificado',
    ),
    Bimestre(
      id: 'bim4',
      nombre: 'Cuarto Bimestre',
      numero: 4,
      color: Colors.purple,
      fechaInicio: '01/08/2024',
      fechaFin: '30/09/2024',
      estado: 'Planificado',
    ),
  ];

  List<Bimestre> get bimestres => _bimestres;

  Color getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'finalizado': return Colors.green;
      case 'en curso': return Colors.blue;
      case 'planificado': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String getEstadoDisplay(String estado) {
    switch (estado.toLowerCase()) {
      case 'en curso': return '🟢 En Curso';
      case 'planificado': return '🟡 Planificado';
      case 'finalizado': return '🔵 Finalizado';
      default: return estado;
    }
  }
}

class Bimestre {
  final String id;
  final String nombre;
  final int numero;
  final Color color;
  final String fechaInicio;
  final String fechaFin;
  final String estado;

  Bimestre({
    required this.id,
    required this.nombre,
    required this.numero,
    required this.color,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
  });

  String get rangoFechas => '$fechaInicio - $fechaFin';
}