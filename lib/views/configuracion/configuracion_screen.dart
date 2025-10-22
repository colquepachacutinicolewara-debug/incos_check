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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.grey[700],
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Notificaciones Push', style: AppTextStyles.body),
            value: _notificationsEnabled,
            onChanged: (value) {
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
          Divider(color: AppColors.background),
          _buildSettingItem(Icons.person, 'Perfil de Usuario', () {
            Helpers.showSnackBar(context, 'Abriendo perfil de usuario');
          }),
          _buildSettingItem(Icons.security, 'Privacidad y Seguridad', () {
            Helpers.showSnackBar(context, 'Configuración de privacidad');
          }),
          _buildSettingItem(Icons.language, 'Idioma', () {
            Helpers.showSnackBar(context, 'Seleccionar idioma');
          }),
          Divider(color: AppColors.background),
          _buildSettingItem(Icons.help, 'Ayuda y Soporte', () {
            Helpers.showSnackBar(context, 'Navegando a ayuda');
          }),
          _buildSettingItem(Icons.info, 'Acerca de ${AppStrings.appName}', () {
            Helpers.showSnackBar(context, 'Información de la aplicación');
          }),
          _buildSettingItem(Icons.exit_to_app, AppStrings.logout, () {
            Helpers.showConfirmationDialog(
              context,
              title: 'Cerrar Sesión',
              content: Messages.confirmacion,
            ).then((confirmed) {
              if (confirmed) {
                Helpers.showSnackBar(context, 'Sesión cerrada', type: 'success');
              }
            });
          }),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}