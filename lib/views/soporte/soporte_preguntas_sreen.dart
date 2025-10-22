import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class SoportePreguntasScreen extends StatelessWidget {
  const SoportePreguntasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preguntas Frecuentes"),
        centerTitle: true,
        elevation: 4,
        backgroundColor: AppColors.secondary, // Color celeste
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          _buildPreguntaItem(
            context,
            "¿Cómo registro la asistencia de los estudiantes?",
            "Puedes registrar la asistencia de dos formas:\n\n"
            "1. Escaneo QR: Usa la cámara para escanear el código QR del estudiante\n"
            "2. Manual: Selecciona manualmente a los estudiantes y marca su asistencia\n\n"
            "La asistencia se guarda automáticamente en el sistema.",
          ),
          _buildPreguntaItem(
            context,
            "¿Qué hago si un estudiante llega tarde?",
            "En el registro de asistencia, puedes marcar la opción 'Tardanza' en lugar de 'Presente'. "
            "El sistema registrará automáticamente la hora de registro y la marcará como tardanza. "
            "Puedes ver el reporte de tardanzas en la sección de Reportes.",
          ),
          _buildPreguntaItem(
            context,
            "¿Cómo genero reportes de asistencia?",
            "Dirígete a la sección 'Reportes' y selecciona el tipo de reporte que necesitas:\n\n"
            "• Reporte general de asistencia\n"
            "• Reporte por curso específico\n"
            "• Reporte por estudiante\n"
            "• Estadísticas mensuales\n\n"
            "Puedes exportar los reportes en PDF o Excel.",
          ),
          _buildPreguntaItem(
            context,
            "¿Puedo gestionar múltiples cursos?",
            "Sí, en la sección 'Gestión Académica' puedes:\n\n"
            "• Crear y editar cursos\n"
            "• Asignar estudiantes a cursos\n"
            "• Gestionar docentes\n"
            "• Administrar carreras\n\n"
            "Cada curso mantiene su propio registro de asistencia.",
          ),
          _buildPreguntaItem(
            context,
            "¿Cómo restablezco mi contraseña?",
            "Para restablecer tu contraseña:\n\n"
            "1. Ve a Configuración → Seguridad\n"
            "2. Selecciona 'Cambiar Contraseña'\n"
            "3. Sigue las instrucciones en pantalla\n\n"
            "Si tienes problemas, contacta al administrador del sistema.",
          ),
          _buildPreguntaItem(
            context,
            "¿La aplicación funciona sin internet?",
            "Sí, la aplicación funciona en modo offline para el registro de asistencia. "
            "Los datos se sincronizarán automáticamente cuando recuperes la conexión a internet. "
            "Algunas funciones como la generación de reportes requieren conexión.",
          ),
          _buildPreguntaItem(
            context,
            "¿Cómo agrego nuevos estudiantes al sistema?",
            "Para agregar nuevos estudiantes:\n\n"
            "1. Ve a Gestión Académica → Estudiantes\n"
            "2. Toca el botón '+' en la esquina inferior derecha\n"
            "3. Completa los datos del estudiante\n"
            "4. Asigna el estudiante a un curso\n\n"
            "Los cambios se reflejarán inmediatamente.",
          ),
          _buildPreguntaItem(
            context,
            "¿Qué significan los diferentes estados de asistencia?",
            "Los estados de asistencia son:\n\n"
            "• ✅ Presente: Estudiante asistió puntualmente\n"
            "• ⏰ Tardanza: Estudiante llegó después de la hora establecida\n"
            "• ❌ Ausente: Estudiante no asistió\n"
            "• 📊 Estadísticas: Porcentaje de asistencia del estudiante",
          ),
          _buildPreguntaItem(
            context,
            "¿Cómo contacto con soporte técnico?",
            "Puedes contactarnos por:\n\n"
            "• WhatsApp: +591 60696135\n"
            "• Email: incos@gmail.com\n"
            "• Teléfono: +591 60696135\n\n"
            "Estamos disponibles de lunes a viernes de 8:00 a 18:00.",
          ),
          _buildPreguntaItem(
            context,
            "¿Los datos están seguros en la aplicación?",
            "Sí, todos los datos están protegidos con:\n\n"
            "• Encriptación de información sensible\n"
            "• Autenticación segura\n"
            "• Copias de seguridad automáticas\n"
            "• Cumplimiento de políticas de privacidad\n\n"
            "Solo el personal autorizado tiene acceso a la información.",
          ),
        ],
      ),
    );
  }

  Widget _buildPreguntaItem(BuildContext context, String pregunta, String respuesta) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      elevation: 3,
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline, color: AppColors.primary),
        title: Text(
          pregunta,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Text(
              respuesta,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}