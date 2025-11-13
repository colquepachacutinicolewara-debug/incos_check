// models/database_helper.dart
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
          version: 2,
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
      version: 2,
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

  // Manejar upgrades de la base de datos
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
  }

  // PRIMERA CREACIÓN
  Future<void> _createDB(Database db, int version) async {
    print('🏗️ Creando base de datos por primera vez...');
    await _runDDL(db);
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

  // ====== DDL CENTRAL (IDEMPOTENTE) ======
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

    // Tabla detalle_asistencias
    await db.execute('''
      CREATE TABLE IF NOT EXISTS detalle_asistencias(
        id TEXT PRIMARY KEY,
        asistencia_id TEXT NOT NULL,
        dia TEXT NOT NULL,
        porcentaje INTEGER DEFAULT 0,
        estado TEXT DEFAULT 'A',
        fecha TEXT NOT NULL,
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

    // Tabla huellas_biometricas
    await db.execute('''
      CREATE TABLE IF NOT EXISTS huellas_biometricas(
        id TEXT PRIMARY KEY,
        estudiante_id TEXT NOT NULL,
        numero_dedo INTEGER NOT NULL,
        nombre_dedo TEXT NOT NULL,
        icono TEXT,
        registrada INTEGER DEFAULT 0,
        template_data BLOB,
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

    // Tabla usuarios - ACTUALIZADA CON CAMPO PASSWORD
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
        fecha_registro TEXT NOT NULL
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
  }

  // ====== ÍNDICES PARA OPTIMIZACIÓN ======
  Future<void> _createIndexes(Database db) async {
    print('🚀 Creando índices de optimización...');
    
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

    print('✅ Índices de optimización creados exitosamente');
  }

  // SEED BÁSICO
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

    // Insertar usuario admin si no existe - ACTUALIZADO CON PASSWORD
    final usuariosCount = await db.rawQuery('SELECT COUNT(*) AS c FROM usuarios');
    if ((usuariosCount.first['c'] as int?) == 0) {
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
        'fecha_registro': DateTime.now().toIso8601String()
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
        'fecha_registro': DateTime.now().toIso8601String()
      });
      print('✅ Usuarios insertados');
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

  // MÉTODO ESPECÍFICO PARA VERIFICAR CREDENCIALES DE USUARIO
  Future<Map<String, Object?>?> verificarCredenciales(String username, String password) async {
    final db = await database;
    final results = await db.query(
      'usuarios',
      where: 'username = ? AND password = ? AND esta_activo = 1',
      whereArgs: [username, password],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // MÉTODO PARA ACTUALIZAR CONTRASEÑA
  Future<int> actualizarPassword(String userId, String nuevaPassword) async {
    final db = await database;
    return await db.update(
      'usuarios',
      {
        'password': nuevaPassword,
        'fecha_actualizacion': DateTime.now().toIso8601String()
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
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
}