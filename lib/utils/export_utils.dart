// utils/export_utils.dart - VERSIÓN ALTERNATIVA
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ExportUtils {
  /// Exportar lista de estudiantes a Excel (versión CSV como alternativa)
  static Future<void> exportStudentsToExcel({
    required List<Map<String, dynamic>> estudiantes,
    required String carrera,
    required String turno,
    required String nivel,
    required String paralelo,
    required bool simple,
  }) async {
    try {
      // Solicitar permisos de almacenamiento
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        // Crear contenido CSV (más compatible)
        StringBuffer csvContent = StringBuffer();

        // Agregar encabezado institucional
        csvContent.writeln('INSTITUCIÓN: $carrera');
        csvContent.writeln('TURNO: $turno');
        csvContent.writeln('NIVEL: $nivel');
        csvContent.writeln('PARALELO: $paralelo');
        csvContent.writeln('FECHA: ${DateTime.now().toString().split(' ')[0]}');
        csvContent.writeln();

        // Encabezados de columnas
        if (simple) {
          csvContent.writeln('N°,APELLIDOS Y NOMBRES');
        } else {
          csvContent.writeln(
            'N°,APELLIDO PATERNO,APELLIDO MATERNO,NOMBRES,CÉDULA,FECHA REGISTRO,HUELLAS REGISTRADAS',
          );
        }

        // Agregar datos de estudiantes
        for (int i = 0; i < estudiantes.length; i++) {
          var estudiante = estudiantes[i];
          if (simple) {
            csvContent.writeln(
              '${i + 1},"${estudiante['apellidoPaterno']} ${estudiante['apellidoMaterno']} ${estudiante['nombres']}"',
            );
          } else {
            csvContent.writeln(
              '${i + 1},${estudiante['apellidoPaterno']},${estudiante['apellidoMaterno']},${estudiante['nombres']},${estudiante['ci']},${estudiante['fechaRegistro']},${estudiante['huellasRegistradas'] ?? 0}/3',
            );
          }
        }

        // Guardar archivo
        final directory = await getExternalStorageDirectory();
        final fileName =
            'Estudiantes_${paralelo}_${DateTime.now().millisecondsSinceEpoch}.csv';
        final filePath = '${directory?.path}/$fileName';

        final file = File(filePath);
        await file.writeAsString(csvContent.toString());

        // Compartir archivo
        await Share.shareXFiles([
          XFile(filePath),
        ], text: 'Lista de Estudiantes - $carrera');
      } else {
        throw Exception('Permiso de almacenamiento denegado');
      }
    } catch (e) {
      throw Exception('Error al exportar: $e');
    }
  }

  /// Método alternativo para generar archivo de texto simple
  static Future<void> exportStudentsToText({
    required List<Map<String, dynamic>> estudiantes,
    required String carrera,
    required String turno,
    required String nivel,
    required String paralelo,
    required bool simple,
  }) async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        StringBuffer content = StringBuffer();

        content.writeln('═' * 50);
        content.writeln('INSTITUCIÓN: $carrera');
        content.writeln('TURNO: $turno');
        content.writeln('NIVEL: $nivel');
        content.writeln('PARALELO: $paralelo');
        content.writeln('FECHA: ${DateTime.now().toString().split(' ')[0]}');
        content.writeln('TOTAL ESTUDIANTES: ${estudiantes.length}');
        content.writeln('═' * 50);
        content.writeln();

        if (simple) {
          content.writeln('LISTA SIMPLE DE ESTUDIANTES');
          content.writeln('─' * 40);
          for (int i = 0; i < estudiantes.length; i++) {
            var estudiante = estudiantes[i];
            content.writeln(
              '${i + 1}. ${estudiante['apellidoPaterno']} ${estudiante['apellidoMaterno']} ${estudiante['nombres']}',
            );
          }
        } else {
          content.writeln('LISTA COMPLETA DE ESTUDIANTES');
          content.writeln('─' * 60);
          for (int i = 0; i < estudiantes.length; i++) {
            var estudiante = estudiantes[i];
            content.writeln(
              '${i + 1}. ${estudiante['apellidoPaterno']} ${estudiante['apellidoMaterno']} ${estudiante['nombres']}',
            );
            content.writeln(
              '   CI: ${estudiante['ci']} | Registro: ${estudiante['fechaRegistro']} | Huellas: ${estudiante['huellasRegistradas'] ?? 0}/3',
            );
            content.writeln();
          }
        }

        final directory = await getExternalStorageDirectory();
        final fileName =
            'Estudiantes_${paralelo}_${DateTime.now().millisecondsSinceEpoch}.txt';
        final filePath = '${directory?.path}/$fileName';

        final file = File(filePath);
        await file.writeAsString(content.toString());

        await Share.shareXFiles([
          XFile(filePath),
        ], text: 'Lista de Estudiantes - $carrera');
      } else {
        throw Exception('Permiso de almacenamiento denegado');
      }
    } catch (e) {
      throw Exception('Error al exportar: $e');
    }
  }
}
