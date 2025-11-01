import 'package:flutter/material.dart';
import 'career_widgets.dart';
import 'package:incos_check/utils/constants.dart';

class CarreraIngles extends StatelessWidget {
  const CarreraIngles({super.key});

  Widget _buildModuleSection(String title, List<Map<String, String>> courses) {
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
            InfoRow("Duración:", "3 años (6 módulos semestrales)"),
            InfoRow("Modalidad:", "Presencial - Modular"),
            InfoRow("Estado:", Estados.activo),
            InfoRow("Resolución:", "0210/2023"),
            InfoRow("Fecha de aprobación:", "14/03/2023"),
            InfoRow("Institución:", "INCOS El Alto, Bolivia"),
            InfoRow("Régimen:", "Sistema Modular Semestral"),
          ],
        ),

        const SizedBox(height: AppSpacing.medium),

        InfoCard(
          titleWidget: _titleWithIcon(Icons.person, "Perfil Profesional"),
          children: [
            const Text(
              "El Técnico Superior en Idioma Inglés en modalidad modular está capacitado para "
              "dominar el idioma inglés mediante un sistema de aprendizaje por módulos semestrales. "
              "Desarrolla competencias lingüísticas integrales que le permiten desempeñarse como "
              "docente de inglés en niveles básicos, asistente bilingüe, traductor de documentos, "
              "guía turístico y profesional en entornos que requieran el dominio del idioma inglés.",
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
            InfoRow("•", "Documentos de identificación personal"),
            InfoRow("•", "Fotocopia de carnet de identidad"),
            InfoRow("•", "Certificado de nacimiento"),
            InfoRow("•", "Aprobar proceso de admisión"),
            InfoRow("•", "Formulario de inscripción debidamente llenado"),
            InfoRow("•", "Prueba de diagnóstico de nivel de inglés"),
          ],
        ),

        const SizedBox(height: AppSpacing.medium),

        InfoCard(
          titleWidget: _titleWithIcon(Icons.star, "Áreas de Interés"),
          children: [
            InfoRow("•", "Enseñanza del idioma inglés en educación regular"),
            InfoRow("•", "Centros de idiomas e institutos especializados"),
            InfoRow("•", "Traducción e interpretación básica"),
            InfoRow("•", "Turismo y servicios de guía bilingüe"),
            InfoRow("•", "Call centers y servicios bilingües"),
            InfoRow("•", "Comercio exterior y negocios internacionales"),
            InfoRow("•", "Gestión cultural y relaciones internacionales"),
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
                            _buildModuleSection("1º Módulo - Primer Semestre", [
                              {
                                "code": "IBI-101",
                                "name": "Inglés Básico I",
                                "hours": "8",
                              },
                              {
                                "code": "IBII-102",
                                "name": "Inglés Básico II",
                                "hours": "8",
                              },
                              {
                                "code": "IBIII-103",
                                "name": "Inglés Básico III",
                                "hours": "8",
                              },
                            ]),
                            _buildModuleSection(
                              "2º Módulo - Segundo Semestre",
                              [
                                {
                                  "code": "IBIV-201",
                                  "name": "Inglés Básico IV",
                                  "hours": "8",
                                },
                                {
                                  "code": "IBV-202",
                                  "name": "Inglés Básico V",
                                  "hours": "8",
                                },
                                {
                                  "code": "IBVI-203",
                                  "name": "Inglés Básico VI",
                                  "hours": "8",
                                },
                              ],
                            ),
                            _buildModuleSection("3º Módulo - Tercer Semestre", [
                              {
                                "code": "III-301",
                                "name": "Inglés Intermedio I",
                                "hours": "8",
                              },
                              {
                                "code": "IIII-302",
                                "name": "Inglés Intermedio II",
                                "hours": "8",
                              },
                              {
                                "code": "IIIII-303",
                                "name": "Inglés Intermedio III",
                                "hours": "8",
                              },
                              {
                                "code": "EMP-304",
                                "name": "Emprendimiento Productivo",
                                "hours": "4",
                              },
                            ]),
                            _buildModuleSection("4º Módulo - Cuarto Semestre", [
                              {
                                "code": "IIIV-401",
                                "name": "Inglés Intermedio IV",
                                "hours": "8",
                              },
                              {
                                "code": "IIV-402",
                                "name": "Inglés Intermedio V",
                                "hours": "8",
                              },
                              {
                                "code": "IIVI-403",
                                "name": "Inglés Intermedio VI",
                                "hours": "8",
                              },
                              {
                                "code": "TMG-404",
                                "name": "Taller de Modalidad de Graduación",
                                "hours": "4",
                              },
                            ]),
                            _buildModuleSection("5º Módulo - Quinto Semestre", [
                              {
                                "code": "IAI-501",
                                "name": "Inglés Avanzado I",
                                "hours": "8",
                              },
                              {
                                "code": "IAII-502",
                                "name": "Inglés Avanzado II",
                                "hours": "8",
                              },
                              {
                                "code": "IAIII-503",
                                "name": "Inglés Avanzado III",
                                "hours": "8",
                              },
                              {
                                "code": "EMPII-504",
                                "name": "Emprendimiento Productivo II",
                                "hours": "4",
                              },
                            ]),
                            _buildModuleSection("6º Módulo - Sexto Semestre", [
                              {
                                "code": "IAIV-601",
                                "name": "Inglés Avanzado IV",
                                "hours": "8",
                              },
                              {
                                "code": "IAV-602",
                                "name": "Inglés Avanzado V",
                                "hours": "8",
                              },
                              {
                                "code": "IAVI-603",
                                "name": "Inglés Avanzado VI",
                                "hours": "8",
                              },
                              {
                                "code": "TMGII-604",
                                "name": "Taller de Modalidad de Graduación II",
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
          titleWidget: _titleWithIcon(Icons.language, "Niveles de Dominio"),
          children: [
            InfoRow("•", "Módulo 1-2: Nivel Básico (A1-A2 MCER)"),
            InfoRow("•", "Módulo 3-4: Nivel Intermedio (B1-B2 MCER)"),
            InfoRow("•", "Módulo 5-6: Nivel Avanzado (C1 MCER)"),
            InfoRow("•", "Total Horas: 360 horas lectivas"),
          ],
        ),

        const SizedBox(height: AppSpacing.medium),

        InfoCard(
          titleWidget: _titleWithIcon(Icons.work, "Campos de Acción"),
          children: [
            InfoRow("•", "Docente de inglés en unidades educativas"),
            InfoRow("•", "Instructor en centros de idiomas"),
            InfoRow("•", "Asistente bilingüe en empresas e instituciones"),
            InfoRow("•", "Guía turístico especializado"),
            InfoRow("•", "Traductor de documentos generales"),
            InfoRow("•", "Agente de call center bilingüe"),
            InfoRow("•", "Coordinador de programas interculturales"),
          ],
        ),
      ],
    );
  }
}
