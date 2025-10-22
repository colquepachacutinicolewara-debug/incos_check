import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';
import 'turnos_screen.dart';

class CarrerasScreen extends StatelessWidget {
  const CarrerasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carreras - INCOS',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.medium),
        children: [
          _buildCarreraCard(
            context,
            'SISTEMAS INFORMÁTICOS',
            'Tecnología en Desarrollo de Software',
            Icons.computer,
            AppColors.primary,
          ),
          _buildCarreraCard(
            context,
            'ADMINISTRACIÓN DE EMPRESAS',
            'Gestión Empresarial y Financiera',
            Icons.business,
            AppColors.success,
          ),
          _buildCarreraCard(
            context,
            'CONTADURÍA GENERAL',
            'Contabilidad y Auditoría',
            Icons.calculate,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildCarreraCard(BuildContext context, String titulo, String descripcion, IconData icon, Color color) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          titulo,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          descripcion,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TurnosScreen(carrera: titulo),
            ),
          );
        },
      ),
    );
  }
}