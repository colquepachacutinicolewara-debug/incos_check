import '../../../models/bimestre_model.dart';

class AsistenciaEstudianteSegundo {
  AsistenciaEstudianteSegundo({
    required this.item,
    required this.nombre,
    this.abrL = '',
    this.abrM = '',
    this.abrMi = '',
    this.abrJ = '',
    this.abrV = '',
    this.mayL = '',
    this.mayM = '',
    this.mayMi = '',
    this.mayJ = '',
    this.mayV = '',
    this.junL = '',
    this.junM = '',
    this.junMi = '',
    this.junJ = '',
    this.junV = '',
    this.julL = '',
    this.julM = '',
    this.julMi = '',
    this.julJ = '',
    this.julV = '',
  });

  final int item;
  final String nombre;
  String abrL;
  String abrM;
  String abrMi;
  String abrJ;
  String abrV;
  String mayL;
  String mayM;
  String mayMi;
  String mayJ;
  String mayV;
  String junL;
  String junM;
  String junMi;
  String junJ;
  String junV;
  String julL;
  String julM;
  String julMi;
  String julJ;
  String julV;

  int get totalAsistencias {
    int total = 0;
    List<String> asistencias = [
      abrL,
      abrM,
      abrMi,
      abrJ,
      abrV,
      mayL,
      mayM,
      mayMi,
      mayJ,
      mayV,
      junL,
      junM,
      junMi,
      junJ,
      junV,
      julL,
      julM,
      julMi,
      julJ,
      julV,
    ];
    for (String asistencia in asistencias) {
      if (asistencia.trim().isNotEmpty && asistencia.toUpperCase() == 'P') {
        total++;
      }
    }
    return total;
  }

  String get totalDisplay => '$totalAsistencias/20';

  // Método para actualizar asistencia por fecha
  void actualizarAsistencia(String fecha, String valor) {
    switch (fecha) {
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
      case 'MAY-L':
        mayL = valor;
        break;
      case 'MAY-M':
        mayM = valor;
        break;
      case 'MAY-MI':
        mayMi = valor;
        break;
      case 'MAY-J':
        mayJ = valor;
        break;
      case 'MAY-V':
        mayV = valor;
        break;
      case 'JUN-L':
        junL = valor;
        break;
      case 'JUN-M':
        junM = valor;
        break;
      case 'JUN-MI':
        junMi = valor;
        break;
      case 'JUN-J':
        junJ = valor;
        break;
      case 'JUN-V':
        junV = valor;
        break;
      case 'JUL-L':
        julL = valor;
        break;
      case 'JUL-M':
        julM = valor;
        break;
      case 'JUL-MI':
        julMi = valor;
        break;
      case 'JUL-J':
        julJ = valor;
        break;
      case 'JUL-V':
        julV = valor;
        break;
    }
  }
}

class SegundoBimestreModel {
  final PeriodoAcademico bimestre = PeriodoAcademico(
    id: 'bim2',
    nombre: 'Segundo Bimestre',
    tipo: 'Bimestral',
    numero: 2,
    fechaInicio: DateTime(2024, 4, 15),
    fechaFin: DateTime(2024, 7, 5),
    estado: 'En curso',
    fechasClases: [
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
      '29/04',
      '30/04',
      '02/05',
      '03/05',
      '06/05',
      '07/05',
      '08/05',
      '09/05',
      '10/05',
      '13/05',
      '14/05',
      '15/05',
      '16/05',
      '17/05',
      '20/05',
      '21/05',
      '22/05',
      '23/05',
      '24/05',
      '27/05',
      '28/05',
      '29/05',
      '30/05',
      '31/05',
      '03/06',
      '04/06',
      '05/06',
      '06/06',
      '07/06',
      '10/06',
      '11/06',
      '12/06',
      '13/06',
      '14/06',
      '17/06',
      '18/06',
      '19/06',
      '20/06',
      '21/06',
      '24/06',
      '25/06',
      '26/06',
      '27/06',
      '28/06',
      '01/07',
      '02/07',
      '03/07',
      '04/07',
      '05/07',
    ],
    descripcion: 'Segundo período académico 2024',
    fechaCreacion: DateTime(2024, 4, 1),
  );

  final List<String> fechas = [
    'ABR-L',
    'ABR-M',
    'ABR-MI',
    'ABR-J',
    'ABR-V',
    'MAY-L',
    'MAY-M',
    'MAY-MI',
    'MAY-J',
    'MAY-V',
    'JUN-L',
    'JUN-M',
    'JUN-MI',
    'JUN-J',
    'JUN-V',
    'JUL-L',
    'JUL-M',
    'JUL-MI',
    'JUL-J',
    'JUL-V',
  ];

  List<AsistenciaEstudianteSegundo> estudiantes = [];
}
