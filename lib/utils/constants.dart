// utils/constants.dart
import 'package:flutter/material.dart';

/// ===========================
/// 🎨 COLORES DE LA APP
/// ===========================
class AppColors {
  static const Color primary = Color(0xFF1565C0); // Azul fuerte
  static const Color secondary = Color(0xFF42A5F5); // Celeste
  static const Color accent = Color(0xFF90CAF9); // Azul claro
  static const Color background = Color(0xFFF5F5F5);
  static const Color info = Color(0xFF17A2B8);

  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);

  // COLORES ORIGINALES (se mantienen para compatibilidad)
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;

  // NUEVOS COLORES PARA TEMA OSCURO
  static Color textPrimaryDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black87;

  static Color textSecondaryDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white70
          : Colors.black54;

  static const Color border = Color(0xFFE0E0E0); // ejemplo de gris
}

/// 🧍 Colores personalizados por tipo de usuario
class UserThemeColors {
  static const Color administrador = Color(0xFF1565C0); // Azul fuerte
  static const Color docente = Color(0xFF42A5F5); // Celeste
  static const Color estudiante = Color(0xFF29B6F6); // Azul intermedio
  static const Color jefeCarrera = Color(0xFF64B5F6); // Azul claro
  static const Color directorAcademico = Color(0xFF1976D2); // Azul intenso
}

/// ===========================
/// ✍ ESTILOS DE TEXTO
/// ===========================
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 🆕 NUEVO ESTILO HEADING3 - SIGUIENDO EL PATRÓN EXISTENTE
  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16, 
    color: AppColors.textSecondary
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Añadido para el drawer
  static const TextStyle drawerItem = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  // NUEVOS ESTILOS PARA TEMA OSCURO (usa estos en lugar de los originales)
  static TextStyle heading1Dark(BuildContext context) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppColors.primary,
      );

  static TextStyle heading2Dark(BuildContext context) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark(context),
      );

  static TextStyle heading3Dark(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark(context),
      );

  static TextStyle bodyDark(BuildContext context) => TextStyle(
        fontSize: 16, 
        color: AppColors.textSecondaryDark(context)
      );

  static TextStyle drawerItemDark(BuildContext context) => TextStyle(
        fontSize: 16, 
        color: AppColors.textPrimaryDark(context)
      );
}

/// ===========================
/// 📏 ESPACIADOS Y RADIOS
/// ===========================
class AppSpacing {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xlarge = 32.0;
}

class AppRadius {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}

/// ===========================
/// 🖼 ASSETS / ICONOS
/// ===========================
class AppAssets {
  static const String logo = "assets/logo.png";
  static const String userPlaceholder = "assets/images/user.png";
  static const String huellaIcon = "assets/icons/huella.png";
}

/// ===========================
/// 🔑 STRINGS COMUNES
/// ===========================
class AppStrings {
  static const String appName = "IncosCheck";
  static const String login = "Iniciar Sesión";
  static const String logout = "Cerrar Sesión";
  static const String dashboard = "IncosCheck";
  static const String asistencia = "Registro de Asistencia";
  static const String estudiantes = "Estudiantes";
  static const String docentes = "Docentes";
  static const String gestion = "Gestión Académica";
  static const String reportes = "Reportes";
  static const String configuracion = "Configuración";
  static const String soporte = "Soporte";
  static const String inicio = "Inicio";
}

/// ===========================
/// 👤 ROLES DE USUARIO
/// ===========================
class UserRoles {
  static const String administrador = 'Administrador';
  static const String docente = 'Docente';
  static const String estudiante = 'Estudiante';
  static const String jefeCarrera = 'Jefe de Carrera';
  static const String directorAcademico = 'Director Académico';
}

/// ===========================
/// 📌 ESTADOS
/// ===========================
class Estados {
  static const String activo = 'Activo';
  static const String inactivo = 'Inactivo';
  static const String presente = 'Presente';
  static const String ausente = 'Ausente';
  static const String tardanza = 'Tardanza';
  static const String suspendido = 'Suspendido';
}

/// ===========================
/// 💬 MENSAJES COMUNES
/// ===========================
class Messages {
  static const String loginError = 'Usuario o contraseña incorrectos';
  static const String campoRequerido = 'Este campo es obligatorio';
  static const String correoInvalido = 'Correo electrónico inválido';
  static const String passwordCorta = 'La contraseña debe tener al menos 6 caracteres';

  static const String registroExitoso = 'Registro guardado exitosamente';
  static const String errorGeneral = 'Ocurrió un error inesperado';
  static const String confirmacion = '¿Estás segura/o de continuar?';
}

/// ===========================
/// ⏱ DURACIONES DE ANIMACIÓN
/// ===========================
class AppDurations {
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration long = Duration(milliseconds: 1000);
  static const Duration splashDelay = Duration(seconds: 2);
}

/// ===========================
/// 📚 MATERIAS Y BIMESTRES
/// ===========================
class AppAcademic {
  static const List<String> bimestres = [
    'Primer Bimestre',
    'Segundo Bimestre',
    'Tercer Bimestre',
    'Cuarto Bimestre',
  ];

  static const List<String> semestres = [
    'Primer Semestre', 
    'Segundo Semestre'
  ];

  static const List<String> tiposPeriodo = [
    'Bimestral', 
    'Semestral'
  ];
}

/// 🎨 Colores para materias
class MateriaColors {
  static const Color matematica = Color(0xFFE74C3C);
  static const Color fisica = Color(0xFF3498DB);
  static const Color quimica = Color(0xFF2ECC71);
  static const Color programacion = Color(0xFF9B59B6);
  static const Color baseDatos = Color(0xFFF39C12);
  static const Color redes = Color(0xFF1ABC9C);
  static const Color ingles = Color(0xFFE67E22);
  static const Color etica = Color(0xFF95A5A6);

  static const List<Color> colors = [
    matematica,
    fisica,
    quimica,
    programacion,
    baseDatos,
    redes,
    ingles,
    etica,
  ];
}

/// ===========================
/// 📚 BIMESTRES Y SEMESTRES
/// ===========================
class AppPeriodos {
  static const List<String> nombresBimestres = [
    'Primer Bimestre',
    'Segundo Bimestre',
    'Tercer Bimestre',
    'Cuarto Bimestre',
  ];

  static const List<String> nombresSemestres = [
    'Primer Semestre',
    'Segundo Semestre',
  ];

  static const List<String> tiposPeriodo = [
    'Bimestral',
    'Semestral',
    'Trimestral',
  ];

  static const List<String> estadosPeriodo = [
    'Planificado',
    'En Curso',
    'Finalizado',
    'Cancelado',
  ];
}

/// 🎨 Colores para períodos
class PeriodoColors {
  static const Color planificado = Color(0xFF2196F3); // Azul
  static const Color enCurso = Color(0xFF4CAF50); // Verde
  static const Color finalizado = Color(0xFF607D8B); // Gris
  static const Color cancelado = Color(0xFFF44336); // Rojo

  static Color getColorPorEstado(String estado) {
    switch (estado) {
      case 'Planificado':
        return planificado;
      case 'En Curso':
        return enCurso;
      case 'Finalizado':
        return finalizado;
      case 'Cancelado':
        return cancelado;
      default:
        return planificado;
    }
  }
}