import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';

class SoportePreguntasScreen extends StatelessWidget {
  const SoportePreguntasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Centro de Ayuda - IncosCheck"),
        centerTitle: true,
        elevation: 4,
        backgroundColor: AppColors.secondary,
      ),
      body: Column(
        children: [
          // Header con búsqueda
          _buildHeader(context),
          // Categorías rápidas
          _buildCategoriasRapidas(context),
          // Lista de preguntas
          Expanded(child: _buildListaPreguntas(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.live_help_rounded,
            size: 50,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            "¿En qué podemos ayudarte?",
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.primary,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.medium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar en preguntas frecuentes...",
                border: InputBorder.none,
                icon: Icon(Icons.search, color: AppColors.primary),
                suffixIcon: Icon(Icons.filter_list, color: AppColors.primary),
              ),
              onChanged: (value) {
                // Implementar búsqueda
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriasRapidas(BuildContext context) {
    final categorias = [
      {
        'icon': Icons.qr_code_scanner,
        'color': Colors.blue,
        'text': 'Registro QR',
      },
      {'icon': Icons.bar_chart, 'color': Colors.green, 'text': 'Reportes'},
      {'icon': Icons.school, 'color': Colors.orange, 'text': 'Cursos'},
      {'icon': Icons.security, 'color': Colors.red, 'text': 'Seguridad'},
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Categorías Populares",
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final categoria = categorias[index];
                return _buildCategoriaItem(
                  categoria['icon'] as IconData,
                  categoria['color'] as Color,
                  categoria['text'] as String,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaItem(IconData icon, Color color, String text) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppSpacing.medium),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            text,
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildListaPreguntas(BuildContext context) {
    final preguntas = [
      {
        'pregunta': "¿Cómo registro la asistencia de los estudiantes?",
        'respuesta':
            "Puedes registrar la asistencia de dos formas:\n\n"
            "📱 **Escaneo QR**: Usa la cámara para escanear el código QR del estudiante\n"
            "👆 **Manual**: Selecciona manualmente a los estudiantes y marca su asistencia\n\n"
            "💾 La asistencia se guarda automáticamente en el sistema.",
        'categoria': 'Registro QR',
        'icon': Icons.qr_code_scanner,
      },
      {
        'pregunta': "¿Qué hago si un estudiante llega tarde?",
        'respuesta':
            "En el registro de asistencia, puedes marcar la opción '⏰ Tardanza' en lugar de '✅ Presente'. "
            "El sistema registrará automáticamente la hora de registro y la marcará como tardanza. "
            "Puedes ver el reporte de tardanzas en la sección de 📊 Reportes.",
        'categoria': 'Registro QR',
        'icon': Icons.access_time,
      },
      {
        'pregunta': "¿Cómo genero reportes de asistencia?",
        'respuesta':
            "Dirígete a la sección '📊 Reportes' y selecciona el tipo de reporte que necesitas:\n\n"
            "• 📈 Reporte general de asistencia\n"
            "• 🎯 Reporte por curso específico\n"
            "• 👨‍🎓 Reporte por estudiante\n"
            "• 📅 Estadísticas mensuales\n\n"
            "💡 Puedes exportar los reportes en PDF o Excel.",
        'categoria': 'Reportes',
        'icon': Icons.bar_chart,
      },
      {
        'pregunta': "¿Puedo gestionar múltiples cursos?",
        'respuesta':
            "✅ Sí, en la sección '🏫 Gestión Académica' puedes:\n\n"
            "• 📚 Crear y editar cursos\n"
            "• 👥 Asignar estudiantes a cursos\n"
            "• 👨‍🏫 Gestionar docentes\n"
            "• 🎓 Administrar carreras\n\n"
            "Cada curso mantiene su propio registro de asistencia.",
        'categoria': 'Cursos',
        'icon': Icons.school,
      },
      {
        'pregunta': "¿Cómo restablezco mi contraseña?",
        'respuesta':
            "Para restablecer tu contraseña:\n\n"
            "1. ⚙️ Ve a Configuración → Seguridad\n"
            "2. 🔒 Selecciona 'Cambiar Contraseña'\n"
            "3. 📝 Sigue las instrucciones en pantalla\n\n"
            "🆘 Si tienes problemas, contacta al administrador del sistema.",
        'categoria': 'Seguridad',
        'icon': Icons.lock,
      },
      {
        'pregunta': "¿La aplicación funciona sin internet?",
        'respuesta':
            "📶 **Sí**, la aplicación funciona en modo offline para el registro de asistencia. "
            "Los datos se sincronizarán automáticamente cuando recuperes la conexión a internet. "
            "Algunas funciones como la generación de reportes requieren conexión.",
        'categoria': 'General',
        'icon': Icons.wifi_off,
      },
      {
        'pregunta': "¿Cómo agrego nuevos estudiantes al sistema?",
        'respuesta':
            "Para agregar nuevos estudiantes:\n\n"
            "1. 🏫 Ve a Gestión Académica → Estudiantes\n"
            "2. ➕ Toca el botón '+' en la esquina inferior derecha\n"
            "3. 📝 Completa los datos del estudiante\n"
            "4. 🎯 Asigna el estudiante a un curso\n\n"
            "Los cambios se reflejarán inmediatamente.",
        'categoria': 'Cursos',
        'icon': Icons.person_add,
      },
      {
        'pregunta': "¿Qué significan los diferentes estados de asistencia?",
        'respuesta':
            "Los estados de asistencia son:\n\n"
            "• ✅ **Presente**: Estudiante asistió puntualmente\n"
            "• ⏰ **Tardanza**: Estudiante llegó después de la hora establecida\n"
            "• ❌ **Ausente**: Estudiante no asistió\n"
            "• 📊 **Estadísticas**: Porcentaje de asistencia del estudiante",
        'categoria': 'General',
        'icon': Icons.info,
      },
      {
        'pregunta': "¿Cómo contacto con soporte técnico?",
        'respuesta':
            "Puedes contactarnos por:\n\n"
            "• 💬 **WhatsApp**: +591 75205630\n"
            "• 📧 **Email**: incos@gmail.com\n"
            "• 📞 **Teléfono**: +591 75205630\n\n"
            "🕐 Estamos disponibles de lunes a viernes de 8:00 a 18:00.",
        'categoria': 'General',
        'icon': Icons.support_agent,
      },
      {
        'pregunta': "¿Los datos están seguros en la aplicación?",
        'respuesta':
            "🛡️ **Sí**, todos los datos están protegidos con:\n\n"
            "• 🔐 Encriptación de información sensible\n"
            "• 👤 Autenticación segura\n"
            "• 💾 Copias de seguridad automáticas\n"
            "• 📜 Cumplimiento de políticas de privacidad\n\n"
            "Solo el personal autorizado tiene acceso a la información.",
        'categoria': 'Seguridad',
        'icon': Icons.security,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.medium),
      itemCount: preguntas.length,
      itemBuilder: (context, index) {
        final pregunta = preguntas[index];
        return _buildPreguntaItem(
          context,
          pregunta['pregunta'] as String,
          pregunta['respuesta'] as String,
          pregunta['categoria'] as String,
          pregunta['icon'] as IconData,
        );
      },
    );
  }

  Widget _buildPreguntaItem(
    BuildContext context,
    String pregunta,
    String respuesta,
    String categoria,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.primary.withOpacity(0.05), Colors.transparent],
          ),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(
            pregunta,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    categoria,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing: const Icon(Icons.help_outline, color: AppColors.primary),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.medium),
                  bottomRight: Radius.circular(AppRadius.medium),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      respuesta,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Divider(color: AppColors.background),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "¿Te sirvió esta respuesta?",
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.thumb_up_alt_outlined,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                Helpers.showSnackBar(
                                  context,
                                  "¡Gracias por tu feedback!",
                                  type: 'success',
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.thumb_down_alt_outlined,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                Helpers.showSnackBar(
                                  context,
                                  "Lamentamos que no te haya servido. ¿Quieres contactar con soporte?",
                                  type: 'info',
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
