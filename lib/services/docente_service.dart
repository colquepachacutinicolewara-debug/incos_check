// services/docente_service.dart - VERSIÓN COMPLETA Y CORREGIDA
import 'package:sqflite/sqflite.dart';
import '../models/database_helper.dart';

class DocenteService {
  static final DocenteService _instance = DocenteService._internal();
  factory DocenteService() => _instance;
  DocenteService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // 🌟 OBTENER ESTUDIANTES ORGANIZADOS POR PARALELO/TURNO/GRADO/MATERIA
  Future<Map<String, dynamic>> obtenerEstudiantesOrganizados(String docenteId) async {
    try {
      final db = await _databaseHelper.database;
      
      final estudiantes = await db.rawQuery('''
        SELECT DISTINCT 
          e.*,
          m.id as materia_id,
          m.nombre as materia_nombre,
          m.codigo as materia_codigo,
          p.id as paralelo_id,
          p.nombre as paralelo_nombre,
          t.id as turno_id,
          t.nombre as turno_nombre,
          n.id as nivel_id,
          n.nombre as nivel_nombre,
          c.id as carrera_id,
          c.nombre as carrera_nombre
        FROM estudiantes e
        JOIN docente_materia dm ON e.paralelo_id = dm.paralelo_id
        JOIN materias m ON dm.materia_id = m.id
        JOIN paralelos p ON e.paralelo_id = p.id
        JOIN turnos t ON e.turno_id = t.id
        JOIN niveles n ON e.nivel_id = n.id
        JOIN carreras c ON e.carrera_id = c.id
        WHERE dm.docente_id = ? AND dm.activo = 1 AND e.activo = 1
        ORDER BY c.nombre, n.nombre, p.nombre, t.nombre, e.apellido_paterno
      ''', [docenteId]);

      // 🌟 ORGANIZAR POR ESTRUCTURA JERÁRQUICA
      final Map<String, dynamic> datosOrganizados = {
        'carreras': {},
        'resumen': {
          'total_estudiantes': 0,
          'total_materias': 0,
          'total_paralelos': 0,
        }
      };

      for (var estudiante in estudiantes) {
        final carreraId = estudiante['carrera_id'].toString();
        final nivelId = estudiante['nivel_id'].toString();
        final paraleloId = estudiante['paralelo_id'].toString();
        final turnoId = estudiante['turno_id'].toString();
        final materiaId = estudiante['materia_id'].toString();

        // 🌟 INICIALIZAR ESTRUCTURA SI NO EXISTE
        if (!datosOrganizados['carreras'].containsKey(carreraId)) {
          datosOrganizados['carreras'][carreraId] = {
            'nombre': estudiante['carrera_nombre'],
            'niveles': {},
            'resumen': {'total_estudiantes': 0, 'total_materias': 0}
          };
        }

        if (!datosOrganizados['carreras'][carreraId]['niveles'].containsKey(nivelId)) {
          datosOrganizados['carreras'][carreraId]['niveles'][nivelId] = {
            'nombre': estudiante['nivel_nombre'],
            'paralelos': {},
            'resumen': {'total_estudiantes': 0, 'total_materias': 0}
          };
        }

        if (!datosOrganizados['carreras'][carreraId]['niveles'][nivelId]['paralelos'].containsKey(paraleloId)) {
          datosOrganizados['carreras'][carreraId]['niveles'][nivelId]['paralelos'][paraleloId] = {
            'nombre': estudiante['paralelo_nombre'],
            'turno': estudiante['turno_nombre'],
            'materias': {},
            'estudiantes': [],
            'resumen': {'total_estudiantes': 0, 'total_materias': 0}
          };
        }

        final paralelo = datosOrganizados['carreras'][carreraId]['niveles'][nivelId]['paralelos'][paraleloId];

        // 🌟 AGREGAR MATERIA SI NO EXISTE
        if (!paralelo['materias'].containsKey(materiaId)) {
          paralelo['materias'][materiaId] = {
            'nombre': estudiante['materia_nombre'],
            'codigo': estudiante['materia_codigo'],
            'estudiantes': []
          };
        }

        // 🌟 AGREGAR ESTUDIANTE A LA MATERIA Y AL PARALELO
        final estudianteData = {
          'id': estudiante['id'],
          'nombres': estudiante['nombres'],
          'apellido_paterno': estudiante['apellido_paterno'],
          'apellido_materno': estudiante['apellido_materno'],
          'ci': estudiante['ci'],
          'carrera': estudiante['carrera_nombre'],
          'nivel': estudiante['nivel_nombre'],
          'paralelo': estudiante['paralelo_nombre'],
          'turno': estudiante['turno_nombre'],
        };

        // Evitar duplicados en estudiantes del paralelo
        final existeEnParalelo = paralelo['estudiantes'].any((e) => e['id'] == estudiante['id']);
        if (!existeEnParalelo) {
          paralelo['estudiantes'].add(estudianteData);
          paralelo['resumen']['total_estudiantes']++;
          
          // Actualizar contadores
          datosOrganizados['carreras'][carreraId]['niveles'][nivelId]['resumen']['total_estudiantes']++;
          datosOrganizados['carreras'][carreraId]['resumen']['total_estudiantes']++;
          datosOrganizados['resumen']['total_estudiantes']++;
        }

        // Agregar estudiante a la materia
        paralelo['materias'][materiaId]['estudiantes'].add(estudianteData);
      }

      // 🌟 CONTAR MATERIAS TOTALES - CORREGIDO
      int totalMaterias = 0;
      int totalParalelos = 0;
      
      datosOrganizados['carreras'].forEach((carreraId, carrera) {
        carrera['niveles'].forEach((nivelId, nivel) {
          nivel['paralelos'].forEach((paraleloId, paralelo) {
            totalParalelos++;
            totalMaterias += (paralelo['materias'].length as int?) ?? 0; // ✅ CORREGIDO
          });
        });
      });

      datosOrganizados['resumen']['total_materias'] = totalMaterias;
      datosOrganizados['resumen']['total_paralelos'] = totalParalelos;

      return datosOrganizados;
    } catch (e) {
      print('❌ Error obteniendo estudiantes organizados: $e');
      return {'carreras': {}, 'resumen': {'total_estudiantes': 0, 'total_materias': 0, 'total_paralelos': 0}};
    }
  }

