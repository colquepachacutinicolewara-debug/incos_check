// viewmodels/soporte_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/soporte_model.dart';
import '../models/database_helper.dart';

class SoporteViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance; // ✅ Cambio aquí
  SoporteModel _model;
  bool _isLoading = false;

  SoporteModel get model => _model;
  bool get isLoading => _isLoading;

  SoporteViewModel() // ✅ Constructor sin parámetros
      : _model = SoporteModel(
          whatsappNumber: '',
          email: '',
          phoneNumber: '',
          whatsappMessage: '',
          emailSubject: '',
          emailBody: '',
        ) {
    _cargarSoporteDesdeSQLite();
  }

  Future<void> _cargarSoporteDesdeSQLite() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _databaseHelper.rawQuery('''
        SELECT * FROM soporte LIMIT 1
      ''');

      if (result.isNotEmpty) {
        _model = SoporteModel.fromMap(Map<String, dynamic>.from(result.first));
      } else {
        // Insertar datos de soporte por defecto
        await _insertarSoportePorDefecto();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error cargando soporte: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _insertarSoportePorDefecto() async {
    final soportePorDefecto = SoporteModel(
      whatsappNumber: '59175205630',
      email: 'incos@gmail.com',
      phoneNumber: '+59175205630',
      whatsappMessage: 'Hola, necesito soporte con la aplicación IncosCheck - Gestión de Asistencias',
      emailSubject: 'Soporte - IncosCheck App',
      emailBody: 'Hola equipo de soporte,\n\nNecesito ayuda con la aplicación IncosCheck:\n\n[Describe tu problema o consulta aquí]\n\n• Tipo de usuario: \n• Dispositivo: \n• Versión de la app: \n\nGracias.',
    );

    try {
      await _databaseHelper.rawInsert('''
        INSERT INTO soporte (id, whatsapp_number, email, phone_number, whatsapp_message, email_subject, email_body, fecha_creacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        'soporte_principal',
        soportePorDefecto.whatsappNumber,
        soportePorDefecto.email,
        soportePorDefecto.phoneNumber,
        soportePorDefecto.whatsappMessage,
        soportePorDefecto.emailSubject,
        soportePorDefecto.emailBody,
        DateTime.now().toIso8601String(),
      ]);

      _model = soportePorDefecto;
    } catch (e) {
      print('Error insertando soporte por defecto: $e');
    }
  }

  // Abrir WhatsApp
  Future<void> openWhatsApp() async {
    if (model.whatsappNumber.isEmpty) {
      debugPrint("Número de WhatsApp no configurado");
      return;
    }

    final String message = Uri.encodeComponent(model.whatsappMessage);
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/${model.whatsappNumber}?text=$message",
    );
    
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("No se pudo abrir WhatsApp");
    }
  }

  // Abrir correo
  Future<void> openGmail() async {
    if (model.email.isEmpty) {
      debugPrint("Email no configurado");
      return;
    }

    final String subject = Uri.encodeComponent(model.emailSubject);
    final String body = Uri.encodeComponent(model.emailBody);

    final Uri emailUrl = Uri(
      scheme: 'mailto',
      path: model.email,
      query: 'subject=$subject&body=$body',
    );

    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    } else {
      debugPrint("No se pudo abrir el correo");
    }
  }

  // Abrir teléfono
  Future<void> openPhone() async {
    if (model.phoneNumber.isEmpty) {
      debugPrint("Número de teléfono no configurado");
      return;
    }

    final Uri telUrl = Uri.parse("tel:${model.phoneNumber}");
    if (await canLaunchUrl(telUrl)) {
      await launchUrl(telUrl);
    } else {
      debugPrint("No se pudo abrir la app de teléfono");
    }
  }

  Future<void> actualizarSoporte(SoporteModel nuevoSoporte) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseHelper.rawUpdate('''
        UPDATE soporte SET 
        whatsapp_number = ?, email = ?, phone_number = ?, 
        whatsapp_message = ?, email_subject = ?, email_body = ?
        WHERE id = ?
      ''', [
        nuevoSoporte.whatsappNumber,
        nuevoSoporte.email,
        nuevoSoporte.phoneNumber,
        nuevoSoporte.whatsappMessage,
        nuevoSoporte.emailSubject,
        nuevoSoporte.emailBody,
        'soporte_principal',
      ]);

      _model = nuevoSoporte;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> recargarSoporte() async {
    await _cargarSoporteDesdeSQLite();
  }

  // Método para verificar si hay datos de soporte configurados
  bool get tieneDatosSoporte {
    return model.whatsappNumber.isNotEmpty || 
           model.email.isNotEmpty || 
           model.phoneNumber.isNotEmpty;
  }

  // Método para obtener resumen de contacto
  String get resumenContacto {
    List<String> contactos = [];
    if (model.whatsappNumber.isNotEmpty) contactos.add('WhatsApp');
    if (model.email.isNotEmpty) contactos.add('Email');
    if (model.phoneNumber.isNotEmpty) contactos.add('Teléfono');
    
    return contactos.isEmpty ? 'Sin contactos configurados' : contactos.join(', ');
  }
}