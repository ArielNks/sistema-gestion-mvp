import 'package:sistema_gestion/dominio/entidades/transaccion.dart';
import 'package:sistema_gestion/dominio/puertos/repositorio_transaccion.dart';

class RegistrarEgreso {
  RegistrarEgreso(this._repositorio);

  final RepositorioTransaccion _repositorio;

  Future<void> ejecutar(Transaccion transaccion) {
    return _repositorio.registrarEgreso(transaccion);
  }
}