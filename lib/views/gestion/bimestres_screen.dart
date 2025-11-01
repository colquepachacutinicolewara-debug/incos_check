import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../models/bimestre_model.dart';
import '../../views/asistencia/planilla/primer_bimestre_screen.dart';
import '../../views/asistencia/planilla/segundo_bimestre_screen.dart';
import '../../views/asistencia/planilla/tercer_bimestre_screen.dart';
import '../../views/asistencia/planilla/cuarto_bimestre_screen.dart';

class BimestresScreen extends StatefulWidget {
  final String materiaSeleccionada;

  const BimestresScreen({super.key, required this.materiaSeleccionada});

  @override
  State<BimestresScreen> createState() => _BimestresScreenState();
}

class _BimestresScreenState extends State<BimestresScreen> {
  final List<PeriodoAcademico> _periodos = [];

  @override
  void initState() {
    super.initState();
    _cargarPeriodosEjemplo();
  }

  void _cargarPeriodosEjemplo() {
    _periodos.addAll([
      PeriodoAcademico(
        id: 'bim1',
        nombre: 'Primer Bimestre',
        tipo: 'Bimestral',
        numero: 1,
        fechaInicio: DateTime(2024, 2, 1),
        fechaFin: DateTime(2024, 3, 31),
        estado: 'Finalizado',
        fechasClases: ['07/05', '08/05', '14/05', '15/05', '21/05', '22/05'],
        descripcion: 'Primer período académico 2024',
        fechaCreacion: DateTime(2024, 1, 15),
      ),
      PeriodoAcademico(
        id: 'bim2',
        nombre: 'Segundo Bimestre',
        tipo: 'Bimestral',
        numero: 2,
        fechaInicio: DateTime(2024, 4, 1),
        fechaFin: DateTime(2024, 5, 31),
        estado: 'En Curso',
        fechasClases: ['04/06', '05/06', '11/06', '12/06', '18/06', '19/06'],
        descripcion: 'Segundo período académico 2024',
        fechaCreacion: DateTime(2024, 3, 15),
      ),
      PeriodoAcademico(
        id: 'bim3',
        nombre: 'Tercer Bimestre',
        tipo: 'Bimestral',
        numero: 3,
        fechaInicio: DateTime(2024, 6, 1),
        fechaFin: DateTime(2024, 7, 31),
        estado: 'Planificado',
        fechasClases: [],
        descripcion: 'Tercer período académico 2024',
        fechaCreacion: DateTime(2024, 5, 15),
      ),
      PeriodoAcademico(
        id: 'bim4',
        nombre: 'Cuarto Bimestre',
        tipo: 'Bimestral',
        numero: 4,
        fechaInicio: DateTime(2024, 8, 1),
        fechaFin: DateTime(2024, 9, 30),
        estado: 'Planificado',
        fechasClases: [],
        descripcion: 'Cuarto período académico 2024',
        fechaCreacion: DateTime(2024, 7, 15),
      ),
    ]);
  }

  void _navigateToBimestreDetalle(PeriodoAcademico bimestre) {
    switch (bimestre.numero) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PrimerBimestreScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SegundoBimestreScreen(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TercerBimestreScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CuartoBimestreScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bimestres - ${widget.materiaSeleccionada}',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(AppSpacing.medium),
        childAspectRatio:
            1.0, // Cambiado de 1.2 a 1.0 para más espacio vertical
        children: _periodos.map((bimestre) {
          return _buildBimestreCard(bimestre);
        }).toList(),
      ),
    );
  }

  Widget _buildBimestreCard(PeriodoAcademico bimestre) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(AppSpacing.small),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: InkWell(
        onTap: () => _navigateToBimestreDetalle(bimestre),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.small), // Padding interno añadido
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono más pequeño
              Icon(
                Icons.calendar_month,
                size: 40, // Reducido de 50 a 40
                color: _getColorPorNumero(bimestre.numero),
              ),
              SizedBox(height: AppSpacing.small),
              Text(
                bimestre.nombre,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 14, // Texto más pequeño
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Limitar a 2 líneas
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4), // Espacio reducido
              Text(
                bimestre.rangoFechas,
                style: AppTextStyles.body.copyWith(
                  fontSize: 10, // Texto más pequeño
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Limitar a 2 líneas
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4), // Espacio reducido
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ), // Padding reducido
                decoration: BoxDecoration(
                  color: bimestre.colorEstado.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: bimestre.colorEstado),
                ),
                child: Text(
                  bimestre.estado,
                  style: TextStyle(
                    color: bimestre.colorEstado,
                    fontSize: 9, // Texto más pequeño
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorPorNumero(int numero) {
    switch (numero) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }
}
