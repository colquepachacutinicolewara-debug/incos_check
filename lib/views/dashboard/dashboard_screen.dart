import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/dashboard_viewmodel.dart' as dashboard_vm;
import '../../viewmodels/carreras_viewmodel.dart';
import '../../utils/constants.dart';
import '../gestion/gestion_screen.dart';
import '../asistencia/asistencia_screen.dart';
import '../inicio/inicio_screen.dart';
import '../reportes/reportes_screen.dart';
import '../configuracion/configuracion_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Cache para las páginas
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _initializePages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _initializePages() {
    _pages.addAll([
      const GestionScreen(),
      const AsistenciaScreen(),
      const InicioScreen(),
      const ReportesScreen(),
      const ConfiguracionScreen(),
    ]);
  }

  void _loadInitialData() {
    final dashboardVM = context.read<dashboard_vm.DashboardViewModel>();
    final carrerasVM = context.read<CarrerasViewModel>();

    // Cargar datos solo si es necesario
    dashboardVM.loadDashboardData();
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
        actions: [_buildUserAvatar()],
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildResponsiveBottomNavigationBar(context),
    );
  }

  Widget _buildUserAvatar() {
    return Consumer<dashboard_vm.DashboardViewModel>(
      builder: (context, dashboardVM, child) {
        final user = dashboardVM.currentUser;
        if (user == null) return const SizedBox();

        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
            child: user.photoURL == null
                ? Icon(Icons.person, size: 16, color: AppColors.primary)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<dashboard_vm.DashboardViewModel>(
      builder: (context, dashboardVM, child) {
        if (dashboardVM.loading && dashboardVM.dashboardData.isEmpty) {
          return _buildLoadingState();
        }

        if (dashboardVM.error.isNotEmpty) {
          return _buildErrorState(dashboardVM);
        }

        return _buildContent(dashboardVM);
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.medium),
          Text('Cargando datos...', style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildErrorState(dashboard_vm.DashboardViewModel dashboardVM) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Error al cargar datos',
              style: AppTextStyles.heading2.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              dashboardVM.error,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton.icon(
              onPressed: () =>
                  dashboardVM.loadDashboardData(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(dashboard_vm.DashboardViewModel dashboardVM) {
    // Usar IndexedStack para mantener el estado de las páginas
    return IndexedStack(index: dashboardVM.selectedIndex, children: _pages);
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: _getDrawerColor(context),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(child: _buildDrawerContent(context)),
            ),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerContent(BuildContext context) {
    final dashboardVM = Provider.of<dashboard_vm.DashboardViewModel>(
      context,
      listen: false,
    );
    final user = dashboardVM.currentUser;

    return Column(
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
            user?.displayName ?? 'Usuario',
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          accountEmail: Text(
            user?.email ?? 'usuario@incos.edu.bo',
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
          currentAccountPicture: CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.accent,
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user?.photoURL == null
                ? Icon(Icons.person, size: 40, color: AppColors.primary)
                : null,
          ),
        ),

        _buildDrawerItem(context, Icons.home, "Inicio", 2, dashboardVM),

        _buildExpansionDrawerItem(
          context,
          Icons.school,
          "Gestión Académica",
          children: [
            _buildSubDrawerItem(
              context,
              Icons.people,
              "Estudiantes",
              () => _navigateToSection(context, 0, 'Estudiantes'),
            ),
            _buildSubDrawerItem(
              context,
              Icons.book,
              "Cursos",
              () => _navigateToSection(context, 0, 'Cursos'),
            ),
            _buildSubDrawerItem(
              context,
              Icons.school,
              "Carreras",
              () => _navigateToSection(context, 0, 'Carreras'),
            ),
            _buildSubDrawerItem(
              context,
              Icons.person,
              "Docentes",
              () => _navigateToSection(context, 0, 'Docentes'),
            ),
          ],
        ),

        _buildExpansionDrawerItem(
          context,
          Icons.event_note,
          "Registro de Asistencia",
          children: [
            _buildSubDrawerItem(
              context,
              Icons.fingerprint,
              "Registrar Asistencia",
              () => _navigateToSection(context, 1, 'Registrar'),
            ),
            _buildSubDrawerItem(
              context,
              Icons.history,
              "Historial de Asistencia",
              () => _navigateToSection(context, 1, 'Historial'),
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

        _buildSystemInfo(context),
      ],
    );
  }

  Widget _buildSystemInfo(BuildContext context) {
    return Consumer<dashboard_vm.DashboardViewModel>(
      builder: (context, dashboardVM, child) {
        final stats = dashboardVM.dashboardData['stats'] ?? {};

        return Container(
          margin: const EdgeInsets.all(AppSpacing.medium),
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen del Sistema',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              _buildStatItem('Estudiantes', stats['estudiantes'] ?? 0),
              _buildStatItem('Docentes', stats['docentes'] ?? 0),
              _buildStatItem('Carreras', stats['carreras'] ?? 0),
              _buildStatItem('Asistencias Hoy', stats['asistencias_hoy'] ?? 0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: _getSecondaryTextColor(context),
            ),
          ),
          Text(
            value.toString(),
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionDrawerItem(
    BuildContext context,
    IconData icon,
    String label, {
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

  void _navigateToSection(BuildContext context, int index, String section) {
    final dashboardVM = context.read<dashboard_vm.DashboardViewModel>();
    dashboardVM.changeIndex(index);

    Navigator.pop(context); // Cerrar drawer

    // Mostrar snackbar solo en debug
    if (kDebugMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navegando a $section'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  ListTile _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    dashboard_vm.DashboardViewModel dashboardVM,
  ) {
    final bool isSelected = dashboardVM.selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : _getSecondaryTextColor(context),
        size: 24,
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

  Widget _buildLogoutButton(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.large),
        Divider(height: 1, color: _getDividerColor(context)),
        ListTile(
          leading: Icon(Icons.logout, color: _getErrorColor(context)),
          title: Text(
            AppStrings.logout,
            style: AppTextStyles.body.copyWith(
              color: _getErrorColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            _showLogoutDialog(context);
          },
        ),
        const SizedBox(height: AppSpacing.medium),
      ],
    );
  }

  Widget _buildResponsiveBottomNavigationBar(BuildContext context) {
    final dashboardVM = Provider.of<dashboard_vm.DashboardViewModel>(context);
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
    dashboard_vm.DashboardViewModel dashboardVM,
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
        border: Border(
          top: BorderSide(color: _getDividerColor(context), width: 0.5),
        ),
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
    dashboard_vm.DashboardViewModel dashboardVM,
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
        border: Border(
          top: BorderSide(color: _getDividerColor(context), width: 0.5),
        ),
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
    dashboard_vm.DashboardViewModel dashboardVM,
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
        border: Border(
          top: BorderSide(color: _getDividerColor(context), width: 0.5),
        ),
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
    dashboard_vm.DashboardViewModel dashboardVM, {
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
          Container(
            padding: const EdgeInsets.all(4),
            decoration: isSelected
                ? BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  )
                : null,
            child: Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : _getSecondaryTextColor(context),
              size: sizes.iconSize,
            ),
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
    dashboard_vm.DashboardViewModel dashboardVM, {
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.success,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isSelected ? 0.3 : 0.2),
                blurRadius: isSelected ? 8 : 4,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: AppColors.error),
              const SizedBox(width: AppSpacing.small),
              Text(
                'Cerrar Sesión',
                style: AppTextStyles.heading2.copyWith(color: AppColors.error),
              ),
            ],
          ),
          content: const Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) async {
    try {
      final dashboardVM = context.read<dashboard_vm.DashboardViewModel>();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: AppSpacing.small),
              Text('Cerrando sesión...'),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );

      await dashboardVM.logout();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // CORRECCIÓN PARA EL ERROR DEL DROPDOWN
  // Añade este método en tu CarrerasViewModel o donde uses DropdownButton
  Widget _buildFixedDropdown(
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    // Asegurar que los valores sean únicos
    final uniqueItems = _ensureUniqueDropdownItems(items);

    return DropdownButton<String>(
      value: selectedValue,
      onChanged: onChanged,
      items: uniqueItems.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      isExpanded: true,
    );
  }

  List<String> _ensureUniqueDropdownItems(List<String> originalItems) {
    final uniqueItems = <String>[];
    final seenItems = <String>{};

    for (final item in originalItems) {
      if (!seenItems.contains(item)) {
        uniqueItems.add(item);
        seenItems.add(item);
      } else {
        // Manejar duplicados añadiendo un identificador
        int counter = 1;
        String newItem = item;
        while (seenItems.contains(newItem)) {
          newItem = '$item (${counter++})';
        }
        uniqueItems.add(newItem);
        seenItems.add(newItem);
      }
    }

    return uniqueItems;
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
