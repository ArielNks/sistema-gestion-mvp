import 'package:sistema_gestion/dominio/entidades/resumen_financiero.dart';
import 'package:sistema_gestion/dominio/entidades/transaccion.dart';

abstract class RepositorioTransaccion {
  Future<void> registrarIngreso(Transaccion transaccion);
  Future<void> registrarEgreso(Transaccion transaccion);
  Future<List<Transaccion>> obtenerTransaccionesPorFecha(DateTime fecha);
  Future<List<Transaccion>> obtenerUltimasTransacciones(int limite);
  Future<List<Transaccion>> obtenerTransaccionesPorPeriodo(DateTime fechaInicio, DateTime fechaFin);
  Future<ResumenFinanciero> obtenerResumenPorPeriodo(DateTime fechaInicio, DateTime fechaFin);
}