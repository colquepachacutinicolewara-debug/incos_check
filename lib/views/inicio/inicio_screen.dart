import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  // Métodos helper para modo oscuro (mismo patrón)
  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.dashboard,
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary, // Cambiado a CELESTE
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          final bool isDesktop = constraints.maxWidth > 900;

          final double iconSize = isDesktop ? 120.0 : (isTablet ? 100.0 : 80.0);
          final double titleFontSize = isDesktop
              ? 32.0
              : (isTablet ? 28.0 : 24.0);
          final double bodyFontSize = isDesktop
              ? 20.0
              : (isTablet ? 18.0 : 16.0);

          return SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              padding: EdgeInsets.all(AppSpacing.medium),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 800 : (isTablet ? 600 : 400),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school,
                        size: iconSize,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: AppSpacing.large),
                      Text(
                        'Sistema de Asistencia ${AppStrings.appName}',
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: titleFontSize,
                          color: _getTextColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.medium),
                      Text(
                        'Bienvenido al sistema de gestión de asistencia académica',
                        style: AppTextStyles.bodyDark(context).copyWith(
                          fontSize: bodyFontSize,
                          color: _getSecondaryTextColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.large),
                      _buildInfoCard(
                        context,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    bool isDesktop = false,
    bool isTablet = false,
  }) {
    final double cardPadding = isDesktop
        ? AppSpacing.large
        : (isTablet ? AppSpacing.medium : AppSpacing.small);

    final double titleFontSize = isDesktop ? 22.0 : (isTablet ? 20.0 : 18.0);
    final double bodyFontSize = isDesktop ? 18.0 : (isTablet ? 16.0 : 14.0);

    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppSpacing.large : AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          children: [
            Text(
              'Información del Sistema',
              style: AppTextStyles.heading2Dark(context).copyWith(
                fontSize: titleFontSize,
                color: _getTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.medium),
            _buildInfoRow(
              'Fecha:',
              Helpers.formatDate(DateTime.now()),
              bodyFontSize,
              context,
            ),
            SizedBox(height: AppSpacing.small),
            _buildInfoRow(
              'Hora:',
              Helpers.formatTime(DateTime.now()),
              bodyFontSize,
              context,
            ),
            SizedBox(height: AppSpacing.small),
            _buildInfoRow('Estado:', 'Sistema Activo', bodyFontSize, context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    double fontSize,
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyDark(context).copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: _getTextColor(context),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyDark(
            context,
          ).copyWith(fontSize: fontSize, color: AppColors.primary),
        ),
      ],
    );
  }
}
