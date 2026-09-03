import 'package:flutter/material.dart';

void main() {
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