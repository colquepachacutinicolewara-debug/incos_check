import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/configuracion_viewmodel.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../services/theme_service.dart';
import '../configuracion/soporte/soporte_screen.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConfiguracionViewModel(),
      child: const _ConfiguracionView(),
    );
  }
}

class _ConfiguracionView extends StatelessWidget {
  const _ConfiguracionView();

  void _showLanguageDialog(BuildContext context) {
    final viewModel = context.read<ConfiguracionViewModel>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Seleccionar Idioma',
          style: AppTextStyles.heading2Dark(context),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: viewModel.languages.length,
            itemBuilder: (context, index) {
              final language = viewModel.languages[index];
              return RadioListTile(
                title: Text(language, style: AppTextStyles.bodyDark(context)),
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
            child: Text('Cancelar', style: AppTextStyles.bodyDark(context)),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final viewModel = context.read<ConfiguracionViewModel>();
    final themeService = Provider.of<ThemeService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Seleccionar Tema',
          style: AppTextStyles.heading2Dark(context),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: viewModel.themes.length,
            itemBuilder: (context, index) {
              final theme = viewModel.themes[index];
              return RadioListTile(
                title: Text(theme, style: AppTextStyles.bodyDark(context)),
                value: theme,
                groupValue: viewModel.configuracion.selectedTheme,
                onChanged: (value) async {
                  await viewModel.updateTheme(value!);
                  await themeService.updateTheme(value!);
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
            child: Text('Cancelar', style: AppTextStyles.bodyDark(context)),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Copia de Seguridad',
          style: AppTextStyles.heading2Dark(context),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.backup, size: 60, color: AppColors.primary),
            SizedBox(height: AppSpacing.medium),
            Text(
              '¿Deseas crear una copia de seguridad de todos tus datos de asistencia?',
              style: AppTextStyles.bodyDark(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.small),
            Text(
              'Se guardarán: estudiantes, docentes, materias y registros de asistencia',
              style: AppTextStyles.bodyDark(context).copyWith(
                fontSize: 12,
                color: AppColors.textSecondaryDark(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: AppTextStyles.bodyDark(context)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Future.delayed(const Duration(seconds: 2));
              Helpers.showSnackBar(
                context,
                '✅ Copia de seguridad creada exitosamente',
                type: 'success',
              );
            },
            child: Text('Crear Backup', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cambiar Contraseña',
          style: AppTextStyles.heading2Dark(context),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Contraseña actual',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: AppColors.primary,
                  ),
                  labelStyle: AppTextStyles.bodyDark(context),
                ),
                obscureText: true,
                style: AppTextStyles.bodyDark(context),
              ),
              SizedBox(height: AppSpacing.medium),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_reset, color: AppColors.primary),
                  hintText:
                      'Mín. 5 chars, mayúscula, minúscula, carácter especial',
                  labelStyle: AppTextStyles.bodyDark(context),
                  hintStyle: AppTextStyles.bodyDark(
                    context,
                  ).copyWith(color: AppColors.textSecondaryDark(context)),
                ),
                obscureText: true,
                style: AppTextStyles.bodyDark(context),
              ),
              SizedBox(height: AppSpacing.medium),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.verified_user,
                    color: AppColors.primary,
                  ),
                  labelStyle: AppTextStyles.bodyDark(context),
                ),
                obscureText: true,
                style: AppTextStyles.bodyDark(context),
              ),
              SizedBox(height: AppSpacing.small),
              Container(
                padding: EdgeInsets.all(AppSpacing.small),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requisitos de contraseña:',
                      style: AppTextStyles.bodyDark(context).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    _buildSimpleRequirement(context, 'Mínimo 5 caracteres'),
                    _buildSimpleRequirement(
                      context,
                      'Una letra mayúscula (A-Z)',
                    ),
                    _buildSimpleRequirement(
                      context,
                      'Una letra minúscula (a-z)',
                    ),
                    _buildSimpleRequirement(
                      context,
                      'Un carácter especial (!@#\$% etc.)',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: AppTextStyles.bodyDark(context)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Helpers.showSnackBar(
                context,
                '✅ Contraseña cambiada exitosamente',
                type: 'success',
              );
            },
            child: Text('Cambiar Contraseña', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleRequirement(BuildContext context, String text) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, size: 14, color: AppColors.primary),
        SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.bodyDark(
            context,
          ).copyWith(fontSize: 11, color: AppColors.textSecondaryDark(context)),
        ),
      ],
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    final viewModel = context.read<ConfiguracionViewModel>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Limpiar Caché',
          style: AppTextStyles.heading2Dark(context),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cleaning_services, size: 50, color: AppColors.primary),
            SizedBox(height: AppSpacing.medium),
            Text(
              '¿Estás seguro de que deseas limpiar el caché?',
              style: AppTextStyles.bodyDark(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.small),
            Text(
              'Se liberarán ${viewModel.configuracion.cacheSize} de espacio de almacenamiento',
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: AppTextStyles.bodyDark(context)),
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
            child: Text('Limpiar', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Acerca de IncosCheck',
              style: AppTextStyles.heading2Dark(context),
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
                style: AppTextStyles.heading1Dark(
                  context,
                ).copyWith(fontSize: 18, color: AppColors.primary),
              ),
              SizedBox(height: AppSpacing.small),
              Text(
                'Sistema de Gestión de Asistencias',
                style: AppTextStyles.bodyDark(
                  context,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: AppSpacing.medium),
              _buildInfoItem(
                context,
                'Desarrollado para:',
                'Instituto Técnico Comercial INCOS - El Alto',
              ),
              _buildInfoItem(
                context,
                'Desarrolladora:',
                'Est. Nicole Wara Colque Pachacuti\n(Sistemas Informáticos - Proyecto de Grado)',
              ),
              _buildInfoItem(
                context,
                'Contacto:',
                '+591 75205630\nincos@gmail.com',
              ),
              SizedBox(height: AppSpacing.medium),
              Text(
                '© 2025 Todos los derechos reservados',
                style: AppTextStyles.bodyDark(context).copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondaryDark(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: AppTextStyles.bodyDark(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyDark(context).copyWith(
              fontSize: 12,
              color: AppColors.textSecondaryDark(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyDark(context).copyWith(fontSize: 14),
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.privacy_tip, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Política de Privacidad',
              style: AppTextStyles.heading2Dark(context),
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
                style: AppTextStyles.bodyDark(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSpacing.medium),
              _buildPrivacyItem(
                context,
                '📊 Datos Recopilados:',
                '• Registros de asistencia\n• Información de estudiantes\n• Datos de docentes\n• Materias, carreras y horarios\n• Turnos y paralelos',
              ),
              _buildPrivacyItem(
                context,
                '🛡️ Protección:',
                '• Autenticación biométrica\n• Almacenamiento seguro en Firebase\n• Acceso restringido al personal autorizado',
              ),
              _buildPrivacyItem(
                context,
                '🚫 Uso de Datos:',
                '• Exclusivamente para control de asistencia interna\n• No se comparte con terceros\n• Uso educativo institucional',
              ),
              _buildPrivacyItem(
                context,
                '📝 Responsabilidad:',
                '• Instituto Técnico Comercial INCOS - El Alto\n• Cumplimiento de normativas educativas',
              ),
              SizedBox(height: AppSpacing.medium),
              Text(
                'Esta aplicación garantiza la confidencialidad y seguridad de los datos académicos.',
                style: AppTextStyles.bodyDark(context).copyWith(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondaryDark(context),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido', style: AppTextStyles.bodyDark(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyItem(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyDark(
              context,
            ).copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          SizedBox(height: 4),
          Text(
            content,
            style: AppTextStyles.bodyDark(context).copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ConfiguracionViewModel>();
    final config = viewModel.configuracion;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: AppTextStyles.heading2Dark(
            context,
          ).copyWith(color: Colors.white),
        ),
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
                _buildUserCard(context, isTablet),
                SizedBox(height: AppSpacing.large),

                // Configuración de notificaciones
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

                // Configuración de seguridad
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

                // Configuración de apariencia
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

                // Configuración de datos
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

                // Información y soporte
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

                // Cerrar sesión
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
                          Helpers.showSnackBar(
                            context,
                            'Sesión cerrada exitosamente',
                            type: 'success',
                          );
                        }
                      });
                    },
                    icon: Icon(Icons.exit_to_app, color: Colors.white),
                    label: Text('Cerrar Sesión', style: AppTextStyles.button),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
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
                  style: AppTextStyles.bodyDark(context).copyWith(
                    color: AppColors.textSecondaryDark(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, bool isTablet) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: [
            CircleAvatar(
              radius: isTablet ? 40 : 30,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.person,
                size: isTablet ? 30 : 20,
                color: Colors.white,
              ),
            ),
            SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usuario Demo',
                    style: AppTextStyles.heading2Dark(
                      context,
                    ).copyWith(fontSize: isTablet ? 20 : 18),
                  ),
                  SizedBox(height: AppSpacing.small),
                  Text(
                    'administrador@incos.edu.bo',
                    style: AppTextStyles.bodyDark(
                      context,
                    ).copyWith(color: AppColors.textSecondaryDark(context)),
                  ),
                  SizedBox(height: AppSpacing.small),
                  Chip(
                    label: Text(
                      'Administrador',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primary),
              onPressed: () {
                Helpers.showSnackBar(
                  context,
                  'Editar perfil de usuario',
                  type: 'success',
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
                  style: AppTextStyles.heading2Dark(
                    context,
                  ).copyWith(color: AppColors.primary),
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
          title: Text(title, style: AppTextStyles.bodyDark(context)),
          subtitle: Text(
            subtitle,
            style: AppTextStyles.bodyDark(context).copyWith(
              color: AppColors.textSecondaryDark(context),
              fontSize: 14,
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
        Divider(color: AppColors.background),
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
          title: Text(title, style: AppTextStyles.bodyDark(context)),
          subtitle: Text(
            subtitle,
            style: AppTextStyles.bodyDark(context).copyWith(
              color: AppColors.textSecondaryDark(context),
              fontSize: 14,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textSecondaryDark(context),
          ),
          onTap: onTap,
        ),
        Divider(color: AppColors.background),
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
          title: Text(title, style: AppTextStyles.bodyDark(context)),
          subtitle: Text(
            value,
            style: AppTextStyles.bodyDark(
              context,
            ).copyWith(color: AppColors.primary, fontSize: 14),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textSecondaryDark(context),
          ),
          onTap: onTap,
        ),
        Divider(color: AppColors.background),
      ],
    );
  }
}
