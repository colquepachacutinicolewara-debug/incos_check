import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/viewmodels/programas_viewmodel.dart';

// Importar las carreras individuales
import 'carrera_secretariado.dart';
import 'carrera_comercio.dart';
import 'carrera_contaduria.dart';
import 'carrera_empresas.dart';
import 'carrera_sistemas.dart';
import 'carrera_ingles.dart';

class ProgramasScreen extends StatefulWidget {
  const ProgramasScreen({super.key});

  @override
  State<ProgramasScreen> createState() => _ProgramasScreenState();
}

class _ProgramasScreenState extends State<ProgramasScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProgramasViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Programas de Estudio"),
          centerTitle: true,
          elevation: 4,
          backgroundColor: AppColors.primary,
        ),
        body: Consumer<ProgramasViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                children: [
                  /// Filtro / búsqueda
                  TextField(
                    controller: viewModel.searchController,
                    decoration: InputDecoration(
                      hintText: "Buscar programa...",
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.small,
                        horizontal: AppSpacing.medium,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  /// Lista de programas
                  Expanded(
                    child: ListView.separated(
                      itemCount: viewModel.filteredProgramas.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.medium),
                      itemBuilder: (context, index) {
                        final programa = viewModel.filteredProgramas[index];
                        final realIndex = viewModel.getRealIndex(
                          programa.nombre,
                        );
                        final isExpanded = viewModel.expandedIndex == realIndex;
                        final iconData = viewModel.getIconFromName(
                          programa.iconoNombre,
                        );

                        return Card(
                          elevation: 6,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                          ),
                          child: ExpansionTile(
                            key: Key('programa_$realIndex'),
                            initiallyExpanded: isExpanded,
                            onExpansionChanged: (expanded) {
                              if (expanded) {
                                viewModel.toggleExpand(realIndex);
                              } else if (viewModel.expandedIndex == realIndex) {
                                viewModel.toggleExpand(-1);
                              }
                            },
                            leading: Icon(iconData, color: AppColors.primary),
                            title: Text(
                              programa.nombre,
                              style: AppTextStyles.heading1.copyWith(
                                fontSize: 18,
                              ),
                            ),
                            trailing: Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: AppColors.primary,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(
                                  AppSpacing.medium,
                                ),
                                child: _getExpandedContent(realIndex),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Función para obtener el contenido expandido según el programa
  Widget _getExpandedContent(int index) {
    switch (index) {
      case 0: // Secretariado Ejecutivo
        return const CarreraSecretariado();
      case 1: // Comercio Internacional
        return const CarreraComercio();
      case 2: // Contaduría General
        return const CarreraContaduria();
      case 3: // Administración de Empresas
        return const CarreraEmpresas();
      case 4: // Sistemas Informáticos
        return const CarreraSistemas();
      case 5: // Idioma Inglés
        return const CarreraIngles();
      default:
        return const SizedBox();
    }
  }
}
