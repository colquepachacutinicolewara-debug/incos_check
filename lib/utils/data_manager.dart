// utils/data_manager.dart
import 'package:flutter/material.dart';

class DataManager {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  // Estructura principal de datos
  final Map<String, Map<String, dynamic>> _carrerasData = {};

  // ========== INICIALIZACIÓN DE DATOS ==========

  // Inicializar datos para una carrera
  void inicializarCarrera(
    String carreraId,
    String carreraNombre,
    String color,
  ) {
    if (!_carrerasData.containsKey(carreraId)) {
      _carrerasData[carreraId] = {
        'id': carreraId,
        'nombre': carreraNombre,
        'color': color,
        'turnos': [],
        'docentes': [],
      };

      // SOLO para Sistemas Informáticos agregar datos por defecto
      if (carreraNombre == 'Sistemas Informáticos' && carreraId == '1') {
        _agregarDatosPorDefectoSistemas(carreraId);
      }
    }
  }

  // Agregar datos por defecto SOLO para Sistemas Informáticos
  void _agregarDatosPorDefectoSistemas(String carreraId) {
    final turnosPorDefecto = [
      {
        'id': '${carreraId}_manana',
        'nombre': 'Mañana',
        'icon': Icons.wb_sunny,
        'horario': '08:00 - 13:00',
        'rangoAsistencia': '07:45 - 08:15',
        'dias': 'Lunes a Viernes',
        'color': '#FFA000',
        'activo': true,
        'niveles': [
          {
            'id': '${carreraId}_manana_tercero',
            'nombre': 'Tercero',
            'activo': true,
            'orden': 3,
            'paralelos': [
              {
                'id': '${carreraId}_manana_tercero_B',
                'nombre': 'B',
                'activo': true,
                'estudiantes': [
                  {
                    'id': 1,
                    'nombres': 'Juan Carlos',
                    'apellidoPaterno': 'Pérez',
                    'apellidoMaterno': 'Gómez',
                    'ci': '1234567',
                    'fechaRegistro': '2024-01-15',
                    'huellasRegistradas': 3,
                  },
                  {
                    'id': 2,
                    'nombres': 'María Elena',
                    'apellidoPaterno': 'López',
                    'apellidoMaterno': 'Martínez',
                    'ci': '7654321',
                    'fechaRegistro': '2024-01-16',
                    'huellasRegistradas': 2,
                  },
                ],
              },
            ],
          },
        ],
      },
      {
        'id': '${carreraId}_noche',
        'nombre': 'Noche',
        'icon': Icons.nights_stay,
        'horario': '18:30 - 22:00',
        'rangoAsistencia': '18:30 - 19:30',
        'dias': 'Lunes a Viernes',
        'color': '#1565C0',
        'activo': true,
        'niveles': [], // Noche empieza vacío
      },
    ];

    final docentesPorDefecto = [
      {
        'id': 1,
        'apellidoPaterno': 'FERNANDEZ',
        'apellidoMaterno': 'GARCIA',
        'nombres': 'MARIA ELENA',
        'ci': '6543210',
        'carrera': 'SISTEMAS INFORMÁTICOS',
        'turno': 'MAÑANA',
        'email': 'mfernandez@gmail.com',
        'telefono': '+59170012345',
        'estado': 'Activo',
      },
      {
        'id': 2,
        'apellidoPaterno': 'BUSTOS',
        'apellidoMaterno': 'MARTINEZ',
        'nombres': 'CARLOS ALBERTO',
        'ci': '6543211',
        'carrera': 'SISTEMAS INFORMÁTICOS',
        'turno': 'NOCHE',
        'email': 'cbustos@gmail.com',
        'telefono': '+59170012346',
        'estado': 'Activo',
      },
    ];

    // Agregar turnos por defecto
    _carrerasData[carreraId]!['turnos'] = turnosPorDefecto;

    // Agregar docentes por defecto
    _carrerasData[carreraId]!['docentes'] = docentesPorDefecto;
  }

  // ========== MÉTODOS PARA CARRERAS ==========

