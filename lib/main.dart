import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sistema_gestion/inyeccion_dependencias.dart';
import 'package:sistema_gestion/infraestructura/entrada/ui/pantallas/pantalla_principal.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await inicializarDependencias();

  runApp(const Aplicacion());
}

class Aplicacion extends StatelessWidget {
  const Aplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Gestión',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey.shade100,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green.shade700,
          brightness: Brightness.light,
          primary: Colors.green.shade700,
          secondary: Colors.blue.shade700,
          error: Colors.red.shade600,
          surface: Colors.white,
          onSurface: Colors.black87,
          onSurfaceVariant: Colors.grey.shade700,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 28,
          ),
          headlineSmall: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 22,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 20,
          ),
          bodyLarge: TextStyle(
            color: Colors.black87,
            fontSize: 17,
          ),
          bodyMedium: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 15,
          ),
          bodySmall: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 16),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 17),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.green.shade700, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green.shade700,
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            side: BorderSide(color: Colors.green.shade700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: Colors.white,
          selectedIconTheme: IconThemeData(color: Colors.green.shade700, size: 24),
          unselectedIconTheme: IconThemeData(color: Colors.grey.shade600, size: 24),
          selectedLabelTextStyle: TextStyle(
            color: Colors.green.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
          indicatorColor: Colors.green.shade50,
        ),
      ),
      home: const PantallaPrincipal(),
    );
  }
}