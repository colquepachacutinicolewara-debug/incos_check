import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  bool _autoSyncEnabled = true;
  String _selectedLanguage = 'Español';
  String _selectedTheme = 'Sistema';

  final List<String> _languages = ['Español', 'English', 'Português'];
  final List<String> _themes = ['Sistema', 'Claro', 'Oscuro'];

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Seleccionar Idioma',
          style: AppTextStyles.heading2,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              return RadioListTile(
                title: Text(_languages[index]),
                value: _languages[index],
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                  Helpers.showSnackBar(
                    context, 
                    'Idioma cambiado a $value',
                    type: 'success'
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Seleccionar Tema',
          style: AppTextStyles.heading2,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _themes.length,
            itemBuilder: (context, index) {
              return RadioListTile(
                title: Text(_themes[index]),
                value: _themes[index],
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  Navigator.pop(context);
                  Helpers.showSnackBar(
                    context, 
                    'Tema cambiado a $value',
                    type: 'success'
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Copia de Seguridad',
          style: AppTextStyles.heading2,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.backup, size: 60, color: AppColors.primary),
            SizedBox(height: AppSpacing.medium),
            Text(
              '¿Deseas crear una copia de seguridad de todos tus datos?',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: AppTextStyles.body),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Helpers.showSnackBar(
                context, 
                'Copia de seguridad creada exitosamente',
                type: 'success'
              );
            },
            child: Text('Crear Backup', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary, // CAMBIADO A CELESTE
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? AppSpacing.large : AppSpacing.medium),
            child: Column(
              children: [
                // Tarjeta de información del usuario
                _buildUserCard(isTablet),
                
                SizedBox(height: AppSpacing.large),
                
                // Configuración de notificaciones
                _buildSettingsSection(
                  'Notificaciones',
                  Icons.notifications,
                  [
                    _buildSwitchSetting(
                      'Notificaciones Push',
                      'Recibir notificaciones importantes',
                      _notificationsEnabled,
                      (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        Helpers.showSnackBar(
                          context, 
                          'Notificaciones ${value ? 'activadas' : 'desactivadas'}',
                          type: 'success'
                        );
                      },
                    ),
                    _buildSwitchSetting(
                      'Sincronización Automática',
                      'Sincronizar datos automáticamente',
                      _autoSyncEnabled,
                      (value) {
                        setState(() {
                          _autoSyncEnabled = value;
                        });
                        Helpers.showSnackBar(
                          context, 
                          'Sincronización automática ${value ? 'activada' : 'desactivada'}',
                          type: 'success'
                        );
                      },
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.large),
                
                // Configuración de seguridad
                _buildSettingsSection(
                  'Seguridad',
                  Icons.security,
                  [
                    _buildSwitchSetting(
                      'Autenticación Biométrica',
                      'Usar huella digital o reconocimiento facial',
                      _biometricEnabled,
                      (value) {
                        setState(() {
                          _biometricEnabled = value;
                        });
                        Helpers.showSnackBar(
                          context, 
                          'Autenticación biométrica ${value ? 'activada' : 'desactivada'}',
                          type: 'success'
                        );
                      },
                    ),
                    _buildActionSetting(
                      'Cambiar Contraseña',
                      Icons.lock,
                      'Actualizar contraseña de acceso',
                      () {
                        Helpers.showSnackBar(
                          context, 
                          'Redirigiendo a cambio de contraseña',
                          type: 'success'
                        );
                      },
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.large),
                
                // Configuración de apariencia
                _buildSettingsSection(
                  'Apariencia',
                  Icons.palette,
                  [
                    _buildSelectionSetting(
                      'Idioma',
                      Icons.language,
                      _selectedLanguage,
                      _showLanguageDialog,
                    ),
                    _buildSelectionSetting(
                      'Tema',
                      Icons.brightness_medium,
                      _selectedTheme,
                      _showThemeDialog,
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.large),
                
                // Configuración de datos
                _buildSettingsSection(
                  'Datos y Almacenamiento',
                  Icons.storage,
                  [
                    _buildActionSetting(
                      'Copia de Seguridad',
                      Icons.backup,
                      'Crear backup de todos los datos',
                      _showBackupDialog,
                    ),
                    _buildActionSetting(
                      'Limpiar Caché',
                      Icons.cleaning_services,
                      'Liberar espacio de almacenamiento',
                      () {
                        Helpers.showConfirmationDialog(
                          context,
                          title: 'Limpiar Caché',
                          content: '¿Estás seguro de limpiar el caché?',
                        ).then((confirmed) {
                          if (confirmed) {
                            Helpers.showSnackBar(
                              context, 
                              'Caché limpiado exitosamente',
                              type: 'success'
                            );
                          }
                        });
                      },
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.large),
                
                // Información y soporte
                _buildSettingsSection(
                  'Información',
                  Icons.info,
                  [
                    _buildActionSetting(
                      'Acerca de ${AppStrings.appName}',
                      Icons.business,
                      'Información de la aplicación',
                      () {
                        Helpers.showSnackBar(
                          context, 
                          'Mostrando información de la aplicación',
                          type: 'success'
                        );
                      },
                    ),
                    _buildActionSetting(
                      'Ayuda y Soporte',
                      Icons.help,
                      'Centro de ayuda y contacto',
                      () {
                        Helpers.showSnackBar(
                          context, 
                          'Navegando a ayuda y soporte',
                          type: 'success'
                        );
                      },
                    ),
                    _buildActionSetting(
                      'Política de Privacidad',
                      Icons.privacy_tip,
                      'Términos y condiciones de uso',
                      () {
                        Helpers.showSnackBar(
                          context, 
                          'Mostrando política de privacidad',
                          type: 'success'
                        );
                      },
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.large),
                
                // Cerrar sesión
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Helpers.showConfirmationDialog(
                        context,
                        title: 'Cerrar Sesión',
                        content: Messages.confirmacion,
                      ).then((confirmed) {
                        if (confirmed) {
                          Helpers.showSnackBar(
                            context, 
                            'Sesión cerrada exitosamente',
                            type: 'success'
                          );
                        }
                      });
                    },
                    icon: Icon(Icons.exit_to_app, color: Colors.white),
                    label: Text(
                      AppStrings.logout,
                      style: AppTextStyles.button,
                    ),
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
                
                // Información de versión
                Text(
                  'Versión 1.0.0',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
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

  Widget _buildUserCard(bool isTablet) {
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
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: isTablet ? 20 : 18,
                    ),
                  ),
                  SizedBox(height: AppSpacing.small),
                  Text(
                    'administrador@incos.edu.bo',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.small),
                  Chip(
                    label: Text(
                      UserRoles.administrador,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
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
                  type: 'success'
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> settings) {
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
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
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

  Widget _buildSwitchSetting(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(title, style: AppTextStyles.body),
          subtitle: Text(subtitle, style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          )),
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        Divider(color: AppColors.background),
      ],
    );
  }

  Widget _buildActionSetting(String title, IconData icon, String subtitle, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: AppTextStyles.body),
          subtitle: Text(subtitle, style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          )),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          onTap: onTap,
        ),
        Divider(color: AppColors.background),
      ],
    );
  }

  Widget _buildSelectionSetting(String title, IconData icon, String value, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: AppTextStyles.body),
          subtitle: Text(value, style: AppTextStyles.body.copyWith(
            color: AppColors.primary,
            fontSize: 14,
          )),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          onTap: onTap,
        ),
        Divider(color: AppColors.background),
      ],
    );
  }
}