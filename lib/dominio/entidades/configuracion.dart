class Configuracion {
  const Configuracion({
    required this.margenGananciaDefecto,
    required this.modoOscuro,
  });

  final double margenGananciaDefecto;
  final bool modoOscuro;

  Configuracion copyWith({
    double? margenGananciaDefecto,
    bool? modoOscuro,
  }) {
    return Configuracion(
      margenGananciaDefecto: margenGananciaDefecto ?? this.margenGananciaDefecto,
      modoOscuro: modoOscuro ?? this.modoOscuro,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Configuracion &&
          runtimeType == other.runtimeType &&
          margenGananciaDefecto == other.margenGananciaDefecto &&
          modoOscuro == other.modoOscuro;

  @override
  int get hashCode =>
      margenGananciaDefecto.hashCode ^ modoOscuro.hashCode;

  @override
  String toString() =>
      'Configuracion(margenGananciaDefecto: $margenGananciaDefecto, modoOscuro: $modoOscuro)';
}