  List<Map<String, dynamic>> getCarreras() {
    return _carrerasData.values.toList();
  }

  Map<String, dynamic>? getCarrera(String carreraId) {
    return _carrerasData[carreraId];
  }

  void agregarCarrera(Map<String, dynamic> carrera) {
    String carreraId = carrera['id'].toString();
    if (!_carrerasData.containsKey(carreraId)) {
      _carrerasData[carreraId] = {...carrera, 'turnos': [], 'docentes': []};
    }
  }

  void actualizarCarrera(
    String carreraId,
    Map<String, dynamic> carreraActualizada,
  ) {
    if (_carrerasData.containsKey(carreraId)) {
      _carrerasData[carreraId] = {
        ..._carrerasData[carreraId]!,
        ...carreraActualizada,
        'turnos': _carrerasData[carreraId]!['turnos'] ?? [],
        'docentes': _carrerasData[carreraId]!['docentes'] ?? [],
      };
    }
  }

  void eliminarCarrera(String carreraId) {
    _carrerasData.remove(carreraId);
  }

  // ========== MÉTODOS PARA TURNOS ==========

  List<Map<String, dynamic>> getTurnos(String carreraId) {
    final carrera = _carrerasData[carreraId];
    if (carrera != null && carrera['turnos'] != null) {
      return List<Map<String, dynamic>>.from(carrera['turnos']);
    }
    return [];
  }

  void agregarTurno(String carreraId, Map<String, dynamic> turno) {
    if (_carrerasData.containsKey(carreraId)) {
      if (_carrerasData[carreraId]!['turnos'] == null) {
        _carrerasData[carreraId]!['turnos'] = [];
      }
      _carrerasData[carreraId]!['turnos'].add(turno);
    }
  }

  void actualizarTurno(
    String carreraId,
    String turnoId,
    Map<String, dynamic> turnoActualizado,
  ) {
    if (_carrerasData.containsKey(carreraId)) {
      final turnos = _carrerasData[carreraId]!['turnos'];
      if (turnos != null) {
        final index = turnos.indexWhere(
          (t) => t['id'].toString() == turnoId.toString(),
        );
        if (index != -1) {
          turnos[index] = turnoActualizado;
        }
      }
    }
  }

  void eliminarTurno(String carreraId, String turnoId) {
    if (_carrerasData.containsKey(carreraId)) {
      final turnos = _carrerasData[carreraId]!['turnos'];
      if (turnos != null) {
        turnos.removeWhere((t) => t['id'].toString() == turnoId.toString());
      }
    }
  }

  // ========== MÉTODOS PARA NIVELES ==========

  List<Map<String, dynamic>> getNiveles(String carreraId, String turnoId) {
    final turno = _getTurno(carreraId, turnoId);
    if (turno != null && turno['niveles'] != null) {
      return List<Map<String, dynamic>>.from(turno['niveles']);
    }
    return [];
  }

  void agregarNivel(
    String carreraId,
    String turnoId,
    Map<String, dynamic> nivel,
  ) {
    final turno = _getTurno(carreraId, turnoId);
    if (turno != null) {
      if (turno['niveles'] == null) {
        turno['niveles'] = [];
      }
      turno['niveles'].add(nivel);
    }
  }

  void actualizarNivel(
    String carreraId,
    String turnoId,
    String nivelId,
    Map<String, dynamic> nivelActualizado,
  ) {
    final turno = _getTurno(carreraId, turnoId);
    if (turno != null && turno['niveles'] != null) {
      final niveles = turno['niveles'];
      final index = niveles.indexWhere(
        (n) => n['id'].toString() == nivelId.toString(),
      );
      if (index != -1) {
        niveles[index] = nivelActualizado;
      }
    }
  }

  void eliminarNivel(String carreraId, String turnoId, String nivelId) {
    final turno = _getTurno(carreraId, turnoId);
    if (turno != null && turno['niveles'] != null) {
      turno['niveles'].removeWhere(
        (n) => n['id'].toString() == nivelId.toString(),
      );
    }
  }

