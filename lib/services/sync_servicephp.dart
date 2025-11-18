// services/sync_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';
import '../models/database_helper.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  // Sincronizar todos los datos pendientes
  Future<Map<String, dynamic>> syncAllData() async {
    try {
      // Obtener últimos timestamps de sincronización
      final lastSync = await _getLastSyncTimestamps();
      
      // Sincronizar cada tabla
      final tables = [
        'estudiantes', 'docentes', 'materias', 'asistencias', 
        'detalle_asistencias', 'notas_asistencia', 'huellas_biometricas'
      ];
      
      for (final table in tables) {
        final changesResult = await ApiService.getChangesSince(
          table, 
          lastSync[table] ?? '1970-01-01 00:00:00'
        );
        
        if (changesResult['success'] == true && changesResult['changes'] is List) {
          final List<dynamic> changes = changesResult['changes'];
          for (final change in changes) {
            // Convertir a Map<String, dynamic>
            final changeMap = Map<String, dynamic>.from(change as Map);
            // Aplicar cambios localmente
            await _applyChangeLocally(table, changeMap);
          }
          
          // Guardar nuevo timestamp
          if (changes.isNotEmpty) {
            await _saveLastSyncTimestamp(table, DateTime.now().toString());
          }
        }
      }
      
      // Sincronizar datos locales al servidor
      await _syncLocalChangesToServer();
      
      return {'success': true, 'message': 'Sincronización completada'};
    } catch (e) {
      return {'success': false, 'error': 'Error en sincronización: $e'};
    }
  }
  
  // Aplicar cambio localmente
  Future<void> _applyChangeLocally(String table, Map<String, dynamic> data) async {
    final db = await _dbHelper.database;
    
    try {
      // Verificar si el registro ya existe
      final existing = await db.query(
        table,
        where: 'id = ?',
        whereArgs: [data['id']],
      );
      
      if (existing.isNotEmpty) {
        // Actualizar
        await db.update(
          table,
          data,
          where: 'id = ?',
          whereArgs: [data['id']],
        );
        print('✅ Actualizado en $table: ${data['id']}');
      } else {
        // Insertar
        await db.insert(table, data);
        print('✅ Insertado en $table: ${data['id']}');
      }
    } catch (e) {
      print('❌ Error aplicando cambio localmente en $table: $e');
    }
  }
  
  // Sincronizar cambios locales al servidor
  Future<void> _syncLocalChangesToServer() async {
    final db = await _dbHelper.database;
    
    try {
      // Verificar si existe la tabla de sincronización pendiente
      final tableExists = await _checkTableExists(db, 'sincronizacion_pendiente');
      
      if (!tableExists) {
        print('⚠️ Tabla sincronizacion_pendiente no existe, creándola...');
        await _createSyncPendingTable(db);
        return;
      }
      
      final localChanges = await db.rawQuery('''
        SELECT * FROM sincronizacion_pendiente 
        WHERE sincronizado = 0 
        ORDER BY fecha_creacion
      ''');
      
      if (localChanges.isNotEmpty) {
        final List<Map<String, dynamic>> batch = [];
        
        for (final change in localChanges) {
          final datosStr = change['datos'] as String?;
          if (datosStr != null) {
            try {
              final datosMap = jsonDecode(datosStr) as Map<String, dynamic>;
              batch.add({
                'table': change['tabla_origen'] as String,
                'operation': 'INSERT',
                'data': datosMap,
              });
            } catch (e) {
              print('❌ Error decodificando datos: $e');
            }
          }
        }
        
        if (batch.isNotEmpty) {
          final result = await ApiService.syncBatch(batch);
          
          if (result['success'] == true) {
            // Marcar como sincronizado
            await db.rawUpdate('''
              UPDATE sincronizacion_pendiente 
              SET sincronizado = 1 
              WHERE sincronizado = 0
            ''');
            print('✅ ${batch.length} cambios sincronizados al servidor');
          } else {
            print('❌ Error sincronizando batch: ${result['error']}');
          }
        }
      }
    } catch (e) {
      print('❌ Error en _syncLocalChangesToServer: $e');
    }
  }
  
  // Verificar si una tabla existe
  Future<bool> _checkTableExists(Database db, String tableName) async {
    try {
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName]
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Crear tabla de sincronización pendiente si no existe
  Future<void> _createSyncPendingTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sincronizacion_pendiente(
        id TEXT PRIMARY KEY,
        tabla_origen TEXT NOT NULL,
        id_registro TEXT NOT NULL,
        datos TEXT NOT NULL,
        intentos INTEGER DEFAULT 0,
        fecha_creacion TEXT NOT NULL,
        sincronizado INTEGER DEFAULT 0
      )
    ''');
    
    // Crear índice para optimización
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sincronizacion_pendiente 
      ON sincronizacion_pendiente(sincronizado, fecha_creacion)
    ''');
    
    print('✅ Tabla sincronizacion_pendiente creada');
  }
  
  // Agregar cambio a la cola de sincronización
  Future<void> addToSyncQueue(
    String table, 
    String recordId, 
    Map<String, dynamic> data
  ) async {
    final db = await _dbHelper.database;
    
    try {
      // Verificar si existe la tabla
      final tableExists = await _checkTableExists(db, 'sincronizacion_pendiente');
      if (!tableExists) {
        await _createSyncPendingTable(db);
      }
      
      await db.insert('sincronizacion_pendiente', {
        'id': 'sync_${DateTime.now().millisecondsSinceEpoch}',
        'tabla_origen': table,
        'id_registro': recordId,
        'datos': jsonEncode(data),
        'fecha_creacion': DateTime.now().toIso8601String(),
        'sincronizado': 0,
        'intentos': 0,
      });
      
      print('✅ Agregado a cola de sincronización: $table - $recordId');
    } catch (e) {
      print('❌ Error agregando a cola de sincronización: $e');
    }
  }
  
  // Obtener últimos timestamps de sincronización
  Future<Map<String, String>> _getLastSyncTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = <String, String>{};
    
    final tables = [
      'estudiantes', 'docentes', 'materias', 'asistencias',
      'detalle_asistencias', 'notas_asistencia', 'huellas_biometricas'
    ];
    
    for (final table in tables) {
      lastSync[table] = prefs.getString('last_sync_$table') ?? '1970-01-01 00:00:00';
    }
    
    return lastSync;
  }
  
  // Guardar último timestamp de sincronización
  Future<void> _saveLastSyncTimestamp(String table, String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_sync_$table', timestamp);
  }
  
  // Obtener estadísticas de sincronización
  Future<Map<String, dynamic>> getSyncStats() async {
    final db = await _dbHelper.database;
    final prefs = await SharedPreferences.getInstance();
    
    try {
      final pendingCount = await db.rawQuery('''
        SELECT COUNT(*) as count FROM sincronizacion_pendiente 
        WHERE sincronizado = 0
      ''');
      
      final lastSyncTables = <String, String>{};
      final tables = ['estudiantes', 'docentes', 'materias', 'asistencias'];
      
      for (final table in tables) {
        lastSyncTables[table] = prefs.getString('last_sync_$table') ?? 'Nunca';
      }
      
      return {
        'pending_sync': pendingCount.first['count'] ?? 0,
        'last_sync': lastSyncTables,
        'is_online': await _checkConnection(),
      };
    } catch (e) {
      return {
        'pending_sync': 0,
        'last_sync': {},
        'is_online': false,
        'error': e.toString(),
      };
    }
  }
  
  // Verificar conexión al servidor
  Future<bool> _checkConnection() async {
    try {
      final result = await ApiService.login('test', 'test').timeout(
        Duration(seconds: 5),
        onTimeout: () => {'success': false, 'error': 'timeout'},
      );
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }
}