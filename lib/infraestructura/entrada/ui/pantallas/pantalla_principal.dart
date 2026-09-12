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
      icon: Icon(Icons.calculate_outlined),
      selectedIcon: Icon(Icons.calculate),
      label: Text('Calculadora'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.point_of_sale_outlined),
      selectedIcon: Icon(Icons.point_of_sale),
      label: Text('Caja'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: Text('Arqueo Diario'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: Text('Reportes'),
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