// views/horarios/horarios_main_screen.dart
import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'horarios_turno_screen.dart';

class HorariosMainScreen extends StatelessWidget {
  const HorariosMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Sistema de Horarios',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView( // ✅ ARREGLADO: Agregado SingleChildScrollView
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información
            _buildHeader(),
            const SizedBox(height: 30),
            
            // ✅ CAMBIO: Turnos en columna vertical
            _buildTurnosSectionVertical(context),
            
            const SizedBox(height: 30),
            
            // Información adicional
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.schedule, size: 32, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión de Horarios',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.primary,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selecciona el turno para gestionar horarios académicos',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ NUEVO: Sección vertical de turnos
  Widget _buildTurnosSectionVertical(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Seleccionar Turno',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimary,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // ✅ CAMBIO: Cards en columna vertical
        Column(
          children: [
            // Turno Mañana (ARRIBA)
            _buildTurnoCardVertical(
              titulo: 'Turno Mañana',
              subtitulo: 'Horario: 7:00 - 12:00',
              descripcion: 'Primer a Tercer Año',
              icono: Icons.wb_sunny,
              color: Colors.orange,
              onTap: () => _navigateToHorariosTurno(context, 'Mañana'),
            ),
            const SizedBox(height: 20),
            
            // Turno Noche (ABAJO)
            _buildTurnoCardVertical(
              titulo: 'Turno Noche',
              subtitulo: 'Horario: 19:00 - 22:00',
              descripcion: 'Primer a Tercer Año',
              icono: Icons.nights_stay,
              color: Colors.indigo,
              onTap: () => _navigateToHorariosTurno(context, 'Noche'),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ NUEVO: Card vertical para turnos
  Widget _buildTurnoCardVertical({
    required String titulo,
    required String subtitulo,
    required String descripcion,
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // ✅ Ocupa todo el ancho
        height: 140, // ✅ Altura fija para consistencia
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Efectos de fondo decorativos
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                icono,
                size: 100,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Icono
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icono, size: 28, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  
                  // Información
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitulo,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          descripcion,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Flecha indicadora
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Qué puedes hacer aquí?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFeatureItem('📅 Ver horarios completos por año y paralelo'),
                _buildFeatureItem('👨‍🏫 Asignar y cambiar docentes'),
                _buildFeatureItem('✏️ Editar horarios fácilmente'),
                _buildFeatureItem('🔄 Gestión completa (CRUD)'),
                _buildFeatureItem('📱 Interfaz responsive y moderna'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primary)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHorariosTurno(BuildContext context, String turno) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HorariosTurnoScreen(turno: turno),
      ),
    );
  }
}