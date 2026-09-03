abstract class ExcepcionDominio implements Exception {
  const ExcepcionDominio();
}

class ExcepcionPersistencia extends ExcepcionDominio {
  const ExcepcionPersistencia(this.mensaje);

  final String mensaje;

  @override
  String toString() => 'ExcepcionPersistencia: $mensaje';
}

class ExcepcionDatosNoEncontrados extends ExcepcionDominio {
  const ExcepcionDatosNoEncontrados(this.mensaje);

  final String mensaje;

  @override
  String toString() => 'ExcepcionDatosNoEncontrados: $mensaje';
}