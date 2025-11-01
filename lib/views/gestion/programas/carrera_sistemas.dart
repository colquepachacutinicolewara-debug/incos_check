import 'package:flutter/material.dart';
import 'career_widgets.dart';
import 'package:incos_check/utils/constants.dart';

class CarreraSistemas extends StatelessWidget {
  const CarreraSistemas({super.key});

  Widget _buildYearSection(String title, List<Map<String, String>> courses) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.small),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1.5),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: AppColors.primary),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Código',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Asignatura',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Horas',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Requisito',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                ...courses
                    .map(
                      (course) => TableRow(
                        decoration: BoxDecoration(
                          color: courses.indexOf(course).isEven
                              ? Colors.grey.shade50
                              : Colors.white,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(course['code'] ?? ''),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              course['name'] ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(course['hours'] ?? ''),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(course['req'] ?? '-'),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleWithIcon(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.heading2),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCard(
          titleWidget: _titleWithIcon(Icons.info, "Información"),
          children: [
            InfoRow("Duración:", "3 años"),
            InfoRow("Modalidad:", "Presencial"),
            InfoRow("Estado:", Estados.activo),
            InfoRow("Resolución:", "0210/2023"),
            InfoRow("Fecha de aprobación:", "14/03/2023"),
            InfoRow("Institución:", "INCOS El Alto, Bolivia"),
          ],
        ),

        const SizedBox(height: AppSpacing.medium),

        InfoCard(
          titleWidget: _titleWithIcon(Icons.person, "Aptitudes y Habilidades"),
          children: [
            InfoRow("•", "Instalar, configurar y operar software"),
            InfoRow("•", "Desarrollar software de gestión"),
            InfoRow("•", "Diseñar y desarrollar aplicaciones web"),
            InfoRow("•", "Gestionar y administrar bases de datos"),
            InfoRow("•", "Ensamblar, configurar, reparar y mantener hardware"),
            InfoRow(
              "•",
              "Instalar, configurar y administrar redes físicas y virtuales",
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.medium),

        InfoCard(
          titleWidget: _titleWithIcon(
            Icons.assignment_turned_in,
            "Requisitos de Ingreso",
          ),
          children: [
            InfoRow("•", "Título de Bachiller"),
            InfoRow("•", "Documentos de identificación"),
            InfoRow("•", "Fotocopia de carnet de identidad"),
            InfoRow("•", "Certificado de nacimiento"),
            InfoRow("•", "Aprobar proceso de admisión"),
            InfoRow("•", "Formulario de inscripción debidamente llenado"),
          ],
        ),

        const SizedBox(height: AppSpacing.medium),

        InfoCard(
          titleWidget: _titleWithIcon(Icons.star, "Áreas de Interés"),
          children: [
            InfoRow("•", "Programación y desarrollo de software"),
            InfoRow("•", "Administración de bases de datos"),
            InfoRow("•", "Redes y conectividad"),
            InfoRow("•", "Desarrollo web y móvil"),
            InfoRow("•", "Sistemas operativos"),
            InfoRow("•", "Emprendimiento tecnológico"),
          ],
        ),

        const SizedBox(height: AppSpacing.medium),

        InfoCard(
          titleWidget: _titleWithIcon(Icons.menu_book, "Plan de Estudios"),
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: 400,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: constraints.maxWidth > 600
                            ? constraints.maxWidth
                            : 600,
                        child: Column(
                          children: [
                            _buildYearSection("Primer Año", [
                              {
                                "code": "INT-103",
                                "name": "Inglés Técnico",
                                "hours": "2",
                              },
                              {
                                "code": "DPW-107",
                                "name": "Diseño y Programación Web I",
                                "hours": "4",
                              },
                              {
                                "code": "PRG-102",
                                "name": "Programación I",
                                "hours": "8",
                              },
                              {
                                "code": "OTM-106",
                                "name": "Ofimática y Tecnología Multimedia",
                                "hours": "4",
                              },
                              {
                                "code": "MPI-101",
                                "name": "Matemática para la Informática",
                                "hours": "4",
                              },
                              {
                                "code": "TSO-105",
                                "name": "Taller de Sistemas Operativos",
                                "hours": "4",
                              },
                              {
                                "code": "HDC-104",
                                "name": "Hardware de Computadoras",
                                "hours": "4",
                              },
                            ]),
                            _buildYearSection("Segundo Año", [
                              {
                                "code": "BDD-208",
                                "name": "Base de Datos I",
                                "hours": "4",
                              },
                              {
                                "code": "DPW-207",
                                "name": "Diseño y Programación Web II",
                                "hours": "4",
                                "req": "DPW-107",
                              },
                              {
                                "code": "ADS-206",
                                "name": "Análisis y Diseño de Sistemas I",
                                "hours": "4",
                              },
                              {
                                "code": "PRG-202",
                                "name": "Programación II",
                                "hours": "6",
                                "req": "PRG-102",
                              },
                              {
                                "code": "EST-201",
                                "name": "Estadística",
                                "hours": "2",
                              },
                              {
                                "code": "EDD-203",
                                "name": "Estructura de Datos",
                                "hours": "2",
                              },
                              {
                                "code": "PDM-205",
                                "name":
                                    "Programación para Dispositivos Móviles I",
                                "hours": "4",
                              },
                              {
                                "code": "RDC-204",
                                "name": "Redes de Computadoras I",
                                "hours": "4",
                              },
                            ]),
                            _buildYearSection("Tercer Año", [
                              {
                                "code": "EMP-301",
                                "name": "Emprendimiento Productivo",
                                "hours": "4",
                              },
                              {
                                "code": "RDC-304",
                                "name": "Redes de Computadoras II",
                                "hours": "4",
                                "req": "RDC-204",
                              },
                              {
                                "code": "BDD-308",
                                "name": "Base de Datos II",
                                "hours": "4",
                                "req": "BDD-208",
                              },
                              {
                                "code": "TMG-305",
                                "name": "Taller de Modalidad de Graduación",
                                "hours": "4",
                              },
                              {
                                "code": "DPW-302",
                                "name": "Diseño y Programación Web III",
                                "hours": "4",
                                "req": "DPW-207",
                              },
                              {
                                "code": "GMC-303",
                                "name":
                                    "Gestión y Mejoramiento de la Calidad de Software",
                                "hours": "2",
                              },
                              {
                                "code": "PDM-307",
                                "name":
                                    "Programación para Dispositivos Móviles II",
                                "hours": "4",
                                "req": "PDM-205",
                              },
                              {
                                "code": "ADS-306",
                                "name": "Análisis y Diseño de Sistemas II",
                                "hours": "4",
                                "req": "ADS-206",
                              },
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.medium),

        InfoCard(
          titleWidget: _titleWithIcon(Icons.work, "Campos de Acción"),
          children: [
            InfoRow("•", "Desarrollador de software y aplicaciones"),
            InfoRow("•", "Administrador de bases de datos"),
            InfoRow("•", "Técnico en redes y conectividad"),
            InfoRow("•", "Desarrollador web y móvil"),
            InfoRow("•", "Soporte técnico y mantenimiento de hardware"),
            InfoRow("•", "Analista de sistemas"),
            InfoRow("•", "Emprendedor tecnológico"),
          ],
        ),
      ],
    );
  }
}
