// utils/helpers.dart
import 'package:flutter/material.dart';
import 'constants.dart'; // Para usar colores de la app

/// ===========================
/// HELPERS / FUNCIONES UTILES
/// ===========================
class Helpers {
  /// Muestra un SnackBar con mensaje y color opcional según tipo de mensaje
  /// type: 'success', 'error', 'warning', o null (negro por defecto)
  static void showSnackBar(BuildContext context, String message,
      {String? type}) {
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
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Formatea fecha en formato dd/mm/yyyy
  static String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}";
  }

  /// Formatea hora en formato hh:mm
  static String formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}";
  }

  /// Formatea fecha y hora completa: dd/mm/yyyy hh:mm
  static String formatDateTime(DateTime date) {
    return "${formatDate(date)} ${formatTime(date)}";
  }

  /// Muestra un diálogo de confirmación
  static Future<bool> showConfirmationDialog(BuildContext context,
      {required String title, required String content}) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar')),
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Aceptar')),
            ],
          ),
        ) ??
        false;
  }

  /// Convierte cualquier texto a mayúsculas y elimina espacios al inicio y final
  static String toUpperCaseTrim(String text) {
    return text.trim().toUpperCase();
  }

  /// Convierte nombre con espacios a mayúsculas
  static String formatName(String name) {
    return toUpperCaseTrim(name);
  }

  /// Convierte departamento a mayúsculas
  static String formatDepartment(String dept) {
    return toUpperCaseTrim(dept);
  }

  /// Valida si un número es positivo y retorna true/false
  static bool isPositiveNumber(String value) {
    final regex = RegExp(r'^\d+$');
    return regex.hasMatch(value);
  }
}

