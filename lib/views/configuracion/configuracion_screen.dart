import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/configuracion_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart' as dashboard_vm;
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../services/theme_service.dart';
import '../configuracion/soporte/soporte_screen.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ConfiguracionView();
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
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

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
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña actual',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: AppColors.primary,
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: AppSpacing.medium),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_reset, color: AppColors.primary),
                  hintText:
                      'Mín. 6 caracteres, mayúscula, minúscula, carácter especial',
                ),
                obscureText: true,
              ),
              SizedBox(height: AppSpacing.medium),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.verified_user,
                    color: AppColors.primary,
                  ),
                ),
                obscureText: true,
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
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    _buildSimpleRequirement('Mínimo 6 caracteres'),
                    _buildSimpleRequirement('Una letra mayúscula (A-Z)'),
                    _buildSimpleRequirement('Una letra minúscula (a-z)'),
                    _buildSimpleRequirement(
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
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentPassword = _currentPasswordController.text;
              final newPassword = _newPasswordController.text;
              final confirmPassword = _confirmPasswordController.text;

              if (newPassword != confirmPassword) {
                Helpers.showSnackBar(
                  context,
                  '❌ Las contraseñas no coinciden',
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

              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final cred = EmailAuthProvider.credential(
                    email: user.email!,
                    password: currentPassword,
                  );

                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(newPassword);

                  _currentPasswordController.clear();
                  _newPasswordController.clear();
                  _confirmPasswordController.clear();

                  Navigator.pop(context);
                  Helpers.showSnackBar(
                    context,
                    '✅ Contraseña cambiada exitosamente',
                    type: 'success',
                  );
                }
              } on FirebaseAuthException catch (e) {
                Helpers.showSnackBar(
                  context,
                  '❌ Error: ${e.message}',
                  type: 'error',
                );
              } catch (e) {
                Helpers.showSnackBar(
                  context,
                  '❌ Error al cambiar contraseña',
                  type: 'error',
                );
              }
            },
            child: Text('Cambiar Contraseña'),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleRequirement(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, size: 14, color: AppColors.primary),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11)),
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
            child: Text('Cancelar'),
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
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.small),
              Text(
                'Sistema de Gestión de Asistencias',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: AppSpacing.medium),
              _buildInfoItem(
                'Desarrollado para:',
                'Instituto Técnico Comercial INCOS - El Alto',
              ),
              _buildInfoItem(
                'Desarrolladora:',
                'Est. Nicole Wara Colque Pachacuti\n(Sistemas Informáticos - Proyecto de Grado)',
              ),
              _buildInfoItem('Contacto:', '+591 75205630\nincos@gmail.com'),
              SizedBox(height: AppSpacing.medium),
              Text(
                '© 2025 Todos los derechos reservados',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(value, style: TextStyle(fontSize: 14)),
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSpacing.medium),
              _buildPrivacyItem(
                '📊 Datos Recopilados:',
                '• Registros de asistencia\n• Información de estudiantes\n• Datos de docentes\n• Materias, carreras y horarios\n• Turnos y paralelos',
              ),
              _buildPrivacyItem(
                '🛡️ Protección:',
                '• Autenticación biométrica\n• Almacenamiento seguro en Firebase\n• Acceso restringido al personal autorizado',
              ),
              _buildPrivacyItem(
                '🚫 Uso de Datos:',
                '• Exclusivamente para control de asistencia interna\n• No se comparte con terceros\n• Uso educativo institucional',
              ),
              _buildPrivacyItem(
                '📝 Responsabilidad:',
                '• Instituto Técnico Comercial INCOS - El Alto\n• Cumplimiento de normativas educativas',
              ),
              SizedBox(height: AppSpacing.medium),
              Text(
                'Esta aplicación garantiza la confidencialidad y seguridad de los datos académicos.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyItem(String title, String content) {
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
          Text(content, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) async {
    try {
      final dashboardVM = context.read<dashboard_vm.DashboardViewModel>();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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

      await dashboardVM.logout();

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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ConfiguracionViewModel>();
    final config = viewModel.configuracion;
    final user = FirebaseAuth.instance.currentUser;

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
                _buildUserCard(context, isTablet, user),
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
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, bool isTablet, User? user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: [
            CircleAvatar(
              radius: isTablet ? 40 : 30,
              backgroundColor: AppColors.primary,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? Icon(
                      Icons.person,
                      size: isTablet ? 30 : 20,
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'Usuario',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.small),
                  Text(
                    user?.email ?? 'No email',
                    style: TextStyle(color: Colors.grey.shade600),
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
          title: Text(title),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        Divider(height: 1),
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
          title: Text(title),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
        Divider(height: 1),
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
          title: Text(title),
          subtitle: Text(
            value,
            style: TextStyle(color: AppColors.primary, fontSize: 14),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
        Divider(height: 1),
      ],
    );
  }
}
