import 'package:sistema_gestion/dominio/entidades/configuracion.dart';

abstract class RepositorioConfiguracion {
  Future<void> guardarConfiguracion(Configuracion configuracion);
  Future<Configuracion> obtenerConfiguracion();
}