import 'package:flutter/material.dart';
import 'career_widgets.dart';
import 'package:incos_check/utils/constants.dart';

class CarreraEmpresas extends StatelessWidget {
  const CarreraEmpresas({super.key});

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
          titleWidget: _titleWithIcon(Icons.person, "Perfil Profesional"),
          children: [
            const Text(
              "El Técnico Superior en Administración de Empresas está capacitado para gestionar "
              "y dirigir organizaciones empresariales, aplicando principios administrativos, "
              "financieros y estratégicos. Desarrolla habilidades en planificación, organización, "
              "dirección y control de recursos, con capacidad para tomar decisiones que optimicen "
              "el funcionamiento de las empresas y promuevan el emprendimiento productivo en el "
              "contexto económico boliviano.",
              textAlign: TextAlign.justify,
              style: AppTextStyles.body,
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
            InfoRow("•", "Gestión empresarial y administrativa"),
            InfoRow("•", "Finanzas y contabilidad empresarial"),
            InfoRow("•", "Marketing e investigación de mercados"),
            InfoRow("•", "Gestión del talento humano"),
            InfoRow("•", "Planificación y evaluación de proyectos"),
            InfoRow("•", "Emprendimiento e incubación de negocios"),
            InfoRow("•", "Comercio internacional"),
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
                                "code": "FUA-101",
                                "name": "Fundamento de la Administración",
                                "hours": "6",
                              },
                              {
                                "code": "CGA-102",
                                "name":
                                    "Contabilidad General para Administradores",
                                "hours": "6",
                              },
                              {
                                "code": "MAF-103",
                                "name": "Matemática Financiera",
                                "hours": "4",
                              },
                              {
                                "code": "ESN-104",
                                "name": "Estadística para los Negocios",
                                "hours": "4",
                              },
                              {
                                "code": "PLT-105",
                                "name": "Práctica Laboral y Tributaria",
                                "hours": "4",
                              },
                              {
                                "code": "IFE-106",
                                "name": "Informática Empresarial",
                                "hours": "2",
                              },
                              {
                                "code": "INT-107",
                                "name": "Inglés Técnico",
                                "hours": "4",
                              },
                            ]),
                            _buildYearSection("Segundo Año", [
                              {
                                "code": "ORA-201",
                                "name": "Organización de la Administración",
                                "hours": "2",
                              },
                              {
                                "code": "IEM-202",
                                "name": "Investigación y Estrategia de Mercado",
                                "hours": "4",
                              },
                              {
                                "code": "ADO-203",
                                "name": "Administración de Operaciones",
                                "hours": "4",
                              },
                              {
                                "code": "GTH-204",
                                "name": "Gestión del Talento Humano",
                                "hours": "4",
                              },
                              {
                                "code": "ADF-205",
                                "name": "Administración Financiera I",
                                "hours": "4",
                                "req": "MAF-103",
                              },
                              {
                                "code": "PEP-206",
                                "name": "Preparación y Evaluación de Proyectos",
                                "hours": "4",
                              },
                              {
                                "code": "ACP-207",
                                "name":
                                    "Administración de Costos y Presupuestos",
                                "hours": "4",
                                "req": "CGA-102",
                              },
                              {
                                "code": "EMP-208",
                                "name": "Economía de la Empresa",
                                "hours": "4",
                              },
                            ]),
                            _buildYearSection("Tercer Año", [
                              {
                                "code": "AMP-301",
                                "name":
                                    "Administración de la Micro, Pequeña y Mediana Empresa",
                                "hours": "6",
                              },
                              {
                                "code": "INM-302",
                                "name": "Incubación y Modelos de Negocios",
                                "hours": "4",
                              },
                              {
                                "code": "ADF-303",
                                "name": "Administración Financiera II",
                                "hours": "4",
                                "req": "ADF-205",
                              },
                              {
                                "code": "TMG-304",
                                "name": "Taller de Modalidad de Grado",
                                "hours": "4",
                              },
                              {
                                "code": "EMP-305",
                                "name": "Emprendimiento Productivo",
                                "hours": "4",
                              },
                              {
                                "code": "CMI-306",
                                "name": "Comercio Internacional",
                                "hours": "4",
                              },
                              {
                                "code": "GEE-307",
                                "name": "Gestión Estratégica",
                                "hours": "4",
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
            InfoRow("•", "Administrador de empresas y organizaciones"),
            InfoRow(
              "•",
              "Gerente de áreas funcionales (producción, marketing, finanzas)",
            ),
            InfoRow("•", "Consultor empresarial y asesor de negocios"),
            InfoRow("•", "Emprendedor y gestor de proyectos empresariales"),
            InfoRow("•", "Analista de mercados e investigador comercial"),
            InfoRow("•", "Coordinador de operaciones y logística"),
            InfoRow("•", "Gestor de recursos humanos"),
          ],
        ),
      ],
    );
  }
}
