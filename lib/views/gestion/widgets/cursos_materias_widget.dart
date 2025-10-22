import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';
// IMPORT CORRECTO (ajusta la ruta si tu proyecto tiene otra estructura)
import '../estudiantes_screen.dart';
class CursosScreen extends StatelessWidget {
  final String carrera;
  final String turno;

  const CursosScreen({super.key, required this.carrera, required this.turno});

  @override
  Widget build(BuildContext context) {
    // Definir cursos según el turno
    List<Map<String, dynamic>> cursos = [];

    if (turno == 'NOCHE') {
      cursos = [
        {'nombre': '1RO A', 'codigo': '1A-SIS-N', 'estudiantes': 25},
        {'nombre': '1RO B', 'codigo': '1B-SIS-N', 'estudiantes': 28},
        {'nombre': '2DO A', 'codigo': '2A-SIS-N', 'estudiantes': 30},
        {'nombre': '2DO B', 'codigo': '2B-SIS-N', 'estudiantes': 27},
        {'nombre': '3RO A', 'codigo': '3A-SIS-N', 'estudiantes': 32},
        {'nombre': '3RO B', 'codigo': '3B-SIS-N', 'estudiantes': 29},
      ];
    } else if (turno == 'MAÑANA') {
      cursos = [
        {'nombre': '1RO A', 'codigo': '1A-SIS-M', 'estudiantes': 26},
        {'nombre': '1RO B', 'codigo': '1B-SIS-M', 'estudiantes': 24},
        {'nombre': '2DO A', 'codigo': '2A-SIS-M', 'estudiantes': 28},
        {'nombre': '2DO B', 'codigo': '2B-SIS-M', 'estudiantes': 25},
        {'nombre': '3RO A', 'codigo': '3A-SIS-M', 'estudiantes': 30},
        {'nombre': '3RO B', 'codigo': '3B-SIS-M', 'estudiantes': 27},
      ];
    } else if (turno == 'TARDE') {
      cursos = [
        {'nombre': '1RO A', 'codigo': '1A-SIS-T', 'estudiantes': 23},
        {'nombre': '1RO B', 'codigo': '1B-SIS-T', 'estudiantes': 26},
        {'nombre': '2DO A', 'codigo': '2A-SIS-T', 'estudiantes': 29},
        {'nombre': '2DO B', 'codigo': '2B-SIS-T', 'estudiantes': 24},
        {'nombre': '3RO A', 'codigo': '3A-SIS-T', 'estudiantes': 31},
        {'nombre': '3RO B', 'codigo': '3B-SIS-T', 'estudiantes': 28},
      ];
    }

    // Si quieres mostrar solo Sistemas Noche al inicio, puedes filtrar aquí.
    // Por ahora dejo la lógica flexible (usa el 'turno' que pases al crear el widget).

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cursos - $turno',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.medium),
        children: cursos.map((curso) {
          return _buildCursoCard(context, curso);
        }).toList(),
      ),
    );
  }

  Widget _buildCursoCard(BuildContext context, Map<String, dynamic> curso) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            // Mostrar la primera parte del nombre (ej. "1RO")
            curso['nombre'].toString().split(' ')[0],
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          '${curso['nombre']} - SISTEMAS',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${curso['estudiantes']} estudiantes • Código: ${curso['codigo']}',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EstudiantesScreen(
                carrera: carrera,
                turno: turno,
                curso: curso['nombre'],
                codigoCurso: curso['codigo'],
              ),
            ),
          );
        },
      ),
    );
  }
}
