// repositories/huella_repository.dart - VERSIÓN 100% COMPLETA
import '../models/huella_model.dart';
import '../models/database_helper.dart';

class HuellaRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // ✅ VERIFICAR QUE EL ESTUDIANTE EXISTE CON MÁS DETALLES
  Future<bool> verificarEstudianteExiste(String estudianteId) async {
    try {
      print('🔍 Verificando estudiante con ID: $estudianteId');
      
      final result = await _databaseHelper.rawQuery(
        'SELECT id, nombres, apellido_paterno FROM estudiantes WHERE id = ? AND activo = 1',
        [estudianteId]
      );
      
      if (result.isNotEmpty) {
        final estudiante = result.first;
        print('✅ Estudiante encontrado: ${estudiante['nombres']} ${estudiante['apellido_paterno']}');
        return true;
      } else {
        print('❌ ERROR: No existe estudiante con ID: $estudianteId');
        
        // Verificar qué estudiantes existen en la BD para debug
        final todosEstudiantes = await _databaseHelper.rawQuery(
          'SELECT id, nombres, apellido_paterno FROM estudiantes LIMIT 5'
        );
        print('📋 Estudiantes en BD: $todosEstudiantes');
        
        return false;
      }
    } catch (e) {
      print('❌ Error verificando estudiante: $e');
      return false;
    }
  }

  // ✅ INSERTAR HUELLA CON DIAGNÓSTICO COMPLETO
  Future<bool> insertarHuella(HuellaModel huella) async {
    try {
      print('🔄 Iniciando inserción de huella...');
      print('📋 Datos huella: ${huella.toMap()}');

      // 1. Verificar que el estudiante existe
      final estudianteExiste = await verificarEstudianteExiste(huella.estudianteId);
      if (!estudianteExiste) {
        print('❌ ABORTANDO: Estudiante no existe');
        return false;
      }

      // 2. Verificar si ya existe una huella para este dedo
      final huellaExistente = await _databaseHelper.obtenerHuellaPorDedo(
        huella.estudianteId, 
        huella.numeroDedo
      );
      
      if (huellaExistente != null) {
        print('🔄 Huella ya existe, actualizando...');
        // Actualizar huella existente
        final resultado = await _databaseHelper.actualizarEstadoHuella(
          huella.estudianteId,
          huella.numeroDedo,
          true
        );
        
        if (resultado > 0) {
          print('✅ Huella actualizada exitosamente');
          await actualizarContadorHuellas(huella.estudianteId);
          return true;
        } else {
          print('❌ Error actualizando huella existente');
          return false;
        }
      }

      // 3. Insertar nueva huella
      print('🆕 Insertando nueva huella...');
      final resultado = await _databaseHelper.insertarHuellaBiometrica(huella.toMap());
      
      print('📊 Resultado inserción: $resultado filas afectadas');
      
      if (resultado > 0) {
        print('✅ Huella insertada exitosamente para estudiante: ${huella.estudianteId}');
        // 3. Actualizar contador de huellas
        await actualizarContadorHuellas(huella.estudianteId);
        return true;
      } else {
        print('❌ Inserción falló - 0 filas afectadas');
        return false;
      }

    } catch (e) {
      print('❌ ERROR CRÍTICO insertando huella: $e');
      print('🧨 Stack trace: ${e.toString()}');
      return false;
    }
  }

  // ✅ OBTENER HUELLAS POR ESTUDIANTE
  Future<List<HuellaModel>> obtenerHuellasPorEstudiante(String estudianteId) async {
    try {
      print('🔍 Obteniendo huellas para estudiante: $estudianteId');
      
      final result = await _databaseHelper.obtenerHuellasPorEstudiante(estudianteId);
      
      print('📊 Huellas encontradas: ${result.length}');

      return result.map((row) => 
        HuellaModel.fromMap(Map<String, dynamic>.from(row))
      ).toList();
    } catch (e) {
      print('❌ Error obteniendo huellas: $e');
      return [];
    }
  }

  // ✅ ACTUALIZAR CONTADOR DE HUELLAS DEL ESTUDIANTE
  Future<void> actualizarContadorHuellas(String estudianteId) async {
    try {
      final huellasRegistradas = await _databaseHelper.obtenerTotalHuellasRegistradas(estudianteId);
      
      print('🔄 Actualizando contador: $huellasRegistradas huellas para $estudianteId');

      final resultado = await _databaseHelper.rawUpdate('''
        UPDATE estudiantes 
        SET huellas_registradas = ?, fecha_actualizacion = ?
        WHERE id = ?
      ''', [
        huellasRegistradas,
        DateTime.now().toIso8601String(),
        estudianteId,
      ]);

      print('✅ Contador actualizado: $resultado filas afectadas');

    } catch (e) {
      print('❌ Error actualizando contador: $e');
    }
  }

  // ✅ ELIMINAR HUELLA
  Future<bool> eliminarHuella(String huellaId, String estudianteId) async {
    try {
      print('🗑️ Eliminando huella: $huellaId');
      
      final resultado = await _databaseHelper.eliminarHuellaBiometrica(huellaId);
      
      if (resultado > 0) {
        print('✅ Huella eliminada exitosamente');
        // Actualizar contador después de eliminar
        await actualizarContadorHuellas(estudianteId);
        return true;
      } else {
        print('❌ Error eliminando huella - 0 filas afectadas');
        return false;
      }
    } catch (e) {
      print('❌ Error eliminando huella: $e');
      return false;
    }
  }

  // ✅ VERIFICAR SI UN DEDO YA ESTÁ REGISTRADO
  Future<bool> verificarDedoRegistrado(String estudianteId, int numeroDedo) async {
    try {
      print('🔍 Verificando dedo $numeroDedo para estudiante: $estudianteId');
      
      final huella = await _databaseHelper.obtenerHuellaPorDedo(estudianteId, numeroDedo);
      final estaRegistrada = huella != null && (huella['registrada'] as int?) == 1;
      
      print('📊 Dedo $numeroDedo registrado: $estaRegistrada');
      return estaRegistrada;
    } catch (e) {
      print('❌ Error verificando dedo registrado: $e');
      return false;
    }
  }

  // ✅ OBTENER ESTADÍSTICAS DE HUELLAS
  Future<Map<String, dynamic>> obtenerEstadisticasHuellas() async {
    try {
      print('📈 Obteniendo estadísticas de huellas...');
      
      final totalEstudiantes = await _databaseHelper.rawQuery(
        'SELECT COUNT(*) as count FROM estudiantes WHERE activo = 1'
      );
      
      final estudiantesConHuellas = await _databaseHelper.rawQuery(
        'SELECT COUNT(DISTINCT estudiante_id) as count FROM huellas_biometricas WHERE registrada = 1'
      );
      
      final totalHuellas = await _databaseHelper.rawQuery(
        'SELECT COUNT(*) as count FROM huellas_biometricas WHERE registrada = 1'
      );

      final totalEst = totalEstudiantes.first['count'] as int? ?? 0;
      final conHuellas = estudiantesConHuellas.first['count'] as int? ?? 0;
      final totalH = totalHuellas.first['count'] as int? ?? 0;

      final estadisticas = {
        'total_estudiantes': totalEst,
        'con_huellas': conHuellas,
        'sin_huellas': totalEst - conHuellas,
        'total_huellas_registradas': totalH,
        'porcentaje_con_huellas': totalEst > 0 ? 
            (conHuellas / totalEst * 100).roundToDouble() : 0.0,
        'promedio_huellas_por_estudiante': conHuellas > 0 ? 
            (totalH / conHuellas).toStringAsFixed(1) : '0.0',
      };

      print('📊 Estadísticas obtenidas: $estadisticas');
      return estadisticas;

    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return {};
    }
  }

  // ✅ OBTENER TODAS LAS HUELLAS REGISTRADAS EN EL SISTEMA
  Future<List<Map<String, dynamic>>> obtenerTodasLasHuellasRegistradas() async {
    try {
      print('🔍 Obteniendo todas las huellas registradas...');
      
      final result = await _databaseHelper.obtenerTodasLasHuellasRegistradas();
      
      print('📊 Total huellas registradas en sistema: ${result.length}');
      
      return result.map((row) => Map<String, dynamic>.from(row)).toList();
    } catch (e) {
      print('❌ Error obteniendo todas las huellas: $e');
      return [];
    }
  }

  // ✅ VERIFICAR SI ESTUDIANTE TIENE HUELLAS REGISTRADAS
  Future<bool> estudianteTieneHuellasRegistradas(String estudianteId) async {
    try {
      final tieneHuellas = await _databaseHelper.estudianteTieneHuellasRegistradas(estudianteId);
      print('🔍 Estudiante $estudianteId tiene huellas: $tieneHuellas');
      return tieneHuellas;
    } catch (e) {
      print('❌ Error verificando huellas del estudiante: $e');
      return false;
    }
  }

  // ✅ OBTENER TOTAL DE HUELLAS REGISTRADAS POR ESTUDIANTE
  Future<int> obtenerTotalHuellasEstudiante(String estudianteId) async {
    try {
      final total = await _databaseHelper.obtenerTotalHuellasRegistradas(estudianteId);
      print('🔍 Estudiante $estudianteId tiene $total huellas registradas');
      return total;
    } catch (e) {
      print('❌ Error obteniendo total de huellas: $e');
      return 0;
    }
  }

  // ✅ MÉTODO PARA LIMPIAR HUELLAS DE UN ESTUDIANTE
  Future<bool> limpiarHuellasEstudiante(String estudianteId) async {
    try {
      print('🧹 Limpiando todas las huellas del estudiante: $estudianteId');
      
      final resultado = await _databaseHelper.rawDelete(
        'DELETE FROM huellas_biometricas WHERE estudiante_id = ?',
        [estudianteId]
      );
      
      if (resultado > 0) {
        print('✅ Huellas eliminadas: $resultado registros');
        await actualizarContadorHuellas(estudianteId);
        return true;
      } else {
        print('ℹ️ No se encontraron huellas para eliminar');
        return true; // No hay huellas, se considera éxito
      }
    } catch (e) {
      print('❌ Error limpiando huellas: $e');
      return false;
    }
  }

  // ✅ MÉTODO PARA OBTENER INFORMACIÓN COMPLETA DE HUELLAS CON DATOS DEL ESTUDIANTE
  Future<List<Map<String, dynamic>>> obtenerHuellasConEstudiantes() async {
    try {
      print('🔍 Obteniendo huellas con información de estudiantes...');
      
      final result = await _databaseHelper.rawQuery('''
        SELECT 
          hb.*,
          e.nombres,
          e.apellido_paterno,
          e.apellido_materno,
          e.ci,
          e.carrera_id,
          e.turno_id
        FROM huellas_biometricas hb
        JOIN estudiantes e ON hb.estudiante_id = e.id
        WHERE hb.registrada = 1
        ORDER BY e.apellido_paterno, e.apellido_materno, e.nombres
      ''');
      
      print('📊 Huellas con estudiantes: ${result.length} registros');
      
      return result.map((row) => Map<String, dynamic>.from(row)).toList();
    } catch (e) {
      print('❌ Error obteniendo huellas con estudiantes: $e');
      return [];
    }
  }
}