import 'package:flutter/material.dart';
import 'package:sistema_gestion/infraestructura/entrada/ui/vistas/vista_arqueo_diario.dart';
import 'package:sistema_gestion/infraestructura/entrada/ui/vistas/vista_calculadora.dart';
import 'package:sistema_gestion/infraestructura/entrada/ui/vistas/vista_caja.dart';
import 'package:sistema_gestion/infraestructura/entrada/ui/vistas/vista_reportes.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceSeleccionado = 0;

  static const List<NavigationRailDestination> _destinos = [
    NavigationRailDestination(
      icon: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Icon(Icons.calculate_outlined),
      ),
      selectedIcon: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Icon(Icons.calculate),
      ),
      label: Text(
        'Calculadora',
        style: TextStyle(fontSize: 12, height: 1.1),
      ),
    ),
    NavigationRailDestination(
      icon: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Icon(Icons.point_of_sale_outlined),
      ),
      selectedIcon: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Icon(Icons.point_of_sale),
      ),
      label: Text(
        'Caja',
        style: TextStyle(fontSize: 12, height: 1.1),
      ),
    ),
    NavigationRailDestination(
      icon: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Icon(Icons.receipt_long_outlined),
      ),
      selectedIcon: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Icon(Icons.receipt_long),
      ),
      label: Text(
        'Arqueo Diario',
        style: TextStyle(fontSize: 12, height: 1.1),
      ),
    ),
    NavigationRailDestination(
      icon: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Icon(Icons.analytics_outlined),
      ),
      selectedIcon: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Icon(Icons.analytics),
      ),
      label: Text(
        'Reportes',
        style: TextStyle(fontSize: 12, height: 1.1),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _indiceSeleccionado,
            onDestinationSelected: (int indice) {
              setState(() {
                _indiceSeleccionado = indice;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: _destinos,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: switch (_indiceSeleccionado) {
              0 => const VistaCalculadora(),
              1 => const VistaCaja(),
              2 => const VistaArqueoDiario(),
              3 => const VistaReportes(),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
  }
}