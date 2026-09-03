import 'package:sistema_gestion/dominio/entidades/calculo_unidad.dart';

class CalcularPrecioUnidad {
  CalculoUnidad ejecutar({
    required double costoTotal,
    required double porcentajeMargen,
  }) {
    final precioVentaSugerido = costoTotal * (1 + (porcentajeMargen / 100));
    final gananciaUnitaria = precioVentaSugerido - costoTotal;

    return CalculoUnidad(
      costoTotal: costoTotal,
      porcentajeMargen: porcentajeMargen,
      precioVentaSugerido: precioVentaSugerido,
      gananciaUnitaria: gananciaUnitaria,
    );
  }
}