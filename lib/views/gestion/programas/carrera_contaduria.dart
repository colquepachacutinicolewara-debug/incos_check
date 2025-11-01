import 'package:flutter/material.dart';
import 'career_widgets.dart';
import 'package:incos_check/utils/constants.dart';

class CarreraContaduria extends StatelessWidget {
  const CarreraContaduria({super.key});

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  Color _getHeaderBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade300;
  }

  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  Color _getRowColor(BuildContext context, int index) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return index.isEven ? Colors.grey.shade800 : Colors.grey.shade900;
    } else {
      return index.isEven ? Colors.grey.shade50 : Colors.white;
    }
  }

  // Construcción de tabla por año (igual que Secretariado)
  Widget _buildYearSection(String title, List<Map<String, String>> courses) {
    return Builder(
      builder: (context) {
        return Card(
          margin: const EdgeInsets.all(AppSpacing.small),
          elevation: 3,
          color: Theme.of(context).cardColor,
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
                    Icon(Icons.school, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: AppTextStyles.heading2Dark(
                        context,
                      ).copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.small),
                Table(
                  border: TableBorder.all(color: _getBorderColor(context)),
                  columnWidths: const {
                    0: FlexColumnWidth(1.5),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1.5),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: AppColors.primary),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Código',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Asignatura',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Horas',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
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
                    ...courses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final course = entry.value;
                      return TableRow(
                        decoration: BoxDecoration(
                          color: _getRowColor(context, index),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              course['code'] ?? '',
                              style: TextStyle(color: _getTextColor(context)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              course['name'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: _getTextColor(context),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              course['hours'] ?? '',
                              style: TextStyle(color: _getTextColor(context)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              course['req'] ?? '-',
                              style: TextStyle(color: _getTextColor(context)),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Encabezado con ícono
  Widget _titleWithIcon(IconData icon, String title) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.heading2Dark(
                context,
              ).copyWith(color: _getTextColor(context)),
            ),
          ],
        );
      },
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
            InfoRow("Estado:", "Activo"),
            InfoRow("Resolución:", "0210/2023"),
            InfoRow("Fecha de aprobación:", "14/03/2023"),
            InfoRow("Institución:", "INCOS El Alto, Bolivia"),
          ],
        ),

        const SizedBox(height: AppSpacing.medium),

        InfoCard(
          titleWidget: _titleWithIcon(Icons.person, "Perfil Profesional"),
          children: [
            Text(
              "El Contador General con Título Profesional, está formado para ejercer la profesión, "
              "aplicando normas contables, tributarias, procedimientos administrativos y disposiciones "
              "legales vigentes. El profesional utiliza metodologías científicas y técnicas para diseñar, "
              "organizar, ejecutar y evaluar la información contable, económica y financiera de las diversas "
              "organizaciones públicas, privadas y mixtas. La finalidad de este trabajo contable es elaborar "
              "estados financieros confiables, útiles, oportunos y comparables para la toma de decisiones que "
              "generen emprendimientos en todo el territorio del Estado Plurinacional de Bolivia.",
              textAlign: TextAlign.justify,
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: _getTextColor(context)),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.medium),

        InfoCard(
          titleWidget: _titleWithIcon(
            Icons.assignment_turned_in,
            "Requisitos de Ingreso",
          ),
          children: const [
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
          children: const [
            InfoRow("•", "Contabilidad general y especializada"),
            InfoRow("•", "Auditoría y control interno"),
            InfoRow("•", "Tributación y legislación fiscal"),
            InfoRow("•", "Costos y presupuestos"),
            InfoRow("•", "Análisis financiero"),
            InfoRow("•", "Contabilidad gubernamental"),
            InfoRow("•", "Sistemas de información contable"),
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
                                "code": "CON-101",
                                "name": "Contabilidad I",
                                "hours": "8",
                              },
                              {
                                "code": "MAF-102",
                                "name": "Matemática Financiera",
                                "hours": "4",
                              },
                              {
                                "code": "ICO-103",
                                "name": "Informática Contable",
                                "hours": "4",
                              },
                              {
                                "code": "ADG-104",
                                "name": "Administración General",
                                "hours": "4",
                              },
                              {
                                "code": "LSA-105",
                                "name":
                                    "Legislación Laboral y Seguridad Social Aplicada",
                                "hours": "2",
                              },
                              {
                                "code": "EGA-106",
                                "name": "Economía General Aplicada",
                                "hours": "2",
                              },
                              {
                                "code": "DCM-107",
                                "name": "Documentos Comerciales y Mercantiles",
                                "hours": "2",
                              },
                              {
                                "code": "ESA-108",
                                "name": "Estadística Aplicada",
                                "hours": "2",
                              },
                              {
                                "code": "INT-109",
                                "name": "Inglés Técnico",
                                "hours": "2",
                              },
                            ]),
                            _buildYearSection("Segundo Año", [
                              {
                                "code": "CON-201",
                                "name": "Contabilidad II",
                                "hours": "6",
                                "req": "CON-101",
                              },
                              {
                                "code": "COC-202",
                                "name": "Contabilidad de Costos I",
                                "hours": "6",
                              },
                              {
                                "code": "COS-203",
                                "name": "Contabilidad de Sociedades",
                                "hours": "4",
                              },
                              {
                                "code": "CD5-204",
                                "name": "Contabilidad de Seguros",
                                "hours": "2",
                              },
                              {
                                "code": "CBC-205",
                                "name": "Contabilidad Bancaria y Cooperativas",
                                "hours": "4",
                              },
                              {
                                "code": "EMP-206",
                                "name": "Emprendimiento Productivo",
                                "hours": "4",
                                "req": "ADG-104",
                              },
                              {
                                "code": "SIT-207",
                                "name": "Sistema Tributario",
                                "hours": "4",
                              },
                            ]),
                            _buildYearSection("Tercer Año", [
                              {
                                "code": "COA-301",
                                "name": "Contabilidad Agropecuaria",
                                "hours": "4",
                              },
                              {
                                "code": "COC-302",
                                "name": "Contabilidad de Costos II",
                                "hours": "4",
                                "req": "COC-202",
                              },
                              {
                                "code": "COG-303",
                                "name": "Contabilidad Gubernamental",
                                "hours": "4",
                              },
                              {
                                "code": "CEP-304",
                                "name":
                                    "Contabilidad Extractiva (Minera, Petrolera y Forestal)",
                                "hours": "4",
                              },
                              {
                                "code": "CHS-305",
                                "name":
                                    "Contabilidad de Servicios (Construcción, Hotelería y Transporte)",
                                "hours": "2",
                              },
                              {
                                "code": "GCI-306",
                                "name": "Gabinete Contable Informático",
                                "hours": "4",
                              },
                              {
                                "code": "AEF-307",
                                "name":
                                    "Análisis e Interpretaciones de Estados Financieros",
                                "hours": "4",
                              },
                              {
                                "code": "TMG-308",
                                "name": "Taller de Modalidad de Graduación",
                                "hours": "4",
                                "req": "EMP-206",
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
          children: const [
            InfoRow("•", "Contador general en empresas públicas y privadas"),
            InfoRow("•", "Auditor interno y externo"),
            InfoRow("•", "Asesor tributario y contable"),
            InfoRow("•", "Controller o gerente financiero"),
            InfoRow("•", "Consultor independiente"),
            InfoRow("•", "Perito contable judicial"),
            InfoRow("•", "Docente en áreas contables y financieras"),
          ],
        ),
      ],
    );
  }
}
