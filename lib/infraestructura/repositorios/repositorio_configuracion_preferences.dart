import 'package:sistema_gestion/dominio/entidades/configuracion.dart';
import 'package:sistema_gestion/dominio/entidades/excepciones/excepciones_dominio.dart';
import 'package:sistema_gestion/dominio/puertos/repositorio_configuracion.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RepositorioConfiguracionPreferences implements RepositorioConfiguracion {
  static const String _claveMargen = 'margen_ganancia_defecto';
  static const String _claveModoOscuro = 'modo_oscuro';

  @override
  Future<void> guardarConfiguracion(Configuracion configuracion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_claveMargen, configuracion.margenGananciaDefecto);
      await prefs.setBool(_claveModoOscuro, configuracion.modoOscuro);
    } catch (e) {
      throw ExcepcionPersistencia('Error al guardar configuración: $e');
    }
  }

  @override
  Future<Configuracion> obtenerConfiguracion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final margen = prefs.getDouble(_claveMargen) ?? 30.0;
      final modoOscuro = prefs.getBool(_claveModoOscuro) ?? false;
      return Configuracion(
        margenGananciaDefecto: margen,
        modoOscuro: modoOscuro,
      );
    } catch (e) {
      throw ExcepcionPersistencia('Error al obtener configuración: $e');
    }
  }
}