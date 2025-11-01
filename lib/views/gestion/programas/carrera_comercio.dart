import 'package:flutter/material.dart';
import 'career_widgets.dart';
import 'package:incos_check/utils/constants.dart';

class CarreraComercio extends StatelessWidget {
  const CarreraComercio({super.key});

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

  // 🔹 Construcción de sección por año (tabla)
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

  // 🔹 Títulos con íconos
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
        // Información básica
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

        // Enfoque del programa
        InfoCard(
          titleWidget: _titleWithIcon(Icons.school, "Enfoque del Programa"),
          children: [
            Text(
              "LA PRODUCCIÓN: Fomenta la creación de emprendimientos productivos – comerciales, "
              "otorgando a los estudiantes los instrumentos necesarios para tal fin, con especial "
              "énfasis en la internacionalización de empresas y de los emprendimientos.\n\n"
              "LA INNOVACIÓN PRODUCTIVA INTEGRAL: Identifica potencialidades productivas, es un "
              "líder motivado para la innovación productiva integral, tanto en la producción de "
              "potenciales productos comercializables a nivel internacional, como la comercialización "
              "internacional de los productos ya existentes en las comunidades.\n\n"
              "DESARROLLO COMUNITARIO: Se complementa con los productores, lograr un desarrollo "
              "comunitario productivo en las comunidades.",
              textAlign: TextAlign.justify,
              style: AppTextStyles.bodyDark(
                context,
              ).copyWith(color: _getTextColor(context)),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.medium),

        // Requisitos
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

        // Áreas de interés
        InfoCard(
          titleWidget: _titleWithIcon(Icons.star, "Áreas de Interés"),
          children: const [
            InfoRow("•", "Comercio internacional y aduanas"),
            InfoRow("•", "Logística y transporte internacional"),
            InfoRow("•", "Clasificación arancelaria y merecología"),
            InfoRow("•", "Marketing internacional"),
            InfoRow("•", "Negociación internacional"),
            InfoRow("•", "Operativización aduanera"),
            InfoRow("•", "Distribución física internacional"),
          ],
        ),

        const SizedBox(height: AppSpacing.medium),

        // Plan de estudios (con tablas estilo Secretariado)
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
                                "code": "RDA-101",
                                "name": "Regímenes y Destinos Aduaneros",
                                "hours": "6",
                              },
                              {
                                "code": "MCA-102",
                                "name":
                                    "Metrología y Clasificación Arancelaria",
                                "hours": "4",
                              },
                              {
                                "code": "IEN-103",
                                "name":
                                    "Integración Económica y Normas de Origen",
                                "hours": "4",
                              },
                              {
                                "code": "GCT-104",
                                "name": "Gestión Comercial y Tributaria",
                                "hours": "2",
                              },
                              {
                                "code": "TEI-105",
                                "name":
                                    "Taller de Emprendimiento e Ideas de Negocios",
                                "hours": "2",
                              },
                              {
                                "code": "COG-106",
                                "name": "Contabilidad General",
                                "hours": "4",
                              },
                              {
                                "code": "MEG-107",
                                "name": "Mercadotecnia General",
                                "hours": "2",
                              },
                              {
                                "code": "DGP-108",
                                "name": "Diseño Gráfico Publicitario",
                                "hours": "2",
                              },
                              {
                                "code": "ESD-109",
                                "name": "Estadística Descriptiva",
                                "hours": "2",
                              },
                            ]),
                            _buildYearSection("Segundo Año", [
                              {
                                "code": "PSA-201",
                                "name": "Procesos y Sistemas Aduaneros",
                                "hours": "4",
                              },
                              {
                                "code": "CAM-202",
                                "name":
                                    "Clasificación Arancelaria y Merecología",
                                "hours": "4",
                              },
                              {
                                "code": "LTI-203",
                                "name": "Logística y Transporte Internacional",
                                "hours": "4",
                              },
                              {
                                "code": "NIN-204",
                                "name": "Negociación Internacional",
                                "hours": "4",
                              },
                              {
                                "code": "INM-205",
                                "name": "Investigación de Mercados",
                                "hours": "2",
                              },
                              {
                                "code": "CDC-206",
                                "name": "Contabilidad de Costos",
                                "hours": "4",
                                "req": "COG-106",
                              },
                              {
                                "code": "MIH-207",
                                "name":
                                    "Mercadotecnia Internacional y Herramientas de Prospección",
                                "hours": "4",
                                "req": "MEG-107",
                              },
                              {
                                "code": "EMI-208",
                                "name":
                                    "E-Commerce y Mercadotecnia en Internet",
                                "hours": "4",
                              },
                            ]),
                            _buildYearSection("Tercer Año", [
                              {
                                "code": "ADE-305",
                                "name": "Administración Empresarial",
                                "hours": "4",
                              },
                              {
                                "code": "OPA-302",
                                "name": "Operativización Aduanera",
                                "hours": "4",
                              },
                              {
                                "code": "DFI-303",
                                "name": "Distribución Física Internacional",
                                "hours": "4",
                                "req": "LTI-203",
                              },
                              {
                                "code": "INT-304",
                                "name": "Inglés Técnico",
                                "hours": "6",
                              },
                              {
                                "code": "TMG-301",
                                "name": "Taller de Modalidad de Graduación",
                                "hours": "6",
                              },
                              {
                                "code": "PEF-306",
                                "name": "Presupuesto y Evaluación Financiera",
                                "hours": "4",
                              },
                              {
                                "code": "TDS-307",
                                "name": "Tramitología de Documentos Soporte",
                                "hours": "2",
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

        // Campos de acción
        InfoCard(
          titleWidget: _titleWithIcon(Icons.work, "Campos de Acción"),
          children: const [
            InfoRow("•", "Agente de aduanas y despachante de aduana"),
            InfoRow("•", "Analista de comercio exterior"),
            InfoRow("•", "Coordinador de logística internacional"),
            InfoRow("•", "Especialista en clasificación arancelaria"),
            InfoRow("•", "Asesor en negocios internacionales"),
            InfoRow("•", "Gestor de operaciones de comercio exterior"),
            InfoRow("•", "Consultor en integración económica regional"),
          ],
        ),
      ],
    );
  }
}
