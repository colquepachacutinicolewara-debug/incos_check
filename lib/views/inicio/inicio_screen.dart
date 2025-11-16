import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/inicio_viewmodel.dart';
import '../../utils/constants.dart';

class InicioScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const InicioScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InicioViewModel(),
      child: _InicioScreenContent(userData: userData),
    );
  }
}

class _InicioScreenContent extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const _InicioScreenContent({this.userData});

  

  // FUNCIONES HELPER para modo oscuro (igual que CarreraContaduria)
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
        title: Builder(
          builder: (context) => Text(
            AppStrings.dashboard,
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white, // Mantener blanco en AppBar
            ),
          ),
        ),
        backgroundColor: AppColors.secondary,
        centerTitle: true,
      ),
      body: _InicioScreenBody(userData: userData),
    );
  }
}

class _InicioScreenBody extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const _InicioScreenBody({this.userData});

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
                      color: AppColors.primary, // Color fijo para ícono
                    ),
                    SizedBox(height: AppSpacing.large),
                    Builder(
                      builder: (context) => Text(
                        'Sistema de Asistencia ${AppStrings.appName}',
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: titleFontSize,
                          color: _getTextColor(context), // Color dinámico
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: AppSpacing.medium),
                    Builder(
                      builder: (context) => Text(
                        'Bienvenido al sistema de gestión de asistencia académica',
                        style: AppTextStyles.bodyDark(context).copyWith(
                          fontSize: bodyFontSize,
                          color: _getSecondaryTextColor(context), // Color dinámico
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: AppSpacing.large),
                    _buildInfoCard(
                      context,
                      viewModel,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                    ),
                    if (userData != null) ...[
                      SizedBox(height: AppSpacing.large),
                      _buildUserInfoCard(
                        context,
                        userData!,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ],
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
      color: Theme.of(context).cardColor, // Color dinámico del tema
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          children: [
            Builder(
              builder: (context) => Text(
                'Información del Sistema',
                style: AppTextStyles.heading2Dark(context).copyWith(
                  fontSize: titleFontSize,
                  color: _getTextColor(context), // Color dinámico
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSpacing.medium),
            _buildInfoRow(
              'Fecha:',
              viewModel.model.formattedDate,
              bodyFontSize,
              context,
            ),
            SizedBox(height: AppSpacing.small),
            _buildInfoRow(
              'Hora:',
              viewModel.model.formattedTime,
              bodyFontSize,
              context,
            ),
            SizedBox(height: AppSpacing.small),
            _buildInfoRow(
              'Estado:',
              viewModel.model.systemStatus,
              bodyFontSize,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(
    BuildContext context,
    Map<String, dynamic> userData, {
    bool isDesktop = false,
    bool isTablet = false,
  }) {
    final double cardPadding = isDesktop
        ? AppSpacing.large
        : (isTablet ? AppSpacing.medium : AppSpacing.small);

    final double titleFontSize = isDesktop ? 20.0 : (isTablet ? 18.0 : 16.0);
    final double bodyFontSize = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);

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
            Builder(
              builder: (context) => Text(
                'Información del Usuario',
                style: AppTextStyles.heading2Dark(context).copyWith(
                  fontSize: titleFontSize,
                  color: _getTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSpacing.medium),
            _buildInfoRow(
              'Usuario:',
              userData['nombre']?.toString() ?? 'Usuario',
              bodyFontSize,
              context,
            ),
            SizedBox(height: AppSpacing.small),
            _buildInfoRow(
              'Rol:',
              userData['role']?.toString() ?? 'Usuario',
              bodyFontSize,
              context,
            ),
            SizedBox(height: AppSpacing.small),
            _buildInfoRow(
              'Email:',
              userData['email']?.toString() ?? 'No especificado',
              bodyFontSize,
              context,
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
  ) {
    return Builder(
      builder: (context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyDark(context).copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: _getTextColor(context), // Color dinámico
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyDark(context).copyWith(
              fontSize: fontSize, 
              color: AppColors.primary, // Color fijo para valores importantes
            ),
          ),
        ],
      ),
    );
  }
}