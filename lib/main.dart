// main.dart - ACTUALIZADO
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Repository
import 'repositories/data_repository.dart';

// Services
import 'services/auth_service.dart';
import 'services/theme_service.dart';

// ViewModels
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart' as dashboard_vm;
import 'viewmodels/carreras_viewmodel.dart';
import 'viewmodels/configuracion_viewmodel.dart';
import 'viewmodels/estudiantes_viewmodel.dart';
import 'viewmodels/paralelos_viewmodel.dart';
import 'viewmodels/docente_viewmodel.dart';
import 'viewmodels/materia_viewmodel.dart';

// Views
import 'views/dashboard/dashboard_screen.dart';
import 'views/dashboard/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('⚠ Error al inicializar Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DataRepository>(create: (_) => DataRepository()),
        
        // Theme
        ChangeNotifierProvider<ThemeService>(
          create: (_) => ThemeService()..loadThemePreference(),
        ),
        
        // Auth
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            Provider.of<AuthService>(context, listen: false),
          )..initialize(),
        ),

        // Other ViewModels
        ChangeNotifierProvider<dashboard_vm.DashboardViewModel>(
          create: (context) => dashboard_vm.DashboardViewModel(
            Provider.of<DataRepository>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<CarrerasViewModel>(
          create: (context) => CarrerasViewModel(
            Provider.of<DataRepository>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<ConfiguracionViewModel>(
          create: (context) => ConfiguracionViewModel(
            Provider.of<DataRepository>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<ParalelosViewModel>(
          create: (context) => ParalelosViewModel(
            Provider.of<DataRepository>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<EstudiantesViewModel>(
          create: (context) => EstudiantesViewModel(
            tipo: '',
            carrera: {},
            turno: {},
            nivel: {},
            paralelo: {},
            repository: Provider.of<DataRepository>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<DocentesViewModel>(
          create: (context) => DocentesViewModel(
            Provider.of<DataRepository>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<MateriaViewModel>(
          create: (context) => MateriaViewModel(
            Provider.of<DataRepository>(context, listen: false),
          ),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Incos App',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeService.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() => ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blueAccent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );

  ThemeData _buildDarkTheme() => ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blueAccent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFF121212),
    ),
  );
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    if (authViewModel.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authViewModel.isAuthenticated) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}