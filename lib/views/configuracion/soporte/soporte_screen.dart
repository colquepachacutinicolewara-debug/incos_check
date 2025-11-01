import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../viewmodels/soporte_viewmodel.dart';
import '../../../models/soporte_model.dart';
import 'soporte_preguntas_sreen.dart';

class SoporteScreen extends StatelessWidget {
  SoporteScreen({super.key});

  final SoporteViewModel viewModel = SoporteViewModel(
    model: SoporteModel(
      whatsappNumber: "59175205630",
      email: "incos@gmail.com",
      phoneNumber: "+59175205630",
      whatsappMessage:
          "Hola, necesito soporte con la aplicación IncosCheck - Gestión de Asistencias",
      emailSubject: "Soporte - IncosCheck App",
      emailBody:
          "Hola equipo de soporte,\n\nNecesito ayuda con la aplicación IncosCheck:\n\n[Describe tu problema o consulta aquí]\n\n• Tipo de usuario: \n• Dispositivo: \n• Versión de la app: \n\nGracias.",
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Soporte - IncosCheck"),
        centerTitle: true,
        elevation: 4,
        backgroundColor: AppColors.secondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              elevation: 6,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Column(
                  children: [
                    const Icon(
                      Icons.support_agent,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      "Soporte IncosCheck",
                      style: AppTextStyles.heading1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      "Soporte especializado para la gestión y reporte de asistencias académicas",
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.large),

            /// Opciones de soporte
            ListTile(
              leading: const Icon(Icons.help_outline, color: AppColors.primary),
              title: const Text("Preguntas Frecuentes"),
              subtitle: const Text(
                "Soluciones rápidas para gestión de asistencias",
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SoportePreguntasScreen(),
                  ),
                );
              },
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.chat, color: AppColors.primary),
              title: const Text("WhatsApp de Soporte"),
              subtitle: const Text("Soporte técnico por WhatsApp"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: viewModel.openWhatsApp,
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.email, color: AppColors.primary),
              title: const Text("Correo de Soporte"),
              subtitle: const Text("Reporta problemas técnicos por email"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: viewModel.openGmail,
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.phone, color: AppColors.primary),
              title: const Text("Línea de Soporte"),
              subtitle: const Text("+591 75205630 - Asistencia telefónica"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: viewModel.openPhone,
            ),
          ],
        ),
      ),
    );
  }
}
