// utils/helpers.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // NECESITAS ESTA IMPORTACIÓN PARA INTRODUCIR LA FECHA EN ESPAÑOL
import 'constants.dart';

class Helpers {
  /// Muestra un SnackBar con mensaje y color opcional según tipo de mensaje
  /// type: 'success', 'error', 'warning', o null (negro por defecto)
  /// duration: duración en segundos (opcional)
  static void showSnackBar(
    BuildContext context,
    String message, {
    String? type,
    int duration = 3,
  }) {
    Color bgColor = Colors.black;
    switch (type) {
      case 'success':
        bgColor = AppColors.success;
        break;
      case 'error':
        bgColor = AppColors.error;
        break;
      case 'warning':
        bgColor = AppColors.warning;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: bgColor,
        duration: Duration(seconds: duration),
      ),
    );
  }

  // --- MÉTODOS AÑADIDOS ---

  /// Obtiene el nombre del día de la semana (ej: "Lunes")
  static String getDiaSemana(DateTime date) {
    // Asegúrate de haber importado 'package:intl/intl.dart' y de tener la dependencia intl en tu pubspec.yaml
    // El 'es_ES' es para obtener el nombre en español
    return DateFormat('EEEE', 'es_ES').format(date);
  }

  /// Obtiene el nombre del mes y el año (ej: "Noviembre 2025")
  static String getMesAnio(DateTime date) {
    // El 'es_ES' es para obtener el nombre en español
    return DateFormat('MMMM yyyy', 'es_ES').format(date);
  }

  // --- FIN MÉTODOS AÑADIDOS ---

  // ... el resto de los métodos permanecen igual
  static String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  static String formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  static String formatDateTime(DateTime date) {
    return "${formatDate(date)} ${formatTime(date)}";
  }

  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  static String toUpperCaseTrim(String text) {
    return text.trim().toUpperCase();
  }

  static String formatName(String name) {
    return toUpperCaseTrim(name);
  }

  static String formatDepartment(String dept) {
    return toUpperCaseTrim(dept);
  }

  static bool isPositiveNumber(String value) {
    final regex = RegExp(r'^\d+$');
    return regex.hasMatch(value);
  }
}