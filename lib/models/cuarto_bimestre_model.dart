import '../../../models/bimestre_model.dart';

class AsistenciaEstudianteCuarto {
  AsistenciaEstudianteCuarto({
    required this.item,
    required this.nombre,
    this.octL = '',
    this.octM = '',
    this.octMi = '',
    this.octJ = '',
    this.octV = '',
    this.novL = '',
    this.novM = '',
    this.novMi = '',
    this.novJ = '',
    this.novV = '',
    this.dicL = '',
    this.dicM = '',
    this.dicMi = '',
    this.dicJ = '',
    this.dicV = '',
  });

  final int item;
  final String nombre;
  String octL;
  String octM;
  String octMi;
  String octJ;
  String octV;
  String novL;
  String novM;
  String novMi;
  String novJ;
  String novV;
  String dicL;
  String dicM;
  String dicMi;
  String dicJ;
  String dicV;

  int get totalAsistencias {
    int total = 0;
    List<String> asistencias = [
      octL,
      octM,
      octMi,
      octJ,
      octV,
      novL,
      novM,
      novMi,
      novJ,
      novV,
      dicL,
      dicM,
      dicMi,
      dicJ,
      dicV,
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
      case 'OCT-L':
        octL = valor;
        break;
      case 'OCT-M':
        octM = valor;
        break;
      case 'OCT-MI':
        octMi = valor;
        break;
      case 'OCT-J':
        octJ = valor;
        break;
      case 'OCT-V':
        octV = valor;
        break;
      case 'NOV-L':
        novL = valor;
        break;
      case 'NOV-M':
        novM = valor;
        break;
      case 'NOV-MI':
        novMi = valor;
        break;
      case 'NOV-J':
        novJ = valor;
        break;
      case 'NOV-V':
        novV = valor;
        break;
      case 'DIC-L':
        dicL = valor;
        break;
      case 'DIC-M':
        dicM = valor;
        break;
      case 'DIC-MI':
        dicMi = valor;
        break;
      case 'DIC-J':
        dicJ = valor;
        break;
      case 'DIC-V':
        dicV = valor;
        break;
    }
  }
}

class CuartoBimestreModel {
  final PeriodoAcademico bimestre = PeriodoAcademico(
    id: 'bim4',
    nombre: 'Cuarto Bimestre',
    tipo: 'Bimestral',
    numero: 4,
    fechaInicio: DateTime(2024, 10, 1),
    fechaFin: DateTime(2024, 12, 6),
    estado: 'En curso',
    fechasClases: [
      '01/10',
      '02/10',
      '03/10',
      '04/10',
      '07/10',
      '08/10',
      '09/10',
      '10/10',
      '11/10',
      '14/10',
      '15/10',
      '16/10',
      '17/10',
      '18/10',
      '21/10',
      '22/10',
      '23/10',
      '24/10',
      '25/10',
      '28/10',
      '29/10',
      '30/10',
      '31/10',
      '04/11',
      '05/11',
      '06/11',
      '07/11',
      '08/11',
      '11/11',
      '12/11',
      '13/11',
      '14/11',
      '15/11',
      '18/11',
      '19/11',
      '20/11',
      '21/11',
      '22/11',
      '25/11',
      '26/11',
      '27/11',
      '28/11',
      '29/11',
      '02/12',
      '03/12',
      '04/12',
      '05/12',
      '06/12',
    ],
    descripcion: 'Cuarto período académico 2024',
    fechaCreacion: DateTime(2024, 9, 20),
  );

  final List<String> fechas = [
    'OCT-L',
    'OCT-M',
    'OCT-MI',
    'OCT-J',
    'OCT-V',
    'NOV-L',
    'NOV-M',
    'NOV-MI',
    'NOV-J',
    'NOV-V',
    'DIC-L',
    'DIC-M',
    'DIC-MI',
    'DIC-J',
    'DIC-V',
  ];

  List<AsistenciaEstudianteCuarto> estudiantes = [];
}
