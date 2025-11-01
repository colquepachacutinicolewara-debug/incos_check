// utils/constants.dart
import 'package:flutter/material.dart';

/// ===========================
/// 🎨 COLORES DE LA APP
/// ===========================
class AppColors {
  static const primary = Color(0xFF1565C0); // Azul fuerte
  static const secondary = Color(0xFF42A5F5); // Celeste
  static const accent = Color(0xFF90CAF9); // Azul claro
  static const background = Color(0xFFF5F5F5);

  static const success = Color(0xFF28A745);
  static const error = Color(0xFFDC3545);
  static const warning = Color(0xFFFFC107);

  static const textPrimary = Colors.black87;
  static const textSecondary = Colors.black54;

  static const Color border = Color(0xFFE0E0E0); // ejemplo de gris
}

/// 🧍 Colores personalizados por tipo de usuario
class UserThemeColors {
  static const administrador = Color(0xFF1565C0); // Azul fuerte
  static const docente = Color(0xFF42A5F5); // Celeste
  static const estudiante = Color(0xFF29B6F6); // Azul intermedio
  static const jefeCarrera = Color(0xFF64B5F6); // Azul claro
  static const directorAcademico = Color(0xFF1976D2); // Azul intenso
}

/// ===========================
/// ✍ ESTILOS DE TEXTO
/// ===========================
class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 🆕 NUEVO ESTILO HEADING3 - SIGUIENDO EL PATRÓN EXISTENTE
  static const heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(fontSize: 16, color: AppColors.textSecondary);

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Añadido para el drawer
  static const drawerItem = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
}

/// ===========================
/// 📏 ESPACIADOS Y RADIOS
/// ===========================
class AppSpacing {
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const xlarge = 32.0;
}

class AppRadius {
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
}

/// ===========================
/// 🖼 ASSETS / ICONOS
/// ===========================
class AppAssets {
  static const logo = "assets/logo.png";
  static const userPlaceholder = "assets/images/user.png";
  static const huellaIcon = "assets/icons/huella.png";
}

/// ===========================
/// 🔑 STRINGS COMUNES
/// ===========================
class AppStrings {
  static const appName = "IncosCheck";
  static const login = "Iniciar Sesión";
  static const logout = "Cerrar Sesión";
  static const dashboard = "IncosCheck";
  static const asistencia = "Registro de Asistencia";
  static const estudiantes = "Estudiantes";
  static const docentes = "Docentes";
  static const gestion = "Gestión Académica";
  static const reportes = "Reportes";
  static const configuracion = "Configuración";
  static const soporte = "Soporte";
  static const inicio = "Inicio";
}

/// ===========================
/// 👤 ROLES DE USUARIO
/// ===========================
class UserRoles {
  static const administrador = 'Administrador';
  static const docente = 'Docente';
  static const estudiante = 'Estudiante';
  static const jefeCarrera = 'Jefe de Carrera';
  static const directorAcademico = 'Director Académico';
}

/// ===========================
/// 📌 ESTADOS
/// ===========================
class Estados {
  static const activo = 'Activo';
  static const inactivo = 'Inactivo';
  static const presente = 'Presente';
  static const ausente = 'Ausente';
  static const tardanza = 'Tardanza';
  static const String suspendido = 'Suspendido';
}

/// ===========================
/// 💬 MENSAJES COMUNES
/// ===========================
class Messages {
  static const loginError = 'Usuario o contraseña incorrectos';
  static const campoRequerido = 'Este campo es obligatorio';
  static const correoInvalido = 'Correo electrónico inválido';
  static const passwordCorta = 'La contraseña debe tener al menos 6 caracteres';

  static const registroExitoso = 'Registro guardado exitosamente';
  static const errorGeneral = 'Ocurrió un error inesperado';
  static const confirmacion = '¿Estás segura/o de continuar?';
}

/// ===========================
/// ⏱ DURACIONES DE ANIMACIÓN
/// ===========================
class AppDurations {
  static const short = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 500);
  static const long = Duration(milliseconds: 1000);
  static const splashDelay = Duration(seconds: 2);
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

  static const List<String> semestres = ['Primer Semestre', 'Segundo Semestre'];

  static const List<String> tiposPeriodo = ['Bimestral', 'Semestral'];
}

/// 🎨 Colores para materias
class MateriaColors {
  static const matematica = Color(0xFFE74C3C);
  static const fisica = Color(0xFF3498DB);
  static const quimica = Color(0xFF2ECC71);
  static const programacion = Color(0xFF9B59B6);
  static const baseDatos = Color(0xFFF39C12);
  static const redes = Color(0xFF1ABC9C);
  static const ingles = Color(0xFFE67E22);
  static const etica = Color(0xFF95A5A6);

  static List<Color> get colors => [
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
  static const planificado = Color(0xFF2196F3); // Azul
  static const enCurso = Color(0xFF4CAF50); // Verde
  static const finalizado = Color(0xFF607D8B); // Gris
  static const cancelado = Color(0xFFF44336); // Rojo

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