  // 🌟 OBTENER ESTADÍSTICAS DETALLADAS POR MATERIA/PARALELO
  Future<Map<String, dynamic>> obtenerEstadisticasDetalladas(String docenteId, String periodoId) async {
    try {
      final db = await _databaseHelper.database;
      
      // Estadísticas por materia
      final statsMaterias = await db.rawQuery('''
        SELECT 
          m.id,
          m.nombre,
          m.codigo,
          p.nombre as paralelo,
          COUNT(DISTINCT e.id) as total_estudiantes,
          COUNT(DISTINCT CASE WHEN da.estado = 'A' THEN e.id END) as estudiantes_presentes,
          COUNT(DISTINCT CASE WHEN da.estado = 'F' THEN e.id END) as estudiantes_ausentes,
          ROUND(AVG(CASE WHEN da.estado = 'A' THEN 100 ELSE 0 END), 2) as porcentaje_asistencia
        FROM materias m
        JOIN docente_materia dm ON m.id = dm.materia_id
        JOIN paralelos p ON dm.paralelo_id = p.id
        JOIN estudiantes e ON p.id = e.paralelo_id
        LEFT JOIN asistencias a ON e.id = a.estudiante_id AND a.materia_id = m.id
        LEFT JOIN detalle_asistencias da ON a.id = da.asistencia_id AND da.fecha >= date('now', '-30 days')
        WHERE dm.docente_id = ? AND dm.activo = 1 AND e.activo = 1
        GROUP BY m.id, m.nombre, p.nombre
        ORDER BY m.nombre, p.nombre
      ''', [docenteId]);

      // Estadísticas generales
      final statsGenerales = await db.rawQuery('''
        SELECT 
          COUNT(DISTINCT e.id) as total_estudiantes,
          COUNT(DISTINCT m.id) as total_materias,
          COUNT(DISTINCT p.id) as total_paralelos,
          COUNT(DISTINCT CASE WHEN da.estado = 'A' THEN e.id END) as total_presentes,
          COUNT(DISTINCT CASE WHEN da.estado = 'F' THEN e.id END) as total_ausentes,
          ROUND(AVG(CASE WHEN da.estado = 'A' THEN 100 ELSE 0 END), 2) as promedio_asistencia
        FROM docente_materia dm
        JOIN materias m ON dm.materia_id = m.id
        JOIN paralelos p ON dm.paralelo_id = p.id
        JOIN estudiantes e ON p.id = e.paralelo_id
        LEFT JOIN asistencias a ON e.id = a.estudiante_id AND a.materia_id = m.id
        LEFT JOIN detalle_asistencias da ON a.id = da.asistencia_id AND da.fecha >= date('now', '-30 days')
        WHERE dm.docente_id = ? AND dm.activo = 1 AND e.activo = 1
      ''', [docenteId]);

      return {
        'estadisticas_materias': statsMaterias,
        'estadisticas_generales': statsGenerales.isNotEmpty ? statsGenerales.first : {},
        'periodo_consulta': periodoId,
        'fecha_consulta': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error obteniendo estadísticas detalladas: $e');
      return {};
    }
  }

  // 🌟 OBTENER NOTAS BIMESTRALES DE ESTUDIANTES
  Future<List<Map<String, dynamic>>> obtenerNotasBimestrales(
    String docenteId, 
    String bimestreId,
    String materiaId
  ) async {
    try {
      final db = await _databaseHelper.database;
      
      return await db.rawQuery('''
        SELECT 
          e.id as estudiante_id,
          e.nombres,
          e.apellido_paterno,
          e.apellido_materno,
          e.ci,
          p.nombre as paralelo,
          na.nota_calculada,
          na.porcentaje_asistencia,
          na.total_clases,
          na.clases_asistidas,
          na.clases_faltadas,
          na.estado,
          na.fecha_calculo
        FROM estudiantes e
        JOIN docente_materia dm ON e.paralelo_id = dm.paralelo_id
        JOIN paralelos p ON e.paralelo_id = p.id
        LEFT JOIN notas_asistencia na ON e.id = na.estudiante_id 
          AND na.materia_id = dm.materia_id 
          AND na.bimestre_id = ?
        WHERE dm.docente_id = ? AND dm.materia_id = ? AND dm.activo = 1 AND e.activo = 1
        ORDER BY e.apellido_paterno, e.apellido_materno, e.nombres
      ''', [bimestreId, docenteId, materiaId]);
    } catch (e) {
      print('❌ Error obteniendo notas bimestrales: $e');
      return [];
    }
  }

  // 🌟 GENERAR REPORTE PDF DE NOTAS
  Future<Map<String, dynamic>> generarReporteNotasPDF({
    required String docenteId,
    required String bimestreId,
    required String materiaId,
  }) async {
    try {
      final notas = await obtenerNotasBimestrales(docenteId, bimestreId, materiaId);
      
      // Aquí integrarías una librería de PDF como pdf/widgets
      // Por ahora retornamos los datos estructurados
      return {
        'success': true,
        'datos': notas,
        'tipo_reporte': 'NOTAS_BIMESTRALES',
        'bimestre_id': bimestreId,
        'materia_id': materiaId,
        'fecha_generacion': DateTime.now().toIso8601String(),
        'total_estudiantes': notas.length,
        'promedio_nota': _calcularPromedio(notas),
      };
    } catch (e) {
      print('❌ Error generando reporte PDF: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // 🌟 GENERAR REPORTE EXCEL DE ASISTENCIAS
  Future<Map<String, dynamic>> generarReporteAsistenciasExcel({
    required String docenteId,
    required String materiaId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final db = await _databaseHelper.database;
      
      final asistencias = await db.rawQuery('''
        SELECT 
          e.nombres,
          e.apellido_paterno,
          e.apellido_materno,
          e.ci,
          p.nombre as paralelo,
          da.fecha,
          da.estado,
          da.estado_puntualidad,
          da.hora_registro,
          da.minutos_retraso
        FROM estudiantes e
        JOIN docente_materia dm ON e.paralelo_id = dm.paralelo_id
        JOIN paralelos p ON e.paralelo_id = p.id
        JOIN asistencias a ON e.id = a.estudiante_id AND a.materia_id = dm.materia_id
        JOIN detalle_asistencias da ON a.id = da.asistencia_id
        WHERE dm.docente_id = ? 
          AND dm.materia_id = ?
          AND da.fecha BETWEEN ? AND ?
          AND dm.activo = 1 
          AND e.activo = 1
        ORDER BY e.apellido_paterno, da.fecha
      ''', [
        docenteId, 
        materiaId,
        "${fechaInicio.year}-${fechaInicio.month.toString().padLeft(2, '0')}-${fechaInicio.day.toString().padLeft(2, '0')}",
        "${fechaFin.year}-${fechaFin.month.toString().padLeft(2, '0')}-${fechaFin.day.toString().padLeft(2, '0')}"
      ]);

      // Aquí integrarías una librería de Excel como excel
      return {
        'success': true,
        'datos': asistencias,
        'tipo_reporte': 'ASISTENCIAS_EXCEL',
        'materia_id': materiaId,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        'total_registros': asistencias.length,
      };
    } catch (e) {
      print('❌ Error generando reporte Excel: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // 🌟 CALCULAR PROMEDIO DE NOTAS
  double _calcularPromedio(List<Map<String, dynamic>> notas) {
    if (notas.isEmpty) return 0.0;
    
    double suma = 0.0;
    int contador = 0;
    
    for (var nota in notas) {
      final valor = nota['nota_calculada'] as double?;
      if (valor != null) {
        suma += valor;
        contador++;
      }
    }
    
    return contador > 0 ? suma / contador : 0.0;
  }

  // 🌟 OBTENER BIMESTRES ACTIVOS
  Future<List<Map<String, dynamic>>> obtenerBimestresActivos() async {
    try {
      final db = await _databaseHelper.database;
      return await db.rawQuery('''
        SELECT * FROM bimestres 
        WHERE id IN (SELECT DISTINCT bimestre_id FROM notas_asistencia)
        ORDER BY nombre
      ''');
    } catch (e) {
      print('❌ Error obteniendo bimestres: $e');
      return [];
    }
  }

  // 🌟 CALCULAR NOTAS BIMESTRALES AUTOMÁTICAMENTE
  Future<bool> calcularNotasBimestrales({
    required String docenteId,
    required String bimestreId,
    required String materiaId,
  }) async {
    try {
      final db = await _databaseHelper.database;
      
      // Obtener estudiantes del docente en esta materia
      final estudiantes = await db.rawQuery('''
        SELECT DISTINCT e.id
        FROM estudiantes e
        JOIN docente_materia dm ON e.paralelo_id = dm.paralelo_id
        WHERE dm.docente_id = ? AND dm.materia_id = ? AND dm.activo = 1 AND e.activo = 1
      ''', [docenteId, materiaId]);

      for (var estudiante in estudiantes) {
        final estudianteId = estudiante['id'].toString();
        
        // Calcular asistencia del bimestre
        final asistenciaData = await db.rawQuery('''
          SELECT 
            COUNT(*) as total_clases,
            SUM(CASE WHEN da.estado = 'A' THEN 1 ELSE 0 END) as clases_asistidas
          FROM asistencias a
          JOIN detalle_asistencias da ON a.id = da.asistencia_id
          JOIN bimestres b ON a.periodo_id = b.periodo_id
          WHERE a.estudiante_id = ? 
            AND a.materia_id = ? 
            AND b.id = ?
        ''', [estudianteId, materiaId, bimestreId]);

        if (asistenciaData.isNotEmpty) {
          final data = asistenciaData.first;
          final totalClases = data['total_clases'] as int? ?? 0;
          final clasesAsistidas = data['clases_asistidas'] as int? ?? 0;
          final porcentajeAsistencia = totalClases > 0 ? (clasesAsistidas / totalClases) * 100 : 0.0;
          
          // Aplicar fórmula de cálculo de nota (sobre 10 puntos)
          final notaCalculada = (porcentajeAsistencia / 100) * 10;

          // Guardar o actualizar nota
          await db.insert('notas_asistencia', {
            'id': 'nota_${estudianteId}_${materiaId}_$bimestreId',
            'estudiante_id': estudianteId,
            'materia_id': materiaId,
            'periodo_id': 'periodo_2024', // Esto debería venir del bimestre
            'bimestre_id': bimestreId,
            'config_asistencia_id': 'config_asistencia_default',
            'total_clases': totalClases,
            'clases_asistidas': clasesAsistidas,
            'clases_faltadas': totalClases - clasesAsistidas,
            'porcentaje_asistencia': porcentajeAsistencia,
            'nota_calculada': notaCalculada,
            'estado': 'CALCULADO',
            'fecha_calculo': DateTime.now().toIso8601String(),
            'observaciones': 'Calculado automáticamente por el docente',
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      return true;
    } catch (e) {
      print('❌ Error calculando notas bimestrales: $e');
      return false;
    }
  }

  // 🌟 OBTENER ESTUDIANTES DE UN DOCENTE ESPECÍFICO
  Future<List<Map<String, dynamic>>> obtenerEstudiantesPorDocente(String docenteId) async {
    try {
      final db = await _databaseHelper.database;
      
      return await db.rawQuery('''
        SELECT DISTINCT e.*, m.nombre as materia_nombre, p.nombre as paralelo_nombre
        FROM estudiantes e
        JOIN docente_materia dm ON e.paralelo_id = dm.paralelo_id
        JOIN materias m ON dm.materia_id = m.id
        JOIN paralelos p ON e.paralelo_id = p.id
        WHERE dm.docente_id = ? AND dm.activo = 1 AND e.activo = 1
        ORDER BY e.apellido_paterno, e.apellido_materno, e.nombres
      ''', [docenteId]);
    } catch (e) {
      print('❌ Error obteniendo estudiantes del docente: $e');
      return [];
    }
  }

  // 🌟 OBTENER MATERIAS DE UN DOCENTE
  Future<List<Map<String, dynamic>>> obtenerMateriasPorDocente(String docenteId) async {
    try {
      final db = await _databaseHelper.database;
      
      return await db.rawQuery('''
        SELECT m.*, dm.paralelo_id, p.nombre as paralelo_nombre
        FROM docente_materia dm
        JOIN materias m ON dm.materia_id = m.id
        LEFT JOIN paralelos p ON dm.paralelo_id = p.id
        WHERE dm.docente_id = ? AND dm.activo = 1
        ORDER BY m.nombre
      ''', [docenteId]);
    } catch (e) {
      print('❌ Error obteniendo materias del docente: $e');
      return [];
    }
  }

  // 🌟 VERIFICAR SI UN DOCENTE TIENE ACCESO A UN ESTUDIANTE - CORREGIDO
  Future<bool> docenteTieneAccesoAEstudiante(String docenteId, String estudianteId) async {
    try {
      final db = await _databaseHelper.database;
      
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM estudiantes e
        JOIN docente_materia dm ON e.paralelo_id = dm.paralelo_id
        WHERE dm.docente_id = ? AND e.id = ? AND dm.activo = 1 AND e.activo = 1
      ''', [docenteId, estudianteId]);
      
      // ✅ CORREGIDO: Usar corchetes en lugar de paréntesis y verificar correctamente
      final count = result.first['count'] as int? ?? 0;
      return count > 0;
    } catch (e) {
      print('❌ Error verificando acceso docente-estudiante: $e');
      return false;
    }
  }

  // 🌟 OBTENER ASISTENCIAS DE ESTUDIANTES DEL DOCENTE
  Future<List<Map<String, dynamic>>> obtenerAsistenciasPorDocente(
    String docenteId, 
    String materiaId, 
    DateTime fecha
  ) async {
    try {
      final db = await _databaseHelper.database;
      final fechaStr = "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
      
      return await db.rawQuery('''
        SELECT e.*, da.estado, da.hora_registro, da.estado_puntualidad
        FROM estudiantes e
        JOIN docente_materia dm ON e.paralelo_id = dm.paralelo_id
        LEFT JOIN asistencias a ON e.id = a.estudiante_id AND a.materia_id = ?
        LEFT JOIN detalle_asistencias da ON a.id = da.asistencia_id AND da.fecha = ?
        WHERE dm.docente_id = ? AND dm.materia_id = ? AND dm.activo = 1 AND e.activo = 1
        ORDER BY e.apellido_paterno, e.apellido_materno, e.nombres
      ''', [materiaId, fechaStr, docenteId, materiaId]);
    } catch (e) {
      print('❌ Error obteniendo asistencias del docente: $e');
      return [];
    }
  }

  // 🌟 REGISTRAR ASISTENCIA POR DOCENTE
  Future<bool> registrarAsistenciaDocente({
    required String docenteId,
    required String estudianteId,
    required String materiaId,
    required bool presente,
    int minutosRetraso = 0,
  }) async {
    try {
      // Verificar que el docente tiene acceso al estudiante
      final tieneAcceso = await docenteTieneAccesoAEstudiante(docenteId, estudianteId);
      if (!tieneAcceso) {
        print('❌ Docente no tiene acceso a este estudiante');
        return false;
      }

      final db = await _databaseHelper.database;
      final now = DateTime.now();
      final fechaStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final horaStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      // Determinar estado de puntualidad
      String estadoPuntualidad = 'PUNTUAL';
      if (minutosRetraso > 0 && minutosRetraso <= 15) {
        estadoPuntualidad = 'TARDANZA_LEVE';
      } else if (minutosRetraso > 15) {
        estadoPuntualidad = 'TARDANZA_GRAVE';
      }

      // Buscar o crear registro de asistencia principal
      final asistenciaId = 'att_${estudianteId}_${materiaId}_${now.millisecondsSinceEpoch}';
      
      // Insertar/actualizar en asistencias
      await db.insert('asistencias', {
        'id': asistenciaId,
        'estudiante_id': estudianteId,
        'materia_id': materiaId,
        'periodo_id': 'periodo_2024', // Esto debería venir del contexto
        'asistencia_registrada_hoy': 1,
        'ultima_actualizacion': now.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Insertar/actualizar en detalle_asistencias
      await db.insert('detalle_asistencias', {
        'id': 'det_${asistenciaId}_$fechaStr',
        'asistencia_id': asistenciaId,
        'dia': _getDayName(now.weekday),
        'porcentaje': presente ? 100 : 0,
        'estado': presente ? 'A' : 'F',
        'fecha': fechaStr,
        'hora_registro': horaStr,
        'minutos_retraso': minutosRetraso,
        'estado_puntualidad': estadoPuntualidad,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      print('✅ Asistencia registrada por docente $docenteId para estudiante $estudianteId');
      return true;
    } catch (e) {
      print('❌ Error registrando asistencia: $e');
      return false;
    }
  }

  // 🌟 MÉTODO AUXILIAR PARA NOMBRE DEL DÍA
  String _getDayName(int weekday) {
    final days = ['', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday];
  }

  // 🌟 OBTENER ESTADÍSTICAS DEL DOCENTE
  Future<Map<String, dynamic>> obtenerEstadisticasDocente(String docenteId) async {
    try {
      final db = await _databaseHelper.database;
      
      final totalEstudiantes = await db.rawQuery('''
        SELECT COUNT(DISTINCT e.id) as total
        FROM estudiantes e
        JOIN docente_materia dm ON e.paralelo_id = dm.paralelo_id
        WHERE dm.docente_id = ? AND dm.activo = 1 AND e.activo = 1
      ''', [docenteId]);

      final totalMaterias = await db.rawQuery('''
        SELECT COUNT(DISTINCT m.id) as total
        FROM docente_materia dm
        JOIN materias m ON dm.materia_id = m.id
        WHERE dm.docente_id = ? AND dm.activo = 1
      ''', [docenteId]);

      final asistenciasHoy = await db.rawQuery('''
        SELECT COUNT(*) as total
        FROM detalle_asistencias da
        JOIN asistencias a ON da.asistencia_id = a.id
        JOIN docente_materia dm ON a.materia_id = dm.materia_id
        WHERE dm.docente_id = ? AND da.fecha = date('now') AND da.estado = 'A'
      ''', [docenteId]);

      return {
        'total_estudiantes': (totalEstudiantes.first['total'] as int?) ?? 0,
        'total_materias': (totalMaterias.first['total'] as int?) ?? 0,
        'asistencias_hoy': (asistenciasHoy.first['total'] as int?) ?? 0,
      };
    } catch (e) {
      print('❌ Error obteniendo estadísticas del docente: $e');
      return {
        'total_estudiantes': 0,
        'total_materias': 0,
        'asistencias_hoy': 0,
      };
    }
  }
}