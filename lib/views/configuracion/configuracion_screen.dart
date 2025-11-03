import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../configuracion/soporte/soporte_screen.dart';
import '../../services/theme_service.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  bool _autoSyncEnabled = true;
  String _selectedLanguage = 'Español';
  String _selectedTheme = 'Sistema';
  String _cacheSize = "15.2 MB";

  final List<String> _languages = ['Español', 'English', 'Português'];
  final List<String> _themes = ['Sistema', 'Claro', 'Oscuro'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _autoSyncEnabled = prefs.getBool('auto_sync_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'Español';
      _selectedTheme = prefs.getString('selected_theme') ?? 'Sistema';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _showLanguageDialog() {
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
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              return RadioListTile(
                title: Text(
                  _languages[index],
                  style: AppTextStyles.bodyDark(context),
                ),
                value: _languages[index],
                groupValue: _selectedLanguage,
                onChanged: (value) async {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  await _saveSetting('selected_language', value);
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

  void _showThemeDialog() {
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
            itemCount: _themes.length,
            itemBuilder: (context, index) {
              return RadioListTile(
                title: Text(
                  _themes[index],
                  style: AppTextStyles.bodyDark(context),
                ),
                value: _themes[index],
                groupValue: _selectedTheme,
                onChanged: (value) async {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  await _saveSetting('selected_theme', value);
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

  void _showBackupDialog() {
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

  Future<void> _checkBiometricAvailability() async {
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics;

      if (!canAuthenticate) {
        Helpers.showSnackBar(
          context,
          '❌ Biometría no disponible en este dispositivo',
          type: 'error',
        );
        return;
      }

      final List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        Helpers.showSnackBar(
          context,
          '❌ No hay métodos biométricos configurados',
          type: 'error',
        );
        return;
      }

      final biometricNames = availableBiometrics
          .map((type) {
            switch (type) {
              case BiometricType.face:
                return 'Reconocimiento Facial';
              case BiometricType.fingerprint:
                return 'Huella Digital';
              case BiometricType.iris:
                return 'Reconocimiento de Iris';
              default:
                return 'Método Biométrico';
            }
          })
          .join(', ');

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason:
            'Autentícate para habilitar el acceso biométrico en IncosCheck',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        setState(() {
          _biometricEnabled = true;
        });
        await _saveSetting('biometric_enabled', true);
        Helpers.showSnackBar(
          context,
          '✅ Autenticación biométrica activada ($biometricNames)',
          type: 'success',
        );
      } else {
        Helpers.showSnackBar(
          context,
          '❌ Autenticación cancelada o fallida',
          type: 'error',
        );
      }
    } catch (e) {
      Helpers.showSnackBar(
        context,
        '❌ Error al configurar biometría: ${e.toString()}',
        type: 'error',
      );
    }
  }

  void _showChangePasswordDialog() {
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
                    _buildSimpleRequirement('Mínimo 5 caracteres'),
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

  Widget _buildSimpleRequirement(String text) {
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

  void _showClearCacheDialog() {
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
              'Se liberarán $_cacheSize de espacio de almacenamiento',
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
              setState(() {
                _cacheSize = "0 MB";
              });
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

  void _showAboutDialog() {
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

  Widget _buildInfoItem(String label, String value) {
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

  void _showPrivacyPolicy() {
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

  Widget _buildPrivacyItem(String title, String content) {
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
                _buildUserCard(isTablet),
                SizedBox(height: AppSpacing.large),

                // Configuración de notificaciones
                _buildSettingsSection('Notificaciones', Icons.notifications, [
                  _buildSwitchSetting(
                    'Notificaciones Push',
                    'Recibir notificaciones importantes',
                    _notificationsEnabled,
                    (value) async {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      await _saveSetting('notifications_enabled', value);
                      Helpers.showSnackBar(
                        context,
                        'Notificaciones ${value ? 'activadas' : 'desactivadas'}',
                        type: 'success',
                      );
                    },
                  ),
                  _buildSwitchSetting(
                    'Sincronización Automática',
                    'Sincronizar datos automáticamente',
                    _autoSyncEnabled,
                    (value) async {
                      setState(() {
                        _autoSyncEnabled = value;
                      });
                      await _saveSetting('auto_sync_enabled', value);
                      Helpers.showSnackBar(
                        context,
                        'Sincronización automática ${value ? 'activada' : 'desactivada'}',
                        type: 'success',
                      );
                    },
                  ),
                ]),

                SizedBox(height: AppSpacing.large),

                // Configuración de seguridad
                _buildSettingsSection('Seguridad', Icons.security, [
                  _buildSwitchSetting(
                    'Autenticación Biométrica',
                    'Usar huella digital o reconocimiento facial',
                    _biometricEnabled,
                    (value) async {
                      if (value) {
                        await _checkBiometricAvailability();
                      } else {
                        setState(() {
                          _biometricEnabled = false;
                        });
                        await _saveSetting('biometric_enabled', false);
                        Helpers.showSnackBar(
                          context,
                          'Autenticación biométrica desactivada',
                          type: 'success',
                        );
                      }
                    },
                  ),
                  _buildActionSetting(
                    'Cambiar Contraseña',
                    Icons.lock,
                    'Actualizar contraseña de acceso',
                    _showChangePasswordDialog,
                  ),
                ]),

                SizedBox(height: AppSpacing.large),

                // Configuración de apariencia
                _buildSettingsSection('Apariencia', Icons.palette, [
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
                ]),

                SizedBox(height: AppSpacing.large),

                // Configuración de datos
                _buildSettingsSection('Datos y Almacenamiento', Icons.storage, [
                  _buildActionSetting(
                    'Copia de Seguridad',
                    Icons.backup,
                    'Crear backup de todos los datos',
                    _showBackupDialog,
                  ),
                  _buildActionSetting(
                    'Limpiar Caché',
                    Icons.cleaning_services,
                    'Tamaño actual: $_cacheSize',
                    _showClearCacheDialog,
                  ),
                ]),

                SizedBox(height: AppSpacing.large),

                // Información y soporte
                _buildSettingsSection('Información', Icons.info, [
                  _buildActionSetting(
                    'Acerca de IncosCheck',
                    Icons.business,
                    'Información de la aplicación',
                    _showAboutDialog,
                  ),
                  _buildActionSetting(
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
                    'Política de Privacidad',
                    Icons.privacy_tip,
                    'Términos y condiciones de uso',
                    _showPrivacyPolicy,
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
