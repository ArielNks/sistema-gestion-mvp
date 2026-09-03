import 'package:sistema_gestion/dominio/entidades/transaccion.dart';
import 'package:sistema_gestion/dominio/puertos/repositorio_transaccion.dart';

class ConsultarArqueoDiario {
  ConsultarArqueoDiario(this._repositorio);

  final RepositorioTransaccion _repositorio;

  Future<List<Transaccion>> ejecutar(DateTime fecha) {
    return _repositorio.obtenerTransaccionesPorFecha(fecha);
  }
}