import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/soporte_model.dart';

class SoporteViewModel {
  final SoporteModel model;

  SoporteViewModel({required this.model});

  // Abrir WhatsApp
  Future<void> openWhatsApp() async {
    final String message = Uri.encodeComponent(model.whatsappMessage);
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/${model.whatsappNumber}?text=$message",
    );
    if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
      debugPrint("No se pudo abrir WhatsApp");
    }
  }

  // Abrir correzo
  Future<void> openGmail() async {
    final String subject = Uri.encodeComponent(model.emailSubject);
    final String body = Uri.encodeComponent(model.emailBody);

    final Uri emailUrl = Uri(
      scheme: 'mailto',
      path: model.email,
      query: 'subject=$subject&body=$body',
    );

    if (!await launchUrl(emailUrl)) {
      debugPrint("No se pudo abrir el correo");
    }
  }

  // Abrir teléfono
  Future<void> openPhone() async {
    final Uri telUrl = Uri.parse("tel:${model.phoneNumber}");
    if (!await launchUrl(telUrl)) {
      debugPrint("No se pudo abrir la app de teléfono");
    }
  }
}
