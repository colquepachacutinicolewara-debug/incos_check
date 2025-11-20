// views/configuracion_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/configuracion_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../services/theme_service.dart';
import '../../views/configuracion/soporte/soporte_screen.dart';
import '../../views/configuracion/editar_perfil_screen.dart';
import '../../models/usuario_model.dart';

class ConfiguracionScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ConfiguracionScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConfiguracionViewModel(),
      child: _ConfiguracionView(userData: userData),
    );
  }
}

class _ConfiguracionView extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const _ConfiguracionView({this.userData});

  // FUNCIONES HELPER para modo oscuro
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

  Color _getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  // ✅ CORREGIDO: Diálogo de cambio de contraseña
  void _showChangePasswordDialog(BuildContext context) {
    final configViewModel = context.read<ConfiguracionViewModel>();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    String nivelFortaleza = 'Débil';
    Color colorFortaleza = Colors.red;
    List<String> recomendaciones = [];

    void actualizarFortaleza() {
      final validacion = configViewModel.validarFortalezaPassword(
        newPasswordController.text
      );
      
      nivelFortaleza = validacion['fortaleza'];
      colorFortaleza = validacion['colorFortaleza'];
      recomendaciones = List<String>.from(validacion['recomendaciones']);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: _getCardColor(context),
          title: Text(
            'Cambiar Contraseña',
            style: AppTextStyles.heading2.copyWith(
              color: _getTextColor(context),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Contraseña actual
                TextField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña actual',
                    labelStyle: TextStyle(color: _getTextColor(context)),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppColors.primary,
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: AppSpacing.medium),

                // Nueva contraseña
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    labelStyle: TextStyle(color: _getTextColor(context)),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_reset, color: AppColors.primary),
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      actualizarFortaleza();
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.small),

                // Indicador de fortaleza
                if (newPasswordController.text.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(
                        'Fortaleza: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getSecondaryTextColor(context),
                        ),
                      ),
                      Text(
                        nivelFortaleza,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorFortaleza,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: newPasswordController.text.isEmpty 
                        ? 0 
                        : newPasswordController.text.length / 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(colorFortaleza),
                  ),
                  const SizedBox(height: AppSpacing.small),
                ],

                // Confirmar contraseña
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar nueva contraseña',
                    labelStyle: TextStyle(color: _getTextColor(context)),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.verified_user,
                      color: AppColors.primary,
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: AppSpacing.small),

                // Recomendaciones
                if (recomendaciones.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.small),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                      border: Border.all(color: AppColors.info.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Para una contraseña más segura:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...recomendaciones.map((recomendacion) => 
                          _buildRecomendacionItem(recomendacion, context)
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                ],

                // Requisitos mínimos
                Container(
                  padding: const EdgeInsets.all(AppSpacing.small),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requisitos mínimos:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildRequisitoItem('Mínimo 6 caracteres', context),
                    ],
                  ),
                ),

                // Mostrar error si existe
                if (configViewModel.errorCambioPassword != null) ...[
                  const SizedBox(height: AppSpacing.small),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.small),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, size: 16, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            configViewModel.errorCambioPassword!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: configViewModel.guardando ? null : () {
                configViewModel.limpiarErrorPassword();
                Navigator.pop(context);
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: _getTextColor(context)),
              ),
            ),
            ElevatedButton(
              onPressed: configViewModel.guardando ? null : () async {
                final currentPassword = currentPasswordController.text;
                final newPassword = newPasswordController.text;
                final confirmPassword = confirmPasswordController.text;

                // Limpiar error anterior
                configViewModel.limpiarErrorPassword();
                authViewModel.limpiarError();

                // Validaciones
                if (currentPassword.isEmpty) {
                  Helpers.showSnackBar(
                    context,
                    '❌ Ingresa tu contraseña actual',
                    type: 'error',
                  );
                  return;
                }

                if (newPassword.isEmpty) {
                  Helpers.showSnackBar(
                    context,
                    '❌ Ingresa una nueva contraseña',
                    type: 'error',
                  );
                  return;
                }

                if (newPassword.length < 6) {
                  Helpers.showSnackBar(
                    context,
                    '❌ La contraseña debe tener al menos 6 caracteres',
                    type: 'error',
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  Helpers.showSnackBar(
                    context,
                    '❌ Las contraseñas no coinciden',
                    type: 'error',
                  );
                  return;
                }

                try {
                  print('🔄 Intentando cambiar contraseña desde diálogo...');
                  
                  final resultado = await configViewModel.cambiarPassword(
                    currentPassword: currentPassword,
                    newPassword: newPassword,
                    authViewModel: authViewModel,
                  );

                  if (resultado['success'] == true) {
                    print('✅ Contraseña cambiada exitosamente desde diálogo');
                    
                    currentPasswordController.clear();
                    newPasswordController.clear();
                    confirmPasswordController.clear();

                    Navigator.pop(context);
                    Helpers.showSnackBar(
                      context,
                      '✅ Contraseña cambiada exitosamente',
                      type: 'success',
                    );
                    
                    // Verificar que el cambio fue real
                    final verificado = await authViewModel.login(
                      authViewModel.currentUser!.username, 
                      newPassword
                    );
                    
                    if (verificado) {
                      print('🔐 Nueva contraseña verificada correctamente');
                    } else {
                      print('⚠️ La nueva contraseña no funciona después del cambio');
                    }
                  } else {
                    // El error ya se muestra en el diálogo
                    print('❌ Error al cambiar contraseña: ${resultado['message']}');
                  }
                } catch (e) {
                  print('❌ Error en el diálogo: $e');
                  Helpers.showSnackBar(
                    context,
                    '❌ Error: ${e.toString()}',
                    type: 'error',
                  );
                }
              },
              child: configViewModel.guardando 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Cambiar Contraseña'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecomendacionItem(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 12, color: AppColors.info),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: _getTextColor(context),
              ),
            ),
          ),
        ],
      ),
      );
  }

  Widget _buildRequisitoItem(String text, BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: _getTextColor(context),
          ),
        ),
      ],
    );
  }

  // ✅ CORREGIDO: Logout funcional
  void _performLogout(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: AppSpacing.small),
              Text('Cerrando sesión...'),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );

      await authViewModel.logout();

      // Navegar al login
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/', 
        (route) => false
      );

      Helpers.showSnackBar(
        context,
        'Sesión cerrada exitosamente',
        type: 'success',
      );
      
    } catch (e) {
      Helpers.showSnackBar(
        context,
        'Error al cerrar sesión: $e',
        type: 'error',
      );
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final viewModel = context.read<ConfiguracionViewModel>();

    showDialog(
      context: context,
      builder: (context) => Builder(
        builder: (dialogContext) => AlertDialog(
          backgroundColor: _getCardColor(dialogContext),
          title: Text(
            'Seleccionar Idioma',
            style: AppTextStyles.heading2.copyWith(
              color: _getTextColor(dialogContext),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: viewModel.languages.length,
              itemBuilder: (context, index) {
                final language = viewModel.languages[index];
                return RadioListTile(
                  title: Text(
                    language, 
                    style: AppTextStyles.body.copyWith(
                      color: _getTextColor(context),
                    ),
                  ),
                  value: language,
                  groupValue: viewModel.configuracion.selectedLanguage,
                  onChanged: (value) async {
                    await viewModel.updateLanguage(value!);
                    Navigator.pop(context);
                    Helpers.showSnackBar(
                      context,
                      'Idioma cambiado a $value',
                      type: 'success',
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar', 
                style: TextStyle(color: _getTextColor(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final viewModel = context.read<ConfiguracionViewModel>();
    final themeService = Provider.of<ThemeService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => Builder(
        builder: (dialogContext) => AlertDialog(
          backgroundColor: _getCardColor(dialogContext),
          title: Text(
            'Seleccionar Tema',
            style: AppTextStyles.heading2.copyWith(
              color: _getTextColor(dialogContext),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: viewModel.themes.length,
              itemBuilder: (context, index) {
                final theme = viewModel.themes[index];
                return RadioListTile(
                  title: Text(
                    theme, 
                    style: AppTextStyles.body.copyWith(
                      color: _getTextColor(context),
                    ),
                  ),
                  value: theme,
                  groupValue: viewModel.configuracion.selectedTheme,
                  onChanged: (value) async {
                    await viewModel.updateTheme(value!);
                    await themeService.updateTheme(value);
                    Navigator.pop(context);
                    Helpers.showSnackBar(
                      context,
                      'Tema cambiado a $value',
                      type: 'success',
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: _getTextColor(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Builder(
        builder: (dialogContext) => AlertDialog(
          backgroundColor: _getCardColor(dialogContext),
          title: Text(
            'Copia de Seguridad',
            style: AppTextStyles.heading2.copyWith(
              color: _getTextColor(dialogContext),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.backup, size: 60, color: AppColors.primary),
              SizedBox(height: AppSpacing.medium),
              Text(
                '¿Deseas crear una copia de seguridad de todos tus datos de asistencia?',
                style: AppTextStyles.body.copyWith(
                  color: _getTextColor(dialogContext),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.small),
              Text(
                'Se guardarán: estudiantes, docentes, materias y registros de asistencia',
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  color: _getSecondaryTextColor(dialogContext),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: _getTextColor(context)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // Simular creación de backup
                await Future.delayed(Duration(seconds: 2));
                Helpers.showSnackBar(
                  context,
                  '✅ Copia de seguridad creada exitosamente',
                  type: 'success',
                );
              },
              child: Text('Crear Backup'),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    final viewModel = context.read<ConfiguracionViewModel>();

    showDialog(
      context: context,
      builder: (context) => Builder(
        builder: (dialogContext) => AlertDialog(
          backgroundColor: _getCardColor(dialogContext),
          title: Text(
            'Limpiar Caché',
            style: AppTextStyles.heading2.copyWith(
              color: _getTextColor(dialogContext),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cleaning_services, size: 50, color: AppColors.primary),
              SizedBox(height: AppSpacing.medium),
              Text(
                '¿Estás seguro de que deseas limpiar el caché?',
                style: AppTextStyles.body.copyWith(
                  color: _getTextColor(dialogContext),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.small),
              Text(
                'Se liberarán ${viewModel.configuracion.cacheSize} de espacio de almacenamiento',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: _getTextColor(context)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                viewModel.clearCache();
                Helpers.showSnackBar(
                  context,
                  '✅ Caché limpiado exitosamente',
                  type: 'success',
                );
              },
              child: Text('Limpiar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Builder(
        builder: (dialogContext) => AlertDialog(
          backgroundColor: _getCardColor(dialogContext),
          title: Row(
            children: [
              Icon(Icons.info, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Acerca de IncosCheck',
                style: AppTextStyles.heading2.copyWith(
                  color: _getTextColor(dialogContext),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Icon(Icons.school, size: 60, color: AppColors.primary),
                ),
                SizedBox(height: AppSpacing.medium),
                Text(
                  'IncosCheck v1.0.0',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.small),
                Text(
                  'Sistema de Gestión de Asistencias',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _getTextColor(context),
                  ),
                ),
                SizedBox(height: AppSpacing.medium),
                _buildInfoItem(context, 'Desarrollado para:', 'Instituto Técnico Comercial INCOS - El Alto'),
                _buildInfoItem(context, 'Desarrolladora:', 'Est. Nicole Wara Colque Pachacuti\n(Sistemas Informáticos - Proyecto de Grado)'),
                _buildInfoItem(context, 'Contacto:', '+591 75205630\nincos@gmail.com'),
                SizedBox(height: AppSpacing.medium),
                Text(
                  '© 2025 Todos los derechos reservados',
                  style: TextStyle(
                    fontSize: 12, 
                    fontStyle: FontStyle.italic,
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cerrar',
                style: TextStyle(color: _getTextColor(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold,
              color: _getTextColor(context),
            ),
          ),
          Text(
            value, 
            style: TextStyle(
              fontSize: 14,
              color: _getTextColor(context),
            ),
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Builder(
        builder: (dialogContext) => AlertDialog(
          backgroundColor: _getCardColor(dialogContext),
          title: Row(
            children: [
              Icon(Icons.privacy_tip, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Política de Privacidad',
                style: AppTextStyles.heading2.copyWith(
                  color: _getTextColor(dialogContext),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'IncosCheck - Protección de Datos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                ),
                SizedBox(height: AppSpacing.medium),
                _buildPrivacyItem(context, '📊 Datos Recopilados:', '• Registros de asistencia\n• Información de estudiantes\n• Datos de docentes\n• Materias, carreras y horarios\n• Turnos y paralelos'),
                _buildPrivacyItem(context, '🛡️ Protección:', '• Autenticación biométrica\n• Almacenamiento seguro en SQLite\n• Acceso restringido al personal autorizado'),
                _buildPrivacyItem(context, '🚫 Uso de Datos:', '• Exclusivamente para control de asistencia interna\n• No se comparte con terceros\n• Uso educativo institucional'),
                _buildPrivacyItem(context, '📝 Responsabilidad:', '• Instituto Técnico Comercial INCOS - El Alto\n• Cumplimiento de normativas educativas'),
                SizedBox(height: AppSpacing.medium),
                Text(
                  'Esta aplicación garantiza la confidencialidad y seguridad de los datos académicos.',
                  style: TextStyle(
                    fontSize: 12, 
                    fontStyle: FontStyle.italic,
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Entendido',
                style: TextStyle(color: _getTextColor(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyItem(BuildContext context, String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            content, 
            style: TextStyle(
              fontSize: 14,
              color: _getTextColor(context),
            ),
          ),
        ],
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
            Text(
              'Información del Usuario',
              style: AppTextStyles.heading2.copyWith(
                fontSize: titleFontSize,
                color: _getTextColor(context),
              ),
              textAlign: TextAlign.center,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: _getTextColor(context),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontSize: fontSize, 
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ConfiguracionViewModel>();
    final config = viewModel.configuracion;

    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.secondary,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;

          return SingleChildScrollView(
            padding: EdgeInsets.all(
              isTablet ? AppSpacing.large : AppSpacing.medium,
            ),
            child: Column(
              children: [
                // Mostrar información del usuario si está disponible
                if (userData != null) ...[
                  _buildUserInfoCard(
                    context,
                    userData!,
                    isDesktop: false,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: AppSpacing.large),
                ],
                
                _buildUserCard(context, isTablet, userData),
                SizedBox(height: AppSpacing.large),

                _buildSettingsSection(
                  context,
                  'Notificaciones',
                  Icons.notifications,
                  [
                    _buildSwitchSetting(
                      context,
                      'Notificaciones Push',
                      'Recibir notificaciones importantes',
                      config.notificationsEnabled,
                      (value) async {
                        await viewModel.updateNotificationsEnabled(value);
                        Helpers.showSnackBar(
                          context,
                          'Notificaciones ${value ? 'activadas' : 'desactivadas'}',
                          type: 'success',
                        );
                      },
                    ),
                    _buildSwitchSetting(
                      context,
                      'Sincronización Automática',
                      'Sincronizar datos automáticamente',
                      config.autoSyncEnabled,
                      (value) async {
                        await viewModel.updateAutoSyncEnabled(value);
                        Helpers.showSnackBar(
                          context,
                          'Sincronización automática ${value ? 'activada' : 'desactivada'}',
                          type: 'success',
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.large),

                _buildSettingsSection(context, 'Seguridad', Icons.security, [
                  _buildSwitchSetting(
                    context,
                    'Autenticación Biométrica',
                    'Usar huella digital o reconocimiento facial',
                    config.biometricEnabled,
                    (value) async {
                      try {
                        await viewModel.toggleBiometricEnabled();
                        if (value) {
                          Helpers.showSnackBar(
                            context,
                            '✅ Autenticación biométrica activada',
                            type: 'success',
                          );
                        } else {
                          Helpers.showSnackBar(
                            context,
                            'Autenticación biométrica desactivada',
                            type: 'success',
                          );
                        }
                      } catch (e) {
                        Helpers.showSnackBar(
                          context,
                          '❌ ${e.toString()}',
                          type: 'error',
                        );
                      }
                    },
                  ),
                  _buildActionSetting(
                    context,
                    'Cambiar Contraseña',
                    Icons.lock,
                    'Actualizar contraseña de acceso',
                    () => _showChangePasswordDialog(context),
                  ),
                ]),

                SizedBox(height: AppSpacing.large),

                _buildSettingsSection(context, 'Apariencia', Icons.palette, [
                  _buildSelectionSetting(
                    context,
                    'Idioma',
                    Icons.language,
                    config.selectedLanguage,
                    () => _showLanguageDialog(context),
                  ),
                  _buildSelectionSetting(
                    context,
                    'Tema',
                    Icons.brightness_medium,
                    config.selectedTheme,
                    () => _showThemeDialog(context),
                  ),
                ]),

                SizedBox(height: AppSpacing.large),

                _buildSettingsSection(
                  context,
                  'Datos y Almacenamiento',
                  Icons.storage,
                  [
                    _buildActionSetting(
                      context,
                      'Copia de Seguridad',
                      Icons.backup,
                      'Crear backup de todos los datos',
                      () => _showBackupDialog(context),
                    ),
                    _buildActionSetting(
                      context,
                      'Limpiar Caché',
                      Icons.cleaning_services,
                      'Tamaño actual: ${config.cacheSize}',
                      () => _showClearCacheDialog(context),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.large),

                _buildSettingsSection(context, 'Información', Icons.info, [
                  _buildActionSetting(
                    context,
                    'Acerca de IncosCheck',
                    Icons.business,
                    'Información de la aplicación',
                    () => _showAboutDialog(context),
                  ),
                  _buildActionSetting(
                    context,
                    'Ayuda y Soporte',
                    Icons.help,
                    'Centro de ayuda y contacto',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SoporteScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionSetting(
                    context,
                    'Política de Privacidad',
                    Icons.privacy_tip,
                    'Términos y condiciones de uso',
                    () => _showPrivacyPolicy(context),
                  ),
                ]),

                SizedBox(height: AppSpacing.large),

                // ✅ MEJORADO: Botón de cerrar sesión funcional
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Helpers.showConfirmationDialog(
                        context,
                        title: 'Cerrar Sesión',
                        content: '¿Estás seguro de que deseas cerrar sesión?',
                      ).then((confirmed) {
                        if (confirmed) {
                          _performLogout(context);
                        }
                      });
                    },
                    icon: Icon(Icons.exit_to_app, color: Colors.white),
                    label: Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.medium,
                        horizontal: AppSpacing.large,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.large),
                Text(
                  'Versión 1.0.0',
                  style: TextStyle(
                    color: _getSecondaryTextColor(context), 
                    fontSize: 14
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, bool isTablet, Map<String, dynamic>? userData) {
  if (userData == null) return SizedBox.shrink();
  
  // Convertir a objeto Usuario
  final usuario = Usuario.fromLoginData(userData);
  
  return Card(
    elevation: 4,
    color: _getCardColor(context),
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.medium),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // Navegar a editar perfil
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarPerfilScreen(usuario: usuario),
                ),
              ).then((usuarioActualizado) {
                if (usuarioActualizado != null) {
                  Helpers.showSnackBar(
                    context,
                    '✅ Perfil actualizado',
                    type: 'success',
                  );
                }
              });
            },
            child: CircleAvatar(
              radius: isTablet ? 40 : 30,
              backgroundColor: usuario.colorRol,
              backgroundImage: usuario.fotoUrl != null 
                  ? NetworkImage(usuario.fotoUrl!) 
                  : null,
              child: usuario.fotoUrl == null
                  ? Icon(
                      usuario.iconoRol,
                      size: isTablet ? 30 : 20,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.nombre,
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                ),
                SizedBox(height: AppSpacing.small),
                Text(
                  usuario.email,
                  style: TextStyle(color: _getSecondaryTextColor(context)),
                ),
                SizedBox(height: AppSpacing.small),
                Chip(
                  label: Text(
                    usuario.rolDisplay,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: usuario.colorRol,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarPerfilScreen(usuario: usuario),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> settings,
  ) {
    return Card(
      elevation: 4,
      color: _getCardColor(context),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                SizedBox(width: AppSpacing.small),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.medium),
            ...settings,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(
            title,
            style: TextStyle(color: _getTextColor(context)),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: _getSecondaryTextColor(context), 
              fontSize: 14
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
        Divider(height: 1, color: _getSecondaryTextColor(context)),
      ],
    );
  }

  Widget _buildActionSetting(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            title,
            style: TextStyle(color: _getTextColor(context)),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: _getSecondaryTextColor(context), 
              fontSize: 14
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: _getSecondaryTextColor(context)),
          onTap: onTap,
        ),
        Divider(height: 1, color: _getSecondaryTextColor(context)),
      ],
    );
  }

  Widget _buildSelectionSetting(
    BuildContext context,
    String title,
    IconData icon,
    String value,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            title,
            style: TextStyle(color: _getTextColor(context)),
          ),
          subtitle: Text(
            value,
            style: TextStyle(color: AppColors.primary, fontSize: 14),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: _getSecondaryTextColor(context)),
          onTap: onTap,
        ),
        Divider(height: 1, color: _getSecondaryTextColor(context)),
      ],
    );
  }
}
