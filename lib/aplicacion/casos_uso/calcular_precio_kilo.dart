import 'package:sistema_gestion/dominio/entidades/calculo_kilo.dart';

class CalcularPrecioKilo {
  CalculoKilo ejecutar({
    required double costoTotal,
    required double pesoKilos,
    required double porcentajeMargen,
  }) {
    final costoPorKilo = costoTotal / pesoKilos;
    final precioVentaSugeridoKilo = costoPorKilo * (1 + (porcentajeMargen / 100));
    final gananciaKilo = precioVentaSugeridoKilo - costoPorKilo;

    return CalculoKilo(
      costoTotal: costoTotal,
      pesoKilos: pesoKilos,
      porcentajeMargen: porcentajeMargen,
      costoPorKilo: costoPorKilo,
      precioVentaSugeridoKilo: precioVentaSugeridoKilo,
      gananciaKilo: gananciaKilo,
    );
  }
}