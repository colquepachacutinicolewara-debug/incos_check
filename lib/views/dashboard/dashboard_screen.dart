import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/carreras_viewmodel.dart';
import '../../utils/constants.dart';
import '../../views/gestion/gestion_screen.dart';
import '../../views/asistencia/asistencia_screen.dart';
import '../../views/inicio/inicio_screen.dart';
import '../../views/reportes/reportes_screen.dart';
import '../../views/configuracion/configuracion_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializar datos cuando se monta el screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardVM = context.read<DashboardViewModel>();
      final carrerasVM = context.read<CarrerasViewModel>();

      dashboardVM.loadDashboardData();
      // Los streams de carreras se inicializan automáticamente en el ViewModel
    });
  }

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

    // Mostrar loading si está cargando
    if (dashboardVM.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Mostrar error si hay error
    if (dashboardVM.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${dashboardVM.error}'),
            ElevatedButton(
              onPressed: () => dashboardVM.loadDashboardData(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final List<Widget> pages = [
      GestionScreen(), // 0 - Gestión
      AsistenciaScreen(), // 1 - Asistencia
      InicioScreen(), // 2 - Inicio
      ReportesScreen(), // 3 - Reportes
      ConfiguracionScreen(), // 4 - Configuración
    ];

    return pages[dashboardVM.selectedIndex];
  }

  Drawer _buildDrawer(BuildContext context) {
    final dashboardVM = Provider.of<DashboardViewModel>(context);
    final carrerasVM = Provider.of<CarrerasViewModel>(context);
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor:
          theme.drawerTheme.backgroundColor ?? _getDrawerColor(context),
      child: SafeArea(
        child: SingleChildScrollView(
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

              _buildExpansionDrawerItem(
                context,
                Icons.school,
                "Gestión Académica",
                dashboardVM,
                children: [
                  _buildSubDrawerItem(
                    context,
                    Icons.people,
                    "Estudiantes",
                    () => _navigateToGestionSubScreen(context, 'Estudiantes'),
                  ),
                  _buildSubDrawerItem(
                    context,
                    Icons.book,
                    "Cursos",
                    () => _navigateToGestionSubScreen(context, 'Cursos'),
                  ),
                  _buildSubDrawerItem(
                    context,
                    Icons.school,
                    "Carreras",
                    () => _navigateToGestionSubScreen(context, 'Carreras'),
                  ),
                  _buildSubDrawerItem(
                    context,
                    Icons.person,
                    "Docentes",
                    () => _navigateToGestionSubScreen(context, 'Docentes'),
                  ),
                ],
              ),

              _buildExpansionDrawerItem(
                context,
                Icons.event_note,
                "Registro de Asistencia",
                dashboardVM,
                children: [
                  _buildSubDrawerItem(
                    context,
                    Icons.fingerprint,
                    "Registrar Asistencia",
                    () => _navigateToAsistenciaSubScreen(context, 'Registrar'),
                  ),
                  _buildSubDrawerItem(
                    context,
                    Icons.history,
                    "Historial de Asistencia",
                    () => _navigateToAsistenciaSubScreen(context, 'Historial'),
                  ),
                ],
              ),

              _buildDrawerItem(
                context,
                Icons.assignment,
                "Reporte General",
                3,
                dashboardVM,
              ),
              _buildDrawerItem(
                context,
                Icons.settings,
                "Configuración y Soporte",
                4,
                dashboardVM,
              ),
              const SizedBox(height: AppSpacing.large),
              Divider(height: 1, color: _getDividerColor(context)),
              ListTile(
                leading: Icon(Icons.logout, color: _getErrorColor(context)),
                title: Text(
                  AppStrings.logout,
                  style: AppTextStyles.body.copyWith(
                    color: _getErrorColor(context),
                  ),
                ),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
              const SizedBox(height: AppSpacing.medium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionDrawerItem(
    BuildContext context,
    IconData icon,
    String label,
    DashboardViewModel dashboardVM, {
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: _getSecondaryTextColor(context)),
      title: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: _getTextColor(context),
          fontWeight: FontWeight.w500,
        ),
      ),
      collapsedIconColor: _getSecondaryTextColor(context),
      iconColor: _getSecondaryTextColor(context),
      children: children,
    );
  }

  Widget _buildSubDrawerItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: ListTile(
        leading: Icon(icon, size: 20, color: _getSecondaryTextColor(context)),
        title: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: _getTextColor(context),
            fontSize: 14,
          ),
        ),
        minLeadingWidth: 0,
        onTap: () {
          onTap();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _navigateToGestionSubScreen(BuildContext context, String tipo) {
    final dashboardVM = Provider.of<DashboardViewModel>(context, listen: false);
    dashboardVM.changeIndex(0);

    // Puedes pasar el tipo de gestión si es necesario
    // Por ejemplo, usando un Provider adicional o Navigator
  }

  void _navigateToAsistenciaSubScreen(BuildContext context, String tipo) {
    final dashboardVM = Provider.of<DashboardViewModel>(context, listen: false);
    dashboardVM.changeIndex(1);

    // Puedes pasar el tipo de asistencia si es necesario
  }

  ListTile _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    DashboardViewModel dashboardVM,
  ) {
    final bool isSelected = dashboardVM.selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : _getSecondaryTextColor(context),
      ),
      title: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: isSelected ? AppColors.primary : _getTextColor(context),
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
        color: _getBottomNavColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                context,
                Icons.person_add,
                "ESTUDIANTES",
                0,
                dashboardVM,
                deviceType: DeviceType.mobile,
              ),
              _buildNavItem(
                context,
                Icons.event_note,
                "ASISTENCIAS",
                1,
                dashboardVM,
                deviceType: DeviceType.mobile,
              ),
              _buildNavItemInicio(
                context,
                dashboardVM,
                deviceType: DeviceType.mobile,
              ),
              _buildNavItem(
                context,
                Icons.assignment,
                "REPORTES",
                3,
                dashboardVM,
                deviceType: DeviceType.mobile,
              ),
              _buildNavItem(
                context,
                Icons.settings,
                "AJUSTES",
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
        color: _getBottomNavColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                      context,
                      Icons.person_add,
                      "Registro de\nEstudiantes",
                      0,
                      dashboardVM,
                      deviceType: DeviceType.tablet,
                    ),
                    _buildNavItem(
                      context,
                      Icons.event_note,
                      "Registro de\nAsistencia",
                      1,
                      dashboardVM,
                      deviceType: DeviceType.tablet,
                    ),
                  ],
                ),
              ),
              _buildNavItemInicio(
                context,
                dashboardVM,
                deviceType: DeviceType.tablet,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context,
                      Icons.assignment,
                      "Reportes",
                      3,
                      dashboardVM,
                      deviceType: DeviceType.tablet,
                    ),
                    _buildNavItem(
                      context,
                      Icons.settings,
                      "Configuración",
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
        color: _getBottomNavColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                      context,
                      Icons.person_add,
                      "Estudiantes",
                      0,
                      dashboardVM,
                      deviceType: DeviceType.desktop,
                    ),
                    _buildNavItem(
                      context,
                      Icons.event_note,
                      "Asistencia",
                      1,
                      dashboardVM,
                      deviceType: DeviceType.desktop,
                    ),
                  ],
                ),
              ),
              _buildNavItemInicio(
                context,
                dashboardVM,
                deviceType: DeviceType.desktop,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      context,
                      Icons.assignment,
                      "Reportes",
                      3,
                      dashboardVM,
                      deviceType: DeviceType.desktop,
                    ),
                    _buildNavItem(
                      context,
                      Icons.settings,
                      "Configuración",
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
    BuildContext context,
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
            color: isSelected
                ? AppColors.primary
                : _getSecondaryTextColor(context),
            size: sizes.iconSize,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : _getSecondaryTextColor(context),
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
    BuildContext context,
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
                color: Colors.black.withOpacity(0.2),
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

  // Funciones para obtener colores según el tema
  Color _getBottomNavColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }

  Color _getDrawerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.white;
  }

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

  Color _getDividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700
        : AppColors.textSecondary;
  }

  Color _getErrorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade400
        : AppColors.error;
  }

  // Método para mostrar diálogo de logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Método para realizar logout
  void _performLogout(BuildContext context) {
    // TODO: Implementar lógica de logout
    // Por ejemplo:
    // - Limpiar datos de sesión
    // - Navegar a la pantalla de login
    // - Reiniciar estados

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesión cerrada correctamente'),
        backgroundColor: Colors.green,
      ),
    );
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
