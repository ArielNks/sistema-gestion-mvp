class CalculoUnidad {
  const CalculoUnidad({
    required this.costoTotal,
    required this.porcentajeMargen,
    required this.precioVentaSugerido,
    required this.gananciaUnitaria,
  });

  final double costoTotal;
  final double porcentajeMargen;
  final double precioVentaSugerido;
  final double gananciaUnitaria;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalculoUnidad &&
          runtimeType == other.runtimeType &&
          costoTotal == other.costoTotal &&
          porcentajeMargen == other.porcentajeMargen &&
          precioVentaSugerido == other.precioVentaSugerido &&
          gananciaUnitaria == other.gananciaUnitaria;

  @override
  int get hashCode =>
      costoTotal.hashCode ^
      porcentajeMargen.hashCode ^
      precioVentaSugerido.hashCode ^
      gananciaUnitaria.hashCode;

  @override
  String toString() =>
      'CalculoUnidad(costoTotal: $costoTotal, porcentajeMargen: $porcentajeMargen, precioVentaSugerido: $precioVentaSugerido, gananciaUnitaria: $gananciaUnitaria)';
}