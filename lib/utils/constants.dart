import 'package:flutter/material.dart';

/// ===========================
/// 🎨 COLORES DE LA APP
/// ===========================
class AppColors {
  static const primary = Color(0xFF2E7D32); // Verde principal
  static const secondary = Color(0xFF66BB6A); // Verde claro
  static const accent = Color.fromARGB(255, 171, 219, 169);
  static const background = Color(0xFFF5F5F5);

  static const success = Color(0xFF28A745);
  static const error = Color(0xFFDC3545);
  static const warning = Color(0xFFFFC107);

  static const textPrimary = Colors.black87;
  static const textSecondary = Colors.black54;
}

/// 🧍 Colores personalizados por tipo de usuario
class UserThemeColors {
  static const administrador = Color(0xFF1565C0); // Azul fuerte
  static const docente = Color(0xFF8E24AA);      // Morado
  static const estudiante = Color(0xFFFF6F00);   // Naranja fuerte
  static const jefeCarrera = Color(0xFF009688);  // Verde azulado
  static const directorAcademico = Color(0xFFD32F2F); // Rojo fuerte
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

  static const body = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

/// ===========================
/// 📏 ESPACIADOS Y RADIOS
/// ===========================
class AppSpacing {
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
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
  static const huellaIcon = "assets/icons/huella.png"; // 👆 ícono para asistencia biométrica
}

/// ===========================
/// 🔑 STRINGS COMUNES
/// ===========================
class AppStrings {
  static const appName = "IncosCheck";
  static const login = "Iniciar Sesión";
  static const logout = "Cerrar Sesión";
  static const dashboard = "Panel de Control";
  static const asistencia = "Registro de Asistencia";
  static const estudiantes = "Estudiantes";
  static const docentes = "Docentes";
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
}

/// ===========================
/// 🗄 COLECCIONES FIRESTORE
/// ===========================
class Collections {
  static const usuarios = 'usuarios';
  static const estudiantes = 'estudiantes';
  static const docentes = 'docentes';
  static const cursos = 'cursos';
  static const asistencias = 'asistencias';
  static const materias = 'materias';
  static const configuraciones = 'configuraciones';
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