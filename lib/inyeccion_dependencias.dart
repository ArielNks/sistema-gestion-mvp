import 'package:get_it/get_it.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/calcular_precio_kilo.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/calcular_precio_unidad.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/consultar_arqueo_diario.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/consultar_reporte_periodo.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/exportar_reporte_pdf.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/registrar_egreso.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/registrar_ingreso.dart';
import 'package:sistema_gestion/dominio/puertos/repositorio_configuracion.dart';
import 'package:sistema_gestion/dominio/puertos/repositorio_transaccion.dart';
import 'package:sistema_gestion/dominio/puertos/servicio_pdf.dart';
import 'package:sistema_gestion/infraestructura/salida/bd/conexion_sqlite.dart';
import 'package:sistema_gestion/infraestructura/salida/repositorios/repositorio_configuracion_preferences.dart';
import 'package:sistema_gestion/infraestructura/salida/repositorios/repositorio_transaccion_sqlite.dart';
import 'package:sistema_gestion/infraestructura/salida/servicios/servicio_pdf_impl.dart';

final GetIt getIt = GetIt.instance;

Future<void> inicializarDependencias() async {
  getIt.registerLazySingleton<ConexionSqlite>(() => ConexionSqlite.instancia);

  getIt.registerLazySingleton<RepositorioTransaccion>(
    () => RepositorioTransaccionSqlite(getIt<ConexionSqlite>()),
  );

  getIt.registerLazySingleton<RepositorioConfiguracion>(
    () => RepositorioConfiguracionPreferences(),
  );

  getIt.registerLazySingleton<ServicioPdf>(
    () => ServicioPdfImpl(),
  );

  getIt.registerFactory<CalcularPrecioUnidad>(
    () => CalcularPrecioUnidad(),
  );

  getIt.registerFactory<CalcularPrecioKilo>(
    () => CalcularPrecioKilo(),
  );

  getIt.registerFactory<RegistrarIngreso>(
    () => RegistrarIngreso(getIt<RepositorioTransaccion>()),
  );

  getIt.registerFactory<RegistrarEgreso>(
    () => RegistrarEgreso(getIt<RepositorioTransaccion>()),
  );

  getIt.registerFactory<ConsultarArqueoDiario>(
    () => ConsultarArqueoDiario(getIt<RepositorioTransaccion>()),
  );

  getIt.registerFactory<ConsultarReportePeriodo>(
    () => ConsultarReportePeriodo(getIt<RepositorioTransaccion>()),
  );

  getIt.registerFactory<ExportarReportePdf>(
    () => ExportarReportePdf(getIt<ServicioPdf>()),
  );
}