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
    final key = carreraId.toString();
    if (!_carrerasData.containsKey(key)) {
      _carrerasData[key] = {
        'id': key,
        'nombre': carreraNombre,
        'color': color,
        'turnos': [],
        'docentes': [],
      };

      // SOLO para Sistemas Informáticos agregar datos por defecto
      if (carreraNombre == 'Sistemas Informáticos' && key == '1') {
        _agregarDatosPorDefectoSistemas(key);
      }
    }
  }

  // Agregar datos por defecto SOLO para Sistemas Informáticos
  void _agregarDatosPorDefectoSistemas(String carreraId) {
    final turnosPorDefecto = [
      {
        'id': '${carreraId}_manana',
        'nombre': 'Mañana',
        'icon': _serializeIcon(Icons.wb_sunny),
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
        'icon': _serializeIcon(Icons.nights_stay),
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
    // Devolver copias con iconos deserializados
    return _carrerasData.values
        .map((c) => _deserializeCarrera(Map<String, dynamic>.from(c)))
        .toList();
  }

  Map<String, dynamic>? getCarrera(String carreraId) {
    final key = carreraId.toString();
    final raw = _carrerasData[key];
    if (raw == null) return null;
    return _deserializeCarrera(Map<String, dynamic>.from(raw));
  }

  void agregarCarrera(Map<String, dynamic> carrera) {
    String carreraId = carrera['id'].toString();
    if (!_carrerasData.containsKey(carreraId)) {
      final stored = Map<String, dynamic>.from(carrera);
      stored['id'] = carreraId.toString();
      stored['icon'] = _serializeIcon(stored['icon']);
      stored['turnos'] = stored['turnos'] ?? [];
      stored['docentes'] = stored['docentes'] ?? [];
      final safe = _ensureJsonCompatible(stored);
      _carrerasData[carreraId] = safe;
    }
  }

  void actualizarCarrera(
    String carreraId,
    Map<String, dynamic> carreraActualizada,
  ) {
    final key = carreraId.toString();
    if (_carrerasData.containsKey(key)) {
      final merged = {..._carrerasData[key]!, ...carreraActualizada};
      if (merged.containsKey('icon')) {
        merged['icon'] = _serializeIcon(merged['icon']);
      }
      merged['turnos'] = _carrerasData[key]!['turnos'] ?? [];
      merged['docentes'] = _carrerasData[key]!['docentes'] ?? [];
      final safe = _ensureJsonCompatible(Map<String, dynamic>.from(merged));
      _carrerasData[key] = safe;
    }
  }

  void eliminarCarrera(String carreraId) {
    final key = carreraId.toString();
    _carrerasData.remove(key);
  }

  // ========== MÉTODOS PARA TURNOS ==========

  List<Map<String, dynamic>> getTurnos(String carreraId) {
    final key = carreraId.toString();
    final carrera = _carrerasData[key];
    if (carrera != null && carrera['turnos'] != null) {
      // Deserializar iconos de turnos antes de devolver
      return (List<Map<String, dynamic>>.from(carrera['turnos']))
          .map((t) => _deserializeTurno(Map<String, dynamic>.from(t)))
          .toList();
    }
    return [];
  }

  void agregarTurno(String carreraId, Map<String, dynamic> turno) {
    final key = carreraId.toString();
    if (_carrerasData.containsKey(key)) {
      if (_carrerasData[key]!['turnos'] == null) {
        _carrerasData[key]!['turnos'] = [];
      }
      final stored = Map<String, dynamic>.from(turno);
      if (stored.containsKey('icon')) stored['icon'] = _serializeIcon(stored['icon']);
      final safe = _ensureJsonCompatible(stored);
      _carrerasData[key]!['turnos'].add(safe);
    }
  }

  void actualizarTurno(
    String carreraId,
    String turnoId,
    Map<String, dynamic> turnoActualizado,
  ) {
    final key = carreraId.toString();
    if (_carrerasData.containsKey(key)) {
      final turnos = _carrerasData[key]!['turnos'];
      if (turnos != null) {
        final index = turnos.indexWhere(
          (t) => t['id'].toString() == turnoId.toString(),
        );
        if (index != -1) {
          final stored = Map<String, dynamic>.from(turnoActualizado);
          if (stored.containsKey('icon')) stored['icon'] = _serializeIcon(stored['icon']);
          final safe = _ensureJsonCompatible(stored);
          turnos[index] = safe;
        }
      }
    }
  }

  void eliminarTurno(String carreraId, String turnoId) {
    final key = carreraId.toString();
    if (_carrerasData.containsKey(key)) {
      final turnos = _carrerasData[key]!['turnos'];
      if (turnos != null) {
        turnos.removeWhere((t) => t['id'].toString() == turnoId.toString());
      }
    }
  }

  // ========== MÉTODOS PARA NIVELES ==========

  List<Map<String, dynamic>> getNiveles(String carreraId, String turnoId) {
    final turno = _getTurno(carreraId.toString(), turnoId);
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
    final turno = _getTurno(carreraId.toString(), turnoId);
    if (turno != null) {
      if (turno['niveles'] == null) {
        turno['niveles'] = [];
      }
      turno['niveles'].add(_ensureJsonCompatible(Map<String, dynamic>.from(nivel)));
    }
  }

  void actualizarNivel(
    String carreraId,
    String turnoId,
    String nivelId,
    Map<String, dynamic> nivelActualizado,
  ) {
    final turno = _getTurno(carreraId.toString(), turnoId);
    if (turno != null && turno['niveles'] != null) {
      final niveles = turno['niveles'];
      final index = niveles.indexWhere(
        (n) => n['id'].toString() == nivelId.toString(),
      );
      if (index != -1) {
        niveles[index] = _ensureJsonCompatible(Map<String, dynamic>.from(nivelActualizado));
      }
    }
  }

  void eliminarNivel(String carreraId, String turnoId, String nivelId) {
    final turno = _getTurno(carreraId.toString(), turnoId);
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
    final nivel = _getNivel(carreraId.toString(), turnoId, nivelId);
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
    final nivel = _getNivel(carreraId.toString(), turnoId, nivelId);
    if (nivel != null) {
      if (nivel['paralelos'] == null) {
        nivel['paralelos'] = [];
      }
      nivel['paralelos'].add(_ensureJsonCompatible(Map<String, dynamic>.from(paralelo)));
    }
  }

  void actualizarParalelo(
    String carreraId,
    String turnoId,
    String nivelId,
    String paraleloId,
    Map<String, dynamic> paraleloActualizado,
  ) {
    final nivel = _getNivel(carreraId.toString(), turnoId, nivelId);
    if (nivel != null && nivel['paralelos'] != null) {
      final paralelos = nivel['paralelos'];
      final index = paralelos.indexWhere(
        (p) => p['id'].toString() == paraleloId.toString(),
      );
      if (index != -1) {
        paralelos[index] = _ensureJsonCompatible(Map<String, dynamic>.from(paraleloActualizado));
      }
    }
  }

  void eliminarParalelo(
    String carreraId,
    String turnoId,
    String nivelId,
    String paraleloId,
  ) {
    final nivel = _getNivel(carreraId.toString(), turnoId, nivelId);
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
    final paralelo = _getParalelo(
      carreraId.toString(),
      turnoId,
      nivelId,
      paraleloId,
    );
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
    final paralelo = _getParalelo(
      carreraId.toString(),
      turnoId,
      nivelId,
      paraleloId,
    );
    if (paralelo != null) {
      if (paralelo['estudiantes'] == null) {
        paralelo['estudiantes'] = [];
      }
      paralelo['estudiantes'].add(_ensureJsonCompatible(Map<String, dynamic>.from(estudiante)));
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
    final paralelo = _getParalelo(
      carreraId.toString(),
      turnoId,
      nivelId,
      paraleloId,
    );
    if (paralelo != null && paralelo['estudiantes'] != null) {
      final estudiantes = paralelo['estudiantes'];
      final index = estudiantes.indexWhere(
        (e) => e['id'].toString() == estudianteId.toString(),
      );
      if (index != -1) {
        estudiantes[index] = _ensureJsonCompatible(Map<String, dynamic>.from(estudianteActualizado));
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
    final paralelo = _getParalelo(
      carreraId.toString(),
      turnoId,
      nivelId,
      paraleloId,
    );
    if (paralelo != null && paralelo['estudiantes'] != null) {
      paralelo['estudiantes'].removeWhere(
        (e) => e['id'].toString() == estudianteId.toString(),
      );
    }
  }

  // ========== MÉTODOS PARA DOCENTES ==========

  List<Map<String, dynamic>> getDocentes(String carreraId) {
    final key = carreraId.toString();
    final carrera = _carrerasData[key];
    if (carrera != null && carrera['docentes'] != null) {
      return List<Map<String, dynamic>>.from(carrera['docentes']);
    }
    return [];
  }

  void agregarDocente(String carreraId, Map<String, dynamic> docente) {
    final key = carreraId.toString();
    if (_carrerasData.containsKey(key)) {
      if (_carrerasData[key]!['docentes'] == null) {
        _carrerasData[key]!['docentes'] = [];
      }
      _carrerasData[key]!['docentes'].add(_ensureJsonCompatible(Map<String, dynamic>.from(docente)));
    }
  }

  void actualizarDocente(
    String carreraId,
    String docenteId,
    Map<String, dynamic> docenteActualizado,
  ) {
    final key = carreraId.toString();
    if (_carrerasData.containsKey(key)) {
      final docentes = _carrerasData[key]!['docentes'];
      if (docentes != null) {
        final index = docentes.indexWhere(
          (d) => d['id'].toString() == docenteId.toString(),
        );
        if (index != -1) {
          docentes[index] = _ensureJsonCompatible(Map<String, dynamic>.from(docenteActualizado));
        }
      }
    }
  }

  void eliminarDocente(String carreraId, String docenteId) {
    final key = carreraId.toString();
    if (_carrerasData.containsKey(key)) {
      final docentes = _carrerasData[key]!['docentes'];
      if (docentes != null) {
        docentes.removeWhere((d) => d['id'].toString() == docenteId.toString());
      }
    }
  }

  // ========== MÉTODOS AUXILIARES PRIVADOS ==========

  Map<String, dynamic>? _getTurno(String carreraId, String turnoId) {
    final key = carreraId.toString();
    if (_carrerasData.containsKey(key)) {
      final turnos = _carrerasData[key]!['turnos'];
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
    final turno = _getTurno(carreraId.toString(), turnoId);
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
    final nivel = _getNivel(carreraId.toString(), turnoId, nivelId);
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

  // ========== HELPERS DE ICONOS / DESERIALIZACIÓN ==========

  dynamic _serializeIcon(dynamic icon) {
    if (icon is IconData) {
      return {'codePoint': icon.codePoint, 'fontFamily': icon.fontFamily};
    }
    if (icon is Map) return icon;
    if (icon is int) return {'codePoint': icon, 'fontFamily': 'MaterialIcons'};
    return null;
  }

  IconData _deserializeIcon(dynamic iconField) {
    try {
      if (iconField is IconData) return iconField;
      if (iconField is Map) {
        final cp = iconField['codePoint'];
        final ff = iconField['fontFamily'];
        if (cp is int) return IconData(cp, fontFamily: ff as String?);
        if (cp is String) {
          final parsed = int.tryParse(cp);
          if (parsed != null) return IconData(parsed, fontFamily: ff as String?);
        }
      }
      if (iconField is int) return IconData(iconField, fontFamily: 'MaterialIcons');
    } catch (e) {
      // fallback below
    }
    return Icons.help;
  }

  // Asegura que el mapa/listas sean compatibles con JSON/operaciones que
  // esperan Map<String, Object> en tiempo de ejecución. Convierte recursivamente
  // IconData a mapas serializables y normaliza mapas anidados.
  Map<String, dynamic> _ensureJsonCompatible(Map<String, dynamic> input) {
    final out = <String, dynamic>{};
    input.forEach((key, value) {
      if (value is IconData) {
        out[key] = _serializeIcon(value);
      } else if (value is Map) {
        try {
          out[key] = _ensureJsonCompatible(Map<String, dynamic>.from(value));
        } catch (e) {
          out[key] = value;
        }
      } else if (value is List) {
        out[key] = value.map((e) {
          if (e is IconData) return _serializeIcon(e);
          if (e is Map) return _ensureJsonCompatible(Map<String, dynamic>.from(e));
          return e;
        }).toList();
      } else {
        out[key] = value;
      }
    });
    return out;
  }

  Map<String, dynamic> _deserializeTurno(Map<String, dynamic> t) {
    final m = Map<String, dynamic>.from(t);
    m['icon'] = _deserializeIcon(m['icon']);
    return m;
  }

  Map<String, dynamic> _deserializeCarrera(Map<String, dynamic> c) {
    final m = Map<String, dynamic>.from(c);
    m['icon'] = _deserializeIcon(m['icon']);
    // Normalizar campo 'activa' a boolean
    final a = m['activa'];
    if (a is bool) {
      m['activa'] = a;
    } else if (a is String) {
      m['activa'] = a.toLowerCase() == 'true';
    } else if (a is int) {
      m['activa'] = a != 0;
    } else {
      m['activa'] = false;
    }
    final turnos = m['turnos'];
    if (turnos is List) {
      m['turnos'] = turnos.map((t) => _deserializeTurno(Map<String, dynamic>.from(t))).toList();
    }
    return m;
  }

  // ========== MÉTODOS DE UTILIDAD ==========

  void limpiarTodosLosDatos() {
    _carrerasData.clear();
  }

  bool existeCarrera(String carreraId) {
    final key = carreraId.toString();
    return _carrerasData.containsKey(key);
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
