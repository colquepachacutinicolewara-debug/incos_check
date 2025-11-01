import 'package:flutter/material.dart';
import 'career_widgets.dart';
import 'package:incos_check/utils/constants.dart';

class CarreraSecretariado extends StatelessWidget {
  const CarreraSecretariado({super.key});

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
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
              "El profesional Técnico Superior en Secretariado Ejecutivo tiene las competencias, "
              "capacidades y habilidades para brindar apoyo administrativo en las diferentes áreas "
              "de la empresa, recepcionar y organizar la correspondencia y documentación administrativa, "
              "atender al público de manera presencial y telefónica, hacer registros contables y "
              "conciliaciones bancarias, llevar la agenda de los directivos y organizar eventos "
              "relacionados con el objeto social de la empresa, con ética, responsabilidad y buen "
              "trato en sus funciones, con especial énfasis en el servicio al cliente.",
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
            InfoRow("•", "Gestión secretarial y administrativa"),
            InfoRow("•", "Comunicación empresarial y correspondencia"),
            InfoRow("•", "Relaciones públicas y organización de eventos"),
            InfoRow("•", "Archivística y gestión documental"),
            InfoRow("•", "Ofimática y tecnología aplicada"),
            InfoRow("•", "Contabilidad básica y finanzas"),
            InfoRow("•", "Idiomas (español, inglés e idioma originario)"),
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
                                "code": "GES-101",
                                "name": "Gestión Secretarial I",
                                "hours": "4",
                              },
                              {
                                "code": "GRA-102",
                                "name": "Gramática Normativa",
                                "hours": "4",
                              },
                              {
                                "code": "REC-103",
                                "name": "Redacción y Correspondencia I",
                                "hours": "4",
                              },
                              {
                                "code": "OFI-104",
                                "name": "Ofimática I",
                                "hours": "4",
                              },
                              {
                                "code": "DOM-105",
                                "name": "Documentos Mercantiles",
                                "hours": "2",
                              },
                              {
                                "code": "AFD-106",
                                "name": "Archivística Física y Digital",
                                "hours": "4",
                              },
                              {
                                "code": "IDO-107",
                                "name": "Idioma Originario I",
                                "hours": "2",
                              },
                              {
                                "code": "MEC-108",
                                "name": "Mecanografía Computarizada",
                                "hours": "4",
                              },
                              {
                                "code": "INC-109",
                                "name": "Inglés Comercial I",
                                "hours": "2",
                              },
                            ]),
                            _buildYearSection("Segundo Año", [
                              {
                                "code": "GES-201",
                                "name": "Gestión Secretarial II",
                                "hours": "4",
                                "req": "GES-101",
                              },
                              {
                                "code": "INC-202",
                                "name": "Inglés Comercial II",
                                "hours": "4",
                                "req": "INC-109",
                              },
                              {
                                "code": "REC-203",
                                "name": "Redacción y Correspondencia II",
                                "hours": "6",
                                "req": "REC-103",
                              },
                              {
                                "code": "OFI-204",
                                "name": "Ofimática II",
                                "hours": "4",
                                "req": "OFI-104",
                              },
                              {
                                "code": "IDO-207",
                                "name": "Idioma Originario II",
                                "hours": "2",
                                "req": "IDO-107",
                              },
                              {
                                "code": "RHE-206",
                                "name":
                                    "Relaciones Humanas y Ética Profesional",
                                "hours": "4",
                              },
                              {
                                "code": "CON-205",
                                "name": "Contabilidad I",
                                "hours": "4",
                              },
                              {
                                "code": "GDA-208",
                                "name": "Gestión Documental y Archivo",
                                "hours": "2",
                              },
                            ]),
                            _buildYearSection("Tercer Año", [
                              {
                                "code": "CON-305",
                                "name": "Contabilidad II",
                                "hours": "4",
                                "req": "CON-205",
                              },
                              {
                                "code": "REC-303",
                                "name": "Redacción y Correspondencia III",
                                "hours": "6",
                                "req": "REC-203",
                              },
                              {
                                "code": "RPO-306",
                                "name":
                                    "Relaciones Públicas y Organización de Eventos",
                                "hours": "4",
                              },
                              {
                                "code": "AOM-301",
                                "name":
                                    "Administración Organizacional y Medio Ambiente",
                                "hours": "4",
                              },
                              {
                                "code": "TMG-304",
                                "name": "Taller de Modalidad de Graduación",
                                "hours": "4",
                              },
                              {
                                "code": "INE-302",
                                "name": "Inglés Empresarial",
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
          children: const [
            InfoRow(
              "•",
              "Secretaria/o ejecutivo en empresas públicas y privadas",
            ),
            InfoRow("•", "Asistente administrativo en diversas áreas"),
            InfoRow("•", "Recepcionista ejecutivo"),
            InfoRow("•", "Asistente de dirección"),
            InfoRow("•", "Coordinador de oficina"),
            InfoRow("•", "Organizador de eventos corporativos"),
            InfoRow("•", "Gestor de documentación y archivo"),
          ],
        ),
      ],
    );
  }
}
