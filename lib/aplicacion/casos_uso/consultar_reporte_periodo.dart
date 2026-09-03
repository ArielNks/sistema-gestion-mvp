import 'package:sistema_gestion/dominio/entidades/resumen_financiero.dart';
import 'package:sistema_gestion/dominio/puertos/repositorio_transaccion.dart';

class ConsultarReportePeriodo {
  ConsultarReportePeriodo(this._repositorio);

  final RepositorioTransaccion _repositorio;

  Future<ResumenFinanciero> ejecutar({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) {
    return _repositorio.obtenerResumenPorPeriodo(fechaInicio, fechaFin);
  }
}