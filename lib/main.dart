// main.dart - VERSIÓN COMPLETA OPTIMIZADA
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Database - SOLO SQLite
import '../models/database_helper.dart';

// ViewModels CORREGIDOS (SQLite)
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/carreras_viewmodel.dart';
import 'viewmodels/configuracion_viewmodel.dart';
import 'viewmodels/estudiantes_viewmodel.dart';
import 'viewmodels/paralelos_viewmodel.dart';
import 'viewmodels/docente_viewmodel.dart';
import 'viewmodels/gestion_viewmodel.dart';
import 'viewmodels/materia_viewmodel.dart';
import 'viewmodels/nivel_viewmodel.dart';
import 'viewmodels/periodo_academico_viewmodel.dart';
import 'viewmodels/primer_bimestre_viewmodel.dart';
import 'viewmodels/registrar_asistencia_viewmodel.dart';
import 'viewmodels/reporte_viewmodel.dart';
import 'viewmodels/soporte_viewmodel.dart';
import 'viewmodels/turnos_viewmodel.dart';
import 'viewmodels/historial_asitencia_viewmodel.dart';
import 'viewmodels/inicio_viewmodel.dart';
import 'viewmodels/asistencia_viewmodel.dart'; 
import 'viewmodels/auth_viewmodel.dart'; 

// Services
import 'services/theme_service.dart';
import 'services/notification_service.dart';

// Views
import 'views/dashboard/dashboard_screen.dart';
import 'views/dashboard/login_screen.dart';

