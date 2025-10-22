import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/soporte_model.dart';

class SoporteViewModel {
  final SoporteModel model;

  SoporteViewModel({required this.model});

  // Abrir WhatsApp
  Future<void> openWhatsApp() async {
    final String message = Uri.encodeComponent(
      "Hola, buen día.\n\nMe gustaría solicitar asistencia con respecto a un problema que estoy experimentando en la plataforma del INCOS. "
      "Agradecería mucho que un asesor pudiera guiarme para resolver esta situación. \n\nGracias de antemano por su apoyo."
    );
    final Uri whatsappUrl = Uri.parse("https://wa.me/${model.whatsappNumber}?text=$message");
    if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
      debugPrint("No se pudo abrir WhatsApp");
    }
  }

  // Abrir correo
  Future<void> openGmail() async {
    final String subject = Uri.encodeComponent("Solicitud de Soporte INCOS");
    final String body = Uri.encodeComponent(
      "Estimado equipo de soporte,\n\n"
      "Espero se encuentren bien. Me pongo en contacto para solicitar asistencia con respecto a un inconveniente que estoy teniendo en la plataforma del INCOS. "
      "Agradecería si pudieran indicarme los pasos necesarios para resolverlo.\n\n"
      "Quedo atento a su respuesta.\n\n"
      "Muchas gracias por su tiempo y apoyo."
    );

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
