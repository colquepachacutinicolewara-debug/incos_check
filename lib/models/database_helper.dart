// models/database_helper.dart - VERSIÓN 100% COMPLETA ACTUALIZADA
import 'dart:async';
//import 'dart:io';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_live/sqflite_live.dart';
import 'package:path/path.dart';
//import 'package:path_provider/path_provider.dart';

// 🌟 IMPORTAR LA FUNCIÓN databaseExists EXPLÍCITAMENTE
import 'package:sqflite/sqflite.dart' as sqflite;

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;
  
  static const String _dbName = 'incos.db';
  static bool _isFirstTime = true;

  // 🌟 MÉTODO MEJORADO PARA DETECTAR SI ES INSTALACIÓN NUEVA
  Future<void> initDatabase() async {
    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, _dbName);
      
      // 🌟 CORREGIDO: Verificar si la BD existe ANTES de cualquier operación
      bool dbExists = await sqflite.databaseExists(path);
      
      if (!dbExists) {
        // 🌟 SOLO crear nueva BD si no existe
        print('🆕 Creando nueva base de datos por primera instalación...');
        _db = await _initDB(_dbName);
        _isFirstTime = true;
      } else {
        // 🌟 SI EXISTE: Solo abrir conexión sin modificar datos
        print('📁 Base de datos existente encontrada, preservando datos...');
        _db = await openDatabase(
          path,
          version: 5, // ✅ INCREMENTADO A VERSIÓN 5 PARA NUEVAS FUNCIONALIDADES
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
          },
          onOpen: (db) async {
            // Solo verificar estructura básica sin recrear tablas
            await _verifyBasicStructure(db);
          },
        );
        _isFirstTime = false;
      }
      
      print('✅ Base de datos lista. Es primera vez: $_isFirstTime');
      
    } catch (e) {
      print('❌ Error en initDatabase: $e');
      rethrow;
    }
  }

  // 🌟 NUEVO: Verificación básica sin recrear tablas
  Future<void> _verifyBasicStructure(Database db) async {
    try {
      // Solo verificar que las tablas principales existan
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='usuarios'"
      );
      
      if (tables.isEmpty) {
        print('⚠️ Tabla usuarios no encontrada, recreando estructura...');
        await _runDDL(db);
      } else {
        print('✅ Estructura de base de datos verificada');
        // Verificar y migrar estructura si es necesario
        await _migrarTablaUsuarios(db);
      }
    } catch (e) {
      print('❌ Error verificando estructura: $e');
    }
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB(_dbName);
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    final db = await openDatabase(
      path,
      version: 5, // ✅ INCREMENTADO A VERSIÓN 5
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: (db) async {
        if (_isFirstTime) {
          await _ensureTables(db);
        }
      },
    );

    // INSPECTOR EN LOCALHOST SOLO EN DEBUG
    if (!kReleaseMode) {
      try {
        await db.live(port: 8888);
        print('✅ SQFLITE LIVE → http://localhost:8888');
        print('💡 Si usas teléfono por USB: adb reverse tcp:8888 tcp:8888');
      } catch (e) {
        print('⚠️ No se pudo iniciar sqflite_live: $e');
      }
    }

    return db;
  }

  // 🚀 ACTUALIZACIÓN: Manejar upgrades de la base de datos CON NUEVAS TABLAS
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print('🔄 Actualizando BD de versión $oldVersion a $newVersion');
    
    if (oldVersion < 2) {
      try {
        await db.execute('''
          ALTER TABLE usuarios ADD COLUMN password TEXT
        ''');
        
        await db.update(
          'usuarios', 
          {'password': 'admin123'},
          where: 'username = ?', 
          whereArgs: ['admin']
        );
        
        print('✅ Campo password agregado a tabla usuarios');
      } catch (e) {
        print('⚠️ Error en upgrade DB (posiblemente campo ya existe): $e');
      }
    }
    
    if (oldVersion < 3) {
      try {
        await _migrarTablaUsuarios(db);
        await _migrarTablaHuellasBiometricas(db);
      } catch (e) {
        print('⚠️ Error en migración a versión 3: $e');
      }
    }
    
    // 🆕 NUEVA MIGRACIÓN PARA VERSIÓN 4 - TABLAS NOTAS DE ASISTENCIA Y PUNTUALIDAD
    if (oldVersion < 4) {
      try {
        await _crearTablasNotasAsistenciaYDocentemateria(db);
        await _agregarCamposPuntualidad(db);
        print('✅ Migración a versión 4 completada - Tablas NOTAS DE ASISTENCIA creadas');
      } catch (e) {
        print('⚠️ Error en upgrade a versión 4: $e');
      }
    }

    // 🆕 NUEVA MIGRACIÓN PARA VERSIÓN 5 - TABLAS DE REPORTES Y RESPALDOS
    if (oldVersion < 5) {
      try {
        await _crearTablasReportesYRespaldos(db);
        print('✅ Migración a versión 5 completada - Tablas REPORTES Y RESPALDOS creadas');
      } catch (e) {
        print('⚠️ Error en upgrade a versión 5: $e');
      }
    }
  }

  // PRIMERA CREACIÓN
  Future<void> _createDB(Database db, int version) async {
    print('🏗️ Creando base de datos por primera vez...');
    await _runDDL(db);
    await _migrarTablaUsuarios(db);
  }

  // REFORZAR EN CADA APERTURA (solo si es primera vez)
  Future<void> _ensureTables(Database db) async {
    print('🔍 Verificando estructura de tablas...');
    await _runDDL(db);
    
    // Solo hacer seed si las tablas principales están vacías
    final usuariosCount = await db.rawQuery('SELECT COUNT(*) AS c FROM usuarios');
    if ((usuariosCount.first['c'] as int?) == 0) {
      print('📝 Insertando datos iniciales...');
      await _seed(db);
    } else {
      print('✅ La base de datos ya contiene datos, no se inserta seed');
    }
  }

  // ====== DDL CENTRAL ACTUALIZADO CON TODAS LAS TABLAS ======
  Future<void> _runDDL(Database db) async {
    // Tabla carreras
    await db.execute('''
      CREATE TABLE IF NOT EXISTS carreras(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        color TEXT DEFAULT '#1565C0',
        icon_code_point INTEGER,
        activa INTEGER DEFAULT 1,
        fecha_creacion TEXT NOT NULL,
        fecha_actualizacion TEXT NOT NULL
      );
    ''');

    // Tabla turnos
    await db.execute('''
      CREATE TABLE IF NOT EXISTS turnos(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        icon_code_point INTEGER,
        horario TEXT,
        rango_asistencia TEXT,
        dias TEXT,
        color TEXT,
        activo INTEGER DEFAULT 1,
        niveles TEXT,
        fecha_creacion TEXT NOT NULL,
        fecha_actualizacion TEXT NOT NULL
      );
    ''');

    // Tabla niveles
    await db.execute('''
      CREATE TABLE IF NOT EXISTS niveles(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        activo INTEGER DEFAULT 1,
        orden INTEGER DEFAULT 99,
        paralelos TEXT,
        fecha_creacion TEXT NOT NULL
      );
    ''');

    // Tabla paralelos
    await db.execute('''
      CREATE TABLE IF NOT EXISTS paralelos(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        activo INTEGER DEFAULT 1,
        estudiantes TEXT,
        fecha_creacion TEXT NOT NULL,
        fecha_actualizacion TEXT NOT NULL
      );
    ''');

    // Tabla estudiantes
    await db.execute('''
      CREATE TABLE IF NOT EXISTS estudiantes(
        id TEXT PRIMARY KEY,
        nombres TEXT NOT NULL,
        apellido_paterno TEXT NOT NULL,
        apellido_materno TEXT NOT NULL,
        ci TEXT NOT NULL UNIQUE,
        fecha_registro TEXT NOT NULL,
        huellas_registradas INTEGER DEFAULT 0,
        carrera_id TEXT,
        turno_id TEXT,
        nivel_id TEXT,
        paralelo_id TEXT,
        fecha_creacion TEXT NOT NULL,
        fecha_actualizacion TEXT NOT NULL,
        activo INTEGER DEFAULT 1,
        FOREIGN KEY(carrera_id) REFERENCES carreras(id) ON UPDATE CASCADE ON DELETE SET NULL,
        FOREIGN KEY(turno_id) REFERENCES turnos(id) ON UPDATE CASCADE ON DELETE SET NULL,
        FOREIGN KEY(nivel_id) REFERENCES niveles(id) ON UPDATE CASCADE ON DELETE SET NULL,
        FOREIGN KEY(paralelo_id) REFERENCES paralelos(id) ON UPDATE CASCADE ON DELETE SET NULL
      );
    ''');

    // Tabla materias
    await db.execute('''
      CREATE TABLE IF NOT EXISTS materias(
        id TEXT PRIMARY KEY,
        codigo TEXT NOT NULL,
        nombre TEXT NOT NULL,
        carrera TEXT NOT NULL,
        anio INTEGER NOT NULL,
        color TEXT DEFAULT '#1565C0',
        activo INTEGER DEFAULT 1,
        paralelo TEXT DEFAULT 'A',
        turno TEXT DEFAULT 'Mañana',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    // Tabla periodos_academicos
    await db.execute('''
      CREATE TABLE IF NOT EXISTS periodos_academicos(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        tipo TEXT NOT NULL,
        numero INTEGER NOT NULL,
        fecha_inicio TEXT NOT NULL,
        fecha_fin TEXT NOT NULL,
        estado TEXT NOT NULL,
        fechas_clases TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        fecha_creacion TEXT NOT NULL,
        total_clases INTEGER,
        duracion_dias INTEGER
      );
    ''');

    // Tabla asistencias
    await db.execute('''
      CREATE TABLE IF NOT EXISTS asistencias(
        id TEXT PRIMARY KEY,
        estudiante_id TEXT NOT NULL,
        periodo_id TEXT NOT NULL,
        materia_id TEXT NOT NULL,
        asistencia_registrada_hoy INTEGER DEFAULT 0,
        datos_asistencia TEXT,
        ultima_actualizacion TEXT NOT NULL,
        UNIQUE(estudiante_id, periodo_id, materia_id),
        FOREIGN KEY(estudiante_id) REFERENCES estudiantes(id) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(periodo_id) REFERENCES periodos_academicos(id) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(materia_id) REFERENCES materias(id) ON UPDATE CASCADE ON DELETE CASCADE
      );
    ''');

    // Tabla detalle_asistencias (CON CAMPOS DE PUNTUALIDAD)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS detalle_asistencias(
        id TEXT PRIMARY KEY,
        asistencia_id TEXT NOT NULL,
        dia TEXT NOT NULL,
        porcentaje INTEGER DEFAULT 0,
        estado TEXT DEFAULT 'A',
        fecha TEXT NOT NULL,
        -- 🆕 CAMPOS NUEVOS PARA PUNTUALIDAD
        hora_registro TEXT,
        estado_puntualidad TEXT DEFAULT 'PUNTUAL',
        minutos_retraso INTEGER DEFAULT 0,
        UNIQUE(asistencia_id, fecha),
        FOREIGN KEY(asistencia_id) REFERENCES asistencias(id) ON UPDATE CASCADE ON DELETE CASCADE
      );
    ''');

    // Tabla bimestres
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bimestres(
        id TEXT PRIMARY KEY,
        periodo_id TEXT NOT NULL,
        nombre TEXT NOT NULL,
        fechas TEXT NOT NULL,
        datos_estudiantes TEXT,
        FOREIGN KEY(periodo_id) REFERENCES periodos_academicos(id) ON UPDATE CASCADE ON DELETE CASCADE
      );
    ''');

    // Tabla docentes
    await db.execute('''
      CREATE TABLE IF NOT EXISTS docentes(
        id TEXT PRIMARY KEY,
        apellido_paterno TEXT NOT NULL,
        apellido_materno TEXT NOT NULL,
        nombres TEXT NOT NULL,
        ci TEXT NOT NULL UNIQUE,
        carrera TEXT NOT NULL,
        turno TEXT DEFAULT 'MAÑANA',
        email TEXT,
        telefono TEXT,
        estado TEXT DEFAULT 'ACTIVO',
        fecha_creacion TEXT NOT NULL,
        fecha_actualizacion TEXT NOT NULL
      );
    ''');

    // 🆕 TABLA DOCENTE_MATERIA
    await db.execute('''
      CREATE TABLE IF NOT EXISTS docente_materia(
        id TEXT PRIMARY KEY,
        docente_id TEXT NOT NULL,
        materia_id TEXT NOT NULL,
        paralelo_id TEXT,
        turno_id TEXT,
        horario TEXT,
        dias_semana TEXT,
        hora_inicio TEXT,
        hora_fin TEXT,
        fecha_asignacion TEXT NOT NULL,
        activo INTEGER DEFAULT 1,
        UNIQUE(docente_id, materia_id, paralelo_id, turno_id),
        FOREIGN KEY(docente_id) REFERENCES docentes(id) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(materia_id) REFERENCES materias(id) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(paralelo_id) REFERENCES paralelos(id) ON UPDATE CASCADE ON DELETE SET NULL,
        FOREIGN KEY(turno_id) REFERENCES turnos(id) ON UPDATE CASCADE ON DELETE SET NULL
      );
    ''');

    // 🆕 TABLA CONFIG_NOTAS_ASISTENCIA
    await db.execute('''
      CREATE TABLE IF NOT EXISTS config_notas_asistencia(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        puntaje_maximo REAL DEFAULT 10.0,
        formula_tipo TEXT DEFAULT 'BIMESTRAL',
        parametros TEXT,
        activo INTEGER DEFAULT 1,
        fecha_creacion TEXT NOT NULL,
        fecha_actualizacion TEXT NOT NULL
      );
    ''');

    // 🆕 TABLA NOTAS_ASISTENCIA
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notas_asistencia(
        id TEXT PRIMARY KEY,
        estudiante_id TEXT NOT NULL,
        materia_id TEXT NOT NULL,
        periodo_id TEXT NOT NULL,
        bimestre_id TEXT NOT NULL,
        config_asistencia_id TEXT NOT NULL,
        total_clases INTEGER DEFAULT 0,
        clases_asistidas INTEGER DEFAULT 0,
        clases_faltadas INTEGER DEFAULT 0,
        porcentaje_asistencia REAL DEFAULT 0.0,
        nota_calculada REAL DEFAULT 0.0,
        estado TEXT DEFAULT 'PENDIENTE',
        fecha_calculo TEXT NOT NULL,
        observaciones TEXT,
        UNIQUE(estudiante_id, materia_id, periodo_id, bimestre_id),
        FOREIGN KEY(estudiante_id) REFERENCES estudiantes(id) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(materia_id) REFERENCES materias(id) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(periodo_id) REFERENCES periodos_academicos(id) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(bimestre_id) REFERENCES bimestres(id) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(config_asistencia_id) REFERENCES config_notas_asistencia(id) ON UPDATE CASCADE ON DELETE CASCADE
      );
    ''');

    // Tabla gestion
    await db.execute('''
      CREATE TABLE IF NOT EXISTS gestion(
        id TEXT PRIMARY KEY,
        carrera_seleccionada TEXT NOT NULL,
        carreras TEXT NOT NULL,
        fecha_actualizacion TEXT NOT NULL
      );
    ''');

    // Tabla historial_asistencias
    await db.execute('''
      CREATE TABLE IF NOT EXISTS historial_asistencias(
        id TEXT PRIMARY KEY,
        estudiante_id TEXT NOT NULL,
        materia_id TEXT NOT NULL,
        periodo_id TEXT NOT NULL,
        fecha_consulta TEXT NOT NULL,
        filtro_mostrar_todas_materias INTEGER DEFAULT 0,
        query_busqueda TEXT,
        datos_consulta TEXT,
        FOREIGN KEY(estudiante_id) REFERENCES estudiantes(id) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(materia_id) REFERENCES materias(id) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(periodo_id) REFERENCES periodos_academicos(id) ON UPDATE CASCADE ON DELETE CASCADE
      );
    ''');

    // ✅ TABLA HUELLAS_BIOMETRICAS CORREGIDA
    await db.execute('''
      CREATE TABLE IF NOT EXISTS huellas_biometricas(
        id TEXT PRIMARY KEY,
        estudiante_id TEXT NOT NULL,
        numero_dedo INTEGER NOT NULL,
        nombre_dedo TEXT NOT NULL,
        icono TEXT,
        registrada INTEGER DEFAULT 0,
        template_data TEXT,
        fecha_registro TEXT NOT NULL,
        UNIQUE(estudiante_id, numero_dedo),
        FOREIGN KEY(estudiante_id) REFERENCES estudiantes(id) ON UPDATE CASCADE ON DELETE CASCADE
      );
    ''');

    // Tabla inicio
    await db.execute('''
      CREATE TABLE IF NOT EXISTS inicio(
        id TEXT PRIMARY KEY,
        fecha_actual TEXT NOT NULL,
        system_status TEXT DEFAULT 'Sistema Operativo',
        fecha_actualizacion TEXT NOT NULL
      );
    ''');

    // Tabla programas
    await db.execute('''
      CREATE TABLE IF NOT EXISTS programas(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        icono_nombre TEXT NOT NULL,
        fecha_creacion TEXT NOT NULL
      );
    ''');

    // Tabla registro_asistencia
    await db.execute('''
      CREATE TABLE IF NOT EXISTS registro_asistencia(
        id TEXT PRIMARY KEY,
        materia_id TEXT NOT NULL,
        fecha TEXT NOT NULL,
        asistencias TEXT NOT NULL,
        biometric_available INTEGER DEFAULT 0,
        estudiantes TEXT,
        isLoading INTEGER DEFAULT 0,
        fecha_creacion TEXT NOT NULL,
        UNIQUE(materia_id, fecha),
        FOREIGN KEY(materia_id) REFERENCES materias(id) ON UPDATE CASCADE ON DELETE CASCADE
      );
    ''');

    // Tabla reportes
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reportes(
        id TEXT PRIMARY KEY,
        progress REAL DEFAULT 0.70,
        status TEXT DEFAULT 'Reportes en Desarrollo',
        features TEXT,
        fecha_creacion TEXT NOT NULL
      );
    ''');

    // Tabla soporte
    await db.execute('''
      CREATE TABLE IF NOT EXISTS soporte(
        id TEXT PRIMARY KEY,
        whatsapp_number TEXT,
        email TEXT,
        phone_number TEXT,
        whatsapp_message TEXT,
        email_subject TEXT,
        email_body TEXT,
        fecha_creacion TEXT NOT NULL
      );
    ''');

    // ✅ TABLA USUARIOS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS usuarios(
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        nombre TEXT NOT NULL,
        password TEXT,
        role TEXT NOT NULL,
        carnet TEXT,
        departamento TEXT,
        esta_activo INTEGER DEFAULT 1,
        fecha_registro TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    // Tabla configuraciones
    await db.execute('''
      CREATE TABLE IF NOT EXISTS configuraciones(
        id TEXT PRIMARY KEY,
        notifications_enabled INTEGER DEFAULT 1,
        dark_mode_enabled INTEGER DEFAULT 0,
        biometric_enabled INTEGER DEFAULT 0,
        auto_sync_enabled INTEGER DEFAULT 1,
        selected_language TEXT DEFAULT 'Español',
        selected_theme TEXT DEFAULT 'Sistema',
        cache_size TEXT DEFAULT '15.2 MB',
        last_updated TEXT NOT NULL,
        value TEXT
      );
    ''');

    // 🆕 TABLA PARA ASISTENCIA DIARIA
    await db.execute('''
      CREATE TABLE IF NOT EXISTS asistencia_diaria(
        id TEXT PRIMARY KEY,
        estudiante_id TEXT NOT NULL,
        materia_id TEXT NOT NULL,
        horario_clase_id TEXT,
        fecha TEXT NOT NULL,
        periodo_numero INTEGER NOT NULL,
        estado TEXT DEFAULT 'A',
        minutos_retraso INTEGER DEFAULT 0,
        observaciones TEXT,
        fecha_creacion TEXT NOT NULL,
        usuario_registro TEXT NOT NULL,
        UNIQUE(estudiante_id, materia_id, fecha, periodo_numero),
        FOREIGN KEY(estudiante_id) REFERENCES estudiantes(id) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(materia_id) REFERENCES materias(id) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(horario_clase_id) REFERENCES horarios_clases(id) ON UPDATE CASCADE ON DELETE SET NULL
      );
    ''');

    // 🆕 TABLA PARA HORARIOS DE CLASES
    await db.execute('''
      CREATE TABLE IF NOT EXISTS horarios_clases(
        id TEXT PRIMARY KEY,
        materia_id TEXT NOT NULL,
        paralelo_id TEXT NOT NULL,
        docente_id TEXT NOT NULL,
        dia_semana TEXT NOT NULL,
        periodo_numero INTEGER NOT NULL,
        hora_inicio TEXT NOT NULL,
        hora_fin TEXT NOT NULL,
        activo INTEGER DEFAULT 1,
        fecha_creacion TEXT NOT NULL,
        UNIQUE(materia_id, paralelo_id, dia_semana, periodo_numero),
        FOREIGN KEY(materia_id) REFERENCES materias(id),
        FOREIGN KEY(paralelo_id) REFERENCES paralelos(id),
        FOREIGN KEY(docente_id) REFERENCES docentes(id)
      );
    ''');

    // 🆕 TABLA PARA REPORTES E INFORMES
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reportes_generados(
        id TEXT PRIMARY KEY,
        tipo_reporte TEXT NOT NULL,
        titulo TEXT NOT NULL,
        periodo_id TEXT NOT NULL,
        materia_id TEXT,
        bimestre_id TEXT,
        formato TEXT DEFAULT 'PDF',
        parametros TEXT,
        ruta_archivo TEXT,
        fecha_generacion TEXT NOT NULL,
        usuario_generador TEXT NOT NULL,
        estado TEXT DEFAULT 'COMPLETADO',
        tamano_bytes INTEGER,
        FOREIGN KEY(periodo_id) REFERENCES periodos_academicos(id),
        FOREIGN KEY(materia_id) REFERENCES materias(id),
        FOREIGN KEY(bimestre_id) REFERENCES bimestres(id)
      );
    ''');

    // 🆕 TABLA PARA RESPALDOS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS respaldos(
        id TEXT PRIMARY KEY,
        tipo_respaldo TEXT NOT NULL,
        descripcion TEXT,
        ruta_archivo TEXT NOT NULL,
        fecha_respaldo TEXT NOT NULL,
        tamano_bytes INTEGER,
        usuario_respaldo TEXT NOT NULL,
        estado TEXT DEFAULT 'COMPLETADO',
        observaciones TEXT,
        checksum TEXT
      );
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS logs_seguridad(
        id TEXT PRIMARY KEY,
        usuario_id TEXT NOT NULL,
        modulo TEXT NOT NULL,
        accion TEXT NOT NULL,
        fecha TEXT NOT NULL,
        tipo TEXT NOT NULL,
        ip TEXT,
        dispositivo TEXT,
        detalles TEXT,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON UPDATE CASCADE ON DELETE CASCADE
      );
    ''');

    // ✅ AGREGAR ÍNDICES DE OPTIMIZACIÓN AL FINAL
    await _createIndexes(db);
  }

  // 🆕 MÉTODO PARA CREAR TABLAS DE REPORTES Y RESPALDOS
  Future<void> _crearTablasReportesYRespaldos(Database db) async {
    try {
      print('🔄 Creando tablas de reportes y respaldos...');
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reportes_generados(
          id TEXT PRIMARY KEY,
          tipo_reporte TEXT NOT NULL,
          titulo TEXT NOT NULL,
          periodo_id TEXT NOT NULL,
          materia_id TEXT,
          bimestre_id TEXT,
          formato TEXT DEFAULT 'PDF',
          parametros TEXT,
          ruta_archivo TEXT,
          fecha_generacion TEXT NOT NULL,
          usuario_generador TEXT NOT NULL,
          estado TEXT DEFAULT 'COMPLETADO',
          tamano_bytes INTEGER,
          FOREIGN KEY(periodo_id) REFERENCES periodos_academicos(id),
          FOREIGN KEY(materia_id) REFERENCES materias(id),
          FOREIGN KEY(bimestre_id) REFERENCES bimestres(id)
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS respaldos(
          id TEXT PRIMARY KEY,
          tipo_respaldo TEXT NOT NULL,
          descripcion TEXT,
          ruta_archivo TEXT NOT NULL,
          fecha_respaldo TEXT NOT NULL,
          tamano_bytes INTEGER,
          usuario_respaldo TEXT NOT NULL,
          estado TEXT DEFAULT 'COMPLETADO',
          observaciones TEXT,
          checksum TEXT
        );
      ''');

      print('✅ Tablas de reportes y respaldos creadas exitosamente');
    } catch (e) {
      print('❌ Error creando tablas de reportes y respaldos: $e');
      rethrow;
    }
  }

  // ====== ÍNDICES PARA OPTIMIZACIÓN ======
  Future<void> _createIndexes(Database db) async {
    print('🚀 Creando índices de optimización...');
    
    // Índices existentes...
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_estudiantes_ci 
      ON estudiantes(ci);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_estudiantes_nombres 
      ON estudiantes(nombres, apellido_paterno);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_estudiantes_carrera 
      ON estudiantes(carrera_id);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_asistencias_estudiante 
      ON asistencias(estudiante_id);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_asistencias_materia 
      ON asistencias(materia_id);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_asistencias_periodo 
      ON asistencias(periodo_id);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_detalle_fecha 
      ON detalle_asistencias(fecha);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_detalle_asistencia_id 
      ON detalle_asistencias(asistencia_id);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_registro_materia_fecha 
      ON registro_asistencia(materia_id, fecha);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_huellas_estudiante 
      ON huellas_biometricas(estudiante_id);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_usuarios_username 
      ON usuarios(username);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_usuarios_email 
      ON usuarios(email);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_materias_carrera 
      ON materias(carrera);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_docentes_ci 
      ON docentes(ci);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_periodos_estado 
      ON periodos_academicos(estado);
    ''');

    // 🆕 ÍNDICES PARA NUEVAS TABLAS
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_docente_materia_docente 
      ON docente_materia(docente_id);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_docente_materia_materia 
      ON docente_materia(materia_id);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_notas_estudiante_materia 
      ON notas_asistencia(estudiante_id, materia_id);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_notas_periodo_bimestre 
      ON notas_asistencia(periodo_id, bimestre_id);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_config_notas_activo 
      ON config_notas_asistencia(activo);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_detalle_hora_registro 
      ON detalle_asistencias(hora_registro);
    ''');

    // 🆕 ÍNDICES PARA NUEVAS TABLAS DE REPORTES Y RESPALDOS
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_reportes_fecha 
      ON reportes_generados(fecha_generacion);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_reportes_tipo 
      ON reportes_generados(tipo_reporte);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_respaldos_fecha 
      ON respaldos(fecha_respaldo);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_asistencia_diaria_fecha 
      ON asistencia_diaria(fecha);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_horarios_dia 
      ON horarios_clases(dia_semana);
    ''');

    print('✅ Índices de optimización creados exitosamente');
  }

  // 🌱 SEED ACTUALIZADO CON DATOS COMPLETOS
  Future<void> _seed(Database db) async {
    print('🌱 Insertando datos iniciales...');
    
    // Insertar carreras si no existen
    final carrerasCount = await db.rawQuery('SELECT COUNT(*) AS c FROM carreras');
    if ((carrerasCount.first['c'] as int?) == 0) {
      await db.insert('carreras', {
        'id': 'info',
        'nombre': 'Informática',
        'color': '#1565C0',
        'icon_code_point': 59509,
        'activa': 1,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String()
      });
      await db.insert('carreras', {
        'id': 'contabilidad',
        'nombre': 'Contabilidad',
        'color': '#2E7D32',
        'icon_code_point': 58086,
        'activa': 1,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String()
      });
      print('✅ Carreras insertadas');
    }

    // Insertar turnos si no existen
    final turnosCount = await db.rawQuery('SELECT COUNT(*) AS c FROM turnos');
    if ((turnosCount.first['c'] as int?) == 0) {
      await db.insert('turnos', {
        'id': 'turno_manana',
        'nombre': 'Mañana',
        'icon_code_point': 58355,
        'horario': '06:30 - 12:30',
        'rango_asistencia': '06:00-12:00',
        'dias': 'Lunes a Viernes',
        'color': '#FFA000',
        'activo': 1,
        'niveles': '["Todos"]',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String()
      });
      print('✅ Turnos insertados');
    }

    // Insertar niveles si no existen
    final nivelesCount = await db.rawQuery('SELECT COUNT(*) AS c FROM niveles');
    if ((nivelesCount.first['c'] as int?) == 0) {
      await db.insert('niveles', {
        'id': 'nivel_secundaria',
        'nombre': 'Secundaria',
        'activo': 1,
        'orden': 1,
        'paralelos': '["A", "B", "C"]',
        'fecha_creacion': DateTime.now().toIso8601String()
      });
      print('✅ Niveles insertados');
    }

    // Insertar paralelos si no existen
    final paralelosCount = await db.rawQuery('SELECT COUNT(*) AS c FROM paralelos');
    if ((paralelosCount.first['c'] as int?) == 0) {
      await db.insert('paralelos', {
        'id': 'paralelo_b',
        'nombre': 'B',
        'activo': 1,
        'estudiantes': '[]',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String()
      });
      print('✅ Paralelos insertados');
    }

    // Insertar materias de ejemplo
    final materiasCount = await db.rawQuery('SELECT COUNT(*) AS c FROM materias');
    if ((materiasCount.first['c'] as int?) == 0) {
      final now = DateTime.now().toIso8601String();
      await db.insert('materias', {
        'id': 'mat_programacion',
        'codigo': 'PROG101',
        'nombre': 'Programación I',
        'carrera': 'info',
        'anio': 3,
        'color': '#1565C0',
        'activo': 1,
        'paralelo': 'B',
        'turno': 'Mañana',
        'created_at': now,
        'updated_at': now
      });
      print('✅ Materias de ejemplo insertadas');
    }

    // ✅ Insertar usuario admin
    final usuariosCount = await db.rawQuery('SELECT COUNT(*) AS c FROM usuarios');
    if ((usuariosCount.first['c'] as int?) == 0) {
      final now = DateTime.now().toIso8601String();
      
      await db.insert('usuarios', {
        'id': 'admin_001',
        'username': 'admin',
        'email': 'admin@incos.edu.bo',
        'nombre': 'Administrador Principal',
        'password': 'admin123',
        'role': 'Administrador',
        'carnet': 'ADMIN001',
        'departamento': 'Dirección',
        'esta_activo': 1,
        'fecha_registro': now,
        'updated_at': now
      });
      
      await db.insert('usuarios', {
        'id': 'docente_001',
        'username': 'profesor',
        'email': 'profesor@incos.edu.bo',
        'nombre': 'Profesor Ejemplo',
        'password': 'profesor123',
        'role': 'Docente',
        'carnet': 'DOC001',
        'departamento': 'Académico',
        'esta_activo': 1,
        'fecha_registro': now,
        'updated_at': now
      });
      print('✅ Usuarios insertados');
    }

    // Insertar docente de ejemplo
    final docentesCount = await db.rawQuery('SELECT COUNT(*) AS c FROM docentes');
    if ((docentesCount.first['c'] as int?) == 0) {
      final now = DateTime.now().toIso8601String();
      await db.insert('docentes', {
        'id': 'docente_001',
        'apellido_paterno': 'Pérez',
        'apellido_materno': 'García',
        'nombres': 'Carlos Alberto',
        'ci': '1234567',
        'carrera': 'Informática',
        'turno': 'MAÑANA',
        'email': 'carlos.perez@incos.edu.bo',
        'telefono': '77788899',
        'estado': 'ACTIVO',
        'fecha_creacion': now,
        'fecha_actualizacion': now
      });
      print('✅ Docente de ejemplo insertado');
    }
// =================================================================
// 🆕 MÉTODOS COMPLETOS PARA DOCENTES - AGREGAR EN DatabaseHelper
// =================================================================

// ✅ MÉTODO PARA OBTENER TODOS LOS DOCENTES
Future<List<Map<String, Object?>>> getDocentes() async {
  final db = await database;
  return await db.query(
    'docentes',
    orderBy: 'apellido_paterno, apellido_materno, nombres'
  );
}

// ✅ MÉTODO PARA OBTENER DOCENTE POR ID
Future<Map<String, Object?>?> getDocenteById(String id) async {
  final db = await database;
  final results = await db.query(
    'docentes',
    where: 'id = ?',
    whereArgs: [id]
  );
  return results.isNotEmpty ? results.first : null;
}



// ✅ MÉTODO PARA ELIMINAR DOCENTE
Future<int> deleteDocente(String id) async {
  final db = await database;
  return await db.delete(
    'docentes',
    where: 'id = ?',
    whereArgs: [id]
  );
}

// ✅ MÉTODO PARA VERIFICAR SI EXISTE DOCENTE CON CI
Future<bool> existeDocenteConCi(String ci, {String? excludeId}) async {
  final db = await database;
  
  String whereClause = 'ci = ?';
  List<Object?> whereArgs = [ci];
  
  if (excludeId != null) {
    whereClause += ' AND id != ?';
    whereArgs.add(excludeId);
  }
  
  final results = await db.query(
    'docentes',
    where: whereClause,
    whereArgs: whereArgs
  );
  
  return results.isNotEmpty;
}

// ✅ MÉTODO PARA OBTENER CONTEO DE DOCENTES
Future<int> getDocentesCount() async {
  final db = await database;
  final results = await db.rawQuery('SELECT COUNT(*) as count FROM docentes');
  return (results.first['count'] as int?) ?? 0;
}

// ✅ MÉTODO PARA OBTENER DOCENTES POR CARRERA
Future<List<Map<String, Object?>>> getDocentesPorCarrera(String carrera) async {
  final db = await database;
  return await db.query(
    'docentes',
    where: 'carrera = ?',
    whereArgs: [carrera],
    orderBy: 'apellido_paterno, apellido_materno, nombres'
  );
}

// ✅ MÉTODO PARA OBTENER DOCENTES POR TURNO
Future<List<Map<String, Object?>>> getDocentesPorTurno(String turno) async {
  final db = await database;
  return await db.query(
    'docentes',
    where: 'turno = ?',
    whereArgs: [turno],
    orderBy: 'apellido_paterno, apellido_materno, nombres'
  );
}

// ✅ MÉTODO PARA OBTENER DOCENTES POR CARRERA Y TURNO
Future<List<Map<String, Object?>>> getDocentesPorCarreraYTurno(String carrera, String turno) async {
  final db = await database;
  return await db.query(
    'docentes',
    where: 'carrera = ? AND turno = ?',
    whereArgs: [carrera, turno],
    orderBy: 'apellido_paterno, apellido_materno, nombres'
  );
}

// ✅ MÉTODO PARA BUSCAR DOCENTES POR NOMBRE O CI
Future<List<Map<String, Object?>>> buscarDocentes(String query) async {
  final db = await database;
  final searchTerm = '%$query%';
  
  return await db.rawQuery('''
    SELECT * FROM docentes 
    WHERE nombres LIKE ? 
       OR apellido_paterno LIKE ? 
       OR apellido_materno LIKE ?
       OR ci LIKE ?
    ORDER BY apellido_paterno, apellido_materno, nombres
  ''', [searchTerm, searchTerm, searchTerm, searchTerm]);
}

// ✅ MÉTODO PARA OBTENER ESTADÍSTICAS DE DOCENTES
Future<Map<String, dynamic>> getEstadisticasDocentes() async {
  final db = await database;
  
  final total = await db.rawQuery('SELECT COUNT(*) as count FROM docentes');
  final activos = await db.rawQuery('SELECT COUNT(*) as count FROM docentes WHERE estado = "ACTIVO"');
  final porCarrera = await db.rawQuery('''
    SELECT carrera, COUNT(*) as count 
    FROM docentes 
    GROUP BY carrera 
    ORDER BY count DESC
  ''');
  final porTurno = await db.rawQuery('''
    SELECT turno, COUNT(*) as count 
    FROM docentes 
    GROUP BY turno 
    ORDER BY count DESC
  ''');
  
  return {
    'total': (total.first['count'] as int?) ?? 0,
    'activos': (activos.first['count'] as int?) ?? 0,
    'inactivos': ((total.first['count'] as int?) ?? 0) - ((activos.first['count'] as int?) ?? 0),
    'por_carrera': porCarrera,
    'por_turno': porTurno,
  };
}

// ✅ MÉTODO PARA OBTENER CARRERAS ÚNICAS DE DOCENTES
Future<List<String>> getCarrerasDocentes() async {
  final db = await database;
  final results = await db.rawQuery('''
    SELECT DISTINCT carrera 
    FROM docentes 
    WHERE carrera IS NOT NULL AND carrera != ''
    ORDER BY carrera
  ''');
  
  return results.map((row) => row['carrera'] as String).toList();
}
    // 🆕 Insertar CONFIGURACIÓN DE NOTAS DE ASISTENCIA por defecto
    final configNotasCount = await db.rawQuery('SELECT COUNT(*) AS c FROM config_notas_asistencia');
    if ((configNotasCount.first['c'] as int?) == 0) {
      final now = DateTime.now().toIso8601String();
      await db.insert('config_notas_asistencia', {
        'id': 'config_asistencia_default',
        'nombre': 'Configuración Notas Asistencia Tercer Año B',
        'descripcion': 'Cálculo de nota de asistencia bimestral sobre 10 puntos',
        'puntaje_maximo': 10.0,
        'formula_tipo': 'BIMESTRAL',
        'parametros': '{"asistencia_minima": 80, "tolerancia_minutos": 15, "considera_puntualidad": true}',
        'activo': 1,
        'fecha_creacion': now,
        'fecha_actualizacion': now
      });
      print('✅ Configuración notas asistencia insertada');
    }

    // 🆕 Insertar relación docente-materia de ejemplo
    final docenteMateriaCount = await db.rawQuery('SELECT COUNT(*) AS c FROM docente_materia');
    if ((docenteMateriaCount.first['c'] as int?) == 0) {
      final now = DateTime.now().toIso8601String();
      await db.insert('docente_materia', {
        'id': 'dm_001',
        'docente_id': 'docente_001',
        'materia_id': 'mat_programacion',
        'paralelo_id': 'paralelo_b',
        'turno_id': 'turno_manana',
        'horario': 'Lunes 08:00-10:00, Miércoles 08:00-10:00',
        'dias_semana': 'Lunes,Martes',
        'hora_inicio': '08:00',
        'hora_fin': '10:00',
        'fecha_asignacion': now,
        'activo': 1
      });
      print('✅ Relación docente-materia insertada');
    }

    // Insertar configuración por defecto si no existe
    final configCount = await db.rawQuery('SELECT COUNT(*) AS c FROM configuraciones');
    if ((configCount.first['c'] as int?) == 0) {
      await db.insert('configuraciones', {
        'id': 'config_default',
        'notifications_enabled': 1,
        'dark_mode_enabled': 0,
        'biometric_enabled': 0,
        'auto_sync_enabled': 1,
        'selected_language': 'Español',
        'selected_theme': 'Sistema',
        'cache_size': '15.2 MB',
        'last_updated': DateTime.now().toIso8601String(),
        'value': '{}'
      });
      print('✅ Configuración insertada');
    }

    // 🆕 Insertar periodo académico de ejemplo
    final periodosCount = await db.rawQuery('SELECT COUNT(*) AS c FROM periodos_academicos');
    if ((periodosCount.first['c'] as int?) == 0) {
      final now = DateTime.now().toIso8601String();
      await db.insert('periodos_academicos', {
        'id': 'periodo_2024',
        'nombre': 'Gestión 2024',
        'tipo': 'ANUAL',
        'numero': 2024,
        'fecha_inicio': '2024-01-01',
        'fecha_fin': '2024-12-31',
        'estado': 'ACTIVO',
        'fechas_clases': '[]',
        'descripcion': 'Periodo académico 2024',
        'fecha_creacion': now,
        'total_clases': 180,
        'duracion_dias': 365
      });
      print('✅ Periodo académico insertado');
    }
    
    print('🎉 Seed completado exitosamente');
  }

  // 🆕 MÉTODOS DE MIGRACIÓN PARA NUEVAS TABLAS
  Future<void> _crearTablasNotasAsistenciaYDocentemateria(Database db) async {
    try {
      print('🔄 Creando tablas notas asistencia y docente_materia...');
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS docente_materia(
          id TEXT PRIMARY KEY,
          docente_id TEXT NOT NULL,
          materia_id TEXT NOT NULL,
          paralelo_id TEXT,
          turno_id TEXT,
          horario TEXT,
          dias_semana TEXT,
          hora_inicio TEXT,
          hora_fin TEXT,
          fecha_asignacion TEXT NOT NULL,
          activo INTEGER DEFAULT 1,
          UNIQUE(docente_id, materia_id, paralelo_id, turno_id),
          FOREIGN KEY(docente_id) REFERENCES docentes(id) ON UPDATE CASCADE ON DELETE CASCADE,
          FOREIGN KEY(materia_id) REFERENCES materias(id) ON UPDATE CASCADE ON DELETE CASCADE,
          FOREIGN KEY(paralelo_id) REFERENCES paralelos(id) ON UPDATE CASCADE ON DELETE SET NULL,
          FOREIGN KEY(turno_id) REFERENCES turnos(id) ON UPDATE CASCADE ON DELETE SET NULL
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS config_notas_asistencia(
          id TEXT PRIMARY KEY,
          nombre TEXT NOT NULL,
          descripcion TEXT,
          puntaje_maximo REAL DEFAULT 10.0,
          formula_tipo TEXT DEFAULT 'BIMESTRAL',
          parametros TEXT,
          activo INTEGER DEFAULT 1,
          fecha_creacion TEXT NOT NULL,
          fecha_actualizacion TEXT NOT NULL
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS notas_asistencia(
          id TEXT PRIMARY KEY,
          estudiante_id TEXT NOT NULL,
          materia_id TEXT NOT NULL,
          periodo_id TEXT NOT NULL,
          bimestre_id TEXT NOT NULL,
          config_asistencia_id TEXT NOT NULL,
          total_clases INTEGER DEFAULT 0,
          clases_asistidas INTEGER DEFAULT 0,
          clases_faltadas INTEGER DEFAULT 0,
          porcentaje_asistencia REAL DEFAULT 0.0,
          nota_calculada REAL DEFAULT 0.0,
          estado TEXT DEFAULT 'PENDIENTE',
          fecha_calculo TEXT NOT NULL,
          observaciones TEXT,
          UNIQUE(estudiante_id, materia_id, periodo_id, bimestre_id),
          FOREIGN KEY(estudiante_id) REFERENCES estudiantes(id) ON UPDATE CASCADE ON DELETE CASCADE,
          FOREIGN KEY(materia_id) REFERENCES materias(id) ON UPDATE CASCADE ON DELETE CASCADE,
          FOREIGN KEY(periodo_id) REFERENCES periodos_academicos(id) ON UPDATE CASCADE ON DELETE CASCADE,
          FOREIGN KEY(bimestre_id) REFERENCES bimestres(id) ON UPDATE CASCADE ON DELETE CASCADE,
          FOREIGN KEY(config_asistencia_id) REFERENCES config_notas_asistencia(id) ON UPDATE CASCADE ON DELETE CASCADE
        );
      ''');

      print('✅ Tablas notas asistencia y docente_materia creadas exitosamente');
    } catch (e) {
      print('❌ Error creando tablas notas asistencia: $e');
      rethrow;
    }
  }

  // 🆕 MÉTODO PARA AGREGAR CAMPOS DE PUNTUALIDAD
  Future<void> _agregarCamposPuntualidad(Database db) async {
    try {
      print('🔄 Agregando campos de puntualidad a detalle_asistencias...');
      
      final tableInfo = await db.rawQuery('PRAGMA table_info(detalle_asistencias)');
      final columnas = tableInfo.map((col) => col['name'] as String).toList();
      
      if (!columnas.contains('hora_registro')) {
        await db.execute('''
          ALTER TABLE detalle_asistencias ADD COLUMN hora_registro TEXT
        ''');
        print('✅ Campo hora_registro agregado');
      }
      
      if (!columnas.contains('estado_puntualidad')) {
        await db.execute('''
          ALTER TABLE detalle_asistencias ADD COLUMN estado_puntualidad TEXT DEFAULT 'PUNTUAL'
        ''');
        print('✅ Campo estado_puntualidad agregado');
      }
      
      if (!columnas.contains('minutos_retraso')) {
        await db.execute('''
          ALTER TABLE detalle_asistencias ADD COLUMN minutos_retraso INTEGER DEFAULT 0
        ''');
        print('✅ Campo minutos_retraso agregado');
      }
      
      print('✅ Campos de puntualidad agregados exitosamente');
    } catch (e) {
      print('⚠️ Error agregando campos de puntualidad: $e');
    }
  }

  // =================================================================
  // 🆕 MÉTODOS COMPLETOS PARA HUELLAS BIOMÉTRICAS - AGREGADOS
  // =================================================================

  // ✅ MÉTODO PARA INSERTAR HUELLA
  Future<int> insertarHuellaBiometrica(Map<String, dynamic> huella) async {
    final db = await database;
    return await db.insert('huellas_biometricas', huella);
  }

  // ✅ MÉTODO PARA OBTENER HUELLAS POR ESTUDIANTE
  Future<List<Map<String, Object?>>> obtenerHuellasPorEstudiante(String estudianteId) async {
    final db = await database;
    return await db.query(
      'huellas_biometricas',
      where: 'estudiante_id = ?',
      whereArgs: [estudianteId],
      orderBy: 'numero_dedo ASC'
    );
  }

  // ✅ MÉTODO PARA ELIMINAR HUELLA
  Future<int> eliminarHuellaBiometrica(String huellaId) async {
    final db = await database;
    return await db.delete(
      'huellas_biometricas',
      where: 'id = ?',
      whereArgs: [huellaId]
    );
  }

  // ✅ MÉTODO PARA OBTENER HUELLA POR DEDO
  Future<Map<String, Object?>?> obtenerHuellaPorDedo(String estudianteId, int numeroDedo) async {
    final db = await database;
    final results = await db.query(
      'huellas_biometricas',
      where: 'estudiante_id = ? AND numero_dedo = ?',
      whereArgs: [estudianteId, numeroDedo]
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ✅ MÉTODO PARA ACTUALIZAR ESTADO DE HUELLA
  Future<int> actualizarEstadoHuella(String estudianteId, int numeroDedo, bool registrada) async {
    final db = await database;
    return await db.update(
      'huellas_biometricas',
      {
        'registrada': registrada ? 1 : 0,
        'fecha_registro': DateTime.now().toIso8601String()
      },
      where: 'estudiante_id = ? AND numero_dedo = ?',
      whereArgs: [estudianteId, numeroDedo]
    );
  }

  // ✅ MÉTODO PARA VERIFICAR SI UN ESTUDIANTE TIENE HUELLAS REGISTRADAS
  Future<bool> estudianteTieneHuellasRegistradas(String estudianteId) async {
    final db = await database;
    final results = await db.rawQuery(
      'SELECT COUNT(*) as count FROM huellas_biometricas WHERE estudiante_id = ? AND registrada = 1',
      [estudianteId]
    );
    return ((results.first['count'] as int?) ?? 0) > 0;
  }

  // ✅ MÉTODO PARA OBTENER EL TOTAL DE HUELLAS REGISTRADAS POR ESTUDIANTE
  Future<int> obtenerTotalHuellasRegistradas(String estudianteId) async {
    final db = await database;
    final results = await db.rawQuery(
      'SELECT COUNT(*) as count FROM huellas_biometricas WHERE estudiante_id = ? AND registrada = 1',
      [estudianteId]
    );
    return results.first['count'] as int? ?? 0;
  }

  // ✅ MÉTODO PARA OBTENER TODAS LAS HUELLAS REGISTRADAS EN EL SISTEMA
  Future<List<Map<String, Object?>>> obtenerTodasLasHuellasRegistradas() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT hb.*, e.nombres, e.apellido_paterno, e.apellido_materno, e.ci
      FROM huellas_biometricas hb
      JOIN estudiantes e ON hb.estudiante_id = e.id
      WHERE hb.registrada = 1
      ORDER BY e.apellido_paterno, e.apellido_materno, e.nombres
    ''');
  }

  // ====== CRUD DE BAJO NIVEL EXPUESTO ======
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? args]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }

  Future<int> rawInsert(String sql, [List<Object?>? args]) async {
    final db = await database;
    return db.rawInsert(sql, args);
  }

  Future<int> rawUpdate(String sql, [List<Object?>? args]) async {
    final db = await database;
    return db.rawUpdate(sql, args);
  }

  Future<int> rawDelete(String sql, [List<Object?>? args]) async {
    final db = await database;
    return db.rawDelete(sql, args);
  }

  // 🔄 BORRAR Y RECREAR RÁPIDO (DEV) - SOLO PARA DESARROLLO
  static Future<void> resetDevDB() async {
    if (kReleaseMode) {
      print('🚫 Reset DB no disponible en modo release');
      return;
    }
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    
    bool exists = await sqflite.databaseExists(path);
    if (exists) {
      await deleteDatabase(path);
      print('🗑️ Base de datos de desarrollo reseteada');
    } else {
      print('📁 No existe BD para resetear');
    }
    
    _db = null;
    _isFirstTime = true;
    await instance.initDatabase();
  }

  // ✅ MÉTODO MIGRACIÓN PARA AGREGAR updated_at SI NO EXISTE
  Future<void> _migrarTablaUsuarios(Database db) async {
    try {
      final tableInfo = await db.rawQuery('PRAGMA table_info(usuarios)');
      final tieneUpdatedAt = tableInfo.any((col) => col['name'] == 'updated_at');
      
      if (!tieneUpdatedAt) {
        print('🔄 Agregando columna updated_at a tabla usuarios...');
        await db.execute('''
          ALTER TABLE usuarios ADD COLUMN updated_at TEXT
        ''');
        
        final now = DateTime.now().toIso8601String();
        await db.update(
          'usuarios',
          {'updated_at': now},
        );
        
        print('✅ Columna updated_at agregada exitosamente');
      } else {
        print('✅ Columna updated_at ya existe en tabla usuarios');
      }
      
    } catch (e) {
      print('⚠️ Error en migración de tabla usuarios: $e');
    }
  }

  // ✅ MÉTODO MIGRACIÓN PARA TABLA HUELLAS BIOMÉTRICAS
  Future<void> _migrarTablaHuellasBiometricas(Database db) async {
    try {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='huellas_biometricas'"
      );
      
      if (tables.isNotEmpty) {
        final tableInfo = await db.rawQuery('PRAGMA table_info(huellas_biometricas)');
        final columnas = tableInfo.map((col) => col['name'] as String).toList();
        
        print('📋 Estructura actual de huellas_biometricas: $columnas');
        
        if (columnas.contains('template_data')) {
          final columnaTemplate = tableInfo.firstWhere(
            (col) => col['name'] == 'template_data',
            orElse: () => {}
          );
          
          if (columnaTemplate.isNotEmpty && columnaTemplate['type'] == 'BLOB') {
            print('🔄 Migrando template_data de BLOB a TEXT...');
            
            await db.execute('''
              CREATE TABLE IF NOT EXISTS huellas_biometricas_temp(
                id TEXT PRIMARY KEY,
                estudiante_id TEXT NOT NULL,
                numero_dedo INTEGER NOT NULL,
                nombre_dedo TEXT NOT NULL,
                icono TEXT,
                registrada INTEGER DEFAULT 0,
                template_data TEXT,
                fecha_registro TEXT NOT NULL,
                UNIQUE(estudiante_id, numero_dedo),
                FOREIGN KEY(estudiante_id) REFERENCES estudiantes(id) ON UPDATE CASCADE ON DELETE CASCADE
              );
            ''');
            
            await db.execute('''
              INSERT INTO huellas_biometricas_temp 
              SELECT * FROM huellas_biometricas
            ''');
            
            await db.execute('DROP TABLE huellas_biometricas');
            await db.execute('ALTER TABLE huellas_biometricas_temp RENAME TO huellas_biometricas');
            
            print('✅ Migración de huellas_biometricas completada');
          } else {
            print('✅ template_data ya es de tipo TEXT');
          }
        }
      }
      
    } catch (e) {
      print('⚠️ Error en migración de tabla huellas_biometricas: $e');
    }
  }

  // =================================================================
  // 🆕 MÉTODOS COMPLETOS PARA REPORTES E INFORMES
  // =================================================================

  // 🆕 GENERAR REPORTE DE ASISTENCIA BIMESTRAL
  Future<List<Map<String, Object?>>> generarReporteAsistenciaBimestral(
    String bimestreId, String materiaId, String formato) async {
    final db = await database;
    
    return await db.rawQuery('''
      SELECT 
        e.id, 
        e.nombres || ' ' || e.apellido_paterno || ' ' || e.apellido_materno as nombre_completo,
        e.ci,
        na.total_clases, 
        na.clases_asistidas, 
        na.clases_faltadas,
        na.porcentaje_asistencia, 
        na.nota_calculada,
        (SELECT COUNT(*) FROM detalle_asistencias da 
         JOIN asistencias a ON da.asistencia_id = a.id 
         WHERE a.estudiante_id = e.id AND a.materia_id = ? 
         AND da.estado_puntualidad = 'TARDANZA') as total_tardanzas,
        (SELECT COUNT(*) FROM detalle_asistencias da 
         JOIN asistencias a ON da.asistencia_id = a.id 
         WHERE a.estudiante_id = e.id AND a.materia_id = ? 
         AND da.estado_puntualidad = 'PUNTUAL') as total_puntual
      FROM estudiantes e
      LEFT JOIN notas_asistencia na ON e.id = na.estudiante_id 
        AND na.materia_id = ? AND na.bimestre_id = ?
      WHERE e.activo = 1
      ORDER BY e.apellido_paterno, e.apellido_materno, e.nombres
    ''', [materiaId, materiaId, materiaId, bimestreId]);
  }

  // 🆕 GENERAR REPORTE ESTADÍSTICO DE ASISTENCIA
  Future<Map<String, dynamic>> generarReporteEstadistico(
    String periodoId, String materiaId) async {
    final db = await database;
    
    final estadisticas = await db.rawQuery('''
      SELECT 
        COUNT(DISTINCT e.id) as total_estudiantes,
        AVG(na.porcentaje_asistencia) as promedio_asistencia,
        MIN(na.porcentaje_asistencia) as minima_asistencia,
        MAX(na.porcentaje_asistencia) as maxima_asistencia,
        SUM(CASE WHEN na.porcentaje_asistencia >= 80 THEN 1 ELSE 0 END) as estudiantes_aprobados,
        SUM(CASE WHEN na.porcentaje_asistencia < 80 THEN 1 ELSE 0 END) as estudiantes_reprobados
      FROM estudiantes e
      LEFT JOIN notas_asistencia na ON e.id = na.estudiante_id 
        AND na.materia_id = ? AND na.periodo_id = ?
      WHERE e.activo = 1
    ''', [materiaId, periodoId]);

    final distribucion = await db.rawQuery('''
      SELECT 
        CASE 
          WHEN porcentaje_asistencia >= 90 THEN '90-100%'
          WHEN porcentaje_asistencia >= 80 THEN '80-89%'
          WHEN porcentaje_asistencia >= 70 THEN '70-79%'
          WHEN porcentaje_asistencia >= 60 THEN '60-69%'
          ELSE 'Menos del 60%'
        END as rango,
        COUNT(*) as cantidad
      FROM notas_asistencia
      WHERE materia_id = ? AND periodo_id = ?
      GROUP BY rango
      ORDER BY rango
    ''', [materiaId, periodoId]);

    return {
      'estadisticas': estadisticas.first,
      'distribucion': distribucion,
      'fecha_generacion': DateTime.now().toIso8601String(),
      'periodo_id': periodoId,
      'materia_id': materiaId
    };
  }

  // 🆕 GUARDAR REPORTE GENERADO
  Future<int> guardarReporteGenerado(Map<String, dynamic> reporte) async {
    final db = await database;
    return await db.insert('reportes_generados', {
      'id': 'reporte_${DateTime.now().millisecondsSinceEpoch}',
      'tipo_reporte': reporte['tipo_reporte'],
      'titulo': reporte['titulo'],
      'periodo_id': reporte['periodo_id'],
      'materia_id': reporte['materia_id'],
      'bimestre_id': reporte['bimestre_id'],
      'formato': reporte['formato'],
      'parametros': reporte['parametros'],
      'ruta_archivo': reporte['ruta_archivo'],
      'fecha_generacion': DateTime.now().toIso8601String(),
      'usuario_generador': reporte['usuario_generador'],
      'estado': 'COMPLETADO',
      'tamano_bytes': reporte['tamano_bytes']
    });
  }

  // 🆕 OBTENER HISTORIAL DE REPORTES
  Future<List<Map<String, Object?>>> obtenerHistorialReportes() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT rg.*, m.nombre as materia_nombre, p.nombre as periodo_nombre
      FROM reportes_generados rg
      LEFT JOIN materias m ON rg.materia_id = m.id
      LEFT JOIN periodos_academicos p ON rg.periodo_id = p.id
      ORDER BY rg.fecha_generacion DESC
    ''');
  }

  // =================================================================
  // 🆕 MÉTODOS COMPLETOS PARA RESPALDOS Y RECUPERACIÓN
  // =================================================================

  // 🆕 GENERAR RESPALDO COMPLETO
  Future<Map<String, dynamic>> generarRespaldoCompleto() async {
    final db = await database;
    final timestamp = DateTime.now().toIso8601String();
    final respaldoId = 'respaldo_${DateTime.now().millisecondsSinceEpoch}';
    
    final tables = [
      'estudiantes', 'docentes', 'materias', 'asistencias', 
      'detalle_asistencias', 'notas_asistencia', 'huellas_biometricas',
      'usuarios', 'periodos_academicos', 'bimestres', 'docente_materia'
    ];
    
    Map<String, dynamic> respaldoData = {
      'fecha_generacion': timestamp,
      'version_bd': 5,
      'total_tablas': tables.length,
      'tablas': {}
    };
    
    for (String table in tables) {
      try {
        final datos = await db.rawQuery('SELECT * FROM $table');
        respaldoData['tablas'][table] = {
          'total_registros': datos.length,
          'datos': datos
        };
      } catch (e) {
        print('⚠️ Error respaldando tabla $table: $e');
      }
    }
    
    await db.insert('respaldos', {
      'id': respaldoId,
      'tipo_respaldo': 'COMPLETO',
      'descripcion': 'Respaldo completo del sistema',
      'ruta_archivo': 'local/$respaldoId.json',
      'fecha_respaldo': timestamp,
      'tamano_bytes': respaldoData.toString().length,
      'usuario_respaldo': 'sistema',
      'estado': 'COMPLETADO',
      'checksum': _generarChecksum(respaldoData.toString())
    });
    
    return respaldoData;
  }

  // 🆕 GENERAR RESPALDO INCREMENTAL
  Future<Map<String, dynamic>> generarRespaldoIncremental() async {
    final db = await database;
    final timestamp = DateTime.now().toIso8601String();
    final respaldoId = 'respaldo_inc_${DateTime.now().millisecondsSinceEpoch}';
    
    final ultimoRespaldo = await db.rawQuery('''
      SELECT fecha_respaldo FROM respaldos 
      WHERE tipo_respaldo = 'COMPLETO' 
      ORDER BY fecha_respaldo DESC LIMIT 1
    ''');
    
    DateTime? fechaUltimoRespaldo;
    if (ultimoRespaldo.isNotEmpty) {
      fechaUltimoRespaldo = DateTime.parse(ultimoRespaldo.first['fecha_respaldo'] as String);
    }
    
    Map<String, dynamic> respaldoData = {
      'fecha_generacion': timestamp,
      'tipo': 'INCREMENTAL',
      'desde_ultimo_respaldo': fechaUltimoRespaldo?.toIso8601String(),
      'tablas': {}
    };
    
    final tablasIncremental = ['asistencias', 'detalle_asistencias', 'notas_asistencia'];
    
    for (String table in tablasIncremental) {
      String whereClause = '';
      List<Object?> whereArgs = [];
      
      if (fechaUltimoRespaldo != null) {
        if (table == 'asistencias') {
          whereClause = 'WHERE ultima_actualizacion > ?';
          whereArgs = [fechaUltimoRespaldo.toIso8601String()];
        } else if (table == 'detalle_asistencias') {
          whereClause = 'WHERE fecha > ?';
          whereArgs = [fechaUltimoRespaldo.toIso8601String()];
        } else if (table == 'notas_asistencia') {
          whereClause = 'WHERE fecha_calculo > ?';
          whereArgs = [fechaUltimoRespaldo.toIso8601String()];
        }
      }
      
      final datos = await db.rawQuery('SELECT * FROM $table $whereClause', whereArgs);
      respaldoData['tablas'][table] = {
        'total_registros': datos.length,
        'datos': datos
      };
    }
    
    await db.insert('respaldos', {
      'id': respaldoId,
      'tipo_respaldo': 'INCREMENTAL',
      'descripcion': 'Respaldo incremental del sistema',
      'ruta_archivo': 'local/$respaldoId.json',
      'fecha_respaldo': timestamp,
      'tamano_bytes': respaldoData.toString().length,
      'usuario_respaldo': 'sistema',
      'estado': 'COMPLETADO',
      'checksum': _generarChecksum(respaldoData.toString())
    });
    
    return respaldoData;
  }

  // 🆕 RESTAURAR DESDE RESPALDO
  Future<bool> restaurarDesdeRespaldo(Map<String, dynamic> respaldoData) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        for (var tableEntry in respaldoData['tablas'].entries) {
          final String tableName = tableEntry.key;
          final dynamic tableData = tableEntry.value;
          
          if (tableData is Map && tableData['datos'] is List) {
            final List<dynamic> datos = tableData['datos'];
            
            if (respaldoData['tipo'] == 'COMPLETO') {
              await txn.delete(tableName);
            }
            
            for (var row in datos) {
              if (row is Map<String, dynamic>) {
                await txn.insert(tableName, row, conflictAlgorithm: ConflictAlgorithm.replace);
              }
            }
          }
        }
      });
      
      print('✅ Restauración completada exitosamente');
      return true;
    } catch (e) {
      print('❌ Error en restauración: $e');
      return false;
    }
  }

  // 🆕 OBTENER HISTORIAL DE RESPALDOS
  Future<List<Map<String, Object?>>> obtenerHistorialRespaldos() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM respaldos 
      ORDER BY fecha_respaldo DESC
    ''');
  }

  // 🆕 ELIMINAR RESPALDO
  Future<int> eliminarRespaldo(String respaldoId) async {
    final db = await database;
    return await db.delete(
      'respaldos',
      where: 'id = ?',
      whereArgs: [respaldoId]
    );
  }

  // =================================================================
  // 🆕 MÉTODOS MEJORADOS PARA CÁLCULO DE NOTAS CON PUNTUALIDAD
  // =================================================================

  // 🆕 MÉTODO MEJORADO PARA CÁLCULO DE NOTAS CON PUNTUALIDAD
  Future<Map<String, dynamic>> calcularNotaAsistenciaCompleta(
    String estudianteId, String materiaId, String periodoId, String bimestreId) async {
    final db = await database;
    
    final config = await obtenerConfiguracionNotasAsistenciaActiva();
    if (config == null) {
      throw Exception('No hay configuración de notas activa');
    }

    final asistenciaData = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_clases,
        SUM(CASE WHEN da.estado = 'A' THEN 1 ELSE 0 END) as clases_asistidas,
        SUM(CASE WHEN da.estado_puntualidad = 'PUNTUAL' THEN 1 ELSE 0 END) as clases_puntuales,
        SUM(CASE WHEN da.estado_puntualidad = 'TARDANZA' THEN 1 ELSE 0 END) as clases_tardanza,
        SUM(CASE WHEN da.estado_puntualidad = 'AUSENTE' THEN 1 ELSE 0 END) as clases_ausente,
        AVG(CASE WHEN da.minutos_retraso > 0 THEN da.minutos_retraso ELSE NULL END) as promedio_retraso
      FROM asistencias a
      JOIN detalle_asistencias da ON a.id = da.asistencia_id
      JOIN bimestres b ON a.periodo_id = b.periodo_id
      WHERE a.estudiante_id = ? AND a.materia_id = ? AND a.periodo_id = ? AND b.id = ?
    ''', [estudianteId, materiaId, periodoId, bimestreId]);

    if (asistenciaData.isEmpty) {
      throw Exception('No se encontraron datos de asistencia para el bimestre');
    }

    final data = asistenciaData.first;
    final totalClases = data['total_clases'] as int? ?? 0;
    final clasesAsistidas = data['clases_asistidas'] as int? ?? 0;
    final clasesPuntuales = data['clases_puntuales'] as int? ?? 0;
    final clasesTardanza = data['clases_tardanza'] as int? ?? 0;
    final promedioRetraso = data['promedio_retraso'] as double? ?? 0.0;
    
    final porcentajeAsistencia = totalClases > 0 ? (clasesAsistidas / totalClases) * 100 : 0.0;
    final porcentajePuntualidad = clasesAsistidas > 0 ? (clasesPuntuales / clasesAsistidas) * 100 : 0.0;

    double notaCalculada = _aplicarFormulaNota(
      porcentajeAsistencia, 
      porcentajePuntualidad, 
      promedioRetraso, 
      config
    );

    final resultado = {
      'estudiante_id': estudianteId,
      'materia_id': materiaId,
      'periodo_id': periodoId,
      'bimestre_id': bimestreId,
      'total_clases': totalClases,
      'clases_asistidas': clasesAsistidas,
      'clases_faltadas': totalClases - clasesAsistidas,
      'clases_puntuales': clasesPuntuales,
      'clases_tardanza': clasesTardanza,
      'promedio_retraso': promedioRetraso,
      'porcentaje_asistencia': porcentajeAsistencia,
      'porcentaje_puntualidad': porcentajePuntualidad,
      'nota_calculada': notaCalculada,
      'configuracion_usada': config['nombre'],
      'fecha_calculo': DateTime.now().toIso8601String()
    };

    await _guardarNotaCalculada(resultado, config['id'] as String);
    
    return resultado;
  }

  double _aplicarFormulaNota(double porcentajeAsistencia, double porcentajePuntualidad, 
                            double promedioRetraso, Map<String, Object?> config) {
    final puntajeMaximo = config['puntaje_maximo'] as double? ?? 10.0;
    
    double notaAsistencia = (porcentajeAsistencia / 100) * (puntajeMaximo * 0.7);
    double notaPuntualidad = (porcentajePuntualidad / 100) * (puntajeMaximo * 0.3);
    
    if (promedioRetraso > 15) {
      double penalizacion = (promedioRetraso - 15) * 0.01;
      notaPuntualidad *= (1 - penalizacion.clamp(0.0, 0.5));
    }
    
    return (notaAsistencia + notaPuntualidad).clamp(0.0, puntajeMaximo);
  }

  Future<void> _guardarNotaCalculada(Map<String, dynamic> resultado, String configId) async {
    final db = await database;
    
    final notaExistente = await db.query(
      'notas_asistencia',
      where: 'estudiante_id = ? AND materia_id = ? AND periodo_id = ? AND bimestre_id = ?',
      whereArgs: [
        resultado['estudiante_id'],
        resultado['materia_id'],
        resultado['periodo_id'],
        resultado['bimestre_id']
      ]
    );
    
    final notaData = {
      'estudiante_id': resultado['estudiante_id'],
      'materia_id': resultado['materia_id'],
      'periodo_id': resultado['periodo_id'],
      'bimestre_id': resultado['bimestre_id'],
      'config_asistencia_id': configId,
      'total_clases': resultado['total_clases'],
      'clases_asistidas': resultado['clases_asistidas'],
      'clases_faltadas': resultado['clases_faltadas'],
      'porcentaje_asistencia': resultado['porcentaje_asistencia'],
      'nota_calculada': resultado['nota_calculada'],
      'estado': 'CALCULADO',
      'fecha_calculo': resultado['fecha_calculo'],
      'observaciones': 'Calculado con puntualidad - ${resultado['configuracion_usada']}'
    };
    
    if (notaExistente.isNotEmpty) {
      await db.update(
        'notas_asistencia',
        notaData,
        where: 'id = ?',
        whereArgs: [notaExistente.first['id']]
      );
    } else {
      notaData['id'] = 'nota_${resultado['estudiante_id']}_${resultado['materia_id']}_${resultado['periodo_id']}_${resultado['bimestre_id']}';
      await db.insert('notas_asistencia', notaData);
    }
  }

  // =================================================================
  // ✅ MÉTODOS EXISTENTES COMPLETOS (LOS QUE YA TENÍAS)
  // =================================================================

  // ✅ MÉTODO DEFINITIVO ROBUSTO PARA ACTUALIZAR CONTRASEÑA
  Future<int> actualizarPassword(String userId, String nuevaPassword) async {
    final db = await database;
    
    try {
      print('🔄 Actualizando contraseña para usuario: $userId');
      
      final tableInfo = await db.rawQuery('PRAGMA table_info(usuarios)');
      final columnas = tableInfo.map((col) => col['name'] as String).toList();
      
      Map<String, dynamic> updateData = {'password': nuevaPassword};
      
      if (columnas.contains('fecha_actualizacion')) {
        updateData['fecha_actualizacion'] = DateTime.now().toIso8601String();
      } 
      if (columnas.contains('updated_at')) {
        updateData['updated_at'] = DateTime.now().toIso8601String();
      }
      
      final resultado = await db.update(
        'usuarios',
        updateData,
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      print('✅ Resultado de actualización: $resultado filas afectadas');
      return resultado;
      
    } catch (e) {
      print('❌ Error en actualizarPassword: $e');
      
      try {
        final resultado = await db.update(
          'usuarios',
          {'password': nuevaPassword},
          where: 'id = ?',
          whereArgs: [userId],
        );
        print('✅ Contraseña actualizada (fallback) - Filas: $resultado');
        return resultado;
      } catch (e2) {
        print('❌ Error incluso en fallback: $e2');
        rethrow;
      }
    }
  }

  // ✅ MÉTODO CORREGIDO PARA VERIFICAR CREDENCIALES
  Future<Map<String, Object?>?> verificarCredenciales(String username, String password) async {
    final db = await database;
    
    try {
      print('🔐 Verificando credenciales para: $username');
      
      final results = await db.query(
        'usuarios',
        where: 'username = ? AND password = ? AND esta_activo = 1',
        whereArgs: [username, password],
      );
      
      print('📊 Resultados de verificación: ${results.length}');
      
      if (results.isNotEmpty) {
        final usuario = results.first;
        print('✅ Usuario encontrado:');
        print('   - ID: ${usuario['id']}');
        print('   - Nombre: ${usuario['nombre']}');
      } else {
        print('❌ Usuario no encontrado o credenciales incorrectas');
      }
      
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      print('❌ Error en verificarCredenciales: $e');
      return null;
    }
  }
  
  // 🌟 MÉTODO PARA VERIFICAR SI LA BASE DE DATOS EXISTE
  Future<bool> databaseExists() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _dbName);
    return await sqflite.databaseExists(path);
  }

  // 🌟 NUEVO: Método para saber si es primera instalación
  bool get isFirstTime => _isFirstTime;

  // 🌟 NUEVO: Obtener información de la base de datos
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
    );
    
    Map<String, dynamic> info = {
      'isFirstTime': _isFirstTime,
      'tableCount': tables.length,
      'tables': {},
    };
    
    for (var table in tables) {
      final tableName = table['name'] as String;
      final count = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      info['tables'][tableName] = count.first['count'];
    }
    
    return info;
  }

  // 🆕 MÉTODOS ESPECÍFICOS PARA NOTAS DE ASISTENCIA
  Future<int> asignarDocenteMateria(Map<String, dynamic> asignacion) async {
    final db = await database;
    return await db.insert('docente_materia', asignacion);
  }

  Future<List<Map<String, Object?>>> obtenerMateriasPorDocente(String docenteId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT m.*, dm.* 
      FROM docente_materia dm
      JOIN materias m ON dm.materia_id = m.id
      WHERE dm.docente_id = ? AND dm.activo = 1
    ''', [docenteId]);
  }

  Future<List<Map<String, Object?>>> obtenerDocentesPorMateria(String materiaId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT d.*, dm.* 
      FROM docente_materia dm
      JOIN docentes d ON dm.docente_id = d.id
      WHERE dm.materia_id = ? AND dm.activo = 1
    ''', [materiaId]);
  }

  // 🆕 MÉTODO PARA CALCULAR NOTA DE ASISTENCIA BIMESTRAL
  Future<int> calcularNotaAsistencia(String estudianteId, String materiaId, String periodoId, String bimestreId) async {
    final db = await database;
    
    final configs = await db.query('config_notas_asistencia', where: 'activo = 1', limit: 1);
    if (configs.isEmpty) {
      throw Exception('No hay configuración de notas de asistencia activa');
    }
    
    final config = configs.first;
    final configId = config['id'] as String;
    final puntajeMaximo = config['puntaje_maximo'] as double? ?? 10.0;
    
    final asistenciaData = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_clases,
        SUM(CASE WHEN da.estado = 'A' THEN 1 ELSE 0 END) as clases_asistidas
      FROM asistencias a
      JOIN detalle_asistencias da ON a.id = da.asistencia_id
      JOIN bimestres b ON a.periodo_id = b.periodo_id
      WHERE a.estudiante_id = ? AND a.materia_id = ? AND a.periodo_id = ? AND b.id = ?
    ''', [estudianteId, materiaId, periodoId, bimestreId]);
    
    if (asistenciaData.isEmpty) {
      throw Exception('No se encontraron datos de asistencia para el bimestre');
    }
    
    final data = asistenciaData.first;
    final totalClases = data['total_clases'] as int? ?? 0;
    final clasesAsistidas = data['clases_asistidas'] as int? ?? 0;
    final porcentajeAsistencia = totalClases > 0 ? (clasesAsistidas / totalClases) * 100 : 0.0;
    
    double notaCalculada = (porcentajeAsistencia / 100) * puntajeMaximo;
    
    final notaExistente = await db.query(
      'notas_asistencia',
      where: 'estudiante_id = ? AND materia_id = ? AND periodo_id = ? AND bimestre_id = ?',
      whereArgs: [estudianteId, materiaId, periodoId, bimestreId]
    );
    
    final now = DateTime.now().toIso8601String();
    final notaData = {
      'estudiante_id': estudianteId,
      'materia_id': materiaId,
      'periodo_id': periodoId,
      'bimestre_id': bimestreId,
      'config_asistencia_id': configId,
      'total_clases': totalClases,
      'clases_asistidas': clasesAsistidas,
      'clases_faltadas': totalClases - clasesAsistidas,
      'porcentaje_asistencia': porcentajeAsistencia,
      'nota_calculada': notaCalculada,
      'estado': 'CALCULADO',
      'fecha_calculo': now,
      'observaciones': 'Calculado automáticamente - Nota sobre ${puntajeMaximo.toInt()} puntos'
    };
    
    if (notaExistente.isNotEmpty) {
      return await db.update(
        'notas_asistencia',
        notaData,
        where: 'id = ?',
        whereArgs: [notaExistente.first['id']]
      );
    } else {
      notaData['id'] = 'nota_${estudianteId}_${materiaId}_${periodoId}_$bimestreId';
      return await db.insert('notas_asistencia', notaData);
    }
  }

  Future<List<Map<String, Object?>>> obtenerNotasAsistenciaPorEstudiante(String estudianteId, String periodoId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT na.*, m.nombre as materia_nombre, b.nombre as bimestre_nombre,
             cna.puntaje_maximo as puntaje_maximo
      FROM notas_asistencia na
      JOIN materias m ON na.materia_id = m.id
      JOIN bimestres b ON na.bimestre_id = b.id
      JOIN config_notas_asistencia cna ON na.config_asistencia_id = cna.id
      WHERE na.estudiante_id = ? AND na.periodo_id = ?
      ORDER BY m.nombre, b.nombre
    ''', [estudianteId, periodoId]);
  }

  // 🆕 MÉTODO PARA OBTENER CONFIGURACIÓN DE NOTAS DE ASISTENCIA ACTIVA
  Future<Map<String, Object?>?> obtenerConfiguracionNotasAsistenciaActiva() async {
    final db = await database;
    final results = await db.query(
      'config_notas_asistencia',
      where: 'activo = 1',
      limit: 1
    );
    return results.isNotEmpty ? results.first : null;
  }

  // =================================================================
  // 🆕 MÉTODOS UTILITARIOS COMPLETOS
  // =================================================================

  // 🆕 GENERAR CHECKSUM PARA VALIDACIÓN
  String _generarChecksum(String data) {
    int checksum = 0;
    for (int i = 0; i < data.length; i++) {
      checksum = (checksum + data.codeUnitAt(i)) % 256;
    }
    return checksum.toRadixString(16).padLeft(2, '0');
  }

  // 🆕 OBTENER ESTADÍSTICAS DEL SISTEMA
  Future<Map<String, dynamic>> obtenerEstadisticasSistema() async {
    final db = await database;
    
    final totalEstudiantes = await db.rawQuery('SELECT COUNT(*) as count FROM estudiantes WHERE activo = 1');
    final totalDocentes = await db.rawQuery('SELECT COUNT(*) as count FROM docentes WHERE estado = "ACTIVO"');
    final totalMaterias = await db.rawQuery('SELECT COUNT(*) as count FROM materias WHERE activo = 1');
    final totalAsistencias = await db.rawQuery('SELECT COUNT(*) as count FROM detalle_asistencias');
    final reportesGenerados = await db.rawQuery('SELECT COUNT(*) as count FROM reportes_generados');
    final respaldos = await db.rawQuery('SELECT COUNT(*) as count FROM respaldos');
    
    return {
      'total_estudiantes': (totalEstudiantes.first['count'] as int?) ?? 0,
      'total_docentes': (totalDocentes.first['count'] as int?) ?? 0,
      'total_materias': (totalMaterias.first['count'] as int?) ?? 0,
      'total_asistencias': (totalAsistencias.first['count'] as int?) ?? 0,
      'reportes_generados': (reportesGenerados.first['count'] as int?) ?? 0,
      'respaldos_realizados': (respaldos.first['count'] as int?) ?? 0,
      'fecha_consulta': DateTime.now().toIso8601String()
    };
  }

  // 🆕 LIMPIAR DATOS TEMPORALES
  Future<int> limpiarDatosTemporales() async {
    final db = await database;
    
    final fechaLimite = DateTime.now().subtract(Duration(days: 365)).toIso8601String();
    
    final resultado = await db.rawDelete('''
      DELETE FROM detalle_asistencias 
      WHERE fecha < ?
    ''', [fechaLimite]);
    
    print('✅ Datos temporales limpiados: $resultado registros eliminados');
    return resultado;
  }

  // 🆕 EXPORTAR DATOS PARA MIGRACIÓN
  Future<Map<String, dynamic>> exportarDatosParaMigracion() async {
    final db = await database;
    
    final datosExportacion = {
      'fecha_exportacion': DateTime.now().toIso8601String(),
      'version_sistema': '1.0.0',
      'datos': {} // Inicializado como mapa vacío
    };
    
    final tablasExportacion = ['estudiantes', 'docentes', 'materias', 'usuarios', 'config_notas_asistencia'];
    
    for (String tabla in tablasExportacion) {
      final datos = await db.rawQuery('SELECT * FROM $tabla');
      // ✅ SOLUCIÓN: Cast explícito a Map<String, dynamic>
      (datosExportacion['datos'] as Map<String, dynamic>)[tabla] = datos;
    }
    
    return datosExportacion;
  }

  // =================================================================
  // 🆕 MÉTODOS COMPLETOS PARA HORARIOS
  // =================================================================

  Future<List<Map<String, Object?>>> obtenerHorariosOrdenados() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM horarios_clases 
      ORDER BY 
        CASE dia_semana 
          WHEN 'Lunes' THEN 1
          WHEN 'Martes' THEN 2
          WHEN 'Miércoles' THEN 3
          WHEN 'Jueves' THEN 4
          WHEN 'Viernes' THEN 5
          WHEN 'Sábado' THEN 6
          ELSE 7
        END,
        periodo_numero
    ''');
  }

  Future<bool> existeHorarioEnMismoDiaYPeriodo(String diaSemana, int periodoNumero, String paraleloId) async {
    final db = await database;
    final existe = await db.rawQuery('''
      SELECT COUNT(*) as count FROM horarios_clases 
      WHERE dia_semana = ? AND periodo_numero = ? AND paralelo_id = ?
    ''', [diaSemana, periodoNumero, paraleloId]);
    return ((existe.first['count'] as int?) ?? 0) > 0;
  }

  Future<int> insertarHorario(Map<String, dynamic> horario) async {
    final db = await database;
    return await db.rawInsert('''
      INSERT INTO horarios_clases (
        id, materia_id, paralelo_id, docente_id, dia_semana,
        periodo_numero, hora_inicio, hora_fin, activo, fecha_creacion
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      horario['id'],
      horario['materia_id'],
      horario['paralelo_id'],
      horario['docente_id'],
      horario['dia_semana'],
      horario['periodo_numero'],
      horario['hora_inicio'],
      horario['hora_fin'],
      horario['activo'] ? 1 : 0,
      horario['fecha_creacion'].toIso8601String(),
    ]);
  }

  Future<int> actualizarHorario(Map<String, dynamic> horario) async {
    final db = await database;
    return await db.rawUpdate('''
      UPDATE horarios_clases SET 
        materia_id = ?, paralelo_id = ?, docente_id = ?, dia_semana = ?,
        periodo_numero = ?, hora_inicio = ?, hora_fin = ?, activo = ?
      WHERE id = ?
    ''', [
      horario['materia_id'],
      horario['paralelo_id'],
      horario['docente_id'],
      horario['dia_semana'],
      horario['periodo_numero'],
      horario['hora_inicio'],
      horario['hora_fin'],
      horario['activo'] ? 1 : 0,
      horario['id'],
    ]);
  }

  Future<int> eliminarHorario(String id) async {
    final db = await database;
    return await db.rawDelete('''
      DELETE FROM horarios_clases WHERE id = ?
    ''', [id]);
  }

  Future<List<Map<String, Object?>>> obtenerHorariosPorDia(String dia) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM horarios_clases 
      WHERE dia_semana = ? AND activo = 1
      ORDER BY periodo_numero
    ''', [dia]);
  }

  // =================================================================
  // 🆕 MÉTODOS COMPLETOS PARA ASISTENCIA DIARIA
  // =================================================================

  Future<List<Map<String, Object?>>> obtenerEstudiantesOrdenados() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM estudiantes 
      ORDER BY apellido_paterno, apellido_materno, nombres
    ''');
  }

  Future<List<Map<String, Object?>>> obtenerAsistenciasPorFecha(String fecha) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM asistencia_diaria 
      WHERE fecha = ?
      ORDER BY periodo_numero, estudiante_id
    ''', [fecha]);
  }

  Future<bool> existeAsistenciaRegistrada(
    String estudianteId, String materiaId, String fecha, int periodoNumero) async {
    final db = await database;
    final existe = await db.rawQuery('''
      SELECT COUNT(*) as count FROM asistencia_diaria 
      WHERE estudiante_id = ? AND materia_id = ? AND fecha = ? AND periodo_numero = ?
    ''', [estudianteId, materiaId, fecha, periodoNumero]);
    return ((existe.first['count'] as int?) ?? 0) > 0;
  }

  Future<int> actualizarAsistenciaDiaria(Map<String, dynamic> asistencia) async {
    final db = await database;
    return await db.rawUpdate('''
      UPDATE asistencia_diaria SET 
        estado = ?, minutos_retraso = ?, observaciones = ?, usuario_registro = ?
      WHERE estudiante_id = ? AND materia_id = ? AND fecha = ? AND periodo_numero = ?
    ''', [
      asistencia['estado'],
      asistencia['minutos_retraso'],
      asistencia['observaciones'],
      asistencia['usuario_registro'],
      asistencia['estudiante_id'],
      asistencia['materia_id'],
      asistencia['fecha'],
      asistencia['periodo_numero'],
    ]);
  }

  Future<int> insertarAsistenciaDiaria(Map<String, dynamic> asistencia) async {
    final db = await database;
    return await db.rawInsert('''
      INSERT INTO asistencia_diaria (
        id, estudiante_id, materia_id, horario_clase_id, fecha,
        periodo_numero, estado, minutos_retraso, observaciones,
        fecha_creacion, usuario_registro
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      asistencia['id'],
      asistencia['estudiante_id'],
      asistencia['materia_id'],
      asistencia['horario_clase_id'],
      asistencia['fecha'],
      asistencia['periodo_numero'],
      asistencia['estado'],
      asistencia['minutos_retraso'],
      asistencia['observaciones'],
      asistencia['fecha_creacion'].toIso8601String(),
      asistencia['usuario_registro'],
    ]);
  }

} // Fin de la clase DatabaseHelper