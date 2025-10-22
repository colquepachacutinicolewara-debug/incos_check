import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../viewmodels/soporte_viewmodel.dart';
import '../../models/soporte_model.dart';
import 'soporte_preguntas_sreen.dart';

class SoporteScreen extends StatelessWidget {
  SoporteScreen({super.key});

  final SoporteViewModel viewModel = SoporteViewModel(
    model: SoporteModel(
      whatsappNumber: "59160696135",
      email: "incos@gmail.com",
      phoneNumber: "+59160696135",
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Soporte"),
        centerTitle: true,
        elevation: 4,
        backgroundColor: AppColors.secondary, // CAMBIADO A CELESTE
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
                    const Icon(Icons.support_agent,
                        size: 80, color: AppColors.primary),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      "Centro de Soporte",
                      style: AppTextStyles.heading1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      "Aquí puedes encontrar ayuda, resolver dudas o "
                      "contactar con nuestro equipo de soporte.",
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
              subtitle: const Text("Consulta respuestas rápidas a dudas comunes"),
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
              title: const Text("Chat en Línea"),
              subtitle: const Text("Habla con un asesor en tiempo real"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: viewModel.openWhatsApp,
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.email, color: AppColors.primary),
              title: const Text("Correo de Soporte"),
              subtitle: const Text("Envía un mensaje a nuestro equipo"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: viewModel.openGmail,
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.phone, color: AppColors.primary),
              title: const Text("Línea Telefónica"),
              subtitle: const Text("Contáctanos directamente por llamada"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: viewModel.openPhone,
            ),
          ],
        ),
      ),
    );
  }
}