class CalculoKilo {
  const CalculoKilo({
    required this.costoTotal,
    required this.pesoKilos,
    required this.porcentajeMargen,
    required this.costoPorKilo,
    required this.precioVentaSugeridoKilo,
    required this.gananciaKilo,
  });

  final double costoTotal;
  final double pesoKilos;
  final double porcentajeMargen;
  final double costoPorKilo;
  final double precioVentaSugeridoKilo;
  final double gananciaKilo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalculoKilo &&
          runtimeType == other.runtimeType &&
          costoTotal == other.costoTotal &&
          pesoKilos == other.pesoKilos &&
          porcentajeMargen == other.porcentajeMargen &&
          costoPorKilo == other.costoPorKilo &&
          precioVentaSugeridoKilo == other.precioVentaSugeridoKilo &&
          gananciaKilo == other.gananciaKilo;

  @override
  int get hashCode =>
      costoTotal.hashCode ^
      pesoKilos.hashCode ^
      porcentajeMargen.hashCode ^
      costoPorKilo.hashCode ^
      precioVentaSugeridoKilo.hashCode ^
      gananciaKilo.hashCode;

  @override
  String toString() =>
      'CalculoKilo(costoTotal: $costoTotal, pesoKilos: $pesoKilos, porcentajeMargen: $porcentajeMargen, costoPorKilo: $costoPorKilo, precioVentaSugeridoKilo: $precioVentaSugeridoKilo, gananciaKilo: $gananciaKilo)';
}