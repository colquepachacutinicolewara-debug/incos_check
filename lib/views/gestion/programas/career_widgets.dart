import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';

// Widget para tarjetas de información
class InfoCard extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget> children;

  const InfoCard({
    super.key,
    this.title,
    this.titleWidget,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (titleWidget != null)
              titleWidget!
            else if (title != null)
              Text(
                title!,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary,
                ),
              ),
            const SizedBox(height: AppSpacing.small),
            ...children,
          ],
        ),
      ),
    );
  }
}

// Widget para filas de información
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8.0),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// Widget para construir secciones de año
Widget buildYearSection(String year, List<Map<String, String>> subjects) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        year,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      const SizedBox(height: AppSpacing.small),
      Table(
        columnWidths: const {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(0.8),
          3: FlexColumnWidth(1.5),
        },
        border: TableBorder.all(color: Colors.grey.shade300),
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Colors.grey),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Código",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Asignatura",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Horas",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Prerequisito",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          ...subjects.map((subject) {
            return TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade50),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(subject["code"] ?? ""),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(subject["name"] ?? ""),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(subject["hours"] ?? ""),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(subject["req"] ?? "-"),
                ),
              ],
            );
          }).toList(),
        ],
      ),
      const SizedBox(height: AppSpacing.medium),
    ],
  );
}

// Widget para construir secciones de módulo
Widget buildModuleSection(String module, List<Map<String, String>> subjects) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        module,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.secondary,
        ),
      ),
      const SizedBox(height: AppSpacing.small),
      Table(
        columnWidths: const {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
        },
        border: TableBorder.all(color: Colors.grey.shade300),
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Colors.grey),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Código",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Asignatura",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Horas/Sem.",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Requisito",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          ...subjects.map((subject) {
            return TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade50),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(subject["code"] ?? ""),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(subject["name"] ?? ""),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(subject["hours"] ?? ""),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(subject["req"] ?? "-"),
                ),
              ],
            );
          }).toList(),
        ],
      ),
      const SizedBox(height: AppSpacing.medium),
    ],
  );
}

// Widget para contenido con scroll
class ScrollableContent extends StatelessWidget {
  final List<Widget> children;

  const ScrollableContent({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: SingleChildScrollView(child: Column(children: children)),
    );
  }
}