// Colors
class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF42A5F5);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 🌟 INICIALIZAR BASE DE DATOS CORRECTAMENTE - MÉTODO CORREGIDO
    await DatabaseHelper.instance.initDatabase();
    print('✅ Base de datos SQLite inicializada y datos preservados');
    
    // Verificar que la base de datos existe y tiene datos
    final db = await DatabaseHelper.instance.database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
    );
    print('📊 Tablas en la base de datos: ${tables.length}');
    
    for (var table in tables) {
      final count = await db.rawQuery('SELECT COUNT(*) as count FROM ${table['name']}');
      print('📋 Tabla ${table['name']}: ${count.first['count']} registros');
    }
    
    // 🌟 INICIALIZAR NOTIFICACIONES
    await NotificationService().initialize();
    print('🔔 Servicio de notificaciones inicializado');
    
  } catch (e) {
    debugPrint('❌ Error crítico al inicializar base de datos: $e');
    // En caso de error, podrías mostrar un screen de error
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🌟 PROVIDER DE DATABASEHELPER - AÑADIR ESTO
        Provider<DatabaseHelper>(
          create: (context) => DatabaseHelper.instance,
        ),
        
        // 🌟 AUTH VIEWMODEL - DEBE ESTAR PRIMERO (CON EL MÉTODO initializeSession)
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(),
        ),
        
        // 🌟 SERVICIO DE TEMA
        ChangeNotifierProvider<ThemeService>(
          create: (_) => ThemeService()..loadThemePreference(),
        ),
        
        // 🌟 VIEWMODELS CORREGIDOS (SIN PARÁMETROS)
        ChangeNotifierProvider<DashboardViewModel>(
          create: (context) => DashboardViewModel(),
        ),
        
        ChangeNotifierProvider<GestionViewModel>(
          create: (context) => GestionViewModel(),
        ),
        
        ChangeNotifierProvider<CarrerasViewModel>(
          create: (context) => CarrerasViewModel(), 
        ),
        
        ChangeNotifierProvider<ConfiguracionViewModel>(
          create: (context) => ConfiguracionViewModel(), 
        ),
        
        ChangeNotifierProvider<MateriaViewModel>(
          create: (context) => MateriaViewModel(), 
        ),
        
        ChangeNotifierProvider<ReporteViewModel>(
          create: (context) => ReporteViewModel(), 
        ),
        
        ChangeNotifierProvider<SoporteViewModel>(
          create: (context) => SoporteViewModel(), 
        ),
        
        ChangeNotifierProvider<ParalelosViewModel>(
          create: (context) => ParalelosViewModel(), 
        ),
        
        ChangeNotifierProvider<InicioViewModel>(
          create: (context) => InicioViewModel(), 
        ),
        
        // 🌟 VIEWMODELS CON DATABASEHELPER - TODOS REGISTRADOS
        ChangeNotifierProvider<DocentesViewModel>(
          create: (context) => DocentesViewModel(),
        ),
        
        ChangeNotifierProvider<PeriodoAcademicoViewModel>(
          create: (context) => PeriodoAcademicoViewModel(),
        ),
        
        ChangeNotifierProvider<HistorialAsistenciaViewModel>(
          create: (context) => HistorialAsistenciaViewModel(),
        ),
        
        ChangeNotifierProvider<PrimerBimestreViewModel>(
          create: (context) => PrimerBimestreViewModel(),
        ),
        
        ChangeNotifierProvider<RegistrarAsistenciaViewModel>(
          create: (context) => RegistrarAsistenciaViewModel(),
        ),
        
        ChangeNotifierProvider<TurnosViewModel>(
          create: (context) => TurnosViewModel(),
        ),
        
        ChangeNotifierProvider<NivelViewModel>(
          create: (context) => NivelViewModel(),
        ),
        
        ChangeNotifierProvider<EstudiantesViewModel>(
          create: (context) => EstudiantesViewModel(),
        ),

        // 🌟 AÑADIR ASISTENCIA VIEWMODEL
        ChangeNotifierProvider<AsistenciaViewModel>(
          create: (context) => AsistenciaViewModel(),
        ),
      ],
      child: Consumer2<ThemeService, AuthViewModel>(
        builder: (context, themeService, authViewModel, child) {
          return FutureBuilder(
            future: authViewModel.initializeSession(),
            builder: (context, snapshot) {
              // Mientras se inicializa la sesión, mostrar pantalla de carga
              if (snapshot.connectionState == ConnectionState.waiting) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: _buildInitialLoadingScreen(),
                );
              }
              
              // Cuando ya se completó la inicialización de sesión
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'INCOS Check - Sistema de Asistencia',
                theme: _buildLightTheme(),
                darkTheme: _buildDarkTheme(),
                themeMode: themeService.themeMode,
                home: const AuthWrapper(),
                // 🌟 RUTAS PARA NAVEGACIÓN (OPCIONAL)
                routes: {
                  '/dashboard': (context) => const DashboardScreen(),
                  '/login': (context) => const LoginScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInitialLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Inicializando aplicación...',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🌟 TEMA CLARO
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.background,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.black87,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF323232),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  // 🌟 TEMA OSCURO
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF90CAF9),
        secondary: Color(0xFF64B5F6),
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onPrimary: Colors.black87,
        onSecondary: Colors.black87,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: Color(0xFF90CAF9),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        color: AppColors.darkSurface,
        surfaceTintColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF90CAF9),
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF90CAF9),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF90CAF9),
          side: const BorderSide(color: Color(0xFF90CAF9)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF90CAF9),
        foregroundColor: Colors.black87,
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF90CAF9),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF424242),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white70),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white70),
        labelLarge: TextStyle(color: Colors.white),
        labelMedium: TextStyle(color: Colors.white),
        labelSmall: TextStyle(color: Colors.white70),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Esperar un poco para asegurar que todos los providers estén listos
    await Future.delayed(const Duration(milliseconds: 100));
    
    setState(() {
      _initializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    if (_initializing) {
      return _buildLoadingScreen();
    }

    // El AuthViewModel ya verificó la sesión automáticamente gracias al FutureBuilder
    if (authViewModel.isLoggedIn) {
      return _buildDashboard(authViewModel);
    }

    return const LoginScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            const Text(
              'Cargando aplicación...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(AuthViewModel authViewModel) {
    final userData = {
      'id': authViewModel.currentUser!.id,
      'username': authViewModel.currentUser!.username,
      'email': authViewModel.currentUser!.email,
      'nombre': authViewModel.currentUser!.nombre,
      'password': authViewModel.currentUser!.password,
      'role': authViewModel.currentUser!.role,
      'carnet': authViewModel.currentUser!.carnet,
      'departamento': authViewModel.currentUser!.departamento,
      'esta_activo': authViewModel.currentUser!.estaActivo,
      'fecha_registro': authViewModel.currentUser!.fechaRegistro.toIso8601String(),
    };
    
    return ChangeNotifierProvider(
      create: (context) => DashboardViewModel(userData: userData),
      child: DashboardScreen(userData: userData),
    );
  }
}