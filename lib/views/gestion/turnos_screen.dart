import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';
import 'cursos_screen.dart';

class TurnosScreen extends StatelessWidget {
  final String carrera;

  const TurnosScreen({super.key, required this.carrera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Turnos - $carrera',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.medium),
        children: [
          _buildTurnoCard(
            context,
            'MAÑANA',
            '07:30 - 12:30',
            Icons.wb_sunny,
            AppColors.warning,
          ),
          _buildTurnoCard(
            context,
            'TARDE', 
            '13:00 - 18:00',
            Icons.brightness_6,
            AppColors.primary,
          ),
          _buildTurnoCard(
            context,
            'NOCHE',
            '18:30 - 22:00',
            Icons.nights_stay,
            AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildTurnoCard(BuildContext context, String turno, String horario, IconData icon, Color color) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          'Turno $turno',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          horario,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CursosScreen(carrera: carrera, turno: turno),
            ),
          );
        },
      ),
    );
  }
}