import 'package:flutter/material.dart';
import '../../../models/bimestre_model.dart';

class AsistenciaEstudiante {
  AsistenciaEstudiante({
    required this.item,
    required this.nombre,
    this.febL = '',
    this.febM = '',
    this.febMi = '',
    this.febJ = '',
    this.febV = '',
    this.marL = '',
    this.marM = '',
    this.marMi = '',
    this.marJ = '',
    this.marV = '',
    this.abrL = '',
    this.abrM = '',
    this.abrMi = '',
    this.abrJ = '',
    this.abrV = '',
  });

  final int item;
  final String nombre;
  String febL;
  String febM;
  String febMi;
  String febJ;
  String febV;
  String marL;
  String marM;
  String marMi;
  String marJ;
  String marV;
  String abrL;
  String abrM;
  String abrMi;
  String abrJ;
  String abrV;

  int get totalAsistencias {
    int total = 0;
    List<String> asistencias = [
      febL,
      febM,
      febMi,
      febJ,
      febV,
      marL,
      marM,
      marMi,
      marJ,
      marV,
      abrL,
      abrM,
      abrMi,
      abrJ,
      abrV,
    ];
    for (String asistencia in asistencias) {
      if (asistencia.trim().isNotEmpty && asistencia.toUpperCase() == 'P') {
        total++;
      }
    }
    return total;
  }

  String get totalDisplay => '$totalAsistencias/15';

  // Método para actualizar asistencia por fecha
  void actualizarAsistencia(String fecha, String valor) {
    switch (fecha) {
      case 'FEB-L':
        febL = valor;
        break;
      case 'FEB-M':
        febM = valor;
        break;
      case 'FEB-MI':
        febMi = valor;
        break;
      case 'FEB-J':
        febJ = valor;
        break;
      case 'FEB-V':
        febV = valor;
        break;
      case 'MAR-L':
        marL = valor;
        break;
      case 'MAR-M':
        marM = valor;
        break;
      case 'MAR-MI':
        marMi = valor;
        break;
      case 'MAR-J':
        marJ = valor;
        break;
      case 'MAR-V':
        marV = valor;
        break;
      case 'ABR-L':
        abrL = valor;
        break;
      case 'ABR-M':
        abrM = valor;
        break;
      case 'ABR-MI':
        abrMi = valor;
        break;
      case 'ABR-J':
        abrJ = valor;
        break;
      case 'ABR-V':
        abrV = valor;
        break;
    }
  }
}

class PrimerBimestreModel {
  final PeriodoAcademico bimestre = PeriodoAcademico(
    id: 'bim1',
    nombre: 'Primer Bimestre',
    tipo: 'Bimestral',
    numero: 1,
    fechaInicio: DateTime(2024, 2, 1),
    fechaFin: DateTime(2024, 4, 30),
    estado: 'Finalizado',
    fechasClases: [
      '05/02',
      '06/02',
      '07/02',
      '08/02',
      '09/02',
      '12/02',
      '13/02',
      '14/02',
      '15/02',
      '16/02',
      '19/02',
      '20/02',
      '21/02',
      '22/02',
      '23/02',
      '26/02',
      '27/02',
      '28/02',
      '29/02',
      '04/03',
      '05/03',
      '06/03',
      '07/03',
      '08/03',
      '11/03',
      '12/03',
      '13/03',
      '14/03',
      '15/03',
      '18/03',
      '19/03',
      '20/03',
      '21/03',
      '22/03',
      '25/03',
      '26/03',
      '27/03',
      '28/03',
      '29/03',
      '01/04',
      '02/04',
      '03/04',
      '04/04',
      '05/04',
      '08/04',
      '09/04',
      '10/04',
      '11/04',
      '12/04',
      '15/04',
      '16/04',
      '17/04',
      '18/04',
      '19/04',
      '22/04',
      '23/04',
      '24/04',
      '25/04',
      '26/04',
    ],
    descripcion: 'Primer período académico 2024',
    fechaCreacion: DateTime(2024, 1, 15),
  );

  final List<String> fechas = [
    'FEB-L',
    'FEB-M',
    'FEB-MI',
    'FEB-J',
    'FEB-V',
    'MAR-L',
    'MAR-M',
    'MAR-MI',
    'MAR-J',
    'MAR-V',
    'ABR-L',
    'ABR-M',
    'ABR-MI',
    'ABR-J',
    'ABR-V',
  ];

  List<AsistenciaEstudiante> estudiantes = [];
}
