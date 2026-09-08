import 'package:sistema_gestion/dominio/entidades/enumerados/medio_pago.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/tipo_movimiento.dart';
import 'package:sistema_gestion/dominio/entidades/resumen_financiero.dart';
import 'package:sistema_gestion/dominio/puertos/repositorio_transaccion.dart';

class ConsultarArqueoDiario {
  ConsultarArqueoDiario(this._repositorio);

  final RepositorioTransaccion _repositorio;

  Future<ResumenFinanciero> ejecutar(DateTime fecha) async {
    final transacciones = await _repositorio.obtenerTransaccionesPorFecha(fecha);

    double ingresosEfectivo = 0;
    double ingresosTransferencia = 0;
    double egresosEfectivo = 0;
    double egresosTransferencia = 0;

    for (final t in transacciones) {
      if (t.tipoMovimiento == TipoMovimiento.ingreso) {
        if (t.medioPago == MedioPago.efectivo) {
          ingresosEfectivo += t.monto;
        } else {
          ingresosTransferencia += t.monto;
        }
      } else {
        if (t.medioPago == MedioPago.efectivo) {
          egresosEfectivo += t.monto;
        } else {
          egresosTransferencia += t.monto;
        }
      }
    }

    final totalIngresos = ingresosEfectivo + ingresosTransferencia;
    final totalEgresos = egresosEfectivo + egresosTransferencia;
    final balanceNeto = totalIngresos - totalEgresos;
    final totalEfectivo = ingresosEfectivo - egresosEfectivo;
    final totalTransferencia = ingresosTransferencia - egresosTransferencia;

    return ResumenFinanciero(
      fechaInicio: DateTime(fecha.year, fecha.month, fecha.day),
      fechaFin: DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59),
      totalIngresos: totalIngresos,
      totalEgresos: totalEgresos,
      balanceNeto: balanceNeto,
      totalEfectivo: totalEfectivo,
      totalTransferencia: totalTransferencia,
      ingresosEfectivo: ingresosEfectivo,
      ingresosTransferencia: ingresosTransferencia,
      egresosEfectivo: egresosEfectivo,
      egresosTransferencia: egresosTransferencia,
      transacciones: transacciones,
    );
  }
}