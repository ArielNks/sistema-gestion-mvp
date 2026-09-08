import 'package:sistema_gestion/dominio/entidades/transaccion.dart';

class ResumenFinanciero {
  const ResumenFinanciero({
    required this.fechaInicio,
    required this.fechaFin,
    required this.totalIngresos,
    required this.totalEgresos,
    required this.balanceNeto,
    required this.totalEfectivo,
    required this.totalTransferencia,
    required this.ingresosEfectivo,
    required this.ingresosTransferencia,
    required this.egresosEfectivo,
    required this.egresosTransferencia,
    required this.transacciones,
  });

  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double totalIngresos;
  final double totalEgresos;
  final double balanceNeto;
  final double totalEfectivo;
  final double totalTransferencia;
  final double ingresosEfectivo;
  final double ingresosTransferencia;
  final double egresosEfectivo;
  final double egresosTransferencia;
  final List<Transaccion> transacciones;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumenFinanciero &&
          runtimeType == other.runtimeType &&
          fechaInicio == other.fechaInicio &&
          fechaFin == other.fechaFin &&
          totalIngresos == other.totalIngresos &&
          totalEgresos == other.totalEgresos &&
          balanceNeto == other.balanceNeto &&
          totalEfectivo == other.totalEfectivo &&
          totalTransferencia == other.totalTransferencia &&
          ingresosEfectivo == other.ingresosEfectivo &&
          ingresosTransferencia == other.ingresosTransferencia &&
          egresosEfectivo == other.egresosEfectivo &&
          egresosTransferencia == other.egresosTransferencia &&
          transacciones == other.transacciones;

  @override
  int get hashCode =>
      fechaInicio.hashCode ^
      fechaFin.hashCode ^
      totalIngresos.hashCode ^
      totalEgresos.hashCode ^
      balanceNeto.hashCode ^
      totalEfectivo.hashCode ^
      totalTransferencia.hashCode ^
      ingresosEfectivo.hashCode ^
      ingresosTransferencia.hashCode ^
      egresosEfectivo.hashCode ^
      egresosTransferencia.hashCode ^
      transacciones.hashCode;

  @override
  String toString() =>
      'ResumenFinanciero(fechaInicio: $fechaInicio, fechaFin: $fechaFin, totalIngresos: $totalIngresos, totalEgresos: $totalEgresos, balanceNeto: $balanceNeto, totalEfectivo: $totalEfectivo, totalTransferencia: $totalTransferencia, ingresosEfectivo: $ingresosEfectivo, ingresosTransferencia: $ingresosTransferencia, egresosEfectivo: $egresosEfectivo, egresosTransferencia: $egresosTransferencia, transacciones: $transacciones)';
}