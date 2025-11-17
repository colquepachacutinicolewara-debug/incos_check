import 'dart:convert';
import 'periodo_academico_model.dart';

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
      octL, octM, octMi, octJ, octV,
      novL, novM, novMi, novJ, novV,
      dicL, dicM, dicMi, dicJ, dicV,
    ];
    for (String asistencia in asistencias) {
      if (asistencia.trim().isNotEmpty && asistencia.toUpperCase() == 'P') {
        total++;
      }
    }
    return total;
  }

  String get totalDisplay => '$totalAsistencias/15';
  double get porcentajeAsistencia => totalAsistencias / 15;

  void actualizarAsistencia(String fecha, String valor) {
    switch (fecha) {
      case 'OCT-L': octL = valor; break;
      case 'OCT-M': octM = valor; break;
      case 'OCT-MI': octMi = valor; break;
      case 'OCT-J': octJ = valor; break;
      case 'OCT-V': octV = valor; break;
      case 'NOV-L': novL = valor; break;
      case 'NOV-M': novM = valor; break;
      case 'NOV-MI': novMi = valor; break;
      case 'NOV-J': novJ = valor; break;
      case 'NOV-V': novV = valor; break;
      case 'DIC-L': dicL = valor; break;
      case 'DIC-M': dicM = valor; break;
      case 'DIC-MI': dicMi = valor; break;
      case 'DIC-J': dicJ = valor; break;
      case 'DIC-V': dicV = valor; break;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'item': item,
      'nombre': nombre,
      'octL': octL, 'octM': octM, 'octMi': octMi, 'octJ': octJ, 'octV': octV,
      'novL': novL, 'novM': novM, 'novMi': novMi, 'novJ': novJ, 'novV': novV,
      'dicL': dicL, 'dicM': dicM, 'dicMi': dicMi, 'dicJ': dicJ, 'dicV': dicV,
      'total_asistencias': totalAsistencias,
    };
  }

  factory AsistenciaEstudianteCuarto.fromMap(Map<String, dynamic> map) {
    return AsistenciaEstudianteCuarto(
      item: map['item'] ?? 0,
      nombre: map['nombre'] ?? '',
      octL: map['octL'] ?? '', octM: map['octM'] ?? '', octMi: map['octMi'] ?? '',
      octJ: map['octJ'] ?? '', octV: map['octV'] ?? '',
      novL: map['novL'] ?? '', novM: map['novM'] ?? '', novMi: map['novMi'] ?? '',
      novJ: map['novJ'] ?? '', novV: map['novV'] ?? '',
      dicL: map['dicL'] ?? '', dicM: map['dicM'] ?? '', dicMi: map['dicMi'] ?? '',
      dicJ: map['dicJ'] ?? '', dicV: map['dicV'] ?? '',
    );
  }
}

class CuartoBimestreModel {
  final PeriodoAcademico bimestre;
  final List<String> fechas;
  List<AsistenciaEstudianteCuarto> estudiantes;

  CuartoBimestreModel({
    required this.bimestre,
    required this.fechas,
    required this.estudiantes,
  });

  factory CuartoBimestreModel.defaultModel() {
    return CuartoBimestreModel(
      bimestre: PeriodoAcademico(
        id: 'bim4',
        nombre: 'Cuarto Bimestre',
        tipo: 'Bimestral',
        numero: 4,
        fechaInicio: DateTime(2024, 10, 1),
        fechaFin: DateTime(2024, 12, 6),
        estado: 'Planificado',
        fechasClases: [
          '01/10', '02/10', '03/10', '04/10', '07/10', '08/10', '09/10', '10/10', '11/10', '14/10',
          '15/10', '16/10', '17/10', '18/10', '21/10', '22/10', '23/10', '24/10', '25/10', '28/10',
          '29/10', '30/10', '31/10', '04/11', '05/11', '06/11', '07/11', '08/11', '11/11', '12/11',
          '13/11', '14/11', '15/11', '18/11', '19/11', '20/11', '21/11', '22/11', '25/11', '26/11',
          '27/11', '28/11', '29/11', '02/12', '03/12', '04/12', '05/12', '06/12',
        ],
        descripcion: 'Cuarto período académico 2024',
        fechaCreacion: DateTime(2024, 9, 20),
      ),
      fechas: [
        'OCT-L', 'OCT-M', 'OCT-MI', 'OCT-J', 'OCT-V',
        'NOV-L', 'NOV-M', 'NOV-MI', 'NOV-J', 'NOV-V',
        'DIC-L', 'DIC-M', 'DIC-MI', 'DIC-J', 'DIC-V',
      ],
      estudiantes: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bimestre': bimestre.toMap(),
      'fechas': json.encode(fechas),
      'estudiantes': json.encode(estudiantes.map((e) => e.toMap()).toList()),
    };
  }

  factory CuartoBimestreModel.fromMap(Map<String, dynamic> map) {
    List<String> fechas = [];
    try {
      if (map['fechas'] is String) {
        fechas = List<String>.from(json.decode(map['fechas']));
      }
    } catch (e) {
      print('Error parsing fechas: $e');
    }

    List<AsistenciaEstudianteCuarto> estudiantes = [];
    try {
      if (map['estudiantes'] is String) {
        final List<dynamic> datos = json.decode(map['estudiantes']);
        estudiantes = datos.map((item) => AsistenciaEstudianteCuarto.fromMap(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      print('Error parsing estudiantes: $e');
    }

    return CuartoBimestreModel(
      bimestre: PeriodoAcademico.fromMap(Map<String, dynamic>.from(map['bimestre'] ?? {})),
      fechas: fechas,
      estudiantes: estudiantes,
    );
  }

  int get totalEstudiantes => estudiantes.length;
  int get totalAsistenciasRegistradas {
    return estudiantes.fold(0, (sum, estudiante) => sum + estudiante.totalAsistencias);
  }

  double get promedioAsistencia {
    if (estudiantes.isEmpty) return 0.0;
    return estudiantes.fold(0.0, (sum, estudiante) => sum + estudiante.porcentajeAsistencia) / estudiantes.length;
  }
}