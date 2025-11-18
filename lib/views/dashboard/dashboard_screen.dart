// views/dashboard/dashboard_screen.dart - VERSIÓN CORREGIDA
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/carreras_viewmodel.dart';
import '../../utils/constants.dart';
import '../../utils/permissions.dart';
import '../gestion/gestion_screen.dart';
import '../asistencia/asistencia_screen.dart';
import '../inicio/inicio_screen.dart';
import '../reportes/reportes_screen.dart';
import '../configuracion/configuracion_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const DashboardScreen({super.key, this.userData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final dashboardVM = context.read<DashboardViewModel>();
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
    return Consumer<AuthViewModel>(
      builder: (context, authVM, child) {
        final user = authVM.currentUser;
        if (user == null) return const SizedBox();

        final userName = user.nombre;
        final firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Text(
              firstLetter,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<DashboardViewModel>(
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

  Widget _buildErrorState(DashboardViewModel dashboardVM) {
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
              onPressed: () => dashboardVM.loadDashboardData(forceRefresh: true),
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

  Widget _buildContent(DashboardViewModel dashboardVM) {
    final authVM = Provider.of<AuthViewModel>(context, listen: true);
    
    return IndexedStack(
      index: dashboardVM.selectedIndex,
      children: [
        // 🌟 PANTALLA 0: GESTIÓN ACADÉMICA (CON PERMISOS)
        _buildProtectedScreen(
          screen: GestionScreen(userData: widget.userData),
          requiredPermission: AppPermissions.ACCESS_GESTION,
          moduleName: 'Gestión Académica',
          authVM: authVM,
        ),
        
        // 🌟 PANTALLA 1: ASISTENCIA (CON PERMISOS)
        _buildProtectedScreen(
          screen: AsistenciaScreen(userData: widget.userData),
          requiredPermission: AppPermissions.ACCESS_ASISTENCIA,
          moduleName: 'Registro de Asistencia',
          authVM: authVM,
        ),
        
        // 🌟 PANTALLA 2: INICIO (SIEMPRE ACCESIBLE)
        InicioScreen(userData: widget.userData),
        
        // 🌟 PANTALLA 3: REPORTES (CON PERMISOS)
        _buildProtectedScreen(
          screen: ReportesScreen(userData: widget.userData),
          requiredPermission: AppPermissions.ACCESS_REPORTES,
          moduleName: 'Reportes e Informes',
          authVM: authVM,
        ),
        
        // 🌟 PANTALLA 4: CONFIGURACIÓN (CON PERMISOS)
        _buildProtectedScreen(
          screen: ConfiguracionScreen(userData: widget.userData),
          requiredPermission: AppPermissions.ACCESS_CONFIGURACION,
          moduleName: 'Configuración',
          authVM: authVM,
        ),
      ],
    );
  }

  // 🌟 WIDGET PARA PROTEGER PANTALLAS CON PERMISOS
  Widget _buildProtectedScreen({
    required Widget screen,
    required String requiredPermission,
    required String moduleName,
    required AuthViewModel authVM,
  }) {
    if (!authVM.isLoggedIn) {
      return _buildAccessDeniedScreen(moduleName);
    }
    
    if (authVM.tienePermiso(requiredPermission)) {
      return screen;
    } else {
      return _buildAccessDeniedScreen(moduleName);
    }
  }

  // 🌟 PANTALLA DE ACCESO DENEGADO
  Widget _buildAccessDeniedScreen(String moduleName) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 80, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'Acceso Restringido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'No tienes permisos para acceder al módulo:\n$moduleName',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  final dashboardVM = context.read<DashboardViewModel>();
                  dashboardVM.changeIndex(2); // Volver al inicio
                },
                icon: Icon(Icons.home),
                label: Text('Volver al Inicio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    final dashboardVM = Provider.of<DashboardViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: true);

    final user = authVM.currentUser;

    final userName = user?.nombre ?? 'Usuario';
    final userEmail = user?.email ?? 'usuario@incos.edu.bo';
    final userRole = user?.role ?? 'Usuario';
    final firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

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
            userName,
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          accountEmail: Text(
            '$userEmail\n$userRole',
            style: AppTextStyles.body.copyWith(
              color: Colors.white70,
              fontSize: 12,
            ),
            maxLines: 2,
          ),
          currentAccountPicture: CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.accent,
            child: Text(
              firstLetter,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // 🌟 INICIO (SIEMPRE VISIBLE)
        _buildDrawerItem(context, Icons.home, "Inicio", 2, dashboardVM),

        // 🌟 GESTIÓN ACADÉMICA (SOLO CON PERMISOS)
        if (authVM.puedeAccederGestion) ...[
          _buildExpansionDrawerItem(
            context,
            Icons.school,
            "Gestión Académica",
            children: [
              if (authVM.puedeGestionarEstudiantes || authVM.esDocente)
                _buildSubDrawerItem(
                  context,
                  Icons.people,
                  authVM.esDocente ? "Mis Estudiantes" : "Estudiantes",
                  () => _navigateToSection(context, 0, 'Estudiantes'),
                ),
              if (authVM.puedeGestionarDocentes)
                _buildSubDrawerItem(
                  context,
                  Icons.person,
                  "Docentes",
                  () => _navigateToSection(context, 0, 'Docentes'),
                ),
              if (authVM.puedeGestionarCarreras)
                _buildSubDrawerItem(
                  context,
                  Icons.school,
                  "Carreras",
                  () => _navigateToSection(context, 0, 'Carreras'),
                ),
              if (authVM.puedeGestionarMaterias)
                _buildSubDrawerItem(
                  context,
                  Icons.book,
                  "Materias",
                  () => _navigateToSection(context, 0, 'Materias'),
                ),
            ],
          ),
        ],

        // 🌟 REGISTRO DE ASISTENCIA (SOLO CON PERMISOS)
        if (authVM.puedeAccederAsistencia) ...[
          _buildExpansionDrawerItem(
            context,
            Icons.event_note,
            "Registro de Asistencia",
            children: [
              if (authVM.puedeRegistrarAsistencia)
                _buildSubDrawerItem(
                  context,
                  Icons.fingerprint,
                  "Registrar Asistencia",
                  () => _navigateToSection(context, 1, 'Registrar'),
                ),
              if (authVM.puedeVerHistorialAsistencia)
                _buildSubDrawerItem(
                  context,
                  Icons.history,
                  "Historial de Asistencia",
                  () => _navigateToSection(context, 1, 'Historial'),
                ),
            ],
          ),
        ],

        // 🌟 REPORTES (SOLO CON PERMISOS)
        if (authVM.puedeAccederReportes)
          _buildDrawerItem(
            context,
            Icons.assignment,
            "Reporte General",
            3,
            dashboardVM,
          ),

        // 🌟 CONFIGURACIÓN (SOLO CON PERMISOS)
        if (authVM.puedeAccederConfiguracion)
          _buildDrawerItem(
            context,
            Icons.settings,
            "Configuración y Soporte",
            4,
            dashboardVM,
          ),

        _buildSystemInfo(context, authVM),
      ],
    );
  }

  Widget _buildSystemInfo(BuildContext context, AuthViewModel authVM) {
    return Consumer<DashboardViewModel>(
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
              const SizedBox(height: AppSpacing.small),
              Divider(height: 1),
              const SizedBox(height: AppSpacing.small),
              // 🌟 INFO DE PERMISOS DEL USUARIO
              Text(
                'Tus Permisos:',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• ${authVM.rolDisplay}',
                style: AppTextStyles.body.copyWith(
                  fontSize: 11,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '• ${authVM.currentUserPermissions.length} permisos activos',
                style: AppTextStyles.body.copyWith(
                  fontSize: 11,
                  color: Colors.green,
                ),
              ),
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

  // 🌟 CORREGIR LA VERIFICACIÓN DE ACCESO
  void _navigateToSection(BuildContext context, int index, String section) {
    final dashboardVM = context.read<DashboardViewModel>();
    final authVM = context.read<AuthViewModel>();
    
    // 🌟 VERIFICAR PERMISOS ANTES DE NAVEGAR - CORREGIDO
    bool tieneAcceso = false;
    
    switch (section.toLowerCase()) {
      case 'estudiantes':
        tieneAcceso = authVM.puedeGestionarEstudiantes || authVM.esDocente;
        break;
      case 'docentes':
        tieneAcceso = authVM.puedeGestionarDocentes;
        break;
      case 'carreras':
        tieneAcceso = authVM.puedeGestionarCarreras;
        break;
      case 'materias':
        tieneAcceso = authVM.puedeGestionarMaterias;
        break;
      case 'registrar':
        tieneAcceso = authVM.puedeRegistrarAsistencia;
        break;
      case 'historial':
        tieneAcceso = authVM.puedeVerHistorialAsistencia;
        break;
      case 'reportes':
        tieneAcceso = authVM.puedeAccederReportes;
        break;
      case 'configuracion':
        tieneAcceso = authVM.puedeAccederConfiguracion;
        break;
      default:
        tieneAcceso = true; // Inicio siempre accesible
    }
    
    if (!tieneAcceso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No tienes permisos para acceder a $section'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    dashboardVM.changeIndex(index);
    Navigator.pop(context); // Cerrar drawer

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
    DashboardViewModel dashboardVM,
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
    final dashboardVM = Provider.of<DashboardViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context, listen: true);
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return _buildMobileBottomNavigationBar(dashboardVM, authVM, context);
    } else if (screenWidth < 1200) {
      return _buildTabletBottomNavigationBar(dashboardVM, authVM, context);
    } else {
      return _buildDesktopBottomNavigationBar(dashboardVM, authVM, context);
    }
  }

  Widget _buildMobileBottomNavigationBar(
    DashboardViewModel dashboardVM,
    AuthViewModel authVM,
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
              // 🌟 SOLO MOSTRAR SI TIENE PERMISOS
              if (authVM.puedeAccederGestion)
                _buildNavItem(
                  context,
                  Icons.person_add,
                  "ESTUDIANTES",
                  0,
                  dashboardVM,
                  deviceType: DeviceType.mobile,
                ),
              if (authVM.puedeAccederAsistencia)
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
              
              if (authVM.puedeAccederReportes)
                _buildNavItem(
                  context,
                  Icons.assignment,
                  "REPORTES",
                  3,
                  dashboardVM,
                  deviceType: DeviceType.mobile,
                ),
              if (authVM.puedeAccederConfiguracion)
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
    AuthViewModel authVM,
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
                    if (authVM.puedeAccederGestion)
                      _buildNavItem(
                        context,
                        Icons.person_add,
                        "Registro de\nEstudiantes",
                        0,
                        dashboardVM,
                        deviceType: DeviceType.tablet,
                      ),
                    if (authVM.puedeAccederAsistencia)
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
                    if (authVM.puedeAccederReportes)
                      _buildNavItem(
                        context,
                        Icons.assignment,
                        "Reportes",
                        3,
                        dashboardVM,
                        deviceType: DeviceType.tablet,
                      ),
                    if (authVM.puedeAccederConfiguracion)
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
    AuthViewModel authVM,
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
                    if (authVM.puedeAccederGestion)
                      _buildNavItem(
                        context,
                        Icons.person_add,
                        "Estudiantes",
                        0,
                        dashboardVM,
                        deviceType: DeviceType.desktop,
                      ),
                    if (authVM.puedeAccederAsistencia)
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
                    if (authVM.puedeAccederReportes)
                      _buildNavItem(
                        context,
                        Icons.assignment,
                        "Reportes",
                        3,
                        dashboardVM,
                        deviceType: DeviceType.desktop,
                      ),
                    if (authVM.puedeAccederConfiguracion)
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
      final authVM = context.read<AuthViewModel>();

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

      await authVM.logout();
      
      // Navegar de vuelta al login después del logout
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/login', 
        (route) => false
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $error'),
          backgroundColor: AppColors.error,
        ),
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