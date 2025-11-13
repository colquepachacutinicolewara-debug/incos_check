// views/soporte_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../../viewmodels/soporte_viewmodel.dart';
import '../soporte/soporte_preguntas_sreen.dart';

class SoporteScreen extends StatelessWidget {
  const SoporteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SoporteViewModel(),
      child: const _SoporteView(),
    );
  }
}

class _SoporteView extends StatelessWidget {
  const _SoporteView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SoporteViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Soporte - IncosCheck"),
        centerTitle: true,
        elevation: 4,
        backgroundColor: AppColors.secondary,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                          const SizedBox(height: AppSpacing.small),
                          Consumer<SoporteViewModel>(
                            builder: (context, viewModel, child) {
                              return Text(
                                viewModel.resumenContacto,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              );
                            },
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

                  Consumer<SoporteViewModel>(
                    builder: (context, viewModel, child) {
                      return ListTile(
                        leading: const Icon(Icons.chat, color: AppColors.primary),
                        title: const Text("WhatsApp de Soporte"),
                        subtitle: Text(
                          viewModel.model.whatsappNumber.isNotEmpty
                              ? "Soporte técnico por WhatsApp"
                              : "WhatsApp no configurado",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: viewModel.model.whatsappNumber.isNotEmpty 
                            ? viewModel.openWhatsApp
                            : null,
                      );
                    },
                  ),
                  const Divider(),

                  Consumer<SoporteViewModel>(
                    builder: (context, viewModel, child) {
                      return ListTile(
                        leading: const Icon(Icons.email, color: AppColors.primary),
                        title: const Text("Correo de Soporte"),
                        subtitle: Text(
                          viewModel.model.email.isNotEmpty
                              ? "Reporta problemas técnicos por email"
                              : "Email no configurado",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: viewModel.model.email.isNotEmpty 
                            ? viewModel.openGmail
                            : null,
                      );
                    },
                  ),
                  const Divider(),

                  Consumer<SoporteViewModel>(
                    builder: (context, viewModel, child) {
                      return ListTile(
                        leading: const Icon(Icons.phone, color: AppColors.primary),
                        title: const Text("Línea de Soporte"),
                        subtitle: Text(
                          viewModel.model.phoneNumber.isNotEmpty
                              ? "${viewModel.model.phoneNumber} - Asistencia telefónica"
                              : "Teléfono no configurado",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: viewModel.model.phoneNumber.isNotEmpty 
                            ? viewModel.openPhone
                            : null,
                      );
                    },
                  ),

                  // Información adicional
                  const SizedBox(height: AppSpacing.large),
                  Card(
                    color: AppColors.info.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: AppColors.info, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Información de Contacto",
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.info,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Horario de atención: Lunes a Viernes 8:00 - 18:00\n"
                            "Tiempo de respuesta estimado: 24-48 horas",
                            style: AppTextStyles.body.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}