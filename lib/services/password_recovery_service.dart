// 🌟 NUEVO: Servicio de recuperación de contraseña
// services/password_recovery_service.dart
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class PasswordRecoveryService {
  static final PasswordRecoveryService _instance = PasswordRecoveryService._internal();
  factory PasswordRecoveryService() => _instance;
  PasswordRecoveryService._internal();

  // Configuración del servidor SMTP (Gmail)
  final smtpServer = gmail('colquepachacuti@gmail.com', 'tu_password_de_aplicacion'); 
  // Nota: Necesitarás una "Contraseña de aplicación" de Gmail

  // 🌟 Base de datos de usuarios y sus correos
  final Map<String, Map<String, String>> _userEmailDatabase = {
    'admin': {
      'email': 'colquepachacuti@gmail.com',
      'nombre': 'Administrador Principal'
    },
    'profesor': {
      'email': 'nicolewaracolquepachacuti4@gmail.com', 
      'nombre': 'Profesor del Sistema'
    },
    'director': {
      'email': 'colquepachacuti@gmail.com', // Mismo que admin por ahora
      'nombre': 'Director Académico'
    }
  };

  // 🌟 Verificar si el usuario existe y obtener su correo
  Future<Map<String, String>?> getUserEmail(String username) async {
    final userData = _userEmailDatabase[username.toLowerCase()];
    if (userData != null) {
      return {
        'email': userData['email']!,
        'nombre': userData['nombre']!,
        'username': username
      };
    }
    return null;
  }

  // 🌟 Generar contraseña temporal
  String _generateTemporaryPassword() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return 'temp${random.toString().substring(8)}';
  }

  // 🌟 Enviar correo de recuperación
  Future<Map<String, dynamic>> sendPasswordRecoveryEmail(String username) async {
    try {
      // Verificar si el usuario existe
      final userInfo = await getUserEmail(username);
      if (userInfo == null) {
        return {
          'success': false,
          'error': 'Usuario no encontrado en el sistema'
        };
      }

      // Generar contraseña temporal
      final temporaryPassword = _generateTemporaryPassword();

      // Crear el mensaje de correo
      final message = Message()
        ..from = const Address('colquepachacuti@gmail.com', 'Sistema INCOS Check')
        ..recipients.add(userInfo['email']!)
        ..subject = 'Recuperación de Contraseña - INCOS Check'
        ..html = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #1565C0, #42A5F5); color: white; padding: 20px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .password-box { background: #e3f2fd; border: 2px dashed #1565C0; padding: 15px; text-align: center; margin: 20px 0; border-radius: 8px; }
        .warning { background: #ffebee; border-left: 4px solid #f44336; padding: 10px; margin: 15px 0; }
        .footer { text-align: center; margin-top: 30px; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 INCOS Check</h1>
            <p>Sistema de Control de Asistencia Biométrica</p>
        </div>
        <div class="content">
            <h2>Hola ${userInfo['nombre']},</h2>
            <p>Has solicitado recuperar tu contraseña para el usuario: <strong>${userInfo['username']}</strong></p>
            
            <div class="password-box">
                <h3>🆕 Contraseña Temporal</h3>
                <p style="font-size: 24px; font-weight: bold; color: #1565C0; margin: 10px 0;">$temporaryPassword</p>
                <p style="font-size: 14px; color: #666;">Esta contraseña es válida por 24 horas</p>
            </div>

            <div class="warning">
                <p><strong>⚠️ Importante:</strong></p>
                <ul>
                    <li>Cambia esta contraseña temporal inmediatamente después de ingresar al sistema</li>
                    <li>No compartas esta contraseña con nadie</li>
                    <li>Si no solicitaste este cambio, contacta al administrador inmediatamente</li>
                </ul>
            </div>

            <p>Para cambiar tu contraseña:</p>
            <ol>
                <li>Ingresa al sistema con la contraseña temporal</li>
                <li>Ve a tu perfil de usuario</li>
                <li>Selecciona "Cambiar Contraseña"</li>
                <li>Establece una nueva contraseña segura</li>
            </ol>

            <p>¿Necesitas ayuda? Contacta al soporte técnico.</p>
        </div>
        <div class="footer">
            <p>Instituto Comercial Superior El Alto<br>
            Sistema INCOS Check © 2024</p>
        </div>
    </div>
</body>
</html>
        ''';

      // Enviar el correo
      try {
        final sendReport = await send(message, smtpServer);
        
        // 🌟 ACTUALIZAR LA CONTRASEña EN LA BASE DE DATOS
        final updateSuccess = await _updatePasswordInDatabase(
          userInfo['username']!, 
          temporaryPassword
        );

        if (updateSuccess) {
          return {
            'success': true,
            'message': 'Se ha enviado una contraseña temporal a ${userInfo['email']}',
            'temporaryPassword': temporaryPassword, // Solo para debug
            'email': userInfo['email']
          };
        } else {
          return {
            'success': false,
            'error': 'Error al actualizar la contraseña en la base de datos'
          };
        }
      } catch (e) {
        return {
          'success': false,
          'error': 'Error al enviar el correo: $e'
        };
      }

    } catch (e) {
      return {
        'success': false,
        'error': 'Error en el proceso de recuperación: $e'
      };
    }
  }

  // 🌟 Actualizar contraseña en la base de datos SQLite
  Future<bool> _updatePasswordInDatabase(String username, String newPassword) async {
    try {
      // Aquí integrarías con tu DatabaseHelper
      // Por ahora simulamos la actualización
      print('🔐 Actualizando contraseña para $username: $newPassword');
      
      // TODO: Integrar con tu DatabaseHelper.actualizarPassword()
      // await DatabaseHelper.instance.actualizarPassword(userId, newPassword);
      
      return true;
    } catch (e) {
      print('❌ Error actualizando contraseña: $e');
      return false;
    }
  }
}