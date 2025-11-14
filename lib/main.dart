// main.dart
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

// Views
import 'views/dashboard/dashboard_screen.dart';
import 'views/dashboard/login_screen.dart';

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
        
        // 🌟 AUTH VIEWMODEL - DEBE ESTAR PRIMERO
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
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'INCOS Check - Sistema de Asistencia',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeService.themeMode,
            home: AuthWrapper(authViewModel: authViewModel),
            // 🌟 RUTAS PARA NAVEGACIÓN (OPCIONAL)
            routes: {
              '/dashboard': (context) => const DashboardScreen(),
              '/login': (context) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }

  // ... (los métodos _buildLightTheme y _buildDarkTheme se mantienen igual)
  // 🌟 TEMA CLARO
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1565C0),
        secondary: Color(0xFF42A5F5),
        background: Color(0xFFF5F5F5),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.black87,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1565C0),
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
        selectedItemColor: Color(0xFF1565C0),
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
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
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
          backgroundColor: const Color(0xFF1565C0),
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
          foregroundColor: const Color(0xFF1565C0),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1565C0),
          side: const BorderSide(color: Color(0xFF1565C0)),
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
        backgroundColor: Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF1565C0),
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
        background: Color(0xFF121212),
        surface: Color(0xFF1E1E1E),
        onPrimary: Colors.black87,
        onSecondary: Colors.black87,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
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
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Color(0xFF90CAF9),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        color: Color(0xFF1E1E1E),
        surfaceTintColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
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
  final AuthViewModel authViewModel;

  const AuthWrapper({super.key, required this.authViewModel});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await widget.authViewModel.verificarSesionGuardada();
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verificando sesión...'),
            ],
          ),
        ),
      );
    }

    // Si ya está logueado, ir al dashboard
    if (widget.authViewModel.isLoggedIn && widget.authViewModel.currentUser != null) {
      final userData = {
        'id': widget.authViewModel.currentUser!.id,
        'username': widget.authViewModel.currentUser!.username,
        'email': widget.authViewModel.currentUser!.email,
        'nombre': widget.authViewModel.currentUser!.nombre,
        'password': widget.authViewModel.currentUser!.password,
        'role': widget.authViewModel.currentUser!.role,
        'carnet': widget.authViewModel.currentUser!.carnet,
        'departamento': widget.authViewModel.currentUser!.departamento,
        'esta_activo': widget.authViewModel.currentUser!.estaActivo,
        'fecha_registro': widget.authViewModel.currentUser!.fechaRegistro.toIso8601String(),
      };
      
      return ChangeNotifierProvider(
        create: (context) => DashboardViewModel(userData: userData),
        child: DashboardScreen(userData: userData),
      );
    }
    
    // Si no está logueado, mostrar login
    return const LoginScreen();
  }
}