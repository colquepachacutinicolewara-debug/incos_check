import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// *[NUEVOS IMPORTS DE FIREBASE]*
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ViewModels
import 'viewmodels/dashboard_viewmodel.dart';
// Services
import 'services/theme_service.dart';

// Views
import 'views/dashboard/dashboard_screen.dart';

void main() async {
  // 1. Asegura que los widgets de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // 2. *[INICIALIZACIÓN DE FIREBASE]*
  // Conecta la app con el proyecto de Firebase usando las opciones específicas de la plataforma
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // ------------------------------------

  // Inicializa localización española para intl

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(
          create: (_) => ThemeService()..loadThemePreference(),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Incos App',
            theme: ThemeData(
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
              // Tema claro personalizado
              colorScheme: ColorScheme.light(
                primary: Colors.blueAccent,
                secondary: Colors.blueAccent,
                surface: Colors.grey[100]!,
                onSurface: Colors.black87, // Texto sobre fondo claro
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
                bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
                bodySmall: TextStyle(color: Colors.black54, fontSize: 12),
                titleLarge: TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                titleMedium: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                titleSmall: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: const Color(
                0xFF121212,
              ), // Gris oscuro equivalente
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
                backgroundColor: Color(0xFF121212), // Gris oscuro equivalente
              ),
              // Tema oscuro personalizado - TEXTOS MEJORADOS
              colorScheme: const ColorScheme.dark(
                primary: Colors.blueAccent,
                secondary: Colors.blueAccent,
                surface: Color(0xFF1E1E1E), // Texto blanco sobre fondo oscuro
                onSurface: Colors.white, // Texto blanco sobre surfaces
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFF1E1E1E), // Gris para cards
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // TEXT THEME MEJORADO PARA TEMA OSCURO
              textTheme: const TextTheme(
                bodyLarge: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ), // Blanco
                bodyMedium: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ), // Blanco
                bodySmall: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ), // Blanco semi-transparente
                titleLarge: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ), // Blanco
                titleMedium: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ), // Blanco
                titleSmall: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ), // Blanco
                labelLarge: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ), // Para botones
                labelMedium: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ), // Para labels pequeños
                labelSmall: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ), // Para labels muy pequeños
              ),
              // ICON THEME para mejor contraste
              iconTheme: const IconThemeData(
                color: Colors.white, // Iconos blancos en tema oscuro
              ),
              // DIVIDER THEME para mejor visibilidad
              dividerTheme: const DividerThemeData(
                color: Color(0xFF333333), // Divisores más visibles
                thickness: 1,
                space: 1,
              ),
            ),
            themeMode:
                themeService.themeMode, // ← CLAVE: Aplica el tema seleccionado
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
