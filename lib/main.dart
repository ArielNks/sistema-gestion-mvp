import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sistema_gestion/inyeccion_dependencias.dart';

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
      home: Scaffold(
        appBar: AppBar(title: const Text('Sistema de Gestión')),
        body: const Center(child: Text('Inicializando...')),
      ),
    );
  }
}