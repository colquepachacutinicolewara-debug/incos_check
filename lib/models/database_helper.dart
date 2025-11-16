// models/database_helper.dart - VERSIÓN COMPLETA CON SOLO CAMBIOS DPS → NOTAS_ASISTENCIA
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_live/sqflite_live.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
          version: 4, // ✅ INCREMENTADO A VERSIÓN 4 PARA NUEVAS TABLAS
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
      version: 4, // ✅ INCREMENTADO A VERSIÓN 4
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
  }

  // PRIMERA CREACIÓN
  Future<void> _createDB(Database db, int version) async {
    print('🏗️ Creando base de datos por primera vez...');
    await _runDDL(db);
    await _migrarTablaUsuarios(db); // ✅ Agregar migración
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

  // ====== DDL CENTRAL ACTUALIZADO CON NUEVAS TABLAS ======
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

    // 🆕 ALTA PRIORIDAD: TABLA DOCENTE_MATERIA
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

    // 🆕 CORREGIDO: TABLA CONFIG_NOTAS_ASISTENCIA (NO DPS)
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

    // 🆕 CORREGIDO: TABLA NOTAS_ASISTENCIA (SIN DPS)
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

    // ✅ TABLA HUELLAS_BIOMETRICAS CORREGIDA (template_data como TEXT)
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

    // ✅ TABLA USUARIOS CORREGIDA (coma agregada)
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
        last_updated TEXT NOT NULL
      );
    ''');

    // ✅ AGREGAR ÍNDICES DE OPTIMIZACIÓN AL FINAL
    await _createIndexes(db);

    // 🆕 MÉTODO PARA AGREGAR COLUMNA VALUE A CONFIGURACIONES
Future<void> _migrarTablaConfiguraciones(Database db) async {
  try {
    final tableInfo = await db.rawQuery('PRAGMA table_info(configuraciones)');
    final columnas = tableInfo.map((col) => col['name'] as String).toList();
    
    if (!columnas.contains('value')) {
      print('🔄 Agregando columna value a tabla configuraciones...');
      await db.execute('''
        ALTER TABLE configuraciones ADD COLUMN value TEXT
      ''');
      print('✅ Columna value agregada a configuraciones');
    } else {
      print('✅ Columna value ya existe en configuraciones');
    }
  } catch (e) {
    print('⚠️ Error migrando tabla configuraciones: $e');
  }
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

    print('✅ Índices de optimización creados exitosamente');
  }

  // 🌱 SEED ACTUALIZADO CON DATOS NOTAS_ASISTENCIA
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
      await db.insert('carreras', {
        'id': 'electronica',
        'nombre': 'Electrónica',
        'color': '#6A1B9A',
        'icon_code_point': 57693,
        'activa': 1,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String()
      });
      await db.insert('carreras', {
        'id': 'mecanica',
        'nombre': 'Mecánica Automotriz',
        'color': '#C62828',
        'icon_code_point': 58125,
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
      await db.insert('turnos', {
        'id': 'turno_tarde',
        'nombre': 'Tarde',
        'icon_code_point': 59658,
        'horario': '12:30 - 18:30',
        'rango_asistencia': '12:00-18:00',
        'dias': 'Lunes a Viernes',
        'color': '#1976D2',
        'activo': 1,
        'niveles': '["Todos"]',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String()
      });
      await db.insert('turnos', {
        'id': 'turno_noche',
        'nombre': 'Noche',
        'icon_code_point': 57539,
        'horario': '18:30 - 22:30',
        'rango_asistencia': '18:00-22:00',
        'dias': 'Lunes a Viernes',
        'color': '#7B1FA2',
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
      await db.insert('niveles', {
        'id': 'nivel_inicial',
        'nombre': 'Inicial',
        'activo': 1,
        'orden': 2,
        'paralelos': '["A", "B"]',
        'fecha_creacion': DateTime.now().toIso8601String()
      });
      await db.insert('niveles', {
        'id': 'nivel_primaria',
        'nombre': 'Primaria',
        'activo': 1,
        'orden': 3,
        'paralelos': '["A", "B", "C", "D"]',
        'fecha_creacion': DateTime.now().toIso8601String()
      });
      print('✅ Niveles insertados');
    }

    // Insertar paralelos si no existen
    final paralelosCount = await db.rawQuery('SELECT COUNT(*) AS c FROM paralelos');
    if ((paralelosCount.first['c'] as int?) == 0) {
      await db.insert('paralelos', {
        'id': 'paralelo_a',
        'nombre': 'A',
        'activo': 1,
        'estudiantes': '[]',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String()
      });
      await db.insert('paralelos', {
        'id': 'paralelo_b',
        'nombre': 'B',
        'activo': 1,
        'estudiantes': '[]',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String()
      });
      await db.insert('paralelos', {
        'id': 'paralelo_c',
        'nombre': 'C',
        'activo': 1,
        'estudiantes': '[]',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String()
      });
      await db.insert('paralelos', {
        'id': 'paralelo_d',
        'nombre': 'D',
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
        'anio': 1,
        'color': '#1565C0',
        'activo': 1,
        'paralelo': 'B',
        'turno': 'Mañana',
        'created_at': now,
        'updated_at': now
      });
      await db.insert('materias', {
        'id': 'mat_basedatos',
        'codigo': 'BD201',
        'nombre': 'Base de Datos',
        'carrera': 'info',
        'anio': 2,
        'color': '#2E7D32',
        'activo': 1,
        'paralelo': 'A',
        'turno': 'Tarde',
        'created_at': now,
        'updated_at': now
      });
      print('✅ Materias de ejemplo insertadas');
    }

    // ✅ Insertar usuario admin CORREGIDO con updated_at
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
        'updated_at': now  // ✅ AGREGADO
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
        'updated_at': now  // ✅ AGREGADO
      });
      print('✅ Usuarios insertados con updated_at');
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

    // 🆕 CORREGIDO: Insertar CONFIGURACIÓN DE NOTAS DE ASISTENCIA por defecto
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

    // 🆕 ALTA PRIORIDAD: Insertar relación docente-materia de ejemplo
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
        'last_updated': DateTime.now().toIso8601String()
      });
      print('✅ Configuración insertada');
    }
    
    print('🎉 Seed completado exitosamente');
  }

  // 🆕 MÉTODOS DE MIGRACIÓN PARA NUEVAS TABLAS
  Future<void> _crearTablasNotasAsistenciaYDocentemateria(Database db) async {
    try {
      print('🔄 Creando tablas notas asistencia y docente_materia...');
      
      // Tabla docente_materia
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

      // 🆕 CORREGIDO: Tabla config_notas_asistencia (NO DPS)
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

      // 🆕 CORREGIDO: Tabla notas_asistencia (SIN DPS)
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
      
      // Verificar si los campos ya existen
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
      // Verificar si existe la columna updated_at
      final tableInfo = await db.rawQuery('PRAGMA table_info(usuarios)');
      final tieneUpdatedAt = tableInfo.any((col) => col['name'] == 'updated_at');
      
      if (!tieneUpdatedAt) {
        print('🔄 Agregando columna updated_at a tabla usuarios...');
        await db.execute('''
          ALTER TABLE usuarios ADD COLUMN updated_at TEXT
        ''');
        
        // Actualizar registros existentes con fecha actual
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
      // Verificar si existe la tabla huellas_biometricas
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='huellas_biometricas'"
      );
      
      if (tables.isNotEmpty) {
        // Verificar estructura de la tabla
        final tableInfo = await db.rawQuery('PRAGMA table_info(huellas_biometricas)');
        final columnas = tableInfo.map((col) => col['name'] as String).toList();
        
        print('📋 Estructura actual de huellas_biometricas: $columnas');
        
        // Si template_data es BLOB, migrar a TEXT
        if (columnas.contains('template_data')) {
          final columnaTemplate = tableInfo.firstWhere(
            (col) => col['name'] == 'template_data',
            orElse: () => {}
          );
          
          if (columnaTemplate.isNotEmpty && columnaTemplate['type'] == 'BLOB') {
            print('🔄 Migrando template_data de BLOB a TEXT...');
            
            // Crear tabla temporal
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
            
            // Copiar datos
            await db.execute('''
              INSERT INTO huellas_biometricas_temp 
              SELECT * FROM huellas_biometricas
            ''');
            
            // Eliminar tabla original
            await db.execute('DROP TABLE huellas_biometricas');
            
            // Renombrar tabla temporal
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

  // ✅ MÉTODO DEFINITIVO ROBUSTO PARA ACTUALIZAR CONTRASEÑA
  Future<int> actualizarPassword(String userId, String nuevaPassword) async {
    final db = await database;
    
    try {
      print('🔄 Actualizando contraseña para usuario: $userId');
      print('🔑 Nueva contraseña: $nuevaPassword');
      
      // Obtener estructura de la tabla para debugging
      final tableInfo = await db.rawQuery('PRAGMA table_info(usuarios)');
      final columnas = tableInfo.map((col) => col['name'] as String).toList();
      print('📋 Columnas disponibles en tabla usuarios: $columnas');
      
      // Preparar datos para actualizar
      Map<String, dynamic> updateData = {'password': nuevaPassword};
      
      // Agregar campo de timestamp según lo disponible
      if (columnas.contains('fecha_actualizacion')) {
        updateData['fecha_actualizacion'] = DateTime.now().toIso8601String();
      } 
      if (columnas.contains('updated_at')) {
        updateData['updated_at'] = DateTime.now().toIso8601String();
      }
      
      print('📦 Datos a actualizar: $updateData');
      
      final resultado = await db.update(
        'usuarios',
        updateData,
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      print('✅ Resultado de actualización: $resultado filas afectadas');
      
      if (resultado > 0) {
        // Verificar la actualización
        final usuarioActualizado = await db.query(
          'usuarios',
          where: 'id = ?',
          whereArgs: [userId],
        );
        
        if (usuarioActualizado.isNotEmpty) {
          final usuario = usuarioActualizado.first;
          print('🎉 Usuario actualizado exitosamente:');
          print('   - Username: ${usuario['username']}');
          print('   - Nuevo password: ${usuario['password']}');
          if (usuario['updated_at'] != null) {
            print('   - Updated at: ${usuario['updated_at']}');
          }
          if (usuario['fecha_actualizacion'] != null) {
            print('   - Fecha actualización: ${usuario['fecha_actualizacion']}');
          }
        }
      }
      
      return resultado;
      
    } catch (e) {
      print('❌ Error en actualizarPassword: $e');
      
      // Fallback: intentar solo con password si hay error
      try {
        print('🔄 Intentando actualización solo con password (fallback)...');
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
        print('   - Password en BD: ${usuario['password']}');
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

  // 🌟 MÉTODOS ESPECÍFICOS PARA HUELLAS BIOMÉTRICAS
  Future<int> insertarHuellaBiometrica(Map<String, dynamic> huella) async {
    final db = await database;
    return await db.insert('huellas_biometricas', huella);
  }

  Future<List<Map<String, Object?>>> obtenerHuellasPorEstudiante(String estudianteId) async {
    final db = await database;
    return await db.query(
      'huellas_biometricas',
      where: 'estudiante_id = ?',
      whereArgs: [estudianteId],
      orderBy: 'numero_dedo ASC'
    );
  }

  Future<int> eliminarHuellaBiometrica(String huellaId) async {
    final db = await database;
    return await db.delete(
      'huellas_biometricas',
      where: 'id = ?',
      whereArgs: [huellaId]
    );
  }

  Future<Map<String, Object?>?> obtenerHuellaPorDedo(String estudianteId, int numeroDedo) async {
    final db = await database;
    final results = await db.query(
      'huellas_biometricas',
      where: 'estudiante_id = ? AND numero_dedo = ?',
      whereArgs: [estudianteId, numeroDedo]
    );
    return results.isNotEmpty ? results.first : null;
  }

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

  // 🆕 MÉTODOS ESPECÍFICOS PARA NOTAS DE ASISTENCIA (SIN DPS)
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

  // 🆕 CORREGIDO: MÉTODO PARA CALCULAR NOTA DE ASISTENCIA BIMESTRAL
  Future<int> calcularNotaAsistencia(String estudianteId, String materiaId, String periodoId, String bimestreId) async {
    final db = await database;
    
    // Obtener configuración de notas de asistencia activa
    final configs = await db.query('config_notas_asistencia', where: 'activo = 1', limit: 1);
    if (configs.isEmpty) {
      throw Exception('No hay configuración de notas de asistencia activa');
    }
    
    final config = configs.first;
    final configId = config['id'] as String;
    final puntajeMaximo = config['puntaje_maximo'] as double? ?? 10.0;
    
    // Calcular asistencia del bimestre
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
    
    // Calcular nota sobre 10 puntos
    double notaCalculada = (porcentajeAsistencia / 100) * puntajeMaximo;
    
    // Insertar o actualizar nota
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
  // 🆕 MÉTODOS ESPECÍFICOS PARA HORARIOS (Extraídos de HorarioViewModel)
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
  // 🆕 MÉTODOS ESPECÍFICOS PARA NOTAS (Extraídos de NotasViewModel)
  // =================================================================

  Future<String?> obtenerPeriodoActivo() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT id FROM periodos_academicos WHERE estado = 'ACTIVO' LIMIT 1
    ''');
    return result.isNotEmpty ? result.first['id']?.toString() : null;
  }

  Future<List<Map<String, Object?>>> obtenerConfiguracionNotasActiva() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM config_notas_asistencia 
      WHERE activo = 1 LIMIT 1
    ''');
  }

  Future<List<Map<String, Object?>>> obtenerTodasLasNotas() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM notas_asistencia 
      ORDER BY bimestre_id, estudiante_id
    ''');
  }

  // ✅ CORREGIDO: MÉTODO obtenerFechasBimestre CON LA BARRA INVERTIDA
  Future<Map<String, String>?> obtenerFechasBimestre(String bimestreId) async {
    final db = await database;
    final bimestreInfo = await db.rawQuery(
      ''' 
        SELECT 
          CAST(json_extract(fechas, '\$.inicio') AS TEXT) as inicio, 
          CAST(json_extract(fechas, '\$.fin') AS TEXT) as fin
        FROM bimestres 
        WHERE id = ?
      ''', 
      [bimestreId]
    );

    if (bimestreInfo.isEmpty) return null;
    
    final inicio = bimestreInfo.first['inicio'];
    final fin = bimestreInfo.first['fin'];

    if (inicio == null || fin == null) return null;

    return {
      'inicio': inicio.toString(),
      'fin': fin.toString(),
    };
  }

  Future<List<Map<String, Object?>>> obtenerEstudiantesActivos() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT id FROM estudiantes WHERE activo = 1
    ''');
  }

  Future<int> obtenerTotalHorasProgramadas(String fechaInicio, String fechaFin) async {
    final db = await database;
    final horariosBimestre = await db.rawQuery('''
      SELECT COUNT(DISTINCT id) as total_horas
      FROM horarios_clases hc
      WHERE hc.fecha_creacion BETWEEN ? AND ? 
      AND hc.activo = 1
    ''', [fechaInicio, fechaFin]);
    return (horariosBimestre.first['total_horas'] as int?) ?? 0;
  }

  Future<List<Map<String, Object?>>> obtenerAsistenciasEstudianteEnRango(
    String estudianteId, String fechaInicio, String fechaFin) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT estado, COUNT(*) as cantidad
      FROM asistencia_diaria ad
      WHERE ad.estudiante_id = ? 
      AND ad.fecha BETWEEN ? AND ?
      GROUP BY estado
    ''', [estudianteId, fechaInicio, fechaFin]);
  }

  Future<int> guardarNotaAsistencia(Map<String, dynamic> notaData) async {
    final db = await database;
    
    // Verificar si ya existe
    final existe = await db.rawQuery('''
      SELECT COUNT(*) as count FROM notas_asistencia 
      WHERE id = ?
    ''', [notaData['id']]);

    final count = (existe.first['count'] as int?) ?? 0;

    if (count > 0) {
      // Actualizar
      return await db.rawUpdate('''
        UPDATE notas_asistencia SET 
          total_horas_programadas = ?, horas_asistidas = ?, horas_retraso = ?, horas_falta = ?,
          porcentaje_asistencia = ?, nota_final = ?, estado = ?, fecha_calculo = ?
        WHERE id = ?
      ''', [
        notaData['total_horas_programadas'],
        notaData['horas_asistidas'],
        notaData['horas_retraso'],
        notaData['horas_falta'],
        notaData['porcentaje_asistencia'],
        notaData['nota_final'],
        notaData['estado'],
        notaData['fecha_calculo'].toIso8601String(),
        notaData['id'],
      ]);
    } else {
      // Insertar nueva
      return await db.rawInsert('''
        INSERT INTO notas_asistencia (
          id, estudiante_id, materia_id, periodo_id, bimestre_id,
          total_horas_programadas, horas_asistidas, horas_retraso, horas_falta,
          porcentaje_asistencia, nota_final, estado, fecha_calculo
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        notaData['id'],
        notaData['estudiante_id'],
        notaData['materia_id'],
        notaData['periodo_id'],
        notaData['bimestre_id'],
        notaData['total_horas_programadas'],
        notaData['horas_asistidas'],
        notaData['horas_retraso'],
        notaData['horas_falta'],
        notaData['porcentaje_asistencia'],
        notaData['nota_final'],
        notaData['estado'],
        notaData['fecha_calculo'].toIso8601String(),
      ]);
    }
  }

  // =================================================================
  // 🆕 MÉTODOS ESPECÍFICOS PARA CONFIGURACIÓN (Extraídos de ConfigViewModel)
  // =================================================================

  Future<List<Map<String, Object?>>> obtenerConfiguracionActiva() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM config_notas_asistencia 
      WHERE activo = 1 
      ORDER BY fecha_actualizacion DESC 
      LIMIT 1
    ''');
  }

  Future<bool> existeConfiguracionConNombre(String nombre, [String? excludeId]) async {
    final db = await database;
    final existe = await db.rawQuery('''
      SELECT COUNT(*) as count FROM config_notas_asistencia 
      WHERE nombre = ? ${excludeId != null ? 'AND id != ?' : ''}
    ''', excludeId != null ? [nombre, excludeId] : [nombre]);
    return ((existe.first['count'] as int?) ?? 0) > 0;
  }

  Future<int> desactivarTodasLasConfiguraciones() async {
    final db = await database;
    return await db.rawUpdate('''
      UPDATE config_notas_asistencia SET activo = 0
      WHERE activo = 1
    ''', []);
  }

  Future<int> insertarConfiguracion(Map<String, dynamic> config) async {
    final db = await database;
    return await db.rawInsert('''
      INSERT INTO config_notas_asistencia (
        id, nombre, puntaje_total, reglas_calculo, activo, 
        fecha_creacion, fecha_actualizacion
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', [
      config['id'],
      config['nombre'],
      config['puntaje_total'],
      config['reglas_calculo'],
      config['activo'] ? 1 : 0,
      config['fecha_creacion'].toIso8601String(),
      config['fecha_actualizacion'].toIso8601String(),
    ]);
  }

  // =================================================================
  // 🆕 MÉTODOS ESPECÍFICOS PARA ASISTENCIA DIARIA (Extraídos de AsistenciaDiariaViewModel)
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
}
