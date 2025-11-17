import 'dart:convert';
import 'periodo_academico_model.dart';

class AsistenciaEstudianteTercer {
  AsistenciaEstudianteTercer({
    required this.item,
    required this.nombre,
    this.julL = '',
    this.julM = '',
    this.julMi = '',
    this.julJ = '',
    this.julV = '',
    this.agoL = '',
    this.agoM = '',
    this.agoMi = '',
    this.agoJ = '',
    this.agoV = '',
    this.sepL = '',
    this.sepM = '',
    this.sepMi = '',
    this.sepJ = '',
    this.sepV = '',
  });

  final int item;
  final String nombre;
  String julL;
  String julM;
  String julMi;
  String julJ;
  String julV;
  String agoL;
  String agoM;
  String agoMi;
  String agoJ;
  String agoV;
  String sepL;
  String sepM;
  String sepMi;
  String sepJ;
  String sepV;

  int get totalAsistencias {
    int total = 0;
    List<String> asistencias = [
      julL, julM, julMi, julJ, julV,
      agoL, agoM, agoMi, agoJ, agoV,
      sepL, sepM, sepMi, sepJ, sepV,
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
      case 'JUL-L': julL = valor; break;
      case 'JUL-M': julM = valor; break;
      case 'JUL-MI': julMi = valor; break;
      case 'JUL-J': julJ = valor; break;
      case 'JUL-V': julV = valor; break;
      case 'AGO-L': agoL = valor; break;
      case 'AGO-M': agoM = valor; break;
      case 'AGO-MI': agoMi = valor; break;
      case 'AGO-J': agoJ = valor; break;
      case 'AGO-V': agoV = valor; break;
      case 'SEP-L': sepL = valor; break;
      case 'SEP-M': sepM = valor; break;
      case 'SEP-MI': sepMi = valor; break;
      case 'SEP-J': sepJ = valor; break;
      case 'SEP-V': sepV = valor; break;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'item': item,
      'nombre': nombre,
      'julL': julL, 'julM': julM, 'julMi': julMi, 'julJ': julJ, 'julV': julV,
      'agoL': agoL, 'agoM': agoM, 'agoMi': agoMi, 'agoJ': agoJ, 'agoV': agoV,
      'sepL': sepL, 'sepM': sepM, 'sepMi': sepMi, 'sepJ': sepJ, 'sepV': sepV,
      'total_asistencias': totalAsistencias,
    };
  }

  factory AsistenciaEstudianteTercer.fromMap(Map<String, dynamic> map) {
    return AsistenciaEstudianteTercer(
      item: map['item'] ?? 0,
      nombre: map['nombre'] ?? '',
      julL: map['julL'] ?? '', julM: map['julM'] ?? '', julMi: map['julMi'] ?? '',
      julJ: map['julJ'] ?? '', julV: map['julV'] ?? '',
      agoL: map['agoL'] ?? '', agoM: map['agoM'] ?? '', agoMi: map['agoMi'] ?? '',
      agoJ: map['agoJ'] ?? '', agoV: map['agoV'] ?? '',
      sepL: map['sepL'] ?? '', sepM: map['sepM'] ?? '', sepMi: map['sepMi'] ?? '',
      sepJ: map['sepJ'] ?? '', sepV: map['sepV'] ?? '',
    );
  }
}

class TercerBimestreModel {
  final PeriodoAcademico bimestre;
  final List<String> fechas;
  List<AsistenciaEstudianteTercer> estudiantes;

  TercerBimestreModel({
    required this.bimestre,
    required this.fechas,
    required this.estudiantes,
  });

  factory TercerBimestreModel.defaultModel() {
    return TercerBimestreModel(
      bimestre: PeriodoAcademico(
        id: 'bim3',
        nombre: 'Tercer Bimestre',
        tipo: 'Bimestral',
        numero: 3,
        fechaInicio: DateTime(2024, 7, 22),
        fechaFin: DateTime(2024, 9, 27),
        estado: 'Planificado',
        fechasClases: [
          '22/07', '23/07', '24/07', '25/07', '26/07', '29/07', '30/07', '31/07', '01/08', '02/08',
          '05/08', '06/08', '07/08', '08/08', '09/08', '12/08', '13/08', '14/08', '15/08', '16/08',
          '19/08', '20/08', '21/08', '22/08', '23/08', '26/08', '27/08', '28/08', '29/08', '30/08',
          '02/09', '03/09', '04/09', '05/09', '06/09', '09/09', '10/09', '11/09', '12/09', '13/09',
          '16/09', '17/09', '18/09', '19/09', '20/09', '23/09', '24/09', '25/09', '26/09', '27/09',
        ],
        descripcion: 'Tercer período académico 2024',
        fechaCreacion: DateTime(2024, 7, 1),
      ),
      fechas: [
        'JUL-L', 'JUL-M', 'JUL-MI', 'JUL-J', 'JUL-V',
        'AGO-L', 'AGO-M', 'AGO-MI', 'AGO-J', 'AGO-V',
        'SEP-L', 'SEP-M', 'SEP-MI', 'SEP-J', 'SEP-V',
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

  factory TercerBimestreModel.fromMap(Map<String, dynamic> map) {
    List<String> fechas = [];
    try {
      if (map['fechas'] is String) {
        fechas = List<String>.from(json.decode(map['fechas']));
      }
    } catch (e) {
      print('Error parsing fechas: $e');
    }

    List<AsistenciaEstudianteTercer> estudiantes = [];
    try {
      if (map['estudiantes'] is String) {
        final List<dynamic> datos = json.decode(map['estudiantes']);
        estudiantes = datos.map((item) => AsistenciaEstudianteTercer.fromMap(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      print('Error parsing estudiantes: $e');
    }

    return TercerBimestreModel(
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