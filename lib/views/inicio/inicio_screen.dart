import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/inicio_viewmodel.dart';
import '../../utils/constants.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InicioViewModel(),
      child: const _InicioScreenContent(),
    );
  }
}

class _InicioScreenContent extends StatelessWidget {
  const _InicioScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.dashboard,
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
        centerTitle: true,
      ),
      body: const _InicioScreenBody(),
    );
  }
}

class _InicioScreenBody extends StatelessWidget {
  const _InicioScreenBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InicioViewModel>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;
        final bool isDesktop = constraints.maxWidth > 900;

        final double iconSize = isDesktop ? 120.0 : (isTablet ? 100.0 : 80.0);
        final double titleFontSize = isDesktop
            ? 32.0
            : (isTablet ? 28.0 : 24.0);
        final double bodyFontSize = isDesktop ? 20.0 : (isTablet ? 18.0 : 16.0);

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
                        color: viewModel.getTextColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.medium),
                    Text(
                      'Bienvenido al sistema de gestión de asistencia académica',
                      style: AppTextStyles.bodyDark(context).copyWith(
                        fontSize: bodyFontSize,
                        color: viewModel.getSecondaryTextColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.large),
                    _buildInfoCard(
                      context,
                      viewModel,
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
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    InicioViewModel viewModel, {
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
                color: viewModel.getTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.medium),
            _buildInfoRow(
              'Fecha:',
              viewModel.model.formattedDate,
              bodyFontSize,
              context,
              viewModel,
            ),
            SizedBox(height: AppSpacing.small),
            _buildInfoRow(
              'Hora:',
              viewModel.model.formattedTime,
              bodyFontSize,
              context,
              viewModel,
            ),
            SizedBox(height: AppSpacing.small),
            _buildInfoRow(
              'Estado:',
              viewModel.model.systemStatus,
              bodyFontSize,
              context,
              viewModel,
            ),
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
    InicioViewModel viewModel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyDark(context).copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: viewModel.getTextColor(context),
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
