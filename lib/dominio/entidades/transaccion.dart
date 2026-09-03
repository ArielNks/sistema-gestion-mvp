import 'package:sistema_gestion/dominio/entidades/enumerados/medio_pago.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/tipo_movimiento.dart';

class Transaccion {
  const Transaccion({
    this.id,
    required this.monto,
    required this.medioPago,
    required this.tipoMovimiento,
    this.descripcion,
    required this.fechaHora,
  });

  final int? id;
  final double monto;
  final MedioPago medioPago;
  final TipoMovimiento tipoMovimiento;
  final String? descripcion;
  final DateTime fechaHora;

  Transaccion copyWith({
    int? id,
    double? monto,
    MedioPago? medioPago,
    TipoMovimiento? tipoMovimiento,
    String? descripcion,
    DateTime? fechaHora,
  }) {
    return Transaccion(
      id: id ?? this.id,
      monto: monto ?? this.monto,
      medioPago: medioPago ?? this.medioPago,
      tipoMovimiento: tipoMovimiento ?? this.tipoMovimiento,
      descripcion: descripcion ?? this.descripcion,
      fechaHora: fechaHora ?? this.fechaHora,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaccion &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          monto == other.monto &&
          medioPago == other.medioPago &&
          tipoMovimiento == other.tipoMovimiento &&
          descripcion == other.descripcion &&
          fechaHora == other.fechaHora;

  @override
  int get hashCode =>
      id.hashCode ^
      monto.hashCode ^
      medioPago.hashCode ^
      tipoMovimiento.hashCode ^
      descripcion.hashCode ^
      fechaHora.hashCode;

  @override
  String toString() =>
      'Transaccion(id: $id, monto: $monto, medioPago: $medioPago, tipoMovimiento: $tipoMovimiento, descripcion: $descripcion, fechaHora: $fechaHora)';
}