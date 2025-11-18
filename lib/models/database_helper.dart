// models/database_helper.dart - VERSIÓN 7 COMPLETA CON SISTEMA DE HUELLAS ESP32
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_live/sqflite_live.dart';
import 'package:path/path.dart';

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
          version: 7, // ✅ INCREMENTADO A VERSIÓN 7
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
      version: 7, // ✅ INCREMENTADO A VERSIÓN 7
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

    // 🆕 NUEVA MIGRACIÓN PARA VERSIÓN 6 - MEJORAS DE SISTEMA
    if (oldVersion < 6) {
      try {
        // Crear tabla estudiante_usuario si no existe
        await db.execute('''
          CREATE TABLE IF NOT EXISTS estudiante_usuario(
            id TEXT PRIMARY KEY,
            estudiante_id TEXT NOT NULL UNIQUE,
            usuario_id TEXT NOT NULL UNIQUE,
            fecha_vinculacion TEXT NOT NULL,
            FOREIGN KEY(estudiante_id) REFERENCES estudiantes(id) ON UPDATE CASCADE ON DELETE CASCADE,
            FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON UPDATE CASCADE ON DELETE CASCADE
          );
        ''');
        
        // Actualizar configuración de notas
        await db.update(
          'config_notas_asistencia',
          {
            'nombre': 'Configuración Notas Asistencia - 10 Puntos Directos',
            'descripcion': 'Cálculo directo de nota sobre 10 puntos - 4 bimestres',
            'formula_tipo': 'DIRECTO',
            'parametros': '{"total_bimestres": 4, "considera_puntualidad": false}',
            'fecha_actualizacion': DateTime.now().toIso8601String()
          },
          where: 'id = ?',
          whereArgs: ['config_asistencia_default']
        );
        
        print('✅ Migración a versión 6 completada - Sistema mejorado');
      } catch (e) {
        print('⚠️ Error en upgrade a versión 6: $e');
      }
    }

    // 🆕 NUEVA MIGRACIÓN PARA VERSIÓN 7 - SISTEMA DE HUELLAS ESP32
    if (oldVersion < 7) {
      try {
        // Agregar campo dispositivo_registro a huellas_biometricas
        await db.execute('''
          ALTER TABLE huellas_biometricas ADD COLUMN dispositivo_registro TEXT DEFAULT 'MOVIL'
        ''');
        
        print('✅ Migración a versión 7 completada - Sistema de huellas ESP32');
      } catch (e) {
        print('⚠️ Error en upgrade a versión 7 (posiblemente campo ya existe): $e');
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

    // 🆕 TABLA PARA RELACIÓN ESTUDIANTE-USUARIO
    await db.execute('''
      CREATE TABLE IF NOT EXISTS estudiante_usuario(
        id TEXT PRIMARY KEY,
        estudiante_id TEXT NOT NULL UNIQUE,
        usuario_id TEXT NOT NULL UNIQUE,
        fecha_vinculacion TEXT NOT NULL,
        FOREIGN KEY(estudiante_id) REFERENCES estudiantes(id) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON UPDATE CASCADE ON DELETE CASCADE
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
        formula_tipo TEXT DEFAULT 'DIRECTO',
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

    // ✅ TABLA HUELLAS_BIOMETRICAS MEJORADA CON ESP32
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
        dispositivo_registro TEXT DEFAULT 'MOVIL',
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

    // 🆕 ÍNDICE PARA ESTUDIANTE_USUARIO
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_estudiante_usuario_usuario 
      ON estudiante_usuario(usuario_id);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_estudiante_usuario_estudiante 
      ON estudiante_usuario(estudiante_id);
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

    // ✅ Insertar usuarios de prueba CON ROLES ESPECÍFICOS
    final usuariosCount = await db.rawQuery('SELECT COUNT(*) AS c FROM usuarios');
    if ((usuariosCount.first['c'] as int?) == 0) {
      final now = DateTime.now().toIso8601String();
      
      // 🌟 ADMINISTRADOR
      await db.insert('usuarios', {
        'id': 'admin_001',
        'username': 'admin',
        'email': 'admin@incos.edu.bo',
        'nombre': 'Administrador Sistema',
        'password': 'admin123',
        'role': 'administrador',
        'carnet': 'ADMIN001',
        'departamento': 'Sistemas',
        'esta_activo': 1,
        'fecha_registro': now,
        'updated_at': now
      });
      
      // 🌟 SECRETARÍA
      await db.insert('usuarios', {
        'id': 'secretaria_001',
        'username': 'secretaria',
        'email': 'secretaria@incos.edu.bo',
        'nombre': 'María López - Secretaría',
        'password': 'secretaria123',
        'role': 'secretaria',
        'carnet': 'SEC001',
        'departamento': 'Secretaría Académica',
        'esta_activo': 1,
        'fecha_registro': now,
        'updated_at': now
      });
      
      // 🌟 DIRECTOR ACADÉMICO
      await db.insert('usuarios', {
        'id': 'director_001',
        'username': 'director',
        'email': 'director@incos.edu.bo',
        'nombre': 'Dr. Carlos Rodríguez - Director',
        'password': 'director123',
        'role': 'director',
        'carnet': 'DIR001',
        'departamento': 'Dirección Académica',
        'esta_activo': 1,
        'fecha_registro': now,
        'updated_at': now
      });
      
      // 🌟 JEFE DE CARRERA
      await db.insert('usuarios', {
        'id': 'jefe_001',
        'username': 'jefe',
        'email': 'jefe.sistemas@incos.edu.bo',
        'nombre': 'Ing. Ana Martínez - Jefe Carrera',
        'password': 'jefe123',
        'role': 'jefe_carrera',
        'carnet': 'JEF001',
        'departamento': 'Sistemas Informáticos',
        'esta_activo': 1,
        'fecha_registro': now,
        'updated_at': now
      });
      
      // 🌟 DOCENTE
      await db.insert('usuarios', {
        'id': 'docente_001',
        'username': 'profesor',
        'email': 'profesor@incos.edu.bo',
        'nombre': 'Lic. Roberto Sánchez - Docente',
        'password': 'profesor123',
        'role': 'docente',
        'carnet': 'DOC001',
        'departamento': 'Académico',
        'esta_activo': 1,
        'fecha_registro': now,
        'updated_at': now
      });
      
      // 🌟 ESTUDIANTE
      await db.insert('usuarios', {
        'id': 'estudiante_001',
        'username': 'estudiante',
        'email': 'estudiante@incos.edu.bo',
        'nombre': 'Juan García López',
        'password': 'estudiante123',
        'role': 'estudiante',
        'carnet': '2023001',
        'departamento': 'Sistemas Informáticos',
        'esta_activo': 1,
        'fecha_registro': now,
        'updated_at': now
      });
      
      print('✅ Usuarios con ROLES ESPECÍFICOS insertados');
      print('💡 NOTA: Solo los ESTUDIANTES pueden registrar huellas biométricas');
    }

    // Insertar docente de ejemplo
    final docentesCount = await db.rawQuery('SELECT COUNT(*) AS c FROM docentes');
    if ((docentesCount.first['c'] as int?) == 0) {
      final now = DateTime.now().toIso8601String();
      await db.insert('docentes', {
        'id': 'docente_001',
        'apellido_paterno': 'Sánchez',
        'apellido_materno': 'Gómez',
        'nombres': 'Roberto Carlos',
        'ci': '1234567',
        'carrera': 'Informática',
        'turno': 'MAÑANA',
        'email': 'roberto.sanchez@incos.edu.bo',
        'telefono': '77788899',
        'estado': 'ACTIVO',
        'fecha_creacion': now,
        'fecha_actualizacion': now
      });
      print('✅ Docente de ejemplo insertado');
    }

    // Insertar estudiante de ejemplo
    final estudiantesCount = await db.rawQuery('SELECT COUNT(*) AS c FROM estudiantes');
    if ((estudiantesCount.first['c'] as int?) == 0) {
      final now = DateTime.now().toIso8601String();
      await db.insert('estudiantes', {
        'id': 'est_001',
        'nombres': 'Juan',
        'apellido_paterno': 'García',
        'apellido_materno': 'López',
        'ci': '9876543',
        'fecha_registro': now,
        'huellas_registradas': 0,
        'carrera_id': 'info',
        'turno_id': 'turno_manana',
        'nivel_id': 'nivel_secundaria',
        'paralelo_id': 'paralelo_b',
        'fecha_creacion': now,
        'fecha_actualizacion': now,
        'activo': 1
      });
      print('✅ Estudiante de ejemplo insertado');
    }

    // 🌟 VINCULAR ESTUDIANTE CON USUARIO
    final estudianteUsuarioCount = await db.rawQuery('SELECT COUNT(*) AS c FROM estudiante_usuario');
    if ((estudianteUsuarioCount.first['c'] as int?) == 0) {
      await db.insert('estudiante_usuario', {
        'id': 'eu_001',
        'estudiante_id': 'est_001',
        'usuario_id': 'estudiante_001',
        'fecha_vinculacion': DateTime.now().toIso8601String()
      });
      print('✅ Estudiante vinculado con usuario');
    }

    // 🆕 Insertar CONFIGURACIÓN DE NOTAS DE ASISTENCIA por defecto - CORREGIDA
    final configNotasCount = await db.rawQuery('SELECT COUNT(*) AS c FROM config_notas_asistencia');
    if ((configNotasCount.first['c'] as int?) == 0) {
      final now = DateTime.now().toIso8601String();
      await db.insert('config_notas_asistencia', {
        'id': 'config_asistencia_default',
        'nombre': 'Configuración Notas Asistencia - 10 Puntos Directos',
        'descripcion': 'Cálculo directo de nota sobre 10 puntos - 4 bimestres',
        'puntaje_maximo': 10.0,
        'formula_tipo': 'DIRECTO',
        'parametros': '{"total_bimestres": 4, "considera_puntualidad": false}',
        'activo': 1,
        'fecha_creacion': now,
        'fecha_actualizacion': now
      });
      print('✅ Configuración notas asistencia CORREGIDA insertada');
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

    // 🌟 INSERTAR BIMESTRES PARA EL AÑO
    final bimestresCount = await db.rawQuery('SELECT COUNT(*) AS c FROM bimestres');
    if ((bimestresCount.first['c'] as int?) == 0) {
      final now = DateTime.now().toIso8601String();
      
      await db.insert('bimestres', {
        'id': 'bimestre_1_2024',
        'periodo_id': 'periodo_2024',
        'nombre': 'Primer Bimestre',
        'fechas': '{"inicio": "2024-01-01", "fin": "2024-03-31"}',
        'datos_estudiantes': '{}'
      });
      
      await db.insert('bimestres', {
        'id': 'bimestre_2_2024',
        'periodo_id': 'periodo_2024',
        'nombre': 'Segundo Bimestre',
        'fechas': '{"inicio": "2024-04-01", "fin": "2024-06-30"}',
        'datos_estudiantes': '{}'
      });
      
      await db.insert('bimestres', {
        'id': 'bimestre_3_2024',
        'periodo_id': 'periodo_2024',
        'nombre': 'Tercer Bimestre',
        'fechas': '{"inicio": "2024-07-01", "fin": "2024-09-30"}',
        'datos_estudiantes': '{}'
      });
      
      await db.insert('bimestres', {
        'id': 'bimestre_4_2024',
        'periodo_id': 'periodo_2024',
        'nombre': 'Cuarto Bimestre',
        'fechas': '{"inicio": "2024-10-01", "fin": "2024-12-31"}',
        'datos_estudiantes': '{}'
      });
      
      print('✅ 4 BIMESTRES insertados para el año 2024');
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
          formula_tipo TEXT DEFAULT 'DIRECTO',
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
  // 🆕 MÉTODOS ESPECÍFICOS PARA EL SISTEMA DE ASISTENCIA - CORREGIDOS
  // =================================================================

  // 🌟 OBTENER USUARIO POR USERNAME
  Future<Map<String, Object?>?> obtenerUsuarioPorUsername(String username) async {
    final db = await database;
    final results = await db.query(
      'usuarios',
      where: 'username = ? AND esta_activo = 1',
      whereArgs: [username],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // 🌟 OBTENER ESTUDIANTE POR USUARIO_ID
  Future<Map<String, Object?>?> obtenerEstudiantePorUsuarioId(String usuarioId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT e.* 
      FROM estudiantes e
      JOIN estudiante_usuario eu ON e.id = eu.estudiante_id
      WHERE eu.usuario_id = ? AND e.activo = 1
    ''', [usuarioId]);
    
    return results.isNotEmpty ? results.first : null;
  }

  // 🌟 OBTENER MATERIAS POR DOCENTE
  Future<List<Map<String, Object?>>> obtenerMateriasPorDocente(String docenteId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT m.*, dm.paralelo_id, p.nombre as paralelo_nombre
      FROM docente_materia dm
      JOIN materias m ON dm.materia_id = m.id
      LEFT JOIN paralelos p ON dm.paralelo_id = p.id
      WHERE dm.docente_id = ? AND dm.activo = 1 AND m.activo = 1
      ORDER BY m.nombre
    ''', [docenteId]);
  }

  // 🌟 OBTENER ESTUDIANTES POR MATERIA Y PARALELO
  Future<List<Map<String, Object?>>> obtenerEstudiantesPorMateriaParalelo(String materiaId, String paraleloId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT e.*, eu.usuario_id
      FROM estudiantes e
      JOIN estudiante_usuario eu ON e.id = eu.estudiante_id
      WHERE e.paralelo_id = ? AND e.activo = 1
      ORDER BY e.apellido_paterno, e.apellido_materno, e.nombres
    ''', [paraleloId]);
  }

  // 🌟 REGISTRAR ASISTENCIA CON HUELLA
  Future<int> registrarAsistenciaBiometrica({
    required String estudianteId,
    required String materiaId,
    required String fecha,
    required int periodoNumero,
    required String usuarioRegistro,
    int minutosRetraso = 0,
    String observaciones = '',
  }) async {
    final db = await database;
    
    // Verificar si ya existe asistencia para evitar duplicados
    final existe = await existeAsistenciaRegistrada(estudianteId, materiaId, fecha, periodoNumero);
    if (existe) {
      throw Exception('Ya existe asistencia registrada para esta clase');
    }
    
    return await insertarAsistenciaDiaria({
      'id': 'asist_${DateTime.now().millisecondsSinceEpoch}',
      'estudiante_id': estudianteId,
      'materia_id': materiaId,
      'fecha': fecha,
      'periodo_numero': periodoNumero,
      'estado': minutosRetraso > 0 ? 'T' : 'A', // T = Tarde, A = Asistió
      'minutos_retraso': minutosRetraso,
      'observaciones': observaciones.isNotEmpty ? observaciones : 'Registro biométrico',
      'fecha_creacion': DateTime.now().toIso8601String(),
      'usuario_registro': usuarioRegistro,
    });
  }

  // 🌟 CALCULAR NOTA DE ASISTENCIA SIMPLE (10 PUNTOS DIRECTOS) - CORREGIDO
  Future<double> calcularNotaAsistenciaSimple(
    String estudianteId, String materiaId, String bimestreId) async {
    final db = await database;
    
    // Primero obtener las fechas del bimestre
    final bimestreData = await db.rawQuery(
      'SELECT fechas FROM bimestres WHERE id = ?',
      [bimestreId]
    );
    
    if (bimestreData.isEmpty) {
      return 0.0;
    }
    
    final fechasJson = bimestreData.first['fechas'] as String?;
    if (fechasJson == null) {
      return 0.0;
    }
    
    // Parsear las fechas manualmente
    final fechas = _parsearFechasBimestre(fechasJson);
    final fechaInicio = fechas['inicio'];
    final fechaFin = fechas['fin'];
    
    if (fechaInicio == null || fechaFin == null) {
      return 0.0;
    }
    
    final asistenciaData = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_clases,
        SUM(CASE WHEN estado IN ('A', 'T') THEN 1 ELSE 0 END) as clases_asistidas
      FROM asistencia_diaria
      WHERE estudiante_id = ? 
        AND materia_id = ?
        AND fecha BETWEEN ? AND ?
    ''', [estudianteId, materiaId, fechaInicio, fechaFin]);
    
    if (asistenciaData.isEmpty) {
      return 0.0;
    }
    
    final data = asistenciaData.first;
    final totalClases = data['total_clases'] as int? ?? 0;
    final clasesAsistidas = data['clases_asistidas'] as int? ?? 0;
    
    if (totalClases == 0) {
      return 0.0;
    }
    
    // Cálculo directo: (clases_asistidas / total_clases) * 10
    final porcentaje = (clasesAsistidas / totalClases) * 100;
    final nota = (porcentaje / 100) * 10.0;
    
    return double.parse(nota.toStringAsFixed(2));
  }

  // 🌟 MÉTODO AUXILIAR MEJORADO PARA PARSEAR FECHAS DEL BIMESTRE
  Map<String, String?> _parsearFechasBimestre(String fechasJson) {
    try {
      // Intentar parsear como JSON primero
      final parsed = jsonDecode(fechasJson) as Map<String, dynamic>;
      return {
        'inicio': parsed['inicio']?.toString(),
        'fin': parsed['fin']?.toString(),
      };
    } catch (e) {
      // Fallback al método manual si el JSON no es válido
      try {
        String cleaned = fechasJson.replaceAll('{', '').replaceAll('}', '').replaceAll('"', '');
        List<String> partes = cleaned.split(',');
        
        String? inicio, fin;
        
        for (String parte in partes) {
          if (parte.contains('inicio:')) {
            inicio = parte.split(':')[1].trim();
          } else if (parte.contains('fin:')) {
            fin = parte.split(':')[1].trim();
          }
        }
        
        return {'inicio': inicio, 'fin': fin};
      } catch (e2) {
        print('❌ Error parseando fechas: $e2');
        return {'inicio': null, 'fin': null};
      }
    }
  }

  // 🌟 OBTENER ASISTENCIA POR ESTUDIANTE Y BIMESTRE - CORREGIDO
  Future<List<Map<String, Object?>>> obtenerAsistenciaPorEstudianteBimestre(
    String estudianteId, String bimestreId, String materiaId) async {
    final db = await database;
    
    // Primero obtener las fechas del bimestre
    final bimestreData = await db.rawQuery(
      'SELECT fechas FROM bimestres WHERE id = ?',
      [bimestreId]
    );
    
    if (bimestreData.isEmpty) {
      return [];
    }
    
    final fechasJson = bimestreData.first['fechas'] as String?;
    if (fechasJson == null) {
      return [];
    }
    
    // Parsear las fechas manualmente
    final fechas = _parsearFechasBimestre(fechasJson);
    final fechaInicio = fechas['inicio'];
    final fechaFin = fechas['fin'];
    
    if (fechaInicio == null || fechaFin == null) {
      return [];
    }
    
    return await db.rawQuery('''
      SELECT 
        ad.fecha,
        ad.estado,
        ad.minutos_retraso,
        ad.observaciones,
        hc.dia_semana,
        hc.hora_inicio,
        hc.hora_fin,
        m.nombre as materia_nombre
      FROM asistencia_diaria ad
      JOIN materias m ON ad.materia_id = m.id
      LEFT JOIN horarios_clases hc ON ad.horario_clase_id = hc.id
      WHERE ad.estudiante_id = ? 
        AND ad.materia_id = ?
        AND ad.fecha BETWEEN ? AND ?
      ORDER BY ad.fecha DESC
    ''', [estudianteId, materiaId, fechaInicio, fechaFin]);
  }

  // 🌟 OBTENER HORARIOS POR ESTUDIANTE
  Future<List<Map<String, Object?>>> obtenerHorariosPorEstudiante(String estudianteId) async {
    final db = await database;
    
    return await db.rawQuery('''
      SELECT 
        hc.*,
        m.nombre as materia_nombre,
        m.codigo as materia_codigo,
        d.nombres || ' ' || d.apellido_paterno as docente_nombre
      FROM horarios_clases hc
      JOIN materias m ON hc.materia_id = m.id
      JOIN docentes d ON hc.docente_id = d.id
      JOIN estudiantes e ON hc.paralelo_id = e.paralelo_id
      WHERE e.id = ? AND hc.activo = 1 AND m.activo = 1
      ORDER BY 
        CASE hc.dia_semana 
          WHEN 'Lunes' THEN 1
          WHEN 'Martes' THEN 2
          WHEN 'Miércoles' THEN 3
          WHEN 'Jueves' THEN 4
          WHEN 'Viernes' THEN 5
          WHEN 'Sábado' THEN 6
          ELSE 7
        END,
        hc.periodo_numero
    ''', [estudianteId]);
  }

  // 🌟 VERIFICAR SI HAY CLASE ACTIVA PARA ESTUDIANTE
  Future<Map<String, dynamic>?> obtenerClaseActiva(String estudianteId) async {
    final db = await database;
    final ahora = DateTime.now();
    final diaSemana = _obtenerDiaSemana(ahora.weekday);
    final horaActual = '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';
    
    final resultados = await db.rawQuery('''
      SELECT 
        hc.*,
        m.nombre as materia_nombre,
        m.id as materia_id
      FROM horarios_clases hc
      JOIN materias m ON hc.materia_id = m.id
      JOIN estudiantes e ON hc.paralelo_id = e.paralelo_id
      WHERE e.id = ? 
        AND hc.dia_semana = ?
        AND hc.activo = 1
        AND ? BETWEEN hc.hora_inicio AND hc.hora_fin
      LIMIT 1
    ''', [estudianteId, diaSemana, horaActual]);
    
    return resultados.isNotEmpty ? {
      'horario': resultados.first,
      'hora_actual': horaActual,
      'dia_actual': diaSemana
    } : null;
  }

  // 🌟 MÉTODO AUXILIAR PARA OBTENER DÍA DE LA SEMANA
  String _obtenerDiaSemana(int weekday) {
    switch (weekday) {
      case 1: return 'Lunes';
      case 2: return 'Martes';
      case 3: return 'Miércoles';
      case 4: return 'Jueves';
      case 5: return 'Viernes';
      case 6: return 'Sábado';
      case 7: return 'Domingo';
      default: return 'Lunes';
    }
  }

  // 🌟 OBTENER ESTADÍSTICAS RÁPIDAS PARA DASHBOARD
  Future<Map<String, dynamic>> obtenerEstadisticasDashboard(String usuarioId, String rol) async {
    final db = await database;
    
    Map<String, dynamic> estadisticas = {
      'rol': rol,
      'fecha_consulta': DateTime.now().toIso8601String()
    };
    
    switch (rol.toLowerCase()) {
      case 'estudiante':
        final estudiante = await obtenerEstudiantePorUsuarioId(usuarioId);
        if (estudiante != null) {
          final estudianteId = estudiante['id'] as String;
          
          // Total asistencias del mes
          final asistenciasMes = await db.rawQuery('''
            SELECT COUNT(*) as total 
            FROM asistencia_diaria 
            WHERE estudiante_id = ? 
              AND strftime('%Y-%m', fecha) = strftime('%Y-%m', 'now')
              AND estado IN ('A', 'T')
          ''', [estudianteId]);
          
          // Clases del día
          final clasesHoy = await db.rawQuery('''
            SELECT COUNT(*) as total
            FROM horarios_clases hc
            JOIN estudiantes e ON hc.paralelo_id = e.paralelo_id
            WHERE e.id = ? AND hc.dia_semana = ? AND hc.activo = 1
          ''', [estudianteId, _obtenerDiaSemana(DateTime.now().weekday)]);
          
          estadisticas['asistencias_mes'] = asistenciasMes.first['total'] ?? 0;
          estadisticas['clases_hoy'] = clasesHoy.first['total'] ?? 0;
          estadisticas['estudiante_id'] = estudianteId;
        }
        break;
        
      case 'docente':
        // Materias asignadas
        final materiasCount = await db.rawQuery('''
          SELECT COUNT(*) as total 
          FROM docente_materia 
          WHERE docente_id = ? AND activo = 1
        ''', [usuarioId]);
        
        // Asistencias por tomar hoy
        final asistenciasHoy = await db.rawQuery('''
          SELECT COUNT(DISTINCT hc.materia_id) as total
          FROM horarios_clases hc
          JOIN docente_materia dm ON hc.materia_id = dm.materia_id AND hc.docente_id = dm.docente_id
          WHERE dm.docente_id = ? AND hc.dia_semana = ? AND hc.activo = 1
        ''', [usuarioId, _obtenerDiaSemana(DateTime.now().weekday)]);
        
        estadisticas['materias_asignadas'] = materiasCount.first['total'] ?? 0;
        estadisticas['clases_hoy'] = asistenciasHoy.first['total'] ?? 0;
        break;
        
      case 'administrador':
        final totalEstudiantes = await db.rawQuery('SELECT COUNT(*) as total FROM estudiantes WHERE activo = 1');
        final totalDocentes = await db.rawQuery('SELECT COUNT(*) as total FROM docentes WHERE estado = "ACTIVO"');
        final totalMaterias = await db.rawQuery('SELECT COUNT(*) as total FROM materias WHERE activo = 1');
        
        estadisticas['total_estudiantes'] = totalEstudiantes.first['total'] ?? 0;
        estadisticas['total_docentes'] = totalDocentes.first['total'] ?? 0;
        estadisticas['total_materias'] = totalMaterias.first['total'] ?? 0;
        break;
    }
    
    return estadisticas;
  }

  // =================================================================
  // 🆕 MÉTODOS COMPLETOS PARA HUELLAS BIOMÉTRICAS CON ESP32
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

  // 🌟 VERIFICAR SI USUARIO PUEDE REGISTRAR HUELLAS (SOLO ESTUDIANTES)
  Future<bool> usuarioPuedeRegistrarHuellas(String usuarioId) async {
    final db = await database;
    
    final usuario = await db.query(
      'usuarios',
      where: 'id = ? AND esta_activo = 1',
      whereArgs: [usuarioId],
      columns: ['role']
    );
    
    if (usuario.isEmpty) return false;
    
    final role = usuario.first['role'] as String?;
    
    // ✅ SOLO estudiantes pueden registrar huellas
    return role?.toLowerCase() == 'estudiante';
  }

  // 🌟 OBTENER ESTUDIANTE_ID DESDE USUARIO_ID
  Future<String?> obtenerEstudianteIdDesdeUsuario(String usuarioId) async {
    final db = await database;
    
    final resultado = await db.rawQuery('''
      SELECT eu.estudiante_id 
      FROM estudiante_usuario eu
      JOIN usuarios u ON eu.usuario_id = u.id
      WHERE u.id = ? AND u.esta_activo = 1
    ''', [usuarioId]);
    
    return resultado.isNotEmpty ? resultado.first['estudiante_id'] as String? : null;
  }

  // 🌟 REGISTRAR HUELLA CON VALIDACIONES DE SEGURIDAD
  Future<Map<String, dynamic>> registrarHuellaEstudiante({
    required String usuarioId,
    required int numeroDedo,
    required String templateData,
    required String dispositivo, // 'MOVIL' o 'ESP32'
  }) async {
    final db = await database;
    
    // 1. VERIFICAR QUE EL USUARIO PUEDE REGISTRAR HUELLAS
    final puedeRegistrar = await usuarioPuedeRegistrarHuellas(usuarioId);
    if (!puedeRegistrar) {
      throw Exception('Solo los estudiantes pueden registrar huellas biométricas');
    }
    
    // 2. OBTENER ESTUDIANTE_ID
    final estudianteId = await obtenerEstudianteIdDesdeUsuario(usuarioId);
    if (estudianteId == null) {
      throw Exception('No se encontró estudiante asociado a este usuario');
    }
    
    // 3. VERIFICAR SI YA TIENE HUELLA REGISTRADA EN ESTE DEDO
    final huellaExistente = await obtenerHuellaPorDedo(estudianteId, numeroDedo);
    if (huellaExistente != null && (huellaExistente['registrada'] as int?) == 1) {
      throw Exception('Ya existe una huella registrada para este dedo');
    }
    
    // 4. NOMBRES DE DEDOS
    final nombresDedos = {
      1: 'Pulgar Derecho', 2: 'Índice Derecho', 3: 'Medio Derecho', 
      4: 'Anular Derecho', 5: 'Meñique Derecho',
      6: 'Pulgar Izquierdo', 7: 'Índice Izquierdo', 8: 'Medio Izquierdo',
      9: 'Anular Izquierdo', 10: 'Meñique Izquierdo'
    };
    
    final nombreDedo = nombresDedos[numeroDedo] ?? 'Dedo $numeroDedo';
    final iconos = {
      1: '👍', 2: '👆', 3: '✌️', 4: '🖖', 5: '🤘',
      6: '👍', 7: '👆', 8: '✌️', 9: '🖖', 10: '🤘'
    };
    
    // 5. INSERTAR O ACTUALIZAR HUELLA
    final ahora = DateTime.now().toIso8601String();
    final huellaData = {
      'id': 'huella_${estudianteId}_$numeroDedo',
      'estudiante_id': estudianteId,
      'numero_dedo': numeroDedo,
      'nombre_dedo': nombreDedo,
      'icono': iconos[numeroDedo],
      'registrada': 1,
      'template_data': templateData,
      'fecha_registro': ahora,
      'dispositivo_registro': dispositivo,
    };
    
    int resultado;
    if (huellaExistente != null) {
      // Actualizar huella existente
      resultado = await db.update(
        'huellas_biometricas',
        huellaData,
        where: 'id = ?',
        whereArgs: [huellaExistente['id']]
      );
    } else {
      // Insertar nueva huella
      resultado = await db.insert('huellas_biometricas', huellaData);
    }
    
    // 6. ACTUALIZAR CONTADOR EN ESTUDIANTE
    await db.update(
      'estudiantes',
      {
        'huellas_registradas': await obtenerTotalHuellasRegistradas(estudianteId),
        'fecha_actualizacion': ahora
      },
      where: 'id = ?',
      whereArgs: [estudianteId]
    );
    
    return {
      'success': true,
      'estudiante_id': estudianteId,
      'huella_id': huellaData['id'],
      'mensaje': 'Huella registrada exitosamente ($nombreDedo) desde $dispositivo',
      'resultado': resultado
    };
  }

  // 🌟 MARCAR ASISTENCIA CON VALIDACIÓN DE HUELLA
  Future<Map<String, dynamic>> marcarAsistenciaConHuella({
    required String templateData,
    required String materiaId,
    required int periodoNumero,
    required String dispositivo, // 'MOVIL' o 'ESP32'
  }) async {
    final db = await database;
    
    try {
      // 1. BUSCAR ESTUDIANTE POR HUELLA
      final estudianteConHuella = await db.rawQuery('''
        SELECT hb.estudiante_id, e.nombres, e.apellido_paterno, e.apellido_materno
        FROM huellas_biometricas hb
        JOIN estudiantes e ON hb.estudiante_id = e.id
        WHERE hb.template_data = ? AND hb.registrada = 1 AND e.activo = 1
      ''', [templateData]);
      
      if (estudianteConHuella.isEmpty) {
        return {
          'success': false,
          'error': 'Huella no reconocida o estudiante no encontrado'
        };
      }
      
      final estudiante = estudianteConHuella.first;
      final estudianteId = estudiante['estudiante_id'] as String;
      final nombreCompleto = '${estudiante['nombres']} ${estudiante['apellido_paterno']} ${estudiante['apellido_materno']}';
      
      // 2. VERIFICAR SI YA TIENE ASISTENCIA REGISTRADA HOY
      final fechaHoy = DateTime.now().toIso8601String().split('T')[0];
      final asistenciaExistente = await existeAsistenciaRegistrada(
        estudianteId, materiaId, fechaHoy, periodoNumero
      );
      
      if (asistenciaExistente) {
        return {
          'success': false,
          'error': 'Ya tienes asistencia registrada para esta clase hoy'
        };
      }
      
      // 3. REGISTRAR ASISTENCIA
      final resultado = await registrarAsistenciaBiometrica(
        estudianteId: estudianteId,
        materiaId: materiaId,
        fecha: fechaHoy,
        periodoNumero: periodoNumero,
        usuarioRegistro: 'sistema_biometrico',
        minutosRetraso: 0,
        observaciones: 'Asistencia biométrica - $dispositivo'
      );
      
      return {
        'success': true,
        'estudiante_id': estudianteId,
        'nombre_estudiante': nombreCompleto,
        'materia_id': materiaId,
        'fecha': fechaHoy,
        'periodo_numero': periodoNumero,
        'dispositivo': dispositivo,
        'mensaje': 'Asistencia registrada exitosamente',
        'resultado': resultado
      };
      
    } catch (e) {
      return {
        'success': false,
        'error': 'Error al registrar asistencia: $e'
      };
    }
  }

  // 🌟 OBTENER ESTUDIANTES SIN HUELLAS REGISTRADAS
  Future<List<Map<String, Object?>>> obtenerEstudiantesSinHuellas() async {
    final db = await database;
    
    return await db.rawQuery('''
      SELECT e.*, u.username, u.email
      FROM estudiantes e
      JOIN estudiante_usuario eu ON e.id = eu.estudiante_id
      JOIN usuarios u ON eu.usuario_id = u.id
      WHERE e.activo = 1 AND e.huellas_registradas = 0
      ORDER BY e.apellido_paterno, e.apellido_materno, e.nombres
    ''');
  }

  // 🌟 OBTENER ESTADÍSTICAS DE HUELLAS
  Future<Map<String, dynamic>> obtenerEstadisticasHuellas() async {
    final db = await database;
    
    final totalEstudiantes = await db.rawQuery(
      'SELECT COUNT(*) as total FROM estudiantes WHERE activo = 1'
    );
    final estudiantesConHuellas = await db.rawQuery('''
      SELECT COUNT(DISTINCT estudiante_id) as total 
      FROM huellas_biometricas 
      WHERE registrada = 1
    ''');
    final totalHuellas = await db.rawQuery('''
      SELECT COUNT(*) as total 
      FROM huellas_biometricas 
      WHERE registrada = 1
    ''');
    final porDispositivo = await db.rawQuery('''
      SELECT dispositivo_registro, COUNT(*) as total
      FROM huellas_biometricas
      WHERE registrada = 1
      GROUP BY dispositivo_registro
    ''');
    
    final totalEst = (totalEstudiantes.first['total'] as int?) ?? 0;
    final conHuellas = (estudiantesConHuellas.first['total'] as int?) ?? 0;
    
    return {
      'total_estudiantes': totalEst,
      'estudiantes_con_huellas': conHuellas,
      'total_huellas_registradas': (totalHuellas.first['total'] as int?) ?? 0,
      'registros_por_dispositivo': porDispositivo,
      'porcentaje_cobertura': totalEst != 0 
          ? ((conHuellas / totalEst) * 100).toStringAsFixed(1)
          : '0.0'
    };
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
      notaData['id'] = 'nota_${estudianteId}_${materiaId}_${periodoId}_${bimestreId}';
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

  // 🆕 EXPORTAR DATOS PARA MIGRACIÓN - CORREGIDO
  Future<Map<String, dynamic>> exportarDatosParaMigracion() async {
    final db = await database;
    
    final datosExportacion = {
      'fecha_exportacion': DateTime.now().toIso8601String(),
      'version_sistema': '1.0.0',
      'datos': <String, dynamic>{} // Inicializado como mapa vacío
    };
    
    final tablasExportacion = ['estudiantes', 'docentes', 'materias', 'usuarios', 'config_notas_asistencia'];
    
    // ✅ CORRECCIÓN: Cast explícito a Map<String, dynamic>
    final datosMap = datosExportacion['datos'] as Map<String, dynamic>;
    
    for (String tabla in tablasExportacion) {
      final datos = await db.rawQuery('SELECT * FROM $tabla');
      datosMap[tabla] = datos;
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
      (horario['fecha_creacion'] is DateTime 
        ? horario['fecha_creacion'].toIso8601String()
        : DateTime.now().toIso8601String()),
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