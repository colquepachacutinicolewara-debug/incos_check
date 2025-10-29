import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../utils/constants.dart';
import '../../views/gestion/gestion_screen.dart';
import '../../views/asistencia/registrar_asistencia_screen.dart';
import '../../views/inicio/inicio_screen.dart';
import '../../views/reportes/reportes_screen.dart';
import '../../views/configuracion/configuracion_screen.dart';
import '../../views/soporte/soporte_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        centerTitle: true,
        elevation: 4,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildResponsiveBottomNavigationBar(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final dashboardVM = Provider.of<DashboardViewModel>(context);
    
    final List<Widget> pages = [
      GestionScreen(), // 0 - Gestión
      RegistrarAsistenciaScreen(), // 1 - Asistencia
      InicioScreen(), // 2 - Inicio (botón central)
      ReportesScreen(), // 3 - Reportes
      ConfiguracionScreen(), // 4 - Configuración/Perfil (CORREGIDO)
      SoporteScreen(), // 5 - Soporte
    ];

    return pages[dashboardVM.selectedIndex];
  }

  Drawer _buildDrawer(BuildContext context) {
    final dashboardVM = Provider.of<DashboardViewModel>(context);
    
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
          _buildDrawerItem(context, Icons.home, "Inicio", 2, dashboardVM),
          _buildDrawerItem(context, Icons.person_add, "Registro de Estudiante", 0, dashboardVM),
          _buildDrawerItem(context, Icons.event_note, "Registro de Asistencia", 1, dashboardVM),
          _buildDrawerItem(context, Icons.assignment, "Reportes", 3, dashboardVM),
          _buildDrawerItem(context, Icons.settings, "Perfil", 4, dashboardVM),
          _buildDrawerItem(context, Icons.help, "Soporte", 5, dashboardVM),
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

  Widget _buildResponsiveBottomNavigationBar(BuildContext context) {
    final dashboardVM = Provider.of<DashboardViewModel>(context);
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
                Icons.person_add,
                "ESTUDIANTES",
                0,
                dashboardVM,
                deviceType: DeviceType.mobile,
              ),
              _buildNavItem(
                Icons.event_note,
                "ASISTENCIAS",
                1,
                dashboardVM,
                deviceType: DeviceType.mobile,
              ),
              _buildNavItemInicio(dashboardVM, deviceType: DeviceType.mobile),
              _buildNavItem(
                Icons.assignment,
                "REPORTES",
                3,
                dashboardVM,
                deviceType: DeviceType.mobile,
              ),
              _buildNavItem(
                Icons.settings,
                "PERFIL",
                4,
                dashboardVM,
                deviceType: DeviceType.mobile,
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
                      Icons.person_add,
                      "Registro de\nEstudiantes",
                      0,
                      dashboardVM,
                      deviceType: DeviceType.tablet,
                    ),
                    _buildNavItem(
                      Icons.event_note,
                      "Registro de\nAsistencia",
                      1,
                      dashboardVM,
                      deviceType: DeviceType.tablet,
                    ),
                  ],
                ),
              ),
              _buildNavItemInicio(dashboardVM, deviceType: DeviceType.tablet),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      Icons.assignment,
                      "Reportes",
                      3,
                      dashboardVM,
                      deviceType: DeviceType.tablet,
                    ),
                    _buildNavItem(
                      Icons.settings,
                      "Perfil",
                      4,
                      dashboardVM,
                      deviceType: DeviceType.tablet,
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
                      Icons.person_add,
                      "Estudiantes",
                      0,
                      dashboardVM,
                      deviceType: DeviceType.desktop,
                    ),
                    _buildNavItem(
                      Icons.event_note,
                      "Asistencia",
                      1,
                      dashboardVM,
                      deviceType: DeviceType.desktop,
                    ),
                  ],
                ),
              ),
              _buildNavItemInicio(dashboardVM, deviceType: DeviceType.desktop),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      Icons.assignment,
                      "Reportes",
                      3,
                      dashboardVM,
                      deviceType: DeviceType.desktop,
                    ),
                    _buildNavItem(
                      Icons.settings,
                      "Perfil",
                      4,
                      dashboardVM,
                      deviceType: DeviceType.desktop,
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
    required DeviceType deviceType,
  }) {
    final bool isSelected = dashboardVM.selectedIndex == index;
    final sizes = _getSizesForDevice(deviceType);

    return MaterialButton(
      minWidth: sizes.minWidth,
      onPressed: () => dashboardVM.changeIndex(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: sizes.iconSize,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: sizes.fontSize,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: sizes.maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItemInicio(
    DashboardViewModel dashboardVM, {
    required DeviceType deviceType,
  }) {
    final bool isSelected = dashboardVM.selectedIndex == 2;
    final sizes = _getSizesForDevice(deviceType);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: deviceType == DeviceType.mobile 
            ? AppSpacing.medium 
            : AppSpacing.large,
      ),
      child: GestureDetector(
        onTap: () => dashboardVM.changeIndex(2),
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
          width: sizes.homeButtonSize,
          height: sizes.homeButtonSize,
          child: Icon(
            Icons.home,
            color: Colors.white,
            size: sizes.homeIconSize,
          ),
        ),
      ),
    );
  }

  _DeviceSizes _getSizesForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return _DeviceSizes(
          minWidth: 40,
          iconSize: 20,
          fontSize: 10,
          maxLines: 1,
          homeButtonSize: 56,
          homeIconSize: 24,
        );
      case DeviceType.tablet:
        return _DeviceSizes(
          minWidth: 60,
          iconSize: 24,
          fontSize: 12,
          maxLines: 2,
          homeButtonSize: 64,
          homeIconSize: 28,
        );
      case DeviceType.desktop:
        return _DeviceSizes(
          minWidth: 80,
          iconSize: 28,
          fontSize: 14,
          maxLines: 1,
          homeButtonSize: 72,
          homeIconSize: 32,
        );
    }
  }
}

class _DeviceSizes {
  final double minWidth;
  final double iconSize;
  final double fontSize;
  final int maxLines;
  final double homeButtonSize;
  final double homeIconSize;
  
  _DeviceSizes({
    required this.minWidth,
    required this.iconSize,
    required this.fontSize,
    required this.maxLines,
    required this.homeButtonSize,
    required this.homeIconSize,
  });
}

enum DeviceType { mobile, tablet, desktop }