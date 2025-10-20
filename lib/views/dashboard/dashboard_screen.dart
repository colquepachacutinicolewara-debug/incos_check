import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../utils/constants.dart';
import '../../views/actividades/actividades_screen.dart';
import '../../views/cursos_materias/cursos_materia_screen.dart';
import '../../views/estudiantes_inscritos/estudiantes_screen.dart';
import '../../views/inicio/inicio_screen.dart';
import '../../views/registro_huella/registro_huella_screen.dart';
import '../../views/reportes/reportes_screen.dart';
import '../../views/soporte/soporte_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardVM = Provider.of<DashboardViewModel>(context);

    final List<Widget> pages = [
      ActividadesScreen(), // 0
      CursosMateriaScreen(), // 1
      EstudiantesScreen(), // 2
      InicioScreen(), // 3 -> botón central
      RegistroHuellaScreen(), // 4
      ReportesScreen(), // 5
      SoporteScreen(), // 6
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        centerTitle: true,
        elevation: 4,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context, dashboardVM),
      body: pages[dashboardVM.selectedIndex],
      bottomNavigationBar: _buildResponsiveBottomNavigationBar(
        dashboardVM,
        context,
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, DashboardViewModel dashboardVM) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              "Usuario Ejemplo",
              style: AppTextStyles.body.copyWith(color: Colors.white),
            ),
            accountEmail: Text(
              "usuario@correo.com",
              style: AppTextStyles.body.copyWith(color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.accent,
              child: Icon(Icons.person, size: 40, color: AppColors.primary),
            ),
          ),
          _buildDrawerItem(context, Icons.home, "Inicio", 3, dashboardVM),
          _buildDrawerItem(context, Icons.event_note, "Actividades", 0, dashboardVM),
          _buildDrawerItem(context, Icons.menu_book, "Materias", 1, dashboardVM),
          _buildDrawerItem(context, Icons.assignment, "Estudiantes", 2, dashboardVM),
          _buildDrawerItem(context, Icons.school, "Registro_Huellas", 4, dashboardVM),
          _buildDrawerItem(context, Icons.message, "Reportess", 5, dashboardVM),
          _buildDrawerItem(context, Icons.support_agent, "Soporte", 6, dashboardVM),
          const Spacer(),
          const Divider(height: 1, color: AppColors.textSecondary),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.error),
            title: Text(
              AppStrings.logout,
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
            onTap: () {
              // TODO: Implementar logout
            },
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(
      BuildContext context, IconData icon, String label, int index, DashboardViewModel dashboardVM) {
    final bool isSelected = dashboardVM.selectedIndex == index;
    
    return ListTile(
      leading: Icon(
        icon, 
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        label, 
        style: AppTextStyles.body.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      onTap: () {
        dashboardVM.changeIndex(index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildResponsiveBottomNavigationBar(
    DashboardViewModel dashboardVM,
    BuildContext context,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Definir breakpoints para diferentes tamaños de pantalla
    if (screenWidth < 600) {
      return _buildMobileBottomNavigationBar(dashboardVM, context);
    } else if (screenWidth < 1200) {
      return _buildTabletBottomNavigationBar(dashboardVM, context);
    } else {
      return _buildDesktopBottomNavigationBar(dashboardVM, context);
    }
  }

  Widget _buildMobileBottomNavigationBar(
    DashboardViewModel dashboardVM,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavItem(
                Icons.event_note,
                "Actividades Academicas",
                0,
                dashboardVM,
                isMobile: true,
              ),
              _buildNavItem(
                Icons.menu_book,
                "Cursos y Materias",
                1,
                dashboardVM,
                isMobile: true,
              ),
              _buildNavItem(
                Icons.assignment,
                "Estudiantes",
                2,
                dashboardVM,
                isMobile: true,
              ),
              _buildNavItemInicio(dashboardVM, isMobile: true),
              _buildNavItem(
                Icons.school,
                "Registro Huella",
                4,
                dashboardVM,
                isMobile: true,
              ),
              _buildNavItem(
                Icons.message,
                "Reportes",
                5,
                dashboardVM,
                isMobile: true,
              ),
              _buildNavItem(
                Icons.support_agent,
                "Soporte",
                6,
                dashboardVM,
                isMobile: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletBottomNavigationBar(
    DashboardViewModel dashboardVM,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      Icons.event_note,
                      "Actividades\nAcadémicas",
                      0,
                      dashboardVM,
                      isTablet: true,
                    ),
                    _buildNavItem(
                      Icons.menu_book,
                      "Cursos y\nMateria",
                      1,
                      dashboardVM,
                      isTablet: true,
                    ),
                    _buildNavItem(
                      Icons.assignment,
                      "Estudiantes",
                      2,
                      dashboardVM,
                      isTablet: true,
                    ),
                  ],
                ),
              ),
              _buildNavItemInicio(dashboardVM, isTablet: true),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      Icons.school,
                      "Registro de Huella",
                      4,
                      dashboardVM,
                      isTablet: true,
                    ),
                    _buildNavItem(
                      Icons.message,
                      "Reportes",
                      5,
                      dashboardVM,
                      isTablet: true,
                    ),
                    _buildNavItem(
                      Icons.support_agent,
                      "Soporte",
                      6,
                      dashboardVM,
                      isTablet: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopBottomNavigationBar(
    DashboardViewModel dashboardVM,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
          height: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      Icons.event_note,
                      "Actividades Académicas",
                      0,
                      dashboardVM,
                      isDesktop: true,
                    ),
                    _buildNavItem(
                      Icons.menu_book,
                      "Cursos y Materia",
                      1,
                      dashboardVM,
                      isDesktop: true,
                    ),
                    _buildNavItem(
                      Icons.assignment,
                      "Estudiantes",
                      2,
                      dashboardVM,
                      isDesktop: true,
                    ),
                  ],
                ),
              ),
              _buildNavItemInicio(dashboardVM, isDesktop: true),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      Icons.school,
                      "Registro de Huella",
                      4,
                      dashboardVM,
                      isDesktop: true,
                    ),
                    _buildNavItem(
                      Icons.message,
                      "Reportes Academicos",
                      5,
                      dashboardVM,
                      isDesktop: true,
                    ),
                    _buildNavItem(
                      Icons.support_agent,
                      "Soporte Técnico",
                      6,
                      dashboardVM,
                      isDesktop: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    DashboardViewModel dashboardVM, {
    bool isMobile = false,
    bool isTablet = false,
    bool isDesktop = false,
  }) {
    final bool isSelected = dashboardVM.selectedIndex == index;

    return MaterialButton(
      minWidth: isMobile
          ? 40
          : isTablet
          ? 60
          : 80,
      onPressed: () => dashboardVM.changeIndex(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: isMobile
                ? 20
                : isTablet
                ? 24
                : 28,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: isMobile
                    ? 10
                    : isTablet
                    ? 12
                    : 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: isTablet ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItemInicio(
    DashboardViewModel dashboardVM, {
    bool isMobile = false,
    bool isTablet = false,
    bool isDesktop = false,
  }) {
    final bool isSelected = dashboardVM.selectedIndex == 3;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.medium : AppSpacing.large,
      ),
      child: GestureDetector(
        onTap: () => dashboardVM.changeIndex(3),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.success,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          width: isMobile
              ? 56
              : isTablet
              ? 64
              : 72,
          height: isMobile
              ? 56
              : isTablet
              ? 64
              : 72,
          child: Icon(
            Icons.home,
            color: Colors.white,
            size: isMobile
                ? 24
                : isTablet
                ? 28
                : 32,
          ),
        ),
      ),
    );
  }
}