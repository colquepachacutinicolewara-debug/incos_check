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
}

/// 🧍 Colores personalizados por tipo de usuario
class UserThemeColors {
  static const administrador = Color(0xFF1565C0); // Azul fuerte
  static const docente = Color(0xFF42A5F5);      // Celeste
  static const estudiante = Color(0xFF29B6F6);   // Azul intermedio
  static const jefeCarrera = Color(0xFF64B5F6);  // Azul claro
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
  static const dashboard = " IncosCheck ";
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

/// ===========================
/// 📝 DISEÑO DE TABLA VISUAL
/// ===========================
class TablaVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabla General'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(AppColors.secondary),
            headingTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            dataRowColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return AppColors.accent; // Azul claro al seleccionar
                }
                return Colors.white; // Fondo de filas
              },
            ),
            border: TableBorder.all(
              color: AppColors.primary,
              width: 2,
            ),
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Descripción')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Fecha')),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('1')),
                DataCell(Text('Juan Perez')),
                DataCell(Text('Estudiante de sistemas')),
                DataCell(Text('Activo')),
                DataCell(Text('2025-10-02')),
              ]),
              DataRow(cells: [
                DataCell(Text('2')),
                DataCell(Text('Maria Lopez')),
                DataCell(Text('Estudiante de informática')),
                DataCell(Text('Inactivo')),
                DataCell(Text('2025-10-01')),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