  // ========== MÉTODOS PARA PARALELOS ==========

  List<Map<String, dynamic>> getParalelos(
    String carreraId,
    String turnoId,
    String nivelId,
  ) {
    final nivel = _getNivel(carreraId, turnoId, nivelId);
    if (nivel != null && nivel['paralelos'] != null) {
      return List<Map<String, dynamic>>.from(nivel['paralelos']);
    }
    return [];
  }

  void agregarParalelo(
    String carreraId,
    String turnoId,
    String nivelId,
    Map<String, dynamic> paralelo,
  ) {
    final nivel = _getNivel(carreraId, turnoId, nivelId);
    if (nivel != null) {
      if (nivel['paralelos'] == null) {
        nivel['paralelos'] = [];
      }
      nivel['paralelos'].add(paralelo);
    }
  }

  void actualizarParalelo(
    String carreraId,
    String turnoId,
    String nivelId,
    String paraleloId,
    Map<String, dynamic> paraleloActualizado,
  ) {
    final nivel = _getNivel(carreraId, turnoId, nivelId);
    if (nivel != null && nivel['paralelos'] != null) {
      final paralelos = nivel['paralelos'];
      final index = paralelos.indexWhere(
        (p) => p['id'].toString() == paraleloId.toString(),
      );
      if (index != -1) {
        paralelos[index] = paraleloActualizado;
      }
    }
  }

  void eliminarParalelo(
    String carreraId,
    String turnoId,
    String nivelId,
    String paraleloId,
  ) {
    final nivel = _getNivel(carreraId, turnoId, nivelId);
    if (nivel != null && nivel['paralelos'] != null) {
      nivel['paralelos'].removeWhere(
        (p) => p['id'].toString() == paraleloId.toString(),
      );
    }
  }

  // ========== MÉTODOS PARA ESTUDIANTES ==========

  List<Map<String, dynamic>> getEstudiantes(
    String carreraId,
    String turnoId,
    String nivelId,
    String paraleloId,
  ) {
    final paralelo = _getParalelo(carreraId, turnoId, nivelId, paraleloId);
    if (paralelo != null && paralelo['estudiantes'] != null) {
      return List<Map<String, dynamic>>.from(paralelo['estudiantes']);
    }
    return [];
  }

  void agregarEstudiante(
    String carreraId,
    String turnoId,
    String nivelId,
    String paraleloId,
    Map<String, dynamic> estudiante,
  ) {
    final paralelo = _getParalelo(carreraId, turnoId, nivelId, paraleloId);
    if (paralelo != null) {
      if (paralelo['estudiantes'] == null) {
        paralelo['estudiantes'] = [];
      }
      paralelo['estudiantes'].add(estudiante);
    }
  }

  void actualizarEstudiante(
    String carreraId,
    String turnoId,
    String nivelId,
    String paraleloId,
    String estudianteId,
    Map<String, dynamic> estudianteActualizado,
  ) {
    final paralelo = _getParalelo(carreraId, turnoId, nivelId, paraleloId);
    if (paralelo != null && paralelo['estudiantes'] != null) {
      final estudiantes = paralelo['estudiantes'];
      final index = estudiantes.indexWhere(
        (e) => e['id'].toString() == estudianteId.toString(),
      );
      if (index != -1) {
        estudiantes[index] = estudianteActualizado;
      }
    }
  }

  void eliminarEstudiante(
    String carreraId,
    String turnoId,
    String nivelId,
    String paraleloId,
    String estudianteId,
  ) {
    final paralelo = _getParalelo(carreraId, turnoId, nivelId, paraleloId);
    if (paralelo != null && paralelo['estudiantes'] != null) {
      paralelo['estudiantes'].removeWhere(
        (e) => e['id'].toString() == estudianteId.toString(),
      );
    }
  }

  // ========== MÉTODOS PARA DOCENTES ==========

