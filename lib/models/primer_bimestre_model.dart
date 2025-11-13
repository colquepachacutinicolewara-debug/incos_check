// models/primer_bimestre_model.dart
import 'package:flutter/material.dart';
import 'dart:convert';

// Primero definimos PeriodoAcademico aquí mismo
class PeriodoAcademico {
  final String id;
  final String nombre;
  final String tipo;
  final int numero;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;
  final List<String> fechasClases;
  final String descripcion;
  final DateTime fechaCreacion;
  final int? totalClases;
  final int? duracionDias;

  PeriodoAcademico({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.numero,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.fechasClases,
    required this.descripcion,
    required this.fechaCreacion,
    this.totalClases,
    this.duracionDias,
  });

  // Getters computados
  int get totalClasesComputed => fechasClases.length;
  int get duracionDiasComputed => fechaFin.difference(fechaInicio).inDays;
  bool get estaActivo => estado == 'En Curso';
  bool get puedeEditar => estado == 'Planificado' || estado == 'En Curso';

  String get rangoFechas =>
      '${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year} - '
      '${fechaFin.day}/${fechaFin.month}/${fechaFin.year}';

  Color get colorEstado {
    switch (estado) {
      case 'Planificado':
        return Colors.blue;
      case 'En Curso':
        return Colors.green;
      case 'Finalizado':
        return Colors.grey;
      case 'Cancelado':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String get estadoDisplay {
    switch (estado) {
      case 'En Curso':
        return 'En Curso';
      case 'Planificado':
        return 'Planificado';
      case 'Finalizado':
        return 'Finalizado';
      case 'Cancelado':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'numero': numero,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'estado': estado,
      'fechas_clases': json.encode(fechasClases),
      'descripcion': descripcion,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'total_clases': totalClasesComputed,
      'duracion_dias': duracionDiasComputed,
    };
  }

  factory PeriodoAcademico.fromMap(Map<String, dynamic> map) {
    List<String> fechasClases = [];
    try {
      if (map['fechas_clases'] is String) {
        fechasClases = List<String>.from(json.decode(map['fechas_clases']));
      } else if (map['fechas_clases'] is List) {
        fechasClases = List<String>.from(map['fechas_clases']);
      }
    } catch (e) {
      print('Error parsing fechas_clases: $e');
    }

    return PeriodoAcademico(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      tipo: map['tipo'] ?? '',
      numero: map['numero'] ?? 0,
      fechaInicio: DateTime.parse(map['fecha_inicio'] ?? DateTime.now().toIso8601String()),
      fechaFin: DateTime.parse(map['fecha_fin'] ?? DateTime.now().toIso8601String()),
      estado: map['estado'] ?? '',
      fechasClases: fechasClases,
      descripcion: map['descripcion'] ?? '',
      fechaCreacion: DateTime.parse(map['fecha_creacion'] ?? DateTime.now().toIso8601String()),
      totalClases: map['total_clases'],
      duracionDias: map['duracion_dias'],
    );
  }

  PeriodoAcademico copyWith({
    String? id,
    String? nombre,
    String? tipo,
    int? numero,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? estado,
    List<String>? fechasClases,
    String? descripcion,
    DateTime? fechaCreacion,
  }) {
    return PeriodoAcademico(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      numero: numero ?? this.numero,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      fechasClases: fechasClases ?? this.fechasClases,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'PeriodoAcademico($id: $nombre - $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PeriodoAcademico && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Ahora la clase AsistenciaEstudiante
class AsistenciaEstudiante {
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

  int get totalAsistencias {
    int total = 0;
    List<String> asistencias = [
      febL, febM, febMi, febJ, febV,
      marL, marM, marMi, marJ, marV,
      abrL, abrM, abrMi, abrJ, abrV,
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
      case 'FEB-L': febL = valor; break;
      case 'FEB-M': febM = valor; break;
      case 'FEB-MI': febMi = valor; break;
      case 'FEB-J': febJ = valor; break;
      case 'FEB-V': febV = valor; break;
      case 'MAR-L': marL = valor; break;
      case 'MAR-M': marM = valor; break;
      case 'MAR-MI': marMi = valor; break;
      case 'MAR-J': marJ = valor; break;
      case 'MAR-V': marV = valor; break;
      case 'ABR-L': abrL = valor; break;
      case 'ABR-M': abrM = valor; break;
      case 'ABR-MI': abrMi = valor; break;
      case 'ABR-J': abrJ = valor; break;
      case 'ABR-V': abrV = valor; break;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'item': item,
      'nombre': nombre,
      'febL': febL, 'febM': febM, 'febMi': febMi, 'febJ': febJ, 'febV': febV,
      'marL': marL, 'marM': marM, 'marMi': marMi, 'marJ': marJ, 'marV': marV,
      'abrL': abrL, 'abrM': abrM, 'abrMi': abrMi, 'abrJ': abrJ, 'abrV': abrV,
      'total_asistencias': totalAsistencias,
    };
  }

  factory AsistenciaEstudiante.fromMap(Map<String, dynamic> map) {
    return AsistenciaEstudiante(
      item: map['item'] ?? 0,
      nombre: map['nombre'] ?? '',
      febL: map['febL'] ?? '', febM: map['febM'] ?? '', febMi: map['fechasClases'] ?? '',
      febJ: map['febJ'] ?? '', febV: map['febV'] ?? '',
      marL: map['marL'] ?? '', marM: map['marM'] ?? '', marMi: map['marMi'] ?? '',
      marJ: map['marJ'] ?? '', marV: map['marV'] ?? '',
      abrL: map['abrL'] ?? '', abrM: map['abrM'] ?? '', abrMi: map['abrMi'] ?? '',
      abrJ: map['abrJ'] ?? '', abrV: map['abrV'] ?? '',
    );
  }
}

// Finalmente la clase PrimerBimestreModel
class PrimerBimestreModel {
  final PeriodoAcademico bimestre;
  final List<String> fechas;
  List<AsistenciaEstudiante> estudiantes;

  PrimerBimestreModel({
    required this.bimestre,
    required this.fechas,
    required this.estudiantes,
  });

  factory PrimerBimestreModel.defaultModel() {
    return PrimerBimestreModel(
      bimestre: PeriodoAcademico(
        id: 'bim1',
        nombre: 'Primer Bimestre',
        tipo: 'Bimestral',
        numero: 1,
        fechaInicio: DateTime(2024, 2, 1),
        fechaFin: DateTime(2024, 4, 30),
        estado: 'Finalizado',
        fechasClases: [
          '05/02', '06/02', '07/02', '08/02', '09/02', '12/02', '13/02', '14/02', '15/02', '16/02',
          '19/02', '20/02', '21/02', '22/02', '23/02', '26/02', '27/02', '28/02', '29/02',
          '04/03', '05/03', '06/03', '07/03', '08/03', '11/03', '12/03', '13/03', '14/03', '15/03',
          '18/03', '19/03', '20/03', '21/03', '22/03', '25/03', '26/03', '27/03', '28/03', '29/03',
          '01/04', '02/04', '03/04', '04/04', '05/04', '08/04', '09/04', '10/04', '11/04', '12/04',
          '15/04', '16/04', '17/04', '18/04', '19/04', '22/04', '23/04', '24/04', '25/04', '26/04',
        ],
        descripcion: 'Primer período académico 2024',
        fechaCreacion: DateTime(2024, 1, 15),
      ),
      fechas: [
        'FEB-L', 'FEB-M', 'FEB-MI', 'FEB-J', 'FEB-V',
        'MAR-L', 'MAR-M', 'MAR-MI', 'MAR-J', 'MAR-V',
        'ABR-L', 'ABR-M', 'ABR-MI', 'ABR-J', 'ABR-V',
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

  factory PrimerBimestreModel.fromMap(Map<String, dynamic> map) {
    List<String> fechas = [];
    try {
      if (map['fechas'] is String) {
        fechas = List<String>.from(json.decode(map['fechas']));
      }
    } catch (e) {
      print('Error parsing fechas: $e');
    }

    List<AsistenciaEstudiante> estudiantes = [];
    try {
      if (map['estudiantes'] is String) {
        final List<dynamic> datos = json.decode(map['estudiantes']);
        estudiantes = datos.map((item) => AsistenciaEstudiante.fromMap(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      print('Error parsing estudiantes: $e');
    }

    return PrimerBimestreModel(
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