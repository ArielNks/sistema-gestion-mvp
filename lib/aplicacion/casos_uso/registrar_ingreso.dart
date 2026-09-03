import 'package:sistema_gestion/dominio/entidades/transaccion.dart';
import 'package:sistema_gestion/dominio/puertos/repositorio_transaccion.dart';

class RegistrarIngreso {
  RegistrarIngreso(this._repositorio);

  final RepositorioTransaccion _repositorio;

  Future<void> ejecutar(Transaccion transaccion) {
    return _repositorio.registrarIngreso(transaccion);
  }
}