  List<Map<String, dynamic>> getDocentes(String carreraId) {
    final carrera = _carrerasData[carreraId];
    if (carrera != null && carrera['docentes'] != null) {
      return List<Map<String, dynamic>>.from(carrera['docentes']);
    }
    return [];
  }

  void agregarDocente(String carreraId, Map<String, dynamic> docente) {
    if (_carrerasData.containsKey(carreraId)) {
      if (_carrerasData[carreraId]!['docentes'] == null) {
        _carrerasData[carreraId]!['docentes'] = [];
      }
      _carrerasData[carreraId]!['docentes'].add(docente);
    }
  }

  void actualizarDocente(
    String carreraId,
    String docenteId,
    Map<String, dynamic> docenteActualizado,
  ) {
    if (_carrerasData.containsKey(carreraId)) {
      final docentes = _carrerasData[carreraId]!['docentes'];
      if (docentes != null) {
        final index = docentes.indexWhere(
          (d) => d['id'].toString() == docenteId.toString(),
        );
        if (index != -1) {
          docentes[index] = docenteActualizado;
        }
      }
    }
  }

  void eliminarDocente(String carreraId, String docenteId) {
    if (_carrerasData.containsKey(carreraId)) {
      final docentes = _carrerasData[carreraId]!['docentes'];
      if (docentes != null) {
        docentes.removeWhere((d) => d['id'].toString() == docenteId.toString());
      }
    }
  }

  // ========== MÉTODOS AUXILIARES PRIVADOS ==========

  Map<String, dynamic>? _getTurno(String carreraId, String turnoId) {
    if (_carrerasData.containsKey(carreraId)) {
      final turnos = _carrerasData[carreraId]!['turnos'];
      if (turnos != null) {
        try {
          return turnos.firstWhere(
            (t) => t['id'].toString() == turnoId.toString(),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  Map<String, dynamic>? _getNivel(
    String carreraId,
    String turnoId,
    String nivelId,
  ) {
    final turno = _getTurno(carreraId, turnoId);
    if (turno != null && turno['niveles'] != null) {
      try {
        return turno['niveles'].firstWhere(
          (n) => n['id'].toString() == nivelId.toString(),
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic>? _getParalelo(
    String carreraId,
    String turnoId,
    String nivelId,
    String paraleloId,
  ) {
    final nivel = _getNivel(carreraId, turnoId, nivelId);
    if (nivel != null && nivel['paralelos'] != null) {
      try {
        return nivel['paralelos'].firstWhere(
          (p) => p['id'].toString() == paraleloId.toString(),
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ========== MÉTODOS DE UTILIDAD ==========

  void limpiarTodosLosDatos() {
    _carrerasData.clear();
  }

  bool existeCarrera(String carreraId) {
    return _carrerasData.containsKey(carreraId);
  }

  Map<String, int> getEstadisticas() {
    int totalCarreras = _carrerasData.length;
    int totalTurnos = 0;
    int totalNiveles = 0;
    int totalParalelos = 0;
    int totalEstudiantes = 0;
    int totalDocentes = 0;

    _carrerasData.forEach((carreraId, carrera) {
      final docentes = carrera['docentes'];
      if (docentes is List) {
        totalDocentes += docentes.length;
      }

      final turnos = carrera['turnos'];
      if (turnos is List) {
        totalTurnos += turnos.length;

        for (var turno in turnos) {
          final niveles = turno['niveles'];
          if (niveles is List) {
            totalNiveles += niveles.length;

            for (var nivel in niveles) {
              final paralelos = nivel['paralelos'];
              if (paralelos is List) {
                totalParalelos += paralelos.length;

                for (var paralelo in paralelos) {
                  final estudiantes = paralelo['estudiantes'];
                  if (estudiantes is List) {
                    totalEstudiantes += estudiantes.length;
                  }
                }
              }
            }
          }
        }
      }
    });

    return {
      'carreras': totalCarreras,
      'turnos': totalTurnos,
      'niveles': totalNiveles,
      'paralelos': totalParalelos,
      'estudiantes': totalEstudiantes,
      'docentes': totalDocentes,
    };
  }
